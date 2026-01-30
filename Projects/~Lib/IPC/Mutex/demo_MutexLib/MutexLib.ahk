#Requires AutoHotkey v2.0

class MutexManager {
    __New(Name) {

        this.Name := "Local\" Name

        ; CreateMutexA is case-sensitive as per requirements
        this.Handle := DllCall("CreateMutexA", "Ptr", 0, "Int", 0, "AStr", this.Name, "Ptr")
        
        if !this.Handle
            throw Error("Could not create Mutex: " this.Name " (Error: " A_LastError ")")
    }

    ; Wait for the Mutex to become available
    Lock(Timeout := -1) {

        Result := DllCall("WaitForSingleObject", "Ptr", this.Handle, "Int", Timeout)

        return (Result = 0) ; Returns true if lock acquired

    }

    ; Release the Mutex for the other party
    Unlock() {
        return DllCall("ReleaseMutex", "Ptr", this.Handle)
    }

    __Delete() {
        if this.Handle
            DllCall("CloseHandle", "Ptr", this.Handle)
    }
}