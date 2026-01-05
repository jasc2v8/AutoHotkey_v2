
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

TimerInterval := 1000

LogFile := "D:\NSSM\serviceLog.txt"

DoWork() {
    CurrentTime := FormatTime(,"HH:mm:ss")
    FileAppend(CurrentTime "`n", LogFile)
}

SetTimer DoWork, TimerInterval

Loop {
    Sleep 250
}