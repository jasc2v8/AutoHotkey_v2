; TITLE: LogArgs v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFile>
#Include <NamedPipe>
#Include C:\ProgramData\AutoHotkey\RunSkipUAC\RunSkipUAC.ahk

logger:= LogFile("D:\TestWorker.log", "WORKER", true)



runner:= RunSkipUAC()
request:= runner.Receive()
logger.Write("Request Received: " request)

; logger.Write("Pipe Create")
; pipe:= NamedPipe("WORKER")
; pipe.Create()
; request:= pipe.Receive()
; logger.Write("Request Received: " request)
; pipe.Close()
; pipe:=""

;Sleep 400

r := runner.Send("ACK: " request)

logger.Write("Reply Sent: ACK:" request ", r: " r)

; pipe:= NamedPipe("WORKER")
; r := pipe.Wait(5000)
; if (!r) {
; 	logger.Write("Timeout Waiting for pipe.")
; 	MsgBox "Timeout Waiting for pipe.", "Timeout", "IconX"
; 	ExitApp()
; }
; pipe.Send("ACK: " request)
; logger.Write("Reply Sent: ACK: " request)
; pipe.Close()


; runner:= RunSkipUAC()

; request:= runner.Receive()

; logger.Write("Request Received: " request)

; logger.Write("Delay to wait for receiver")
; Sleep 1000

; r := runner.Send("ACK: " request)

; logger.Write("Reply Sent: ACK:" request ", r: " r)

logger.Write("Exit")

; try {

;   ; Create a pipe instance
;   logger.Write("Create Pipe.")
;   pipe:=NamedPipe("WORKER")
;   pipe.Create()

;   ; Receive the request from the client
;   logger.Write("Read request.")
;   request := pipe.Receive()
;   logger.Write("Request Received: " request)
;   pipe.Close()

;   ; Send reply to the client
;   pipe:=NamedPipe("WORKER")
;       r := pipe.Wait(5000)
;       if (!r) {
;         logger.Write("Timeout Waiting for pipe.")
;         ExitApp()
;       }
;   logger.Write("Send reply.")
;   pipe.Send("ACK:" request)
;   pipe.Close()


; } catch any as e {

;   logger.Write("ERROR: " e.Message)
  
; } finally {

;   logger.Write("Pipe close.")
;   pipe.Close()
;   pipe:=""
; }
