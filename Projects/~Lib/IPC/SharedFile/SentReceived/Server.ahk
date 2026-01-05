; TITLE:    SharedFile Server v1.0
; SOURCE :  jasc2v8 12/24/2025
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

#Include <LogFile>
#Include SharedFile.ahk

global logger:= LogFile("D:\LogFileServer.txt", "SERVER")
logger.Clear()
logger.Disable()

;global SharedFilePath:= "D:\SharedFile.txt"
;global SF:= SharedFile("Server", SharedFilePath)

global SF:= SharedFile("Server")

TrayTip "Server Listening...", "SERVER"

Loop {

    logger.Write("WaitSent")

    SF.WaitSent(-1)

    logger.Write("Read")

    request := SF.Read()

    logger.Write("Request: " request)

    if (request = "TERMINATE") {
        logger.Write(request)
        SF.SetReceived()
        Sleep 500
        break
    }

    logger.Write("Simulate Work")

    SoundBeep

    reply:= "ACK: " request

    logger.Write(reply)

    SF.Write(reply)

    Sleep 100
}
