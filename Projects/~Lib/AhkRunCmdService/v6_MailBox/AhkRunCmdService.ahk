; TITLE: AhkRunCmdService v0.3 - Change to Red/Green Sync
/*
  TODO:
    fix icon (does it need one?)

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunCMD>
#Include <MailBox>

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
global SF := MailBox("Server")
global OutputFilePath:= SF.GetFilePath("Output")

OnExit(ExitHandler)

; have the Server waith until a command is sent to it
SF.SetMailRead()

WriteLog("Service Start!")

; Server will loop until Timer is reset
SetTimer(CheckMail, 250) ; default 250ms

CheckMail() {

;WriteLog("DEBUG Service CheckMail, IsAcquired (SB TRUE): " state:=SF.IsAcquired()?"TRUE":"FALSE")

;WriteLog("DEBUG Service CheckMail, GetMutexAttributes): " SF.GetMutexAttributes())

    ; Wait forever until Client writes the cmd to the SharedBuffer
     ; success=true, timeout=false, don't wait=0Ms, wait forever=-1Ms
    receivedMail := SF.WaitNewMail(-1)

;Sleep 1000

;WriteLog("Service Acquired Mutex")

;WriteLog("DEBUG Service Acquired Mutex, GetMutexAttributes): " SF.GetMutexAttributes())

    if (!receivedMail) {
        MsgBox "Timeout waiting for Client to SendMail.`n`nPress OK to exit.", "SERVICE", "iconX"
        SetTimer , 0
        ExitApp()
    }

    ; Read the command from the shared file and SetEmpty()
    command:= SF.ReadMail() ;SetMailRead

    ; Log the command
    if (Logging)
        WriteLog("Service Command: [" command "]")

    ;msgCSV:= ConvertToCSV(command)
    msgCSV:= command

    ;WriteLog("Service Run Command: [" msgCSV "]")

    ; Includes both StdOut and StdErr in the Output
    RunCMD.SetOutput("StdOutStdErr")

    ; Run the command and capture Output
    RunCMD.CSV(msgCSV)

    ; Share the Output with the Client and SetFull()
    ;SF.Write(Output) ; SetFull()

    ;WriteLog("Service Output Len: " StrLen(Output))
    ;WriteLog("Service Output    : [" Output "]")

    ;WriteLog("DEBUG Service ReleaseMutex Before, IsReleased (SB FALSE): " state:=SF.IsReleased()?"TRUE":"FALSE")

    ; Wait until Client Reads the Output
    ; isEmpty:= SF.WaitEmpty(5000)

    ; if (!isEmpty) {
    ;     ; Client may have exited so SetEmpty() and wait until Client is restarted
    ;     SF.SetEmpty()
    ;     WriteLog("Timeout waiting for Client to Read and SetEmpty(). Resuming...")
    ; }

    ;WriteLog("DEBUG Service ReleaseMutex After, IsReleased (SB TRUE): " state:=SF.IsReleased()?"TRUE":"FALSE")

}

; Convert string and number variables into a CSV string

WriteLog(command) {
    if (Logging) {
        currentTime := FormatTime(A_Now, "HH:mm:ss")
        FileAppend(currentTime ": " command "`n", ServiceLogFile)
    }
}

ExitHandler(*) {
    ; the SharedFile Class Destructor will delete the shared file
    WriteLog("Service Exit!")
}