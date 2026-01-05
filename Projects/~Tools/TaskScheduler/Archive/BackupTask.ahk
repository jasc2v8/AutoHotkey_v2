; TITLE: AhkRunCmdService v0.3 - Change to Red/Green Sync
/*
  TODO:
    fix icon (does it need one?)

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunCMD>

; no ;@Ahk2Exe-ConsoleApp

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Run SyncBack
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, BackupTask
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, BackupTask.exe
;@Ahk2Exe-Set ProductName, BackupTask
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon ..\..\Icons\under-construction.ico

;@Inno-Set AppId, {{B7311B9B-1E22-411B-AE2A-55179D8A70B8}}
;@Inno-Set AppPublisher, jasc2v8

global Logging:= true
global LogFile:= "D:\BackupTaskLog.txt"

global SyncBackPath := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackAction := "" ; "", "-shutdown", "-standby"
;global SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
global SyncBackProfile := "TEST"

; run standalone, Syncback will UAC for Admin

; full_command_line := DllCall("GetCommandLine", "str")

; if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\\ S)"))
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


OnExit(ExitHandler)

if (Logging)
    WriteLog("Task Start!")

if DirExist("D:\Docs_Backup")
   DirDelete("D:\Docs_Backup", Recurse:=1)

RunCMD.SetOutput("StdOutStdErr")

cmd:= ConvertToCSV(SyncBackPath, SyncBackAction, SyncBackProfile)

Output := RunCMD.CSV(cmd)

Output := Trim(Output)
Output := StrReplace(Output, "`n", "")

WriteLog("StrLen Output: " StrLen(Output))
WriteLog("Output    : [" Output "]")

;if (Logging)
;    WriteLog(Output) 


ConvertToCSV(Params*) {
    myString:= ""
    for item in Params {
        if IsSet(item)
            myString .= item . ","
    }
    return RTrim(myString, ",")
}

; Convert string and number variables into a CSV string
WriteLog(command) {
    if (Logging) {
        currentTime := FormatTime(A_Now, "HH:mm:ss")
        FileAppend(currentTime ": " command "`n", LogFile)
    }
}

; the SharedFile Class Destructor will delete the shared file
ExitHandler(*) {
    if (Logging)
        WriteLog("Task Exit!")
}