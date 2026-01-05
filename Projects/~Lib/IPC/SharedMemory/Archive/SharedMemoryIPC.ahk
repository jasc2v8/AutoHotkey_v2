#Requires AutoHotkey v2.0

; ============================================================
;  UTF‑16 Helpers
; ============================================================

WriteUTF16(pView, text, maxBytes) {
    bin := Buffer(StrPut(text, "UTF-16"))
    StrPut(text, bin, "UTF-16")
    len := Min(bin.Size, maxBytes)
    DllCall("RtlMoveMemory", "ptr", pView, "ptr", bin.Ptr, "uptr", len)
}

ReadUTF16(pView, maxBytes) {
    buf := Buffer(maxBytes, 0)
    DllCall("RtlMoveMemory", "ptr", buf.Ptr, "ptr", pView, "uptr", maxBytes)
    return StrGet(buf, "UTF-16")
}

; ============================================================
;  Security Descriptor → SECURITY_ATTRIBUTES
; ============================================================

CreateSecurityAttributesFromSDDL(sddl) {
    local pSD := 0, cbSD := 0

    if !DllCall("advapi32\ConvertStringSecurityDescriptorToSecurityDescriptorW"
        , "str", sddl
        , "uint", 1
        , "ptr*", pSD
        , "uint*", cbSD
        , "int")
    {
        throw Error("ConvertStringSecurityDescriptorToSecurityDescriptorW failed: " A_LastError)
    }

    saSize := 8 + A_PtrSize
    pSA := Buffer(saSize, 0)

    NumPut("uint", saSize, pSA, 0)
    NumPut("ptr",  pSD,   pSA, 4)
    NumPut("int",  0,     pSA, 4 + A_PtrSize)

    return { bufSA: pSA, pSD: pSD }
}

FreeSecurityDescriptor(pSD) {
    if pSD
        DllCall("LocalFree", "ptr", pSD)
}

; ============================================================
;  File Mapping + View
; ============================================================

CreateFileMappingGlobal(name, size, saObj) {
    return DllCall("kernel32\CreateFileMappingW"
        , "ptr", -1
        , "ptr", saObj ? saObj.bufSA.Ptr : 0
        , "uint", 0x04
        , "uint", 0
        , "uint", size
        , "str", name
        , "ptr")
}

OpenFileMappingGlobal(name) {
    return DllCall("kernel32\OpenFileMappingW"
        , "uint", 0x0002 | 0x0004
        , "int",  false
        , "str",  name
        , "ptr")
}

MapView(hMap) {
    return DllCall("kernel32\MapViewOfFile"
        , "ptr", hMap
        , "uint", 0x0002 | 0x0004
        , "uint", 0
        , "uint", 0
        , "uptr", 0
        , "ptr")
}

UnmapView(p) {
    if p
        DllCall("kernel32\UnmapViewOfFile", "ptr", p)
}

CloseHandle(h) {
    if h
        DllCall("kernel32\CloseHandle", "ptr", h)
}

; ============================================================
;  Named Events
; ============================================================

CreateEventGlobal(name, saObj) {
    return DllCall("kernel32\CreateEventW"
        , "ptr", saObj ? saObj.bufSA.Ptr : 0
        , "int", false
        , "int", false
        , "str", name
        , "ptr")
}

OpenEventGlobal(name) {
    return DllCall("kernel32\OpenEventW"
        , "uint", 0x1F0003
        , "int",  false
        , "str",  name
        , "ptr")
}

SetEvent(h) {
    DllCall("kernel32\SetEvent", "ptr", h)
}

WaitEvent(h, timeout := 0xFFFFFFFF) {
    return DllCall("kernel32\WaitForSingleObject"
        , "ptr", h
        , "uint", timeout)
}

; ============================================================
;  IPC ENGINE CLASS
; ============================================================

class SharedMemoryIPC {

    __New(name, size, role, sddl := "") {
        this.Name := name
        this.Size := size
        this.Role := role

        baseC2S := "Global\" name "_C2S"
        baseS2C := "Global\" name "_S2C"
        evtC2S  := "Global\" name "_C2S_Ready"
        evtS2C  := "Global\" name "_S2C_Ready"

        if (role = "server") {

            if !sddl
                sddl := "D:(A;;GRGW;;;WD)S:(ML;;NW;;;LW)"

            this._saObj := CreateSecurityAttributesFromSDDL(sddl)
            this._pSD   := this._saObj.pSD

            this.hMap_C2S := CreateFileMappingGlobal(baseC2S, size, this._saObj)
            this.hMap_S2C := CreateFileMappingGlobal(baseS2C, size, this._saObj)

            this.pC2S := MapView(this.hMap_C2S)
            this.pS2C := MapView(this.hMap_S2C)

            this.hEvt_C2S := CreateEventGlobal(evtC2S, this._saObj)
            this.hEvt_S2C := CreateEventGlobal(evtS2C, this._saObj)

        } else if (role = "client") {

            this.hMap_C2S := OpenFileMappingGlobal(baseC2S)
            this.hMap_S2C := OpenFileMappingGlobal(baseS2C)

            this.pC2S := MapView(this.hMap_C2S)
            this.pS2C := MapView(this.hMap_S2C)

            this.hEvt_C2S := OpenEventGlobal(evtC2S)
            this.hEvt_S2C := OpenEventGlobal(evtS2C)

        } else {
            throw Error("Role must be 'server' or 'client'")
        }
    }

    ; ========================================================
    ;  CLIENT API
    ; ========================================================

    SendRequest(text) {
        WriteUTF16(this.pC2S, text, this.Size)
        SetEvent(this.hEvt_C2S)
        WaitEvent(this.hEvt_S2C)
        return ReadUTF16(this.pS2C, this.Size)
    }

    ; ========================================================
    ;  SERVER API
    ; ========================================================

    WaitForRequest() {
        WaitEvent(this.hEvt_C2S)
        return ReadUTF16(this.pC2S, this.Size)
    }

    SendReply(text) {
        WriteUTF16(this.pS2C, text, this.Size)
        SetEvent(this.hEvt_S2C)
    }

    ; ========================================================
    ;  Cleanup
    ; ========================================================

    __Delete() {
        UnmapView(this.pC2S)
        UnmapView(this.pS2C)

        CloseHandle(this.hMap_C2S)
        CloseHandle(this.hMap_S2C)

        CloseHandle(this.hEvt_C2S)
        CloseHandle(this.hEvt_S2C)

        if this._pSD
            FreeSecurityDescriptor(this._pSD)
    }
}

; ============================================================
;  DEMO MODE
; ============================================================

; if A_Args.Length = 0 {
;     MsgBox "Run with argument: server OR client"
;     ExitApp
; }

; mode := A_Args[1]

mode := "Server"
ipc := SharedMemoryIPC("MyIpcDemo", 4096, mode)

if mode = "server" {
    Loop {
        req := ipc.WaitForRequest()
        reply := "Server received: " req
        ipc.SendReply(reply)
    }
}

if mode = "client" {
    MsgBox ipc.SendRequest("Hello from client")
}