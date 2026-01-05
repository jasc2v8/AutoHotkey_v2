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

global Looping := true

; Mutex is set to "Acquired" upon start
global SF := SharedFile("Client")

SF.ReleaseMutex(0)

defaultText:= "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST"

OnExit(ExitHandler)

WriteLog("Client Start!")

While Looping {

    ; Wait until Server Releases the Mutex.
    ; This is an extended wait until Server completes RunCMD
    ;acquired := SF.AcquireMutex(-1)

WriteLog("DEBUG Client Start Before, IsAcquired (SB FALSE): " state:=SF.IsAcquired()?"TRUE":"FALSE")

    acquired := SF.AcquireMutex(-1)

WriteLog("DEBUG Client Start After, IsAcquired (SB TRUE): " state:=SF.IsAcquired()?"TRUE":"FALSE")


Sleep 1000

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
        SF.Write("TERMINATE")
        SF.ReleaseMutex(0)

 
Sleep 1000

    WriteLog("DEBUG Client TERMINATE, IsReleased (SB TRUE): " state:=SF.IsReleased()?"TRUE":"FALSE")

        break

    } else if (IB.Value = "Exit") OR (IB.Result = "Cancel") {
        ExitApp()
    }
    
    ;msgClientCSV:= reg.ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)
    msgCSV:= IB.Value

    ; Write message into shared memory.
    ; Service will Output:=RunCMD.CSV(message) and write Output.txt
    SF.Write(msgCSV)

    ; Release the Mutex and Wait until Server Acquires the Mutex 
    released := SF.ReleaseMutex(10000)

    WriteLog("DEBUG Client ReleaseMutex, IsReleased (SB TRUE): " state:=SF.IsReleased()?"TRUE":"FALSE")

    
Sleep 1000

    if (!released) {
        MsgBox "Timeout waiting for Service to Acquire Mutex.`n`nPress OK to exit.", "CLIENT", "iconX"
        ExitApp()
    }

; WriteLog("Client write message and set GREEN")

    ;Sleep 200 ; short delay here?

    ; Wait until Server sends response


;    WriteLog("TO SERVICE  : [" msgCSV "]")
;    WriteLog("FROM SERVICE: [" response "]")

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
    if IsSet(SF)
        SF.AcquireMutex(0)
    WriteLog("Client Exit!")
}

