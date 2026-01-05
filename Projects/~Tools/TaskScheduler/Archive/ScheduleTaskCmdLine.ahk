; TITLE:    MyScript v0.0
; SOURCE:   AHKv2 mikeyww https://www.autohotkey.com/boards/viewtopic.php?f=82&t=134356&hilit=Scheduler.ahk&start=80
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

taskName  := 'AhkLogArgs'
app       := 'schtasks.exe'
;exe       := A_ProgramFiles '\Microsoft OneDrive\OneDrive.exe'
exe       := "D:\Software\DEV\Work\AHK2\Projects\ScheduleTask\LogArgs.exe"
arguments := '/background'
schedule  := 'ONCE'
startTime := '00:00'
params    := ' /create /tn "' taskName '" /tr "\"' exe '\" ' arguments '" /sc ' schedule ' /st ' startTime
RunWait app params,, 'Hide'
MsgBox 'Done!', 'Status', 'Iconi'