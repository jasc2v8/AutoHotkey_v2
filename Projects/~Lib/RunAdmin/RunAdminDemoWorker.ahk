; TITLE   : RunAdminDemoWorker v1.0.0.3
; SOURCE  : jasc2v8
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : Demo of Case #2 (Run as a Task then send Program and Parameters via NamedPipe IPC)

/*
  TODO:
*/
#Requires AutoHotkey 2+
#SingleInstance Ignore
#NoTrayIcon

#Include <RunAdminIPC>
#Include <RunLib>

global ipc := RunAdminIPC()

global runner := RunLib()

Loop {

  ; Receive request
  requestCSV := ipc.Receive()

  ; Check if terminate
  if (requestCSV = 'TERMINATE')
    ExitApp()

  ; Run request
  reply := runner.RunWait(requestCSV)

  ; Send ack
  ipc.Send("ACK:" reply)

}
