; TITLE  :  SyncShared v1.0.0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/
#Requires AutoHotkey v2.0+

class SyncSharedMutex {

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
             this.hMutex := DllCall("CreateMutex", "Ptr", 0, "Int", 0, "Str", this.MutexName, "Ptr")
         else
             this.hMutex := DllCall("OpenMutex", "UInt", 0x00100000, "Int", 0, "Str", this.MutexName, "Ptr") ; SYNCHRONIZE (0x00100000)

        ; Create or Open Mutex
        ;this.hMutex := DllCall("CreateMutex", "Ptr", 0, "Int", 0, "Str", this.MutexName, "Ptr")

        if (!this.hMutex) {
            MsgBox("Could not open Mutex. Is the Server running?")
            ExitApp()
        }

        ;MsgBox this.hMutex, "this.Mutex"

        if (this.IsServer)
            ;this.Lock()
            this.Release()
        else
            this.Lock()
            ;this.Release()

    }

    Send(Text, CallbackFunction, Timeout := -1) {

        ; Wait for ownership
        ;result := DllCall("WaitForSingleObject", "Ptr", this.hMutex, "UInt", Timeout)

        CallbackFunction(Text)

        ; Release ownership
        ;DllCall("ReleaseMutex", "Ptr", this.hMutex)
        ;Sleep 1000
    }

    Receive(CallbackFunction, Timeout := -1) {

    ;MsgBox "Receive", "SyncSharedMutex"

        receivedText := ""

        try {

            ; Wait for ownership
            result := DllCall("WaitForSingleObject", "Ptr", this.hMutex, "UInt", Timeout)
            
            Sleep 100 ; Short wait for changes to take effect
            
        ;MsgBox "Receive is Owner", "SyncSharedMutex"

            if (result = 0) ; WAIT_OBJECT_0 (Success)
                receivedText := CallbackFunction(false) ; no timeout
            else
                receivedText := CallbackFunction(true) ; timeout

            ; Release ownership
            DllCall("ReleaseMutex", "Ptr", this.hMutex)

            Sleep 1000

        } catch Any as e {

            MsgBox "Receive ERROR:`n`n" e.Message, "SyncSharedMutex"
            receivedText := "ERROR"
        } 

        return receivedText
    }

    Lock(Timeout:=-1) {
        result := DllCall("WaitForSingleObject", "Ptr", this.hMutex, "UInt", Timeout)
        Sleep 1000
    }

    Release() {
        DllCall("ReleaseMutex", "Ptr", this.hMutex)
        Sleep 1000
    }

    __Delete() {

        if (this.hMutex)
            DllCall("CloseHandle", "Ptr", this.hMutex)
    }
}