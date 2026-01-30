
#Requires AutoHotkey v2.0+

class SyncShared {

    __New(IsServer:=false) {

        this.IsServer := IsServer ; Track if this instance is the Server or Client
        
        ; Setup Security Descriptor (Grant Everyone access)
        SD := Buffer(100, 0)
        DllCall("Advapi32\ConvertStringSecurityDescriptorToSecurityDescriptor", "Str", "D:(A;;GA;;;WD)", "UInt", 1, "Ptr*", &pSD := 0, "Ptr", 0)
        SA := Buffer(A_PtrSize == 8 ? 24 : 12, 0)
        NumPut("UInt", SA.Size, SA, 0), NumPut("Ptr", pSD, SA, A_PtrSize)

        ; Setup Events
        this.hEventServer := DllCall("CreateEvent", "Ptr", SA, "Int", 0, "Int", 0, "Str", "EVENT_SERVER", "Ptr")
        this.hEventClient := DllCall("CreateEvent", "Ptr", SA, "Int", 0, "Int", 0, "Str", "EVENT_CLIENT", "Ptr")

    }

    Send(Text, CallbackFunction) {
        CallbackFunction(Text)
        ; If I am Server, reset Server event. If I am Client, reset Client event.
        hEvent := this.IsServer ? this.hEventServer : this.hEventClient
        DllCall("SetEvent", "Ptr", hEvent)
    }

    Receive(CallbackFunction, Timeout := -1) {
        
        ; If I am Server, wait for Client event. If I am Client, wait for Server event.
        hEventWait := this.IsServer ? this.hEventClient : this.hEventServer
        
        result := DllCall("WaitForSingleObject", "Ptr", hEventWait, "UInt", Timeout)
        
        Sleep 100 ; Short wait for changes to take effect
        
        ;if (result != 0)            MsgBox "Receive Timeout!", "SyncShared"
        ;if (result != 0)            Throw Error "SyncShared: Timeout Receive"

        if (result = 0) ; WAIT_OBJECT_0 (Success)
            receivedText := CallbackFunction(false) ; no timeout
        else
            receivedText := CallbackFunction(true) ; timeout

        return receivedText
    }

    __Delete() {
        
        if (this.hEventServer)
            DllCall("CloseHandle", "Ptr", this.hEventServer)
        if (this.hEventClient)
            DllCall("CloseHandle", "Ptr", this.hEventClient)
    }
}