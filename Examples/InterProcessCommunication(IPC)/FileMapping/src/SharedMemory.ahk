; ABOUT  : SharedMemory.ahk v1.0
; SOURCE : Copilot
; LICENSE:  The Unlicense, see https://unlicense.org
;
; the practical maximum size you can successfully create on a modern 64-bit Windows system is approximately 8 TB

class SharedMemory {
    hMap := 0
    pView := 0
    size := 0
    console:=""
    ; Constructor: create or open a mapping (OG was 4096)
    __New(name := "MyFileMap", size := 1024) {
        this.size := size
        ; INVALID_HANDLE_VALUE (-1) → use system paging file
        this.hMap := DllCall("CreateFileMappingW"
            , "ptr", -1                ; hFile
            , "ptr", 0                 ; lpSecurityAttributes
            , "uint", 0x04             ; PAGE_READWRITE
            , "uint", 0                ; dwMaximumSizeHigh
            , "uint", size             ; dwMaximumSizeLow
            , "wstr", name             ; lpName
            , "ptr")                   ; return HANDLE

        if (!this.hMap) {
            throw Error("CreateFileMappingW failed. LastError=" DllCall("GetLastError","uint"))
        }

        ; Map a view of the file
        this.pView := DllCall("MapViewOfFile"
            , "ptr", this.hMap
            , "uint", 0xF001F          ; FILE_MAP_ALL_ACCESS
            , "uint", 0
            , "uint", 0
            , "uptr", size
            , "ptr")

        if (!this.pView) {
            DllCall("CloseHandle", "ptr", this.hMap)
            throw Error("MapViewOfFile failed. LastError=" DllCall("GetLastError","uint"))
        }

    }

    IsEmpty() {
        return StrLen(this.Read()) == 0
    }

    ; Clear the contents of the shared memory
    Clear() {
        StrPut("", this.pView, this.size, "UTF-16")
    }

    ; Write a string into the shared memory
    Write(text) {
        StrPut(text, this.pView, this.size, "UTF-16")
    }

    ; Read a string back
    Read() {
        return StrGet(this.pView, this.size, "UTF-16")
    }

    ; Waits until the shared memory has changed or timeout
    ; This gives another process time to write to the shared memory before we read it.
    ReadWait(Retry:=5) {

        oldContent := StrGet(this.pView, this.size, "UTF-16")

        timeout := true

    ;counter:=0

        Loop Retry {

            newContent := StrGet(this.pView, this.size, "UTF-16")

            if (newContent != oldContent) {
                timeout:= false
                break
            }

            Sleep 100

            ;counter++
        }

        ;FileAppend(counter ",", A_ScriptDir "\SharedMemory.txt")

        return timeout ? "NO_RESPONSE" : newContent
    }

    ; Destructor: unmap and close
    __Delete() {
        if (this.pView)
            DllCall("UnmapViewOfFile", "ptr", this.pView)
        if (this.hMap)
            DllCall("CloseHandle", "ptr", this.hMap)
    }
}

; If run directly, execute the following block of code
If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    MyFunction__Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

MyFunction__Tests() {

    smallString:= "Hello from Shared Memory!"
    largeString:= 
    "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
    "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
    "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
    "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
    "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
    "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
    "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
    "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
    "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
    "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
    "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
    "1234567890123456789012345678901234"
   
    myString:=smallString

    ; Script 1 (writer)
    mem := SharedMemory("DemoMap")
    mem.Write(myString)

    ; Script 2 (reader)
    ;mem := SharedMemory("DemoMap", 1024)
    MsgBox mem.Read() , "Len: " StrLen(MyString)

    mem.Clear()
    MsgBox '[' mem.Read() ']' ", IsEmpty:" mem.IsEmpty(), "Len: " StrLen(MyString)

    mem.Write("new string")
    MsgBox '[' mem.Read() ']' ", IsEmpty:" mem.IsEmpty(), "Len: " StrLen(MyString)


}