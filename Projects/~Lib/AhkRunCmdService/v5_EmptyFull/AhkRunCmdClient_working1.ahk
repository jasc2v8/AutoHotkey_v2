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
#Include <SharedFile>

global Logging := true
global ServiceLogFile := "D:\ServiceLog.txt"

global SyncBackPath := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackAction := "" ; "", "-shutdown", "-standby"
;global SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
global SyncBackProfile := "TEST"

global defaultText:= "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST"

; Mutex is set to "Acquired" upon start
global SF := SharedFile("Client")

OnExit(ExitHandler)

; have the Server waith until a command is sent
;SF.SetEmpty()

WriteLog("Client Start!")

Loop {

;WriteLog("DEBUG Client Start Before, IsAcquired (SB FALSE): " state:=SF.IsAcquired()?"TRUE":"FALSE")

    ; Wait for Client to send a command
    ;isFull := SF.WaitFull(-1)

;WriteLog("DEBUG Client Start After, IsAcquired (SB TRUE): " state:=SF.IsAcquired()?"TRUE":"FALSE")


;Sleep 1000

    ; if (!acquired) {

    ;  WriteLog("Timeout waiting for Server to Release Mutex.")

    ;     MsgBox "Timeout waiting for Server to Release Mutex`n`nPress OK to exit.", "CLIENT", "iconX"
    ;     ExitApp()
    ; }

    if (DirExist("D:\Docs_Backup"))
        DirDelete("D:\Docs_Backup", Recurse:=1)

    IB := InputBox("Enter CSV Command:", "Service Control",,defaultText)

 ;MsgBox "IB.Value: " IB.Value "`n`nIB.Result: " IB.Result, "IB.ValueResult"

    if (IB.Value = "TERMINATE") {
        WriteLog("DEBUG Client TERMINATE") ;, IsReleased (SB TRUE): " state:=SF.IsReleased()?"TRUE":"FALSE")
        SF.Write("TERMINATE") ; SetFull()
        Sleep 5000
        break

    } else if (IB.Value = "Exit") OR (IB.Result = "Cancel") {
        WriteLog("DEBUG Client EXIT")    ; , IsReleased (SB TRUE): " state:=SF.IsReleased()?"TRUE":"FALSE")
        SF.SetEmpty()
        ExitApp()
    }
    
    ;msgClientCSV:= reg.ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)
    cmdCSV:= IB.Value

    ; Write message into shared memory.
    ; Service will Output:=RunCMD.CSV(message) and write Output.txt
    SF.Write(cmdCSV) ; SetFull()

    ; Wait for Server to read cmd
    isEmpty:= SF.WaitEmpty(-1)

    if (!isEmpty) {
        MsgBox "Timeout waiting for Service to Read Command.`n`nPress OK to exit.", "CLIENT", "iconX"
        WriteLog("DEBUG Client Timeout waiting for Service to Read Command, EXIT")
        ExitApp()
    }

    ; Wait for Server to Write(Output)
    ; isFull:= SF.WaitFull(-1)

    ; if (!isFull) {
    ;     MsgBox "Timeout waiting for Service to Write(Output).`n`nPress OK to exit.", "CLIENT", "iconX"
    ;     WriteLog("DEBUG Client Timeout waiting for Service to Write(Output), EXIT")
    ;     ExitApp()
    ; }

    ; Read the Service Output
    ; Output:= SF.Read() ; SetEmpty()

    ; Output := Trim(Output)
    ; Output := StrReplace(Output, "`n", "")
    ; Output := "DEBUG: " Output
    
    ;WriteLog("DEBUG Client Read(Output): " Output)



    ;WriteLog("DEBUG Client ReleaseMutex, IsReleased (SB TRUE): " state:=SF.IsReleased()?"TRUE":"FALSE")

    ; WriteLog("Client write message and set GREEN")

    ;Sleep 200 ; short delay here?

    ; Wait until Server sends response


    ; WriteLog("CLIENT: TO SERVICE  : [" cmdCSV "]")
    ; WriteLog("CLIENT: FROM SERVICE: [" Output "]")

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
    SF.SetEmpty()
    WriteLog("Client Exit!")
}

