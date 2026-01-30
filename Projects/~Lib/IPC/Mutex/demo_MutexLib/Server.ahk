#Requires AutoHotkey v2.0
#Include MutexLib.ahk

; Define the shared resource and Mutex name
SharedFile := "comm_channel.tmp"
Sync := MutexManager("MySharedChannel")

ToolTip("Server: Listening for Client data...")

Loop {
    ; Server waits for the Client to finish writing
    if Sync.Lock() {
        if FileExist(SharedFile) {
            Data := FileRead(SharedFile)
            FileDelete(SharedFile) ; Clear the "buffer"
            
            ; Handle the "Message"
            MsgBox("Server Received: " Data, "Listener", "T2")
        }
        
        Sync.Unlock() ; Allow Client to send again

        ;MsgBox("Server has locked the Mutex and will NOT release it. Now run the Client and press Send.")
    }
    Sleep(100)
}