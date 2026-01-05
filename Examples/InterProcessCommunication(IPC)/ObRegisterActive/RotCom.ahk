#Requires AutoHotkey v2

; ============================================================
; COM environment helper
; ============================================================
class ComEnv {
    static _initCount := 0

    static Init() {
        if ComEnv._initCount > 0 {
            ComEnv._initCount += 1
            return
        }

        hr := DllCall("ole32\CoInitialize", "ptr", 0, "uint")
        if (hr != 0 && hr != 1)
            throw Error("CoInitialize failed: 0x" Format("{:08X}", hr))

        ComEnv._initCount := 1
        OnExit(ComEnv._OnExit.Bind())
    }

    static Uninit() {
        if (ComEnv._initCount <= 0)
            return
        ComEnv._initCount -= 1
        if ComEnv._initCount = 0
            DllCall("ole32\CoUninitialize")
    }

    static _OnExit(*) {
        while (ComEnv._initCount > 0) {
            ComEnv._initCount -= 1
            DllCall("ole32\CoUninitialize")
        }
    }
}

; ============================================================
; ROT server
; ============================================================
class RotServer {
    Name       := ""
    Object     := ""
    Cookie     := 0
    _pROT      := 0
    _keepAlive := ""

    __New(name, comObj) {
        this.Name       := name
        this.Object     := comObj
        this._keepAlive := comObj

        ComEnv.Init()

        this._pROT  := RotServer.GetRunningObjectTable()
        this.Cookie := this.RegisterInROT(name, comObj)

        OnExit(ObjBindMethod(this, "Revoke"))
    }

    __Delete() {
        this.Revoke()
        if this._pROT {
            ObjRelease(this._pROT)
            this._pROT := 0
        }
        this._keepAlive := ""
        this.Object     := ""
        ComEnv.Uninit()
    }

    Revoke() {
        if !this.Cookie || !this._pROT
            return
        RotServer.ROT_Revoke(this._pROT, this.Cookie)
        this.Cookie := 0
    }

    ; ---------- static helpers ----------

    static GetRunningObjectTable() {
        pROT := 0
        hr := DllCall("ole32\GetRunningObjectTable",
            "uint", 0,
            "ptr*", &pROT,   ; MUST use &
            "uint")
        if hr != 0
            throw Error("GetRunningObjectTable failed: 0x" Format("{:08X}", hr))
        return pROT
    }

    RegisterInROT(name, comObj) {
        pMoniker := 0
        hr := DllCall("ole32\CreateItemMoniker",
            "wstr", "!",
            "wstr", name,
            "ptr*", &pMoniker,   ; MUST use &
            "uint")
        if hr != 0
            throw Error("CreateItemMoniker failed: 0x" Format("{:08X}", hr))

        punk := ComObjValue(comObj)

        vtbl        := NumGet(this._pROT, 0, "ptr")
        pRegisterFn := NumGet(vtbl, 3 * A_PtrSize, "ptr")

        cookie := 0
        hr := DllCall(pRegisterFn,
            "ptr",  this._pROT,
            "uint", 0,
            "ptr",  punk,
            "ptr",  pMoniker,
            "uint*", &cookie,   ; MUST use &
            "uint")

        ObjRelease(pMoniker)

        if hr != 0
            throw Error("IRunningObjectTable::Register failed: 0x" Format("{:08X}", hr))

        return cookie
    }

    static ROT_Revoke(pROT, cookie) {
        if !cookie || !pROT
            return
        vtbl      := NumGet(pROT, 0, "ptr")
        pRevokeFn := NumGet(vtbl, 4 * A_PtrSize, "ptr")
        DllCall(pRevokeFn, "ptr", pROT, "uint", cookie, "uint")
    }
}

; ============================================================
; ROT client
; ============================================================
class RotClient {
    Name   := ""
    Object := ""

    __New(name) {
        this.Name := name
        ComEnv.Init()
        this.Object := this.GetFromROT(name)
    }

    __Delete() {
        this.Object := ""
        ComEnv.Uninit()
    }

    static GetRunningObjectTable() {
        pROT := 0
        hr := DllCall("ole32\GetRunningObjectTable",
            "uint", 0,
            "ptr*", &pROT,   ; MUST use &
            "uint")
        if hr != 0
            throw Error("GetRunningObjectTable failed: 0x" Format("{:08X}", hr))
        return pROT
    }

    GetFromROT(name) {
        pROT := RotClient.GetRunningObjectTable()

        pMoniker := 0
        hr := DllCall("ole32\CreateItemMoniker",
            "wstr", "!",
            "wstr", name,
            "ptr*", &pMoniker,   ; MUST use &
            "uint")
        if hr != 0 {
            ObjRelease(pROT)
            throw Error("CreateItemMoniker failed: 0x" Format("{:08X}", hr))
        }

        vtbl       := NumGet(pROT, 0, "ptr")
        pGetObject := NumGet(vtbl, 6 * A_PtrSize, "ptr")

        punk := 0
        hr := DllCall(pGetObject,
            "ptr",  pROT,
            "ptr",  pMoniker,
            "ptr*", &punk,      ; MUST use &
            "uint")

        ObjRelease(pMoniker)
        ObjRelease(pROT)

        if hr != 0
            throw Error("IRunningObjectTable::GetObject failed: 0x" Format("{:08X}", hr))

        obj := ComObjFromPtr(punk)
        ObjRelease(punk)
        return obj
    }
}