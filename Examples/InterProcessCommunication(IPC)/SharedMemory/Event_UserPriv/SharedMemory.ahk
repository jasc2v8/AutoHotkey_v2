; ABOUT  : SharedMemory.ahk v1.0
; SOURCE : Copilot
; LICENSE:  The Unlicense, see https://unlicense.org
;
; the practical maximum size you can successfully create on a modern 64-bit Windows system is approximately 8 TB

/*
    TODO:

    SharedMemory PsuedoCode
    -------------------------
    SERVER:
    Create()
    SetReceived()
    Loop
        WaitSent
            Read
            SetReceived
        Do Work
        Write Reply
            Write
            SetSent
            WaitReceived
    Loop

    CLIENT:
    Loop
        ; not needed: WaitReceived
        Write request
            Write
            SetSent
            WaitReceived
        Read reply
            WaitSent
            Read
            SetReceived
    Loop

*/

class SharedMemory {
    mem := 0
    size := 0
    console:=""
    hMapFile := 0
    pMapView := 0
    
    ; Constructor: create or open a mapping (OG was 4096)
    __New(Role, name := "MyFileMap", size := 4096) {

        this.size := size

        FILE_MAP_ALL_ACCESS:= 0xF001F

        ; Try to open existing mapping
        this.hMapFile := DllCall("Kernel32\OpenFileMappingW", "UInt", FILE_MAP_ALL_ACCESS, "Int", 0, "Str", name, "Ptr")

        ; If not found, create one
        if (this.hMapFile = 0) {

            if (Role != "Server") {
                MsgBox "Shared Memory not created.`n`nPlease start the Server first.", "SharedMemory", 'IconX'
                ExitApp()
            }

            ; INVALID_HANDLE_VALUE (-1) → use system paging file
            this.hMapFile := DllCall("CreateFileMappingW"
                , "ptr", -1                ; hFile
                , "ptr", 0                 ; lpSecurityAttributes
                , "uint", 0x04             ; PAGE_READWRITE
                , "uint", 0                ; dwMaximumSizeHigh
                , "uint", size             ; dwMaximumSizeLow
                , "wstr", name             ; lpName
                , "ptr")                   ; return HANDLE
        }

        if (this.hMapFile)=0 {
            throw Error("Failed to create/open shared memory. Last Error: " . A_LastError)
        }

        ; Map a view of the file
        this.pMapView := DllCall("MapViewOfFile"
            , "ptr", this.hMapFile
            , "uint", FILE_MAP_ALL_ACCESS
            , "uint", 0
            , "uint", 0
            , "uptr", size
            , "ptr")

        if (!this.pMapView) {
            DllCall("CloseHandle", "ptr", this.hMapFile)
            throw Error("MapViewOfFile failed. LastError=" DllCall("GetLastError","uint"))
        }

        ; Create and open named events for synchronization
        this.CreateEvent("Sent")
        this.CreateEvent("Received")

        ; Set the initial state of the event
        this.SetEvent("Received")

    }

    ; Clear the contents of the shared memory
    Clear() {
        this.Write("")
        ;StrPut("", this.pMapView, this.size, "UTF-16")
    }

    ; Create and open a named event for synchronization
    ; Returns hEvent or "" if fail
    CreateEvent(EventName) {
        static MANUAL_RESET :=  false
        static INITIAL_STATE:=  false ; nonsignaled
        return DllCall("CreateEvent", "ptr", 0, "int", MANUAL_RESET, "int", INITIAL_STATE, "str", EventName, "ptr")
    }

    ; Open a named event for synchronization
    ; Returns hEvent or "" if fail
    OpenEvent(EventName) {
        ; SYNCHRONIZE (0x100000) | EVENT_MODIFY_STATE (0x2)
        static INHERIT_HANDLE:=  false
        return DllCall("OpenEvent", "uint", 0x100002, "int", INHERIT_HANDLE, "str", EventName, "ptr")
    }

    ; Signal the event so server knows data is ready
    ; Success !=0, Fail=0
    SetEvent(EventName) {
        hEvent:= this.OpenEvent(EventName)
        return DllCall("SetEvent", "ptr", hEvent)
    }

    ; Set the event to the nonsignaled state
    ; Success !=0, Fail=0
    ResetEvent(EventName) {
        hEvent:= this.OpenEvent(EventName)
        return DllCall("ResetEvent", "ptr", hEvent)
    }

    ; Wait for a named event
    ; Success: Returns a value for the event that caused the function to return, Fail=-1
    ; Timeout: No wait=0 milliseconds, Wait forever=-1 milliseconds
    ;WAIT_TIMEOUT=0x00000102L, WAIT_OBJECT_0=0x00000000L, WAIT_FAILED=-1L
    WaitEvent(EventName, Milliseconds:=-1) {
        hEvent:= this.OpenEvent(EventName)
        return DllCall("WaitForSingleObject", "ptr", hEvent, "uint", Milliseconds)
    }

    ; Write a string into the shared memory
    Write(text) {
        StrPut(text, this.pMapView, this.size, "UTF-16")
        this.SetEvent("Sent")
        this.WaitEvent("Received")
    }

    ; Read a string from shared memory
    Read() {
        this.WaitEvent("Sent")
        text:= StrGet(this.pMapView, this.size, "UTF-16")
        this.SetEvent("Received")
        return text
    }

    ; Destructor: unmap and close
    __Delete() {
        if (this.pMapView)
            DllCall("UnmapViewOfFile", "ptr", this.pMapView)
        if (this.hMapFile)
            DllCall("CloseHandle", "ptr", this.hMapFile)
    }
}
