; TITLE   : RunAdminDemo v1.0.0.3
; SOURCE  : jasc2v8
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : Demo of Case #2 (Run as a Task then send Program and Parameters via NamedPipe IPC)

/*
  TODO:   
*/
#Requires AutoHotkey 2+
#SingleInstance Force
TraySetIcon('imageres.dll', 315) ; toolbox

#Include <RunAdminIPC>
#Include <LogFile>

; #region Globals

global WorkerPath   := A_ScriptDir "\RunAdminDemoWorker.ahk"
global SoundSuccess := "C:\Windows\Media\Windows Notify Calendar.wav"

global ipc:= RunAdminIPC()

; #region Create Gui

MyGui := Gui(, "RunAdminDemo v1.0.0.3")

; #region Create Controls

MyGui.SetFont("S10", "Consolas")
ButtonStart   := MyGui.AddButton("yp w75 Default", "Start")
ButtonCancel  := MyGui.AddButton("yp w75", "Cancel")
SB            := MyGui.AddStatusBar()

WriteStatus('Ready.')

; #region Event Handlers

ButtonStart.OnEvent("Click", ButtonStart_Click)
ButtonCancel.OnEvent("Click", ButtonCancel_Click)
MyGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI
MyGui.Show("w300 h50")

;
; #region Functions
;

ButtonCancel_Click(Ctrl, Info) {
    ExitApp()
}

ButtonStart_Click(Ctrl, Info) {

  ; kill process if exists due to previous error
  DetectHiddenWindows true
  if WinExist("RunAdmin.ahk ahk_class AutoHotkey")
    ProcessClose(WinGetPID())

  ; Start RunAdmin in Listen() mode...
  WriteStatus("Start Task..")

  ipc.StartTask()

  ; Send request to Start the Worker
  requestCSV:= ipc.ToCSV("/Run", WorkerPath)

  ipc.Send(requestCSV)

  ; Send program and parameters to the Worker
  requestCSV:= "robocopy.exe /e /is c:\windows\temp c:\windows\test /NJH /NDL /NFL /NC /NS"

  ipc.Send(requestCSV)

  ; Receive reply
  reply:= ipc.Receive()

  MsgBox reply, "Reply from Worker"

  ; Inform user
  MsgBox "Note created: c:\windows\test`n`nPress OK to remove this dir and end the demo."

  ; Remove test dir
  ipc.Send("rmdir, /s, /q, c:\windows\test")

  ; Receive reply
  reply:= ipc.Receive()

  ; Stop the Worker
  ipc.Send("TERMINATE")

  ; Report finished
  SoundPlay(SoundSuccess)

  WriteStatus("Finished.")

  if (reply != "ACK: `n")
    MsgBox '[' reply ']', "Reply"

}

WriteStatus(Message) {
  SB.Text := '  ' Message
}
