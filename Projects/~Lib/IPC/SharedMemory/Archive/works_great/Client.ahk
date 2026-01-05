; ABOUT: ShowArgs.ahk v10
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
;#NoTrayIcon

#Include <LogFile>
#Include SharedMemory.ahk
;#Include <RunAsAdmin>

; Initialize as Client (3rd param = false/omitted)
;mem := SharedMemory("MyBridge", 4096, false)
mem := SharedMemory("MyBridge", , IsServer:=false)

Loop {

    ;Uncomment to validate that the previous read cleared the memory
    ; MsgBox mem.Read()

    IB:= InputBox("Enter Message:", "CLIENT",,"TERMINATE")

    if (IB.Result="Cancel")
        break

    ; 1. Send data (automatically signals the server)
    mem.Write(IB.Value)

    if (IB.Value="TERMINATE")
        break

    ; 2. Wait for response
    if (response := mem.WaitRead(2000)) {
        MsgBox "Response: " response
    } else {
        MsgBox "No response from Server."
    }


}
