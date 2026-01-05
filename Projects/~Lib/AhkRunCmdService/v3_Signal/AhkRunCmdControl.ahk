; TITLE: BackupControlTool v2.3, 
; 
/*
    TODO:
        SharedMemory("AhkRunCmdService")

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunCMD>
#Include <SharedFile>

global Logging := true
global ServiceLogFile := "D:\ServiceLog.txt"

global SF := SharedFile("Client")

global SyncBackPath := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackAction := "" ; "", "-shutdown", "-standby"
;global SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
global SyncBackProfile := "TEST"

; cmd:= reg.ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)

; MsgBox cmd

; Output := RunCMD.CSV(cmd)

; MsgBox Output

; ExitApp

; Client Generates a new command for Server to Execute
; Client writes data
; Client SetEvent CLIENT_DATA_READY
; 	Server WaitEvent CLIENT_DATA_READY   
; 	Server reads Client data.
; 	Server processes client data (Do Work e.g. RunCMD)
; 	Server writes response data.
; 	Server SetEvent SERVER_DATA_READY
; 	Server Loop
; Client WaitEvent SERVER_DATA_READY
; Client reads Server response data.
; Client processes Server data (Success/Fail)
; Client Exit

global Looping := true

defaultText:= "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST"

While Looping {

    if (DirExist("D:\Docs_Backup"))
        DirDelete("D:\Docs_Backup", Recurse:=1)

    IB := InputBox("Enter CSV Command:", "Service Control",,defaultText)

 ;MsgBox "IB.Value: " IB.Value "`n`nIB.Result: " IB.Result, "IB.ValueResult"

    if (IB.Value = "TERMINATE") {
        SF.Write("TERMINATE")
        SF.SetGreen()
        break

    } else if (IB.Value = "Exit") OR (IB.Result = "Cancel") {
        break
    }
    
    ;msgClientCSV:= reg.ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)
    msgCSV:= IB.Value

    ; Write message into shared memory
    ; TODO SHOULD EVERY WRITE AUTO SET GREEN?
    ; OR Write(message, SetGreen:=true)?
    SF.Write(msgCSV)
    SF.SetGreen()

 WriteLog("Client write message and set GREEN")

    Sleep 200 ; short delay here?

    ; Wait until Server sends response
    serviceAvailable := SF.WaitGreen(10000)

    SF.SetRed()

    if (!serviceAvailable) {
        MsgBox "Service not Available.`n`nPress OK to exit.", "NO RESPONSE", "iconi"
        WriteLog("Service not Available!")
        break
    }

    WriteLog("Client waited for GREEN and immedialtey set RED")

    response := "RESET"

    ; Read the Server response from shared memory
    response := SF.Read()

    WriteLog("Client read response and set RED")
    ; Client does NOT set GREEN for Service access until next cmd

    WriteLog("TO SERVICE  : [" msgCSV "]")
    WriteLog("FROM SERVICE: [" response "]")

}

ExitApp()

;   # region Functions

AhkRunCmdControlExit(*) {
    ; reg.ResetEvent(SERVER_DATA_READY)
    ; reg.ResetEvent(CLIENT_DATA_READY)
    ; reg:=""
    ; hEventCLIENT_DATA_READY := ""
    ; hEventSERVER_DATA_READY := ""
    ExitApp()
}

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


