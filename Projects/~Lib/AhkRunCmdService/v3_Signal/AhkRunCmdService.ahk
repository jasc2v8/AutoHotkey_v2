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
global SENDER:="Client"
global RECEIVER:="Server"

global SF := SharedFile("Server")

WriteLog("Service start!")

; Server will loop until Timer is reset
SetTimer(CheckMessages, 250) ; default 250ms

CheckMessages() {

    ; Wait forever until Client writes a message
    ready := SF.WaitGreen(-1)

WriteLog("Service GREEN")

    SF.SetRed() ; stop client access

WriteLog("Service SetRed")

    if (!ready) {
        MsgBox "Timeout waiting for Client`n`nPress OK to exit.", "SERVICE", "iconi"
        SetTimer , 0
        ExitApp()
    }


    ; Read the message from the shared file
    message:= SF.Read()
    SF.SetRed() ; stop client access

    ; Log the message
    WriteLog("Service Command: " message)

    ; if terminate then exit
    if (message = "TERMINATE") {
        SetTimer , 0
        WriteLog("Service TERMINATED!")
        return
    }

    ; RunCMD.CSV(CommandCSV)
    RunCMD.SetOutput("StdOutStdErr")

    ; includes both StdOut and StdErr
    Output := RunCMD.CSV(message)
    Output := Trim(message)
    Output := StrReplace(Output, "`n", "")

    WriteLog("Service Output Len: " StrLen(Output))
    WriteLog("Service Output    : [" Output "]")

    ; Write Server response message
    SF.Write("ACK: " Output)

    WriteLog("Service Response: ACK: " Output)

    ; Signal Client message is ready
    SF.SetGreen()

    Sleep 10 ; short delay here?

}

WriteLog(Message) {
    if (Logging) {
        currentTime := FormatTime(A_Now, "HH:mm:ss")
        FileAppend(currentTime ": " Message "`n", ServiceLogFile)
    }
}

ExitHandler(*) {
    WriteLog("Service Exit!")
}