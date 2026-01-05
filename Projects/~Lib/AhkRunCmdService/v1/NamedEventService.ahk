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
#Include <SharedRegistry>

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

OnExit(AhkRunCmdServiceExit)

global Logging:= true
global ServiceLogFile:= "D:\ServerLog.txt"

global reg := SharedRegistry("AhkRunCmd", "Message")

; Create and open named events for synchronization
global CLIENT_DATA_READY := "CLIENT_DATA_READY"
global SERVER_DATA_READY := "SERVER_DATA_READY"

global hEventCLIENT_DATA_READY := reg.CreateEvent(CLIENT_DATA_READY)
global hEventSERVER_DATA_READY := reg.CreateEvent(SERVER_DATA_READY)

WriteLog("Service start!")

; Server will loop until Timer is reset
SetTimer(CheckMessages, 1000) ; default 250ms

CheckMessages() {

    Loop {

        ; Wait until Client sends data
        reg.WaitEvent(CLIENT_DATA_READY, -1)
        reg.ResetEvent(CLIENT_DATA_READY)

        ; Read the string from shared memory
        msgClient := reg.Read()

        WriteLog("Service Command: " msgClient)

        ; if valid cmd then RunCmd(cmd)
        if (msgClient = "TERMINATE")
            AhkRunCmdServiceExit()

        ; if status requested, reply OK
        if (msgClient = "STATUS") {
            reg.Write("OK")
            reg.SetEvent(SERVER_DATA_READY)

            WriteLog("Service Status: OK")

            continue
        }

        ; if valid cmd then RunCMD.CSV(CommandCSV)
        RunCMD.SetOutput("StdOutStdErr")

        ; includes both StdOut and StdErr
        Output := RunCMD.CSV(msgClient)
        Output := Trim(msgClient)
        Output := StrReplace(Output, "`n", "")

        WriteLog("Service Output Len: " StrLen(Output))
        WriteLog("Service Output: [" Output "]")

        ; Form Server response message
        msgServer := "ACK" ;:`n" Output

        ; Write to shared memory
        reg.Write(msgServer)

        ; Inform Client that data is ready
        reg.SetEvent(SERVER_DATA_READY)    

        WriteLog("Service Response: ACK")

    }

}

WriteLog(Message) {
    if (Logging) {
        currentTime := FormatTime(A_Now, "HH:mm:ss")
        FileAppend(currentTime ": " Message "`n", ServiceLogFile)
    }
}

AhkRunCmdServiceExit(*) {
    global mem
    global hEventCLIENT_DATA_READY
    global hEventSERVER_DATA_READY
    mem:=""
    hEventCLIENT_DATA_READY := ""
    hEventSERVER_DATA_READY := ""
    ExitApp()
}