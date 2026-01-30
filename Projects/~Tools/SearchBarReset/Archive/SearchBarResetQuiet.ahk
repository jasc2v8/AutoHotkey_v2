; TITLE:    SearchBarReset v1.0.0.2
; SOURCE:   jasc2v8 12/15/2025
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  A work-around for the Win11 issue of empty Sarch bar
;           Intended to be on-demand Task scheduled in Task Scheduler with runLevel='highest'
;           Recommend to run at login until windows 11 gets fixed?

/*
    TODO:
*/

#Requires AutoHotkey v2+

#Include <LogFile>
#Include <NamedPipe>
#Include <AdminLauncher>

;MsgBox(,"Search Bar Reset")

logger:= LogFile("D:\SearchBarResetQuiet.log", "CONTROL", true)

logger.Write("Run Task")

runner:= AdminLauncher()

runner.StartTask()

runner.Run("D:\Software\DEV\Work\AHK2\Projects\~Tools\SearchBarReset\SearchBarResetWorker.ahk")

runner.Send("START")

reply:= runner.Receive()

logger.Write("Reply Received: " reply)

;MsgBox("Reset Complete.","Search Bar Reset")
