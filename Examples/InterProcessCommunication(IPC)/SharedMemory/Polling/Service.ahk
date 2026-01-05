; ABOUT: ShowArgs.ahk v10
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFile>
#Include SharedMemory.ahk

;#Include <RunAsAdmin>

logger:= LogFile("D:\SharedMemory_Service.log", "SERVICE")
logger.Clear()

oldMessage := ""
name := "MySharedMemory"
size := 4096
global mem := SharedMemory(name, size)

logger.Write("Service Start")

Loop {

        message := mem.ReadString()

        ; if (message = oldMessage)
        ;     continue


        ; if (message = 'STATUS') {
             ;logger.Write("RECEIVED: " message)
        ; }

        if (SubStr(message,1,7) = 'CLIENT:') {

            logger.Write(message)

            mem.WriteString("SERVER: ACK: " message)

            if (message = 'CLIENT: TERMINATE') {
                ;logger.Write(message)
                break
            }
        }

        oldMessage:= message

        ;logger.Write("TICK")

        Sleep 100
}

