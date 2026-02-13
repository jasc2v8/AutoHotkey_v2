; TITLE   : RunAdminDemo v1.0.0.2
; SOURCE  : jasc2v8
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : Test RunAdmin.ahk and RunAdminIPC.ahk Case #1 (Run with Parameters)
; OVERVIEW: Copy c:\windows\temp\*.* c:\windows\test\, then rmdir c:\windows\test\ (requires Admin)
;           Output: MsgBox with StdOut+StdErr from robocopy
; SCRIPTS : RunAdminDemo.ahk => run Task RunAdmin => RunAdmin.ahk => robocopy and rmdir commands

/*
  TODO:   
*/
#Requires AutoHotkey 2+
#SingleInstance Force
TraySetIcon('imageres.dll', 315) ; toolbox

#Include <RunAdminIPC>

; #region Globals

global WorkerPath   := A_ScriptDir "\RunAdminDemoWorker.ahk"

global SoundSuccess := "C:\Windows\Media\Windows Notify Calendar.wav"

global ipc:= RunAdminIPC()

; #region Create Gui

MyGui := Gui(, "RunAdminDemo v1.0.0.2")

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

  ; Send request - robocopy Job Summary output only
  requestCSV:= "/RunWait, robocopy.exe /e /is c:\windows\temp c:\windows\test /NJH /NDL /NFL /NC /NS"

  ipc.Send(requestCSV)

  ; Receive reply
  reply:= ipc.Receive()

  MsgBox reply, "Reply"

  ; Start RunAdmin again
  ipc.StartTask()

  ; Send another requestCSV
  ipc.Send("/RunWait, rmdir /s /q c:\windows\test")

  ; Receive reply
  reply:= ipc.Receive()

  ; Report finished
  SoundPlay(SoundSuccess)

  WriteStatus("Finished.")

  if (reply != "ACK: `n")
    MsgBox '[' reply ']', "Reply"

}

WriteStatus(Message) {
  SB.Text := '  ' Message
}
