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
#Include <SharedMemory>
; #region Admin Check

; SyncBack requires Administrator privileges
full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\\ S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp  ; Exit the current, non-elevated instance
}

OnExit(AhkRunCmdControlExit)

name := "Global\AhkRunCmdServiceSharedMemory"
size := 1024
mem := SharedMemory(name, size)

; BufferEmpty:= "BufferEmpty"
; BufferFull := "BufferFull"

; Create and open named events for synchronization
CLIENT_DATA_READY := "CLIENT_DATA_READY"
SERVER_DATA_READY := "SERVER_DATA_READY"

hEventCLIENT_DATA_READY := mem.CreateEvent(CLIENT_DATA_READY)
hEventSERVER_DATA_READY := mem.CreateEvent(SERVER_DATA_READY)

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

; start at a known state with events reset
mem.ResetEvent(SERVER_DATA_READY)
mem.ResetEvent(CLIENT_DATA_READY)

global Looping := true

defaultText:= "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST"

While Looping {

    if (DirExist("D:\Docs_Backup"))
        DirDelete("D:\Docs_Backup", Recurse:=1)

    IB := InputBox("Enter CSV Command:", "Service Control",,defaultText)

; MsgBox "IB.Value: " IB.Value "`n`nIB.Result: " IB.Result, "IB.ValueResult"

    msgClientCSV:= IB.Value
 
    if (IB.Value = "TERMINATE") {
        mem.Write("TERMINATE")
        mem.SetEvent(CLIENT_DATA_READY)
        continue
        ;break ; DEBUG - uncomment to allow the server to run

    } else if (IB.Value = "Exit") OR (IB.Result = "Cancel"){
        ExitApp()
    }
    
;msgClientCSV:= "TERMINATE"d

    ; Check if server is still alive
    mem.Write("STATUS")

    ; Signal the event so server knows data is ready
    mem.SetEvent(CLIENT_DATA_READY)

;debug
;oops, the server doesn't respond until syncback is finished!!!

    ; Wait until Server sends response
    ; -1 means wait forever
    serviceAvailable := mem.WaitEvent(SERVER_DATA_READY, 5000)

    mem.ResetEvent(SERVER_DATA_READY)

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

    ; Write a message into shared memory
    mem.Write(msgClientCSV)

    ; Signal the event so server knows data is ready
    mem.SetEvent(CLIENT_DATA_READY)

;debug
;oops, the server doesn't respond until syncback is finished!!!

    ; Wait until Server sends response
    ; -1 means wait forever
    serviceAvailable := mem.WaitEvent(SERVER_DATA_READY, -1)

    mem.ResetEvent(SERVER_DATA_READY)
    
    ; Read the Server response from shared memory
    msgService := mem.Read()

; Terminate Server
;mem.Write("TERMINATE")

    msg := Trim(msgService)
    MsgBox "RESPONSE FROM SERVICE:`n`n" msg "`n`nLen: " StrLen(msg), "CLIENT"

    currentTime := FormatTime(A_Now, "HH:mm:ss")
    FileAppend( currentTime ": TO SERVICE : [" msgClientCSV "]`n", A_ScriptDir "\ServerLog.txt")
    FileAppend( currentTime ": FROM SERVER: [" msgService "]`n", A_ScriptDir "\ServerLog.txt")
    ;FileAppend( A_Index ": FROM SERVICE: [" msgService "]`n", A_ScriptDir "\ServerLog.txt")

}

; if we allow the Server to continue running,
; then Reset the event so the Server will wait for Client data
; THE SERVER HAS ALREADY RESET THIS.
;mem.ResetEvent(CLIENT_DATA_READY)
    
; Terminate Client
ExitApp()

;   # region Functions

AhkRunCmdControlExit(*) {
    global mem
    global hEventCLIENT_DATA_READY
    global hEventSERVER_DATA_READY
    mem.ResetEvent(SERVER_DATA_READY)
    mem.ResetEvent(CLIENT_DATA_READY)
    mem:=""
    hEventCLIENT_DATA_READY := ""
    hEventSERVER_DATA_READY := ""
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

