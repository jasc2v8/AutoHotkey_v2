#Requires AutoHotkey v2.0
#Include MutexLib.ahk

SharedFile := "comm_channel.tmp"

;Sync := MutexManager("MySharedChannel")
Sync := MutexManager(false)

; SendMsg(Message) {
;     ToolTip("Client: Requesting permission to send...")

Loop {

    ; Form request
    request := InputBox("Enter Message:", "Client",,"TERMINATE")

    if (request.Value = "")
        continue

    if (request.Value = "BYE") or (request.Result = "Cancel")
        break

    ; Try to get the lock (wait up to 2 seconds)
    if Sync.Lock(2000) {

        ;ToolTip("Client: Writing data...")

        FileAppend(request.Value, SharedFile)

        Sleep(250) ; Simulate transmission time
        
        Sync.Unlock()

        ;ToolTip("Client: Data Sent.")

        ; if terminate, don't wait for a reply
        if (request.Value = "TERMINATE")
            break
 

    } else {
        MsgBox("Timed out: Server is busy.")
    }
}

; ; GUI to send messages
; Main := Gui()
; Main.Add("Edit", "vMsg w200", "Hello Server!")
; Main.Add("Button", "Default", "Send").OnEvent("Click", (*) => SendMsg(Main["Msg"].Value))
; Main.Show()