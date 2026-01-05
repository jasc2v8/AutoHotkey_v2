; TITLE:    MyScript v0.0
; SOURCE:   AHKv2 https://www.autohotkey.com/boards/viewtopic.php?f=13&t=31695&p=212511&hilit=schtasks#p212511
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunCMD>

; requires Admin if runLevel = 'highest'

taskName  := 'AhkBackupSkipUAC - Jim'
app       := 'schtasks.exe'
exe       := "D:\Software\DEV\Work\AHK2\Projects\ScheduleTask\LogArgs.exe"
arguments := '/background'  ; for RunWait
schedule  := 'once'
startDate := '01/01/1910'   ; far in the past so it will never run as scheduled
startTime := '00:00'
runLevel  := 'limited'      ; 'highest' ; highest required Admin
runUser   := 'Users'        ; default is current user

;params    := ' /create /tn "' taskName '" /tr "\"' exe '\" ' arguments '" /sc ' schedule ' /st ' startTime
;RunWait app params,, 'Hide'

;SCHTASKS /create /tn "AhkOnDemand" /tr "D:\Software\DEV\Work\AHK2\Projects\ScheduleTask\LogArgs.exe" /sc ONCE /sd 01/01/1910 /st 00:00

;YES output := RunCMD.Array(app, " /create /tn ", taskName, " /tr ", exe, " /sc ", schedule, " /st ", " 00:00 ", " /rl ", "highest ")

;YES output := RunCMD.Array(app, " /create /tn ", taskName, " /tr ", exe, " /sc ", schedule, " /st ", " 00:00 ")

output := RunCMD.Array(app, "/create /tn", taskName, "/tr", exe, "/sc", schedule, "/st", startTime, "/rl", runLevel)

MsgBox 'Output: ' output, 'Status', 'Iconi'
