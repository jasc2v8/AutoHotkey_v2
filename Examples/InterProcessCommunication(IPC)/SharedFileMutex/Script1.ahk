; Script1.ahk
#Requires AutoHotkey v2.0
#Include MutexHelpers.ahk

logFile := A_ScriptDir "\SharedLog.txt"

Loop {
    hMutex := AcquireMutex("MySharedMutex")

    ; --- Critical section: write to log ---
    FileAppend "Script 1 wrote at " A_Now "`n", logFile
    ToolTip "Script 1 writing..."
    Sleep 2000
    ToolTip

    ReleaseMutex(hMutex)
    Sleep 1000
}