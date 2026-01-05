#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

if ProcessExist("explorer.exe") {
        ProcessClose("explorer.exe")
        ; Give it a split second to fully close
        ProcessWaitClose("explorer.exe", 2)
    }
    Run("explorer.exe")