; TITLE:    RestartFontCache v1.0
; SOURCE:   jasc2v8 12/15/2025
; LICENSE:  The Unlicense, see https://unlicense.org

; TITLE:    A work-around for the Win11 issue of empty Sarch bar results
;           Intended to be on-demand Task scheduled in Task Scheduler with runLevel='highest'
;           Recommend to run at login until windows 11 gets fixed

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

; Requires Admin

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, RestartFontCache
;@Ahk2Exe-Set FileVersion, 1.0.0.0
;@Ahk2Exe-Set InternalName, Restart Font Cache Task
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, RestartFontCache.exe
;@Ahk2Exe-Set ProductName, RestartFontCache
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-SetMainIcon D:\Software\DEV\Work\AHK2\Projects\RestartFontCache\Cogs.ico

;@Inno-Set AppId, {{D27EC431-B8B5-4171-B68A-8B123DCD5BED}}
;@Inno-Set AppPublisher, jasc2v8

#Include <LogFile>
#Include <IniFile>
#Include <RunCMD>
#Include <RunTask>

; #region Globals

global Logging := true

global logger := LogFile("D:\RestartFontCache.log", "CONTROL")

global WorkerPath := "D:\Software\DEV\Work\AHK2\Projects\~Tools\RestartFontCache\RestartFontCacheTask.ahk"

;   #region Main

MsgBox "Press OK to Restart Windows Font Cache.", "Icon?"

;
; Write settings to IniFile
;

ini := IniFile("C:\ProgramData\AutoHotkey\RunSkipUAC\RunSkipUAC.ini")

    logger.Write("Writing to IniFile...")

ini.WriteSettings("PATH", WorkerPath)
ini.WriteSettings("REQUEST", "START")
ini.WriteSettings("REPLY", "NONE")

;
; Run AHK_RunSkipUAC => RunSkipUAC.ahk
;

    logger.Write("AHK_RunSkipUAC => RunSkipUAC.ahk")

task := RunTask("AHK_RunSkipUAC") ; Runs RunSkipUAC.ahk

    logger.Write("Wait for Worker to start...")

;
; Wait for Worker to start
;
DetectHiddenWindows true
SetTitleMatchMode 2 ; contains=default
;WinWait("RestartFontCacheTask")

;
; Wait for Worker to ACK
;
    logger.Write("Wait for Worker Reply...")

Loop {

    reply := ini.ReadSettings("REPLY")

    if (reply != "NONE")
        break

    logger.Write("Tick...")

    Sleep 1000

}


logger.Write("Worker Reply: " reply)

logger.Write("EXIT.")

