; TITLE  :  Listen v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

; ok #Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include Messenger.ahk
#Include <CRC>

TargetScriptTitle := "Listen.ahk" ; Change this to your listener's script name

DetectHiddenWindows True
if !WinExist(TargetScriptTitle) {
    Run TargetScriptTitle
    WinWait(TargetScriptTitle)
}


; Other options:
;   TargetScriptTitle:= "Listen.ahk ahk_class AutoHotkey"
;   TargetScriptTitle:= "ahk_id hwnd"

; Establish an inter-process communication channel with a unique passkey
ipc:= Messenger(CRC.Get64(TargetScriptTitle))
; ok ipc:= Messenger("ahk_id " TargetHWND, CRC.Get64(TargetScriptTitle))

; Listen for incoming messages
ipc.Listen(OnMessageReceived)

; Send a message to the listener
success := ipc.Send(TargetScriptTitle, "Hello from the Class Sender!")

; Check success
if (!success) {
    MsgBox "Message Refused or Timeout!", "Sender"
    ExitApp()
}

; Send an exit message to the listener
ipc.Send(TargetScriptTitle, "IPC_EXIT", 0)

; Handle incoming messages
OnMessageReceived(Text, SenderHWND) {

    MsgBox("From Listener:`n`n" Text)

    if (Text="IPC_EXIT")
        ExitApp()
}
