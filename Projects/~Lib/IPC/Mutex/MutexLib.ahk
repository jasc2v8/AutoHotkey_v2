#Requires AutoHotkey v2.0

class MutexManager {

    MutexName := "Local\SharedSyncMutex"

    __New(IsServer:=false) {

        this.IsServer := IsServer ; Track if this instance is the Server or Client
        
        ; Setup Security Descriptor (Grant Everyone access)
        SD := Buffer(100, 0)
        DllCall("Advapi32\ConvertStringSecurityDescriptorToSecurityDescriptor", "Str", "D:(A;;GA;;;WD)", "UInt", 1, "Ptr*", &pSD := 0, "Ptr", 0)
        SA := Buffer(A_PtrSize == 8 ? 24 : 12, 0)
        NumPut("UInt", SA.Size, SA, 0), NumPut("Ptr", pSD, SA, A_PtrSize)

        ; Create or Open Mutex
         if (this.IsServer)
        ;     ;this.hMutex := DllCall("CreateMutex", "Ptr", SA, "Int", 0, "Str", this.MutexName, "Ptr")
             this.hMutex := DllCall("CreateMutex", "Ptr", SA, "Int", 0, "Str", this.MutexName, "Ptr")
         else
             this.hMutex := DllCall("OpenMutex", "UInt", 0x00100000, "Int", 0, "Str", this.MutexName, "Ptr") ; SYNCHRONIZE (0x00100000)

        ; Create or Open Mutex
        ;this.hMutex := DllCall("CreateMutex", "Ptr", 0, "Int", 0, "Str", this.MutexName, "Ptr")

        if (!this.hMutex) {
            MsgBox("Could not open Mutex. Is the Server running?")
            ExitApp()
        }

    }

    ; __New(Name) {

    ;     this.Name := "Local\" Name

    ;     ; CreateMutexA is case-sensitive as per requirements
    ;     this.hMutex := DllCall("CreateMutexA", "Ptr", 0, "Int", 0, "AStr", this.Name, "Ptr")
        
    ;     if !this.hMutex
    ;         throw Error("Could not create Mutex: " this.Name " (Error: " A_LastError ")")
    ; }

    ; Wait for the Mutex to become available
    Lock(Timeout := -0xFFFFFFFF) {

        Result := DllCall("WaitForSingleObject", "Ptr", this.hMutex, "UInt", Timeout)

        return (Result = 0) ; Returns true if lock acquired

    }

    ; Release the Mutex for the other party
    Unlock() {
        return DllCall("ReleaseMutex", "Ptr", this.hMutex)
    }

    __Delete() {
        if this.hMutex
            DllCall("CloseHandle", "Ptr", this.hMutex)
    }
}