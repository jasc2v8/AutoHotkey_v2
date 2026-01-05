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

    msgCSV:= IB.Value

    if (IB.Value = "TERMINATE") {
        SF.Write("TERMINATE")
        SF.UnLock("Client")
        break

    } else if (IB.Value = "Exit") OR (IB.Result = "Cancel") {
        break
    }
    
;msgClientCSV:= "TERMINATE"d

    ; Check if server is still alive
    SF.Write("STATUS")
    SF.UnLock("Server")

    ; Wait until Server sends response
    ; -1 means wait forever
    serviceAvailable := SF.WaitUnLock("Server", 10000)

    SF.Lock("Server")

;MsgBox serviceAvailable, "serviceAvailable"

;serviceAvailable:=0

    if (!serviceAvailable) {
        MsgBox "Service not Available.`n`nPress OK to exit.", "NO RESPONSE", "iconi"
        break
    } 

;debug
    ;msgClientCSV:= reg.ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)
    msgCSV:= IB.Value
    ; Write message into shared memory
    SF.Write(msgCSV)
    SF.UnLock("Client")

    ;SF.SetMessageReady("Client")?
    ;SF.SetReady("Client")?

    ; Wait until Server sends response
    serviceAvailable := SF.WaitUnLock("Server", 10000)

    if (!serviceAvailable) {
        MsgBox "Service not Available.`n`nPress OK to exit.", "NO RESPONSE", "iconi"
        break
    }

    ;Sleep 500

    WriteLog("serviceAvailable : [" serviceAvailable "]")

    ; Read the Server response from shared memory
    response := SF.Read()
    SF.Lock("Server")

    ;SF.ResetMessageReady("Server")?
    ;SF.ResetReady("Server")?
    
; Terminate Server
;reg.Write("TERMINATE")

    ;MsgBox "RESPONSE FROM CLIENT:`n`n" msgClientCSV

    ;msg := Trim(msgService)
    ;MsgBox "RESPONSE FROM SERVICE:`n`n" msg "`n`nLen: " StrLen(msg), "CLIENT"

    WriteLog("TO SERVICE  : [" msgCSV "]")
    WriteLog("FROM SERVICE: [" response "]")

}

; if we allow the Server to continue running,
; then Reset the event so the Server will wait for Client data
; THE SERVER HAS ALREADY RESET THIS.
;reg.ResetEvent(CLIENT_DATA_READY)
    
; Terminate Client
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


;   # region Debug

Send_Debug() {

    if FileExist("D:\Docs_Backup")
        DirDelete("D:\Docs_Backup", Recurse:=1)

    exe:= "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
    p1 := "" ; -standby, -shutdown
    p2 := "TEST"
    messageCSV := RunCMD.ConvertToCSV(exe, p2)

        ; RunCMD.SetOutput("StdOutStdErr")
        ; Output := RunCMD.CSV(messageCSV)

        ; ; Form Server response message
        ; MsgBox "ACK:`n" Output, "DEBUG"

    ; SyncBackPath := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
    ; SyncBackAction := "" ; "", "-shutdown", "-standby"
    ; ;SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
    ; SyncBackProfile := "TEST"

    ; form the message
    ;message := SyncBackPath ", " SyncBackAction ", " SyncBackProfile
    ;messageCSV := message := ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)

    ; ExeFile:= "D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\StdOutArgs.exe"
    ; P1:= "one two"
    ; P2:= ""
    ; ;P3:= 3.14
    ; P3:= " > D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\StdOutArgs.txt"

    ;StdOut:
    ; Arg 1: ,one
    ; Arg 2: two,,

    ; ExeFile := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
    ; P1 := "" ; "", "-shutdown", "-standby"
    ; ;SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
    ; P2 := "TEST"
    ; P3 := ""
    
    ;messageCSV := ConvertToCSV(ExeFile, P1, P2, P3)
    ;messageCSV := ConvertToCSV(ExeFile, P2)
    ;messageCSV := "notepad.exe, p1, p2"

    ;message := ConvertToCSV("echo TEST")
    ;message := "echo TEST"
    ;message := ""

    ;MsgBox messageCSV ', ' IsStringArray(messageCSV), "messageCSV"

;ExitApp

    return messageCSV
}

WriteLog(Message) {
    if (Logging) {
        currentTime := FormatTime(A_Now, "HH:mm:ss")
        FileAppend(currentTime ": " Message "`n", ServiceLogFile)
    }
}


