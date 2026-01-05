; TITLE: BackupControlTool v2.3, 
; 
/*
    TODO:
        Error if Client exists when Server not running

        Client hangs if restarting while server is running


*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunCMD>
#Include <MailBox>

global Logging := true
global ServiceLogFile := "D:\ServiceLog.txt"

global SyncBackPath := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackAction := "" ; "", "-shutdown", "-standby"
;global SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
global SyncBackProfile := "TEST"

global defaultText:= "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST"

; Mutex is set to "Acquired" upon start
global SF := MailBox("Client")

OnExit(ExitHandler)

; have the Server waith until a command is sent
;SF.SetEmpty()

WriteLog("Client Start!")

Loop {

    if (DirExist("D:\Docs_Backup"))
        DirDelete("D:\Docs_Backup", Recurse:=1)

    IB := InputBox("Enter CSV Command:", "Service Control", , defaultText)

    if (IB.Value = "Exit") OR (IB.Result = "Cancel") {
        ExitApp()
    }
    
    ;msgClientCSV:= reg.ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)
    cmdCSV:= IB.Value

    ; Write message into shared memory.
    ; Service will Output:=RunCMD.CSV(message) and write Output.txt
    SF.SendMail(cmdCSV) ; SetNewMail()

    ; Wait for Server to read cmd
    mailRead:= SF.WaitMailRead(-1)

    if (!mailRead) {
        MsgBox "Timeout waiting for Service to Read Mail.`n`nPress OK to exit.", "CLIENT", "iconX"
        ExitApp()
    }

}

ExitApp()

;   # region Functions

; Convert string and number variables into a CSV string
ConvertToCSV(Params*) {
    myString:= ""
    for item in Params {
        if IsSet(item)
            myString .= item . ","
    }
    return RTrim(myString, ",")
}

WriteLog(Message) {
    if (Logging) {
        currentTime := FormatTime(A_Now, "HH:mm:ss")
        FileAppend(currentTime ": " Message "`n", ServiceLogFile)
    }
}

ExitHandler(*) {
    SF.SetMailRead()
    WriteLog("Client Exit!")
}

