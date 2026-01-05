; TITLE:    MyScript v0.0
; SOURCE:   AHKv2 mikeyww https://www.autohotkey.com/boards/viewtopic.php?f=82&t=134356&hilit=Scheduler.ahk&start=80
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:S
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunCMD>

;schtasks /create tn <YourTaskName> /sc onlogon /rl highest /ru Users /tr <PathToexe>

taskName  := 'AhkLogArgs'
app       := 'schtasks.exe'
;exe       := A_ProgramFiles '\Microsoft OneDrive\OneDrive.exe'
exe       := "D:\Software\DEV\Work\AHK2\Projects\ScheduleTask\LogArgs.exe"
arguments := '/background'
schedule  := 'ONCE'
startTime := '00:00'
params    := ' /create /tn "' taskName '" /tr "\"' exe '\" ' arguments '" /sc ' schedule ' /st ' startTime
;RunWait app params,, 'Hide'

cmd := RunCMD.Array(app, " /create /tn ", taskName, " /sc ", schedule, " tr \", exe)

;output := RunCMD(cmd)
output:="test"
MsgBox "output: " output, 'Done!', 'Iconi'
