; TITLE: LogArgs v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFile>
#Include <RunShell>

#Include <AdminLauncher>
;#Include AdminLauncher.ahk

;
; Initialize
;

logger:= LogFile("D:\TestWorker.log", "WORKER", true)

launcher:= AdminLauncher() ; Create instance

;
; Receive request
;

requestCSV:= launcher.Receive()

logger.Write("Request Received: " requestCSV)

;
; Run request
;

RunShell(requestCSV)

r := launcher.Send("ACK: " requestCSV)

logger.Write("Reply Sent: ACK:" requestCSV ", r: " r)

;
; Done
;

logger.Write("Exit")
