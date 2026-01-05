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
#Include <SharedRegistry>

; #region Admin Check

; SyncBack requires Administrator privileges

; if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\\ S)"))
; {
;     try
;     {
;         if A_IsCompiled
;             Run '*RunAs "' A_ScriptFullPath '" /restart'
;         else
;             Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
;     }
;     ExitApp  ; Exit the current, non-elevated instance
; }

;OnExit(AhkRunCmdControlExit)

global Logging := true
global ServiceLogFile := "D:\ServerLog.txt"

global reg := SharedRegistry("AhkRunCmd", "Message")

; Create and open named events for synchronization
global CLIENT_DATA_READY := "CLIENT_DATA_READY"
global SERVER_DATA_READY := "SERVER_DATA_READY"


global hEventCLIENT_DATA_READY := reg.CreateEvent(CLIENT_DATA_READY, true, true)
global hEventSERVER_DATA_READY := reg.CreateEvent(SERVER_DATA_READY, true, true)

;global hEventCLIENT_DATA_READY := reg.OpenEvent(CLIENT_DATA_READY)
;global hEventSERVER_DATA_READY := reg.OpenEvent(SERVER_DATA_READY)

;        MsgBox hEventCLIENT_DATA_READY ", " hEventSERVER_DATA_READY, "WaitEvent"
;FileAppend(FormatTime(A_Now, "HH:mm:ss") ": FROM CLIENT: hEventCLIENT_DATA_READY : [" hEventCLIENT_DATA_READY "]`n", ServiceLogFile)
;FileAppend(FormatTime(A_Now, "HH:mm:ss") ": FROM CLIENT: hEventSERVER_DATA_READY : [" hEventSERVER_DATA_READY "]`n", ServiceLogFile)


; if FileExist(ServiceLogFile)
;     FileDelete(ServiceLogFile)

; if DirExist("D:\Docs_Backup")
;     DirDelete("D:\Docs_Backup", Recurse:=1)

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

    msgClientCSV:= IB.Value

    if (IB.Value = "TERMINATE") {
        reg.Write("TERMINATE")
        reg.SetEvent(CLIENT_DATA_READY)
        continue
        ;break ; DEBUG - uncomment to allow the server to run

    } else if (IB.Value = "Exit") OR (IB.Result = "Cancel"){
        ExitApp()
    }
    
;msgClientCSV:= "TERMINATE"d

    ; Check if server is still alive
    reg.Write("STATUS")

    ; Signal the event so server knows data is ready
    reg.SetEvent(CLIENT_DATA_READY)

    ; Wait until Server sends response
    ; -1 means wait forever
    serviceAvailable := reg.WaitEvent(SERVER_DATA_READY, 10000)

    reg.ResetEvent(SERVER_DATA_READY)

;MsgBox serviceAvailable, "serviceAvailable"

;serviceAvailable:=0

    ; WAIT_TIMEOUT=0x0000010 (decimal 258), WAIT_FAILED=-1
    if (serviceAvailable = 0x00000102) {
        MsgBox "Service  not Available`n`nPress OK to exit.", "NO RESPONSE", "iconi"
        continue
    } else if (serviceAvailable != 0) {
        MsgBox "WaitEvent failed.`n`nPress OK to exit.", "ERROR", "iconX"
        continue
    }

;debug
    ;msgClientCSV:= reg.ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)

    ; Write a message into shared memory
    reg.Write(msgClientCSV)

    ; Signal the event so server knows data is ready
    reg.SetEvent(CLIENT_DATA_READY)

;debug
;oops, the server doesn't respond until syncback is finished!!!

    ; Wait until Server sends response
    ; -1 means wait forever
    serviceAvailable := reg.WaitEvent(SERVER_DATA_READY, 5000)

    Sleep 500

    FileAppend(FormatTime(A_Now, "HH:mm:ss") ": serviceAvailable : [" serviceAvailable "]`n", ServiceLogFile)

    reg.ResetEvent(SERVER_DATA_READY)
    
    ; Read the Server response from shared memory
    msgService := reg.Read()

; Terminate Server
;reg.Write("TERMINATE")

    ;MsgBox "RESPONSE FROM CLIENT:`n`n" msgClientCSV

    msg := Trim(msgService)
    ;MsgBox "RESPONSE FROM SERVICE:`n`n" msg "`n`nLen: " StrLen(msg), "CLIENT"

    currentTime := FormatTime(A_Now, "HH:mm:ss")
    FileAppend( currentTime ": TO SERVICE : [" msgClientCSV "]`n", ServiceLogFile)
    FileAppend( currentTime ": FROM SERVER: [" msgService "]`n", ServiceLogFile)
    ;FileAppend( A_Index ": FROM SERVICE: [" msgService "]`n", ServiceLogFile")

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

