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

global Logging:= true
global ServiceLogFile:= "D:\ServiceLog.txt"

global SF := SharedFile("Server")

OnExit(ExitHandler)

; Enable the Service to WaitRead()
SF.SetWrite()

WriteLog("Service Start!")

; Server will loop until Timer is reset
SetTimer(CheckMessages, 1000) ; default 250ms

CheckMessages() {

    ;WriteLog("DEBUG Service CheckMessages, IsAcquired (SB TRUE): " state:=SF.IsAcquired()?"TRUE":"FALSE")
    WriteLog("DEBUG Service WaitRead")

    ; Wait forever until the Client writes a cmd to the SharedFile
    success := SF.WaitRead(-1)
    ;Sleep 1000

    ;WriteLog("Service Acquired Mutex")

    ;WriteLog("DEBUG Service Acquired Mutex, GetMutexAttributes): " SF.GetMutexAttributes())

    if (!success) {
        MsgBox "Timeout waiting for Client to Write a Command.`n`nPress OK to exit.", "SERVICE", "iconX"
        SetTimer , 0
        ExitApp()
    }

    WriteLog("DEBUG Service Read")

    ; Read the command from the SharedFile
    command:= SF.Read()

    ; Log the command
    if (Logging)
        WriteLog("Service Command: [" command "]")

    WriteLog("DEBUG Service SetWrite")

    ; Signal Client to write a command
    SF.SetWrite()

    ;msgCSV:= ConvertToCSV(command)
    msgCSV:= command

    ;WriteLog("Service Run Command: [" msgCSV "]")

    ; Includes both StdOut and StdErr in the Output
    RunCMD.SetOutput("StdOutStdErr")

    WriteLog("DEBUG Service RunCMD")

    ; Run the command and capture Output
    Output := RunCMD.CSV(msgCSV)

    WriteLog("DEBUG Service ACK")

    ; Share the Output with the Client
    SF.Write("ACK: [" Output "]")

    WriteLog("DEBUG Service SetRead")

    ; Signal Client to read the Output
    SF.SetRead()

    WriteLog("DEBUG Service WaitWrite")

    ; Wait for Client to Read the Output
    success := SF.WaitWrite(5000)

    if (!success) {
        MsgBox "Timeout waiting for Client to Read the Output.`n`nPress OK to exit.", "SERVICE", "iconX"
        SetTimer , 0
        ExitApp()
    }

}

; Convert string and number variables into a CSV string
WriteLog(command) {
    if (Logging) {
        currentTime := FormatTime(A_Now, "HH:mm:ss")
        FileAppend(currentTime ": " command "`n", ServiceLogFile)
    }
}

; the SharedFile Class Destructor will delete the shared file
ExitHandler(*) {
    WriteLog("Service Exit!")
}