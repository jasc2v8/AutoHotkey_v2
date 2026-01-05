; ABOUT  : SharedMemory.ahk v1.0
; SOURCE : Copilot
; LICENSE:  The Unlicense, see https://unlicense.org
;
; the practical maximum size you can successfully create on a modern 64-bit Windows system is approximately 8 TB

class SharedMemory {

    ; Constructor: open or create a shared memory mapping
    __New(name, size := 1024, access := "rw") {

        this.name := name
        this.size := size
        this.access := access

        ; Create a Shared Memory Object

        ; INVALID_HANDLE_VALUE (-1) → use system paging file
        this.hMapFile := DllCall("CreateFileMappingW"
            , "ptr", -1                ; hFile
            , "ptr", 0                 ; lpSecurityAttributes
            , "uint", 0x04             ; PAGE_READWRITE
            , "uint", 0                ; dwMaximumSizeHigh
            , "uint", size             ; dwMaximumSizeLow
            , "wstr", name             ; lpName
            , "ptr")                   ; return HANDLE

        if (!this.hMapFile) {
            throw Error("CreateFileMappingW failed. LastError=" DllCall("GetLastError","uint"))
        }

        ; Map a view of the file
        this.pMapView := DllCall("MapViewOfFile"
            , "ptr", this.hMapFile
            , "uint", 0xF001F          ; FILE_MAP_ALL_ACCESS
            , "uint", 0
            , "uint", 0
            , "uptr", size
            , "ptr")

        if (!this.pMapView) {
            DllCall("CloseHandle", "ptr", this.hMapFile)
            throw Error("MapViewOfFile failed. LastError=" DllCall("GetLastError","uint"))
        }

    }

    ; Read as string
    ReadString(encoding := "UTF-16") {
        text:= StrGet(this.pMapView, this.size, encoding)
        ;this.WriteString("")
        return text
    }

    ; Write a string
    WriteString(text, encoding := "UTF-16") {
        StrPut(text, this.pMapView, this.size, encoding)
    }

    ; Read raw bytes
    ReadRaw(len) {
        buf := Buffer(len)
        DllCall("RtlMoveMemory", "ptr", buf, "ptr", this.pMapView, "uptr", len)
        return buf
    }

    ; Write raw bytes
    WriteRaw(buf) {
        DllCall("RtlMoveMemory", "ptr", this.pMapView, "ptr", buf, "uptr", buf.Size)
    }

    ; Cleanup
    __Delete() {
        ; if this.pMapView
        ;     DllCall("UnmapViewOfFile", "ptr", this.pMapView)
        ; if this.hMapFile
        ;     DllCall("CloseHandle", "ptr", this.hMapFile)
    }
}
