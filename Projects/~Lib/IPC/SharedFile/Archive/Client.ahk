; TITLE:    Server v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\SharedFile.ahk

global LogFile:= ".\ClientLogFile.txt"

global SharedFilePath := ".\SharedFile.txt"

global SF:= SharedFile("Client", SharedFilePath)

if !FileExist(SharedFilePath) {
    MsgBox("Shared File not found.`n`nRun the Server before the Client.`n`nPress OK to exit.", "CLIENT")
    ExitApp()
}

Loop {

    IB:= InputBox("Enter Message:", "CLIENT",,"TERMINATE")

    if (IB.Result="Cancel")
        break

    WriteLog("WaitWrite command to Server: " IB.Value)

    timeout := SF.WaitWrite(IB.Value, -1)

    if (timeout)
        WriteLog("Timeout WaitWrite")

    if (IB.Value="TERMINATE") {
        WriteLog(IB.Value)
        break
    }
    
    WriteLog("Wait Read Response from Server")

    response := SF.WaitRead(-1)

    if (response = "")
        WriteLog("Timeout WaitRead")

    WriteLog("response: [" response "]")

    if (SubStr(response, 1, 3) != "ACK") {
        MsgBox("Server not responding.`n`nPress OK to exit.", "CLIENT")
        ExitApp()
    }

    Sleep 100

}

CheckTimeout(timedOut, number) {
    if (timedOut)
        MsgBox("Timeout Number: " number , "CLIENT")
}

WriteLog(Message) {
    currentTime := FormatTime(A_Now, "HH:mm:ss")
    FileAppend(currentTime ": " Message "`n", LogFile)
}