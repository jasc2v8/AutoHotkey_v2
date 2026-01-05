; ABOUT: ShowArgs.ahk v10
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
;#NoTrayIcon

#Include <LogFile>
#Include SharedMemoryMutex.ahk
#Include <RunAsAdmin>

global logger:= LogFile("D:\Server.log", "SERVER")
;logger.Clear()
logger.Disable()

; Include the class above here
Mem := SharedMemory("MyProject", 1024)

Loop {

    IB:= InputBox("Enter Message:", "CLIENT",,"TERMINATE")

    if (IB.Result="Cancel")
        break

    mem.Write(IB.Value)
       
    if (IB.Value="TERMINATE") {
        break
    }

    reply := Mem.WaitForWrite()

    if (SubStr(reply, 1, 3) != "ACK") {
        MsgBox("Server not responding.`n`nPress OK to exit.", "CLIENT")
        ExitApp()
    }

    MsgBox("Sever Reply:`n`n" reply, "CLIENT", "")    

}