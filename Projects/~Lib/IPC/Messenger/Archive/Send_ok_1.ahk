; TITLE  :  Listen v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include Messenger.ahk
#Include <CRC>

DetectHiddenWindows True
SetTitleMatchMode 2 ; contains (default)

TargetScriptTitle := "Listen.ahk" ; Change this to your listener's script name

TargetHWND := WinExist(TargetScriptTitle)
;ok TargetHWND := WinExist("Listen.ahk ahk_class AutoHotkey")

; Find the listener script
;Target := WinExist("MessengerListenDemo.ahk ahk_class AutoHotkey")
;Target := WinExist("ListenGui ahk_class AutoHotkeyGUI")
;Target := WinExist("ListenGui")
; ok Target := WinExist("ListenGui")
; ok ;Target := WinExist("ahk_exe MessengerListenGuiDemo.exe")

;ok ipc:= Messenger(TargetScriptTitle)

hwnd:= WinExist(TargetScriptTitle)
;MsgBox WinExist("ahk_id " hwnd), "DEBUG"

;OK but breaks CRC ipc:= Messenger("ahk_id " TargetHWND, 0)
ipc:= Messenger("ahk_id " TargetHWND, CRC.Get64(TargetScriptTitle))
; ok ipc:= Messenger(TargetScriptTitle)

if TargetHWND {

    ipc.Listen(MyCallBackFunction)

    ; ok success := ipc.Send(TargetHWND, "Hello from the Class Sender!")
    success := ipc.Send(TargetHWND, "Hello from the Class Sender!")
    ;Messenger.Send(Target, "Hello from the Class Sender!", 2)
    ;Messenger.Send(Target, "Hello from the Class Sender!", 3)

    if (!success)
        MsgBox "Message Refused or Timeout!", "Sender"

    ;ipc.Send(TargetHWND, "IPC_EXIT", 0)
    ipc.Send(TargetScriptTitle, "IPC_EXIT", 0)

} else {
    MsgBox "Listener not found."
}

MyCallBackFunction(Text, SenderHWND) {

    MsgBox("From Listener:`n`n" Text)

    if (Text="IPC_EXIT")
        Persistent false
}
