; TITLE:    SearchBarResetWorker v1.0.0.4
; SOURCE:   jasc2v8 12/15/2025
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  A work-around for the Win11 issue of empty Sarch bar
;           Intended to be on-demand Task scheduled in Task Scheduler with runLevel='highest'
;           Recommend to run at login until windows 11 gets fixed?

/*
    TODO:
*/
#Requires AutoHotkey 2.0+
#NoTrayIcon

#Include <LogFile>

logger:= LogFile("D:\AdminStartSearchBarReset.log", "WORKER", false)

logger.Write("Start AdminStartSearchBarReset")

ScriptPath := "D:\Software\DEV\Work\AHK2\Projects\~Tools\SearchBarReset\RebuildFontCache.ps1"
ExecuteScript(ScriptPath)

ScriptPath := "D:\Software\DEV\Work\AHK2\Projects\~Tools\SearchBarReset\RestartSearchHost.ps1"
ExecuteScript(ScriptPath)

ScriptPath := "D:\Software\DEV\Work\AHK2\Projects\~Tools\SearchBarReset\RestartShell.ps1"
ExecuteScript(ScriptPath)

logger.Write("Exit")

ExitApp()

ExecuteScript(ScriptPath) {

    p := ScriptPath

    if (p = "" || p = "No file selected...")
        return
    
    SplitPath(p,,, &ext)

    isBatch := (StrLower(ext) = "bat" || StrLower(ext) = "cmd")
    
    TempFile := A_Temp "\script_output.txt"
    
    try {
        if FileExist(TempFile)
            FileDelete(TempFile)
    }

    logger.Write("Running: " ScriptPath)

    ;EditPreview.Value := AsAdmin ? "--- RUNNING AS ADMIN ---" : "--- RUNNING ---"
    ;Prefix := AsAdmin ? "*RunAs " : ""
    Prefix := ""
    
    try {
        if (isBatch) {
            RunWait(Prefix 'cmd.exe /c "`"' p '`" > `"' TempFile '`" 2>&1"', , "Hide")
        } else {
            RunWait(Prefix 'cmd.exe /c powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' p '" > "' TempFile '" 2>&1', , "Hide")
        }
    
        Sleep(250)
        
        if FileExist(TempFile) {
            try FileDelete(TempFile)
        } else {
            logger.Write("No TempFile to delete!")
       }
    } catch Error as e {
        logger.Write("ERROR: " e.Message)

    }
}