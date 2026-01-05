#Requires AutoHotkey v2
#SingleInstance Force

class SharedMemory {
    ; ===== constants =====
    static PAGE_READWRITE := 0x04
    static FILE_MAP_ALL_ACCESS := 0xF001F
    static MUTEX_ALL_ACCESS := 0x1F0001
    static EVENT_ALL_ACCESS := 0x1F0003
    static WAIT_OBJECT_0 := 0
    static INFINITE := 0xFFFFFFFF

    ; SYSTEM + Administrators full, Users read/write/sync
    static SDDL := "D:(A;;GA;;;SY)(A;;GA;;;BA)(A;;GRGWGX;;;BU)"

    __New(name, size := 4096, isServer := false) {
        this.name := name
        this.size := size
        this.isServer := isServer
        prefix := "Global\" name

        ; ---------- SECURITY (server only) ----------
        if isServer
            sa := this._CreateSecurityAttributes()

        ; ---------- MUTEX ----------
        if isServer {
            this.hMutex := DllCall("CreateMutexW", "ptr", sa, "int", false, "str", prefix "_mtx", "ptr")
        } else {
            this.hMutex := this._OpenWithRetry("OpenMutexW", SharedMemory
        .MUTEX_ALL_ACCESS, prefix "_mtx")
        }
        if !this.hMutex
            throw Error("Mutex open/create failed")

        ; ---------- EVENTS ----------
        if isServer {
            this.hDataReady := DllCall("CreateEventW", "ptr", sa, "int", true, "int", false, "str", prefix "_data", "ptr")
            this.hAck       := DllCall("CreateEventW", "ptr", sa, "int", true, "int", true,  "str", prefix "_ack",  "ptr")
        } else {
            this.hDataReady := this._OpenWithRetry("OpenEventW", SharedMemory
        .EVENT_ALL_ACCESS, prefix "_data")
            this.hAck       := this._OpenWithRetry("OpenEventW", SharedMemory
        .EVENT_ALL_ACCESS, prefix "_ack")
        }
        if !(this.hDataReady && this.hAck)
            throw Error("Event open/create failed")

        ; ---------- FILE MAPPING ----------
        if isServer {
            this.hMap := DllCall("CreateFileMappingW", "ptr", -1, "ptr", sa, "uint", SharedMemory
        .PAGE_READWRITE, "uint", 0, "uint", size, "str", prefix, "ptr")
        } else {
            this.hMap := this._OpenWithRetry("OpenFileMappingW", SharedMemory
        .FILE_MAP_ALL_ACCESS, prefix)
        }
        if !this.hMap
            throw Error("File mapping open/create failed")

        this.pView := DllCall("MapViewOfFile", "ptr", this.hMap, "uint", SharedMemory
    .FILE_MAP_ALL_ACCESS, "uint", 0, "uint", 0, "uptr", size, "ptr")
        if !this.pView
            throw Error("MapViewOfFile failed")

        if isServer
            this.ClearView()
    }

    ; ===== CLIENT send =====
    Write(text, timeout := 5000) {
        if !this._Wait(this.hAck, timeout)
            throw Error("ACK timeout")

        this._Lock()
        try {
            bytes := StrPut(text, "UTF-16") * 2
            if bytes + 4 > this.size
                throw Error("Message too large")
            NumPut("uint", bytes, this.pView)
            StrPut(text, this.pView + 4, bytes // 2, "UTF-16")
        } finally this._Unlock()

        DllCall("ResetEvent", "ptr", this.hAck)
        DllCall("SetEvent", "ptr", this.hDataReady)
    }

    ; ===== SERVER receive =====
    Read(timeout := SharedMemory
    .INFINITE) {
        if !this._Wait(this.hDataReady, timeout)
            return ""

        this._Lock()
        try {
            bytes := NumGet(this.pView, "uint")
            msg := bytes ? StrGet(this.pView + 4, bytes // 2, "UTF-16") : ""
            NumPut("uint", 0, this.pView)
        } finally this._Unlock()

        DllCall("ResetEvent", "ptr", this.hDataReady)
        DllCall("SetEvent", "ptr", this.hAck)
        return msg
    }

    RunServer(callback) {
        while true
            callback.Call(this.Read())
    }

    ; ===== MEMORY =====
    ClearView() {
        this._Lock()
        try DllCall("RtlZeroMemory", "ptr", this.pView, "uptr", this.size)
        finally this._Unlock()
    }

    ; ===== INTERNALS =====
    _Wait(h, timeout) {
        return DllCall("WaitForSingleObject", "ptr", h, "uint", timeout) = SharedMemory
    .WAIT_OBJECT_0
    }

    _Lock() {
        if !this._Wait(this.hMutex, 5000)
            throw Error("Mutex timeout")
    }

    _Unlock() {
        DllCall("ReleaseMutex", "ptr", this.hMutex)
    }

    _CreateSecurityAttributes() {
        sa := Buffer(A_PtrSize * 3, 0)
        pSD := 0
        if !DllCall("Advapi32\ConvertStringSecurityDescriptorToSecurityDescriptorW", "str", SharedMemory
        .SDDL, "uint", 1, "ptr*", pSD, "ptr", 0)
            throw Error("SDDL conversion failed")
        NumPut("uint", sa.Size, sa, 0)
        NumPut("ptr", pSD, sa, A_PtrSize)
        NumPut("int", false, sa, A_PtrSize * 2)
        this._pSD := pSD
        return sa
    }

    _OpenWithRetry(funcName, access, name, attempts := 10, delay := 200) {
        h := 0
        Loop attempts {
            h := DllCall(funcName, "uint", access, "int", false, "str", name, "ptr")
            if h
                break
            Sleep delay
        }
        return h
    }

    Close() {
        if this.pView {
            DllCall("UnmapViewOfFile", "ptr", this.pView)
            this.pView := 0
        }

        for name in ["hMap","hMutex","hDataReady","hAck"] {
            h := this.%name%
            if h {
                DllCall("CloseHandle","ptr",h)
                this.%name% := 0
            }
        }

        if this._pSD {
            DllCall("LocalFree","ptr",this._pSD)
            this._pSD := 0
        }
    }

    __Delete() {
        try this.Close()
    }
}
