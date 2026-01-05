; TITLE:    SharedFile Client v1.0
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

global logger:= LogFile("D:\LogFileClient.txt", "CLIENT")
logger.Clear()
logger.Disable()

;global SharedFilePath:= "D:\SharedFile.txt"
;global SF:= SharedFile("Client", SharedFilePath)

global SF:= SharedFile("Client")

if !SF.Exist() {
    MsgBox("Shared File not found.`n`nRun the Server before the Client.`n`nPress OK to exit.", "CLIENT", "Iconx")
    ExitApp()
}

Loop {

    ; always received here SF.WaitReceived(-1)

    IB:= InputBox("Enter Message:", "CLIENT",,"TERMINATE")

    if (IB.Result="Cancel")
        break

    logger.Write("Write Request to Server: " IB.Value)

    SF.Write(IB.Value)
       
    if (IB.Value="TERMINATE") {
        logger.Write(IB.Value)
        break
    }
    
    logger.Write("Read Reply from Server")

    reply := SF.Read()

    logger.Write("reply: [" reply "]")

    if (SubStr(reply, 1, 3) != "ACK") {
        MsgBox("Server not responding.`n`nPress OK to exit.", "CLIENT")
        ExitApp()
    }

    MsgBox("Sever Reply:`n`n" reply, "CLIENT", "")

    Sleep 100

}
