; TITLE: AhkRunCmdService v0.1
/*
  TODO:
    fix icon (does it need one?)
    accept a message array with many parameters?

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

    ; Wait forever until Client sends data
    ;ready := SF.WaitUnLock("Client", -1)
    ready := SF.Wait("Client", -1)
    ;wait CLIENT
    if (!ready) {
        MsgBox "Timeout waiting for Client`n`nPress OK to exit.", "SERVICE", "iconi"
        SetTimer , 0
    }

    ; Read the message from a shared file
    message:= SF.Read()
    ;message:= SF.Read(Received:="Client")

    ; Reset the lock
    ;SF.Lock("Client")
    ;SF.ReceivedFrom("Client")
    SF.ReceivedFrom()
    ;received CLIENT

    ; Form Server response message
    if (message = "STATUS")
        response:= "OK"
    else 
        response:= "ACK: " message

    ; Write to shared file
    SF.Write(response) 
    ;SF.Write(response, Sent:="Server")

    ; Signal Client message is ready
    ;SF.UnLock("Server")
    SF.SentFrom("Server")

    ; Log the message
    WriteLog("Service Command: " message)

    ; if terminate then exit
    if (message = "TERMINATE") {
        SetTimer , 0
        return
    }

    ; if status requested, reply OK
    if (message = "STATUS") {
        SF.Write("OK")
        SF.SentFrom("Server")
        ;SF.Ready Server
        WriteLog("Service Status: OK")
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
    SF.SentFrom("Server")

    WriteLog("Service Response: ACK: " Output)

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