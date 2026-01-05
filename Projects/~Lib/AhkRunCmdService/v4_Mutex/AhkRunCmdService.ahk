; TITLE: AhkRunCmdService v0.3 - Change to Red/Green Sync
/*
  TODO:
    fix icon (does it need one?)

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunCMD>
#Include <SharedFile>

;@Ahk2Exe-ConsoleApp

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Ahk RunCMD Service
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, AhkRunCmdService
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, AhkRunCmdService.exe
;@Ahk2Exe-Set ProductName, AhkRunCmdService
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon ..\..\Icons\under-construction.ico

;@Inno-Set AppId, {{83BEBE1D-34CD-4ACC-BE79-B0CC93983818}}
;@Inno-Set AppPublisher, jasc2v8

OnExit(ExitHandler)

global Logging:= true
global ServiceLogFile:= "D:\ServiceLog.txt"

global SF := SharedFile("Server")

global OutputFilePath:= SF.GetFilePath("Output")

SF.AcquireMutex(0)

WriteLog("Service Start!")

; Server will loop until Timer is reset
SetTimer(CheckMessages, 250) ; default 250ms

CheckMessages() {

WriteLog("DEBUG Service CheckMessages, IsAcquired (SB TRUE): " state:=SF.IsAcquired()?"TRUE":"FALSE")

WriteLog("DEBUG Service CheckMessages, GetMutexAttributes): " SF.GetMutexAttributes())

    ; Wait forever until Client Releases the Mutex, then Acquire it
    acquired := SF.AcquireMutex(-1)

Sleep 1000

WriteLog("Service Acquired Mutex")

WriteLog("DEBUG Service Acquired Mutex, GetMutexAttributes): " SF.GetMutexAttributes())

    if (!acquired) {
        MsgBox "Timeout waiting for Client to Release Mutex`n`nPress OK to exit.", "SERVICE", "iconX"
        SetTimer , 0
        ExitApp()
    }

    ; Read the message from the shared file
    message:= SF.Read()

    ; Log the message
    WriteLog("Service Command: [" message "]")

    ; if terminate then exit
    if (message = "TERMINATE") {
        SetTimer , 0
        WriteLog("Service TERMINATED!")
        return
    }

    ;msgCSV:= ConvertToCSV(message)
    msgCSV:= message

    WriteLog("Service Run Command: [" message "]")

    ; Includes both StdOut and StdErr in the Output
    RunCMD.SetOutput("StdOutStdErr")

    ; Run the command and capture Output
    Output := RunCMD.CSV(msgCSV)
    Output := Trim(Output)
    Output := StrReplace(Output, "`n", "")
    Output := "DEBUG: " Output

    ; if (output) write to output file
    If FileExist(OutputFilePath)
        FileDelete(OutputFilePath)
    FileAppend(Output, OutputFilePath)

    WriteLog("Service Output Len: " StrLen(Output))
    WriteLog("Service Output    : [" Output "]")

    WriteLog("DEBUG Service ReleaseMutex Before, IsReleased (SB FALSE): " state:=SF.IsReleased()?"TRUE":"FALSE")

    ; Release then Wait until Client Acquires the Mutex
    released := SF.ReleaseMutex(5000)
    ; no released := SF.ReleaseMutex(0)
    
Sleep 1000

    WriteLog("DEBUG Service ReleaseMutex After, IsReleased (SB TRUE): " state:=SF.IsReleased()?"TRUE":"FALSE")

    if (!released) {
        WriteLog("Timeout waiting for Client to Acquire Mutex. Resuming...")
        ; Client may have exited so Acquire the Mutex and wait until Client is restarted
        SF.AcquireMutex(0)

        WriteLog("DEBUG Service !released, IsAcquired (SB TRUE): " state:=SF.IsAcquired()?"TRUE":"FALSE")

    ; WriteLog("Timeout waiting for Client to Acquire Mutex.")

    ;     MsgBox "Timeout waiting for Client to Acquire Mutex.`n`nPress OK to exit.", "SERVICE", "iconX"
    ;     SetTimer , 0
    ;     ExitApp()
    }

    ;WriteLog("Service Released Mutex")

    ;Sleep 10 ; short delay here?

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

ExitHandler(*) {
    if FileExist(OutputFilePath)
        FileDelete(OutputFilePath)
    WriteLog("Service Exit!")
}