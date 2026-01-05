; ABOUT: BackupControlTool v2.3, 
; 
/*
    TODO:
        SharedMemory("AhkRunCmdService")

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
;#NoTrayIcon

#Include <LogFile>
#Include SharedMemory.ahk

logger:= LogFile("D:\SharedMemory_Client.log", "CLIENT")
logger.Clear()

name := "MySharedMemory"
size := 4096
mem := SharedMemory(name, size)
SleepDuration:= 500

        ; Attach to shared memory created by a service
        mem := SharedMemory(name, 1024)

        ; Write string
        logger.Write("Hello from AHK v2!")

        mem.WriteString("CLIENT: Hello from AHK v2!")
       
        Sleep SleepDuration

        loop {
            reply:= mem.ReadString()
            if (SubStr(reply,1,7)="SERVER:") {
                break
            }
            Sleep 100
        }

        MsgBox reply, "Client"
        
        r := MsgBox("Terminate service?", "TERMINATE", "YesNo icon?")

        if (r  ="Yes") {
            mem.WriteString("CLIENT: TERMINATE")
            Sleep SleepDuration
            ;MsgBox mem.ReadString()
        }

