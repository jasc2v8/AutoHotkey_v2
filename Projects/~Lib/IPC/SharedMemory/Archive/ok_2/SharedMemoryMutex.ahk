; ABOUT  : SharedMemory.ahk v1.0
; SOURCE : Copilot
; LICENSE:  The Unlicense, see https://unlicense.org
;
; the practical maximum size you can successfully create on a modern 64-bit Windows system is approximately 8 TB

#Requires AutoHotkey v2.0+

class SharedMemory {

    __New(Role, Name, Size := 2048) {
        this.Role := Role
        this.Name := Name
        this.Size := Size
        this.Prefix := "Local\" ; Use this for debug running without privilege escalation
        ;this.Prefix := "Global\" ; Admin creates Global but allows non-admin access
        ; this.PData:=0
        ; this.hMap:=0
        ; this.hMutex:=0
        ; this.hEvent:=0
        
        if (this.Role = "SERVER") {

            SA:= this.GetSecurityAttributes()

            ; 1. Create/Open File Mapping with Security Attributes
            this.hMap := DllCall("CreateFileMapping", "Ptr", -1, "Ptr", SA, "UInt", 0x04, "UInt", 0, "UInt", Size, "Str", this.Prefix . Name, "Ptr")
            if !this.hMap
                throw Error("SERVER_INIT_FAILED: Mapping not found. Is the Server running as Admin?", -1)

            ; Create/Open Mutex with Security Attributes
            this.hMutex := DllCall("CreateMutex", "Ptr", SA, "Int", 0, "Str", this.Prefix . Name "_Mutex", "Ptr")
            
            ; Create/Open Event with Security Attributes
            this.hEvent := DllCall("CreateEvent", "Ptr", SA, "Int", 0, "Int", 0, "Str", this.Prefix . Name "_Event", "Ptr")

        }
        else if (this.Role = "Client") {

            ; CLIENT: Only attempts to open existing objects
            this.hMap := DllCall("OpenFileMapping", "UInt", 0xF001F, "Int", 0, "Str", this.Prefix . Name, "Ptr")
            if !this.hMap
                throw Error("CLIENT_INIT_FAILED: Mapping not found. Is the Server running?", -1)

            ;0x1F0001	Full Access (MUTEX_ALL_ACCESS)
            this.hMutex := DllCall("OpenMutex", "UInt", 0x1F0001, "Int", 0, "Str", this.Prefix . Name "_Mutex", "Ptr")
            ;0x1F0003	Full Access (EVENT_ALL_ACCESS)
            this.hEvent := DllCall("OpenEvent", "UInt", 0x1F0003, "Int", 0, "Str", this.Prefix . Name "_Event", "Ptr")

        } 
        else {
            throw Error("INVALID_ROLE: Role must be 'server' or 'client'.")
        }

        this.pData := DllCall("MapViewOfFile", "Ptr", this.hMap, "UInt", 0xF001F, "UInt", 0, "UInt", 0, "Ptr", Size, "Ptr")

    }

    ; --- WRITER METHOD ---
    Write(StringData) {
        ;if this.Lock() {
            StrPut(StringData, this.pData, "UTF-16")
            DllCall("FlushViewOfFile", "Ptr", this.pData, "Ptr", this.Size)
            ;this.Unlock()
            
            ; Signal that data is ready
            DllCall("SetEvent", "Ptr", this.hEvent)
        ;}
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
        ;if this.Lock() {
            data := StrGet(this.pData, "UTF-16")
            ;this.Unlock()
            return data
        ;}
        ;return ""
    }

    Lock(Timeout := -1) {
        res := DllCall("WaitForSingleObject", "Ptr", this.hMutex, "UInt", Timeout, "UInt")
        return (res = 0 || res = 128)
    }

    Unlock() => DllCall("ReleaseMutex", "Ptr", this.hMutex)

    GetSecurityAttributes() {

            ; --- Prepare Security Attributes for Non-Admin Access ---
            ; We create a SECURITY_DESCRIPTOR and set its DACL to NULL (Anyone can access)
            static SD_SIZE := 20 ; SECURITY_DESCRIPTOR size
            static SA_SIZE := A_PtrSize == 8 ? 24 : 12 ; SECURITY_ATTRIBUTES size
            
            SD := Buffer(SD_SIZE, 0)
            ; Initialize Security Descriptor (1 = SECURITY_DESCRIPTOR_REVISION)
            DllCall("Advapi32\InitializeSecurityDescriptor", "Ptr", SD, "UInt", 1)
            ; Set DACL to NULL (3rd param 1 = bDaclPresent, 4th param 0 = pDacl (NULL))
            DllCall("Advapi32\SetSecurityDescriptorDacl", "Ptr", SD, "Int", 1, "Ptr", 0, "Int", 0)
            
            ; Prepare the Security Attributes structure
            SA := Buffer(SA_SIZE, 0)
            NumPut("UInt", SA_SIZE, SA, 0)      ; nLength
            NumPut("Ptr", SD.Ptr, SA, A_PtrSize) ; lpSecurityDescriptor
            NumPut("Int", 1, SA, A_PtrSize * 2)  ; bInheritHandle
            return SA
    }

    __Delete() {
        if this.pData
            DllCall("UnmapViewOfFile", "Ptr", this.pData)
        for handle in [this.hMap, this.hMutex, this.hEvent]
            if handle
                DllCall("CloseHandle", "Ptr", handle)
    }
}