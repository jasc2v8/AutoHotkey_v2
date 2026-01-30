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

#Include <IniHelper>
#Include <SharedFile>
#Include <RunHelper>

; #region Globals

global Logging := true

global LogFile          := "D:\Software\DEV\Work\AHK2\Projects\RestartFontCache\AhkRestartFontCache.log"

global SharedFilePath   := "D:\Software\DEV\Work\AHK2\Projects\RestartFontCache\SharedFile.txt"

global TASK_PATH        := "D:\Software\DEV\Work\AHK2\Projects\RestartFontCache\AhkRestartFontCacheTask.exe"

global INI_PROGRAM_PATH := EnvGet("PROGRAMDATA") "\AutoHotkey\AhkRunSkipUAC\AhkRunSkipUAC.ini"

global INI_PROGRAM      := IniHelper(INI_PROGRAM_PATH)

; #region Shared File

; The SharedFile will be created by the BackupControlTask Task when it is started
global SF := SharedFile("Client", SharedFilePath)

    MsgBox "Press OK to Restart Windows Font Cache.", "Icon?"

StartTask(TASK_PATH)

; Form the command to run
;command:= RunHelper.ConvertToCSV("sc", "stop",  "FontCache")
;command:= "C:\WINDOWS\System32\sc.exe, stop,  FontCache"
command:= "C:\WINDOWS\System32\sc.exe stop FontCache"

;command:= "sc stop FontCache"

    WriteLog("WaitWrite command to Server: " command)

timedOut := SF.WaitWrite(command)

if (timedOut)
    WriteLog("Timeout WaitWrite")

    WriteLog("Wait Read Response from Server")

response := SF.WaitRead()

if (response = "")
    WriteLog("Timeout WaitRead")

    WriteLog("response: [" response "]")

if (SubStr(response, 1, 3) != "ACK") {
    MsgBox("Server not responding.`n`nPress OK to exit.", "CLIENT")
    ExitApp()
}

ExitApp()

; Allow time to stop
Sleep 2000

command:= RunHelper.ConvertToCSV("sc", "start",  "FontCache")
;command:= "sc start FontCache"

WriteLog("WaitWrite command to Server: " command)

timedOut := SF.WaitWrite(command)

response := SF.WaitRead()

if (response = "")
    WriteLog("Timeout WaitRead")

WriteLog("response: [" response "]")

if (SubStr(response, 1, 3) != "ACK") {
    MsgBox("Server not responding.`n`nPress OK to exit.", "CLIENT")
    ExitApp()
}

; The Task will end itsself

WriteLog("Finished.")

MsgBox "Finished Restarting Windows Font Cache.", "Iconi"

IsRunning := false

ExitApp()

; #region Functions

SetTaskProgram(TASK_PATH) {
  programPath := INI_PROGRAM.ReadSettings("PROGRAM")
  if (programPath != TASK_PATH)
    INI_PROGRAM.WriteSettings("PROGRAM", TASK_PATH)
}

StartTask(TASK_PATH) {

  ; Set AhkRunSkipUAC.ini to run BackupControlTask
  SetTaskProgram(TASK_PATH)

  ; Start Task to read command from the Shared Memory
  command := RunHelper.ConvertToArray('schtasks.exe', "/run /tn", 'AhkRunSkipUAC')
  output  := RunHelper(command)

  WriteLog("Waiting for SharedFile.")

  timedOut:= WaitFileExist(SharedFilePath, 5000)

  if (timedOut) {
    MsgBox("Worker Task did not start.`n`nPress OK to exit.", "BackupControlTool")
    ExitApp()
  }

  WriteLog("Started Task: " RTrim(output, "`n"))
}


; 0=success, non-zero=failure
success := ServiceControl("stop", "FontCache")

if (!success) {
    MsgBox "Failed to stop FontCache.", "RestartFontCache", "IconX"
    ExitApp()
}

; Allow time to stop
Sleep 2000

; 0=success, non-zero=failure
success := ServiceControl("start", "FontCache")

if (!success) {
    MsgBox "Failed to start FontCache.", "RestartFontCache", "IconX"
    ExitApp()
}


; --- Service Control Wrapper ---
ServiceControl(action, serviceName) {
    ; action: "start", "stop", "query"
    ; serviceName: internal service name (not display name)

    ; Build command
    cmd := Format('sc {} "{}"', action, serviceName)

    ; Run and capture output
    shell := ComObject("WScript.Shell")
    exec  := shell.Exec(cmd)
    output := ""
    while !exec.StdOut.AtEndOfStream {
        output .= exec.StdOut.ReadLine() . "`n"
    }

    ; Return structured result
    return {
        Action: action,
        Service: serviceName,
        Output: output,
        ExitCode: exec.ExitCode
    }
}

WaitFileExist(FilePath, TimeoutMs:=-1)
{
      StartTime := A_TickCount
      EndTime := StartTime + TimeoutMs

      Loop {
          if FileExist(FilePath) {
              returnValue:= false
              break
          }

          if (TimeoutMs!=-1) and (A_TickCount >= EndTime) {
              returnValue:= true
              break
          }
          Sleep 100
      }

      return returnValue
}

WriteLog(Message) {
    global LogFile

    if (Logging) {
        currentTime := FormatTime(A_Now, "HH:mm:ss")
        FileAppend(currentTime ": " Message "`n", LogFile)
    }
}
