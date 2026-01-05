; ABOUT: Client.ahk v1.0 (SharedFile)
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
;#NoTrayIcon

;#Include <RunAsAdmin>
#Include <LogFile>
#Include SharedFile.ahk

; Initialize as Client
;mem := SharedFile("Client")
mem := SharedFile()

Loop {

    IB:= InputBox("Enter Message:", "CLIENT",,"TERMINATE")

    if (IB.Result="Cancel")
        break

    ; 1. Send data (automatically signals the server)
    mem.Write(IB.Value)

    ; 2. Wait for response
    if (response := mem.WaitRead(2000)) {
        MsgBox "Response: " response
    } else {
        MsgBox "No response from Server."
    }

    if (IB.Value="TERMINATE")
        break


}
