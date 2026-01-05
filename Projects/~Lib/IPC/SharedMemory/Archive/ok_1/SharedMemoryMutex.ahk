; ABOUT  : SharedMemory.ahk v1.0
; SOURCE : Copilot
; LICENSE:  The Unlicense, see https://unlicense.org
;
; the practical maximum size you can successfully create on a modern 64-bit Windows system is approximately 8 TB

#Requires AutoHotkey v2.0+

class SharedMemory {
    __New(Name, Size := 1024) {
        this.Name := Name
        this.Size := Size
        
        ; 1. Create/Open File Mapping
        this.hMap := DllCall("CreateFileMapping", "Ptr", -1, "Ptr", 0, "UInt", 0x04, "UInt", 0, "UInt", Size, "Str", "Global\" Name, "Ptr")
        this.pData := DllCall("MapViewOfFile", "Ptr", this.hMap, "UInt", 0xF001F, "UInt", 0, "UInt", 0, "Ptr", Size, "Ptr")
        
        ; 2. Create/Open Mutex (For safety during the write/read)
        this.hMutex := DllCall("CreateMutex", "Ptr", 0, "Int", 0, "Str", "Global\" Name "_Mutex", "Ptr")
        
        ; 3. Create/Open Event (For signaling "Data Ready")
        ; bManualReset = FALSE (Auto-resets after one waiter is released)
        this.hEvent := DllCall("CreateEvent", "Ptr", 0, "Int", 0, "Int", 0, "Str", "Global\" Name "_Event", "Ptr")
    }

    ; --- WRITER METHOD ---
    Write(StringData) {
        if this.Lock() {
            StrPut(StringData, this.pData, "UTF-8")
            DllCall("FlushViewOfFile", "Ptr", this.pData, "Ptr", this.Size)
            this.Unlock()
            
            ; Signal that data is ready
            DllCall("SetEvent", "Ptr", this.hEvent)
        }
    }

    ; --- READER METHOD ---
    ; This will block the script until the writer calls SetEvent
    WaitForWrite(Timeout := -1) {
        ; Wait for the event signal
        res := DllCall("WaitForSingleObject", "Ptr", this.hEvent, "UInt", Timeout, "UInt")
        if (res = 0) { ; WAIT_OBJECT_0
            return this.Read()
        }
        return ""
    }

    Read() {
        if this.Lock() {
            data := StrGet(this.pData, "UTF-8")
            this.Unlock()
            return data
        }
        return ""
    }

    Lock(Timeout := -1) {
        res := DllCall("WaitForSingleObject", "Ptr", this.hMutex, "UInt", Timeout, "UInt")
        return (res = 0 || res = 128)
    }

    Unlock() => DllCall("ReleaseMutex", "Ptr", this.hMutex)

    __Delete() {
        if this.pData
            DllCall("UnmapViewOfFile", "Ptr", this.pData)
        for handle in [this.hMap, this.hMutex, this.hEvent]
            if handle
                DllCall("CloseHandle", "Ptr", handle)
    }
}