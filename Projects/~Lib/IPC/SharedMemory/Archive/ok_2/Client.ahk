; ABOUT: ShowArgs.ahk v10
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
; #NoTrayIcon

#Include <LogFile>
#Include SharedMemory.ahk

name := "MyFileMap"
size := 1024
mem := SharedMemory("Client", name, size)

global logger:= LogFile("D:\Client.log", "CLIENT")
logger.Clear()
;logger.Disable()

Loop {

    IB:= InputBox("Enter Message:", "CLIENT",,"TERMINATE")

    if (IB.Result="Cancel")
        break

    logger.Write("Write Request to Server: " IB.Value)

    mem.Write(IB.Value)
       
    if (IB.Value="TERMINATE") {
        logger.Write(IB.Value)
        break
    }
    
    logger.Write("Read Reply from Server")

    reply := mem.Read()

    logger.Write("reply: [" reply "]")

    if (SubStr(reply, 1, 3) != "ACK") {
        MsgBox("Server not responding.`n`nPress OK to exit.", "CLIENT")
        ExitApp()
    }

    MsgBox("Sever Reply:`n`n" reply, "CLIENT", "")

    Sleep 100

}