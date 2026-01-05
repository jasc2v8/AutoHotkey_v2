class SharedMemory {
    static PAGE_READWRITE := 0x04
    static FILE_MAP_ALL_ACCESS := 0xF001F
    static WAIT_OBJECT_0 := 0
    static SCOPE := ""

    __New(name, size := 4096, isServer := false) {
        this.name := name
        this.size := size
        this.isServer := isServer
        this.SCOPE := "Local\" ; or Local

        this.hMutex := DllCall("CreateMutexW"
            , "ptr", 0
            , "int", false
            , "str", this.SCOPE name "_mtx" ; "Global\"
            , "ptr")

        if !this.hMutex
            throw Error("Failed to create/open mutex")

        if isServer {
            this.hMap := DllCall("CreateFileMappingW"
                , "ptr", -1
                , "ptr", 0
                , "uint", SharedMemory.PAGE_READWRITE
                , "uint", 0
                , "uint", size
                , "str", this.SCOPE name
                , "ptr")
        } else {
            this.hMap := DllCall("OpenFileMappingW"
                , "uint", SharedMemory.FILE_MAP_ALL_ACCESS
                , "int", false
                , "str", this.SCOPE name
                , "ptr")
        }

        if !this.hMap
            throw Error("Failed to create/open file mapping")

        this.pView := DllCall("MapViewOfFile"
            , "ptr", this.hMap
            , "uint", SharedMemory.FILE_MAP_ALL_ACCESS
            , "uint", 0
            , "uint", 0
            , "uptr", size
            , "ptr")

        if !this.pView
            throw Error("Failed to map view")
    }

    Write(text) {
        this._Lock()
        try {
            bytes := StrPut(text, "UTF-16") * 2
            if bytes + 4 > this.size
                throw Error("Message too large")

            NumPut("uint", bytes, this.pView)
            StrPut(text, this.pView + 4, bytes // 2, "UTF-16")
        } finally {
            this._Unlock()
        }
    }

    Read() {
        this._Lock()
        try {
            bytes := NumGet(this.pView, "uint")
            if bytes = 0
                return ""

            text:= StrGet(this.pView + 4, bytes // 2, "UTF-16")
            this.ClearView()
            return text

        } finally {
            this._Unlock()
        }
    }

    Clear() {
        this._Lock()
        try NumPut("uint", 0, this.pView)
        finally this._Unlock()
    }

    ClearView() {
        this._Lock()
        try {
            DllCall("RtlZeroMemory"
                , "ptr", this.pView
                , "uptr", this.size)
        } finally {
            this._Unlock()
        }
    }

    _Lock() {
        if DllCall("WaitForSingleObject", "ptr", this.hMutex, "uint", 5000) != SharedMemory.WAIT_OBJECT_0
            throw Error("Mutex timeout")
    }

    _Unlock() {
        DllCall("ReleaseMutex", "ptr", this.hMutex)
    }

    Close() {
        if this.pView
            DllCall("UnmapViewOfFile", "ptr", this.pView)
        if this.hMap
            DllCall("CloseHandle", "ptr", this.hMap)
        if this.hMutex
            DllCall("CloseHandle", "ptr", this.hMutex)
    }
}
