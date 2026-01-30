#Requires AutoHotkey v2.0
#Include MutexLib.ahk

SharedFile := "comm_channel.tmp"
Sync := MutexManager("MySharedChannel")

SendMsg(Message) {
    ToolTip("Client: Requesting permission to send...")
    
    ; Try to get the lock (wait up to 5 seconds)
    if Sync.Lock(5000) {
        ToolTip("Client: Writing data...")
        FileAppend(Message, SharedFile)
        Sleep(500) ; Simulate transmission time
        
        Sync.Unlock()
        ToolTip("Client: Data Sent.")
    } else {
        MsgBox("Timed out: Server is busy.")
    }
}

; GUI to send messages
Main := Gui()
Main.Add("Edit", "vMsg w200", "Hello Server!")
Main.Add("Button", "Default", "Send").OnEvent("Click", (*) => SendMsg(Main["Msg"].Value))
Main.Show()