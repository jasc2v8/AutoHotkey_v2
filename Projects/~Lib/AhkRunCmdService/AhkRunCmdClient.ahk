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

#Include <SharedFile>

global Logging := true
global LogFile := "D:\ClientLog.txt"

global SyncBackPath := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackAction := "" ; "", "-shutdown", "-standby"
;global SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
global SyncBackProfile := "TEST"

;global defaultText:= "D:\Software\DEV\Work\AHK2\Projects\RunResolved\StdOutArgs.exe, TEST WITH SPACES"
global defaultText:= "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST WITH SPACES"

global SF := SharedFile("Client")

OnExit(ExitHandler)

; The Service will init SetWrite() and WaitRead() so Client can write a cmd to the Service

WriteLog("Client Start!")

Loop {

    IB := InputBox("Enter CSV Command:", "Service Control", , defaultText)

    if (IB.Value = "Exit") OR (IB.Result = "Cancel") {
        ; logged by ExitHandler WriteLog("Client Exit!")
        ExitApp()
    }
    
    ;msgClientCSV:= reg.ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)
    command:= IB.Value

    ; if (DirExist("D:\Docs_Backup"))
    ;     DirDelete("D:\Docs_Backup", Recurse:=1)

    ; Send a command to the Service
    SF.Write(command)

    ; Signal Service to read cmd
    SF.SetRead()

    ; Check TERMINATE
    if (command = "TERMINATE") {
        WriteLog("Client TERMINATED!")
        ExitApp()
    }
    
    ; Wait for Server to read cmd and SetWrite()
    success := SF.WaitWrite(5000)
    if (!success) {
        MsgBox "Timeout waiting for Service to Read cmd and SetWrite().`n`nPress OK to exit.", "CLIENT", "iconX"
        ExitApp()
    }


    ; wait for the Service to run the command and return the output
    success:= SF.WaitRead(-1)
    if (!success) {
        MsgBox "Timeout waiting for Service to Respond with it's Output.`n`nPress OK to exit.", "CLIENT", "iconX"
        ExitApp()
    }

    ; Read the output from the Service
    Output:= SF.Read()

    ; Log the Output
    Output := Trim(Output)
    Output := StrReplace(Output, "`n", "")
    WriteLog("DEBUG Client Read: " Output)

    ; Signal Service to Write
    SF.SetWrite()

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
        FileAppend(currentTime ": " Message "`n", LogFile)
    }
}

ExitHandler(*) {
    ;SF.SetWrite()
    WriteLog("Client Exit!")
}

