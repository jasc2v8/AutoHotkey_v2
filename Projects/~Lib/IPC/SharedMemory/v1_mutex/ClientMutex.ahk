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

global logger:= LogFile("D:\Server.log", "SERVER")
logger.Clear()
;logger.Disable()

; Check if server is running and has created the shared memory object
try {
    mem := SharedMemory("client", "MyProject", 2048)
} catch any as e {
    MsgBox "Error: " e.Message, "CLIENT", "IconX"
    ExitApp()
}

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