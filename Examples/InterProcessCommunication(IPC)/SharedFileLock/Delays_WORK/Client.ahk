; ABOUT:    Server v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\SharedFile.ahk

global SF:= SharedFile("Client", ".\SharedFile.txt")

global LogFile:= ".\ClientLogFile.txt"

Loop {

    WriteLog("WaitReady")

    SF.WaitReady(-1)
    Sleep 100

    WriteLog("SetNotReady")

    SF.SetNotReady()
    Sleep 100

    ; get user input
    IB:= InputBox("Enter Message:", "CLIENT",,"TERMINATE")

    ; if user pressed Cancel then break out of loop to exit
    if (IB.Result="Cancel")
        break

    WriteLog("Write")

    SF.Write(IB.Value)

    WriteLog("SetReady")

    SF.SetReady()
    Sleep 100

    ; handle terminate command from user
    if (IB.Value="TERMINATE")
        break
    
    WriteLog("WaitNotReady")

    SF.WaitNotReady(-1)
    Sleep 100

    WriteLog("WaitReady")

    SF.WaitReady(-1)
    Sleep 100

    WriteLog("SetNotReady")

    SF.SetNotReady()
    Sleep 100

    WriteLog("Read")

    response := SF.Read()

    WriteLog("response: " response)

    if (SubStr(response, 1, 3) != "ACK") {
        MsgBox("Server not responding.`n`nPress OK to exit.", "CLIENT")
        SF.DeleteSharedFile()
        ExitApp()
    }

    ;MsgBox "From Server:`n`n[" response "]", "CLIENT"

    WriteLog("SetReady")

    SF.SetReady()
    Sleep 100

}

CheckTimeout(timeout, number) {
    if (timeout)
        MsgBox("Timeout Number: " number , "CLIENT")
}

WriteLog(Message) {
    currentTime := FormatTime(A_Now, "HH:mm:ss")
    FileAppend(currentTime ": " Message "`n", LogFile)
}