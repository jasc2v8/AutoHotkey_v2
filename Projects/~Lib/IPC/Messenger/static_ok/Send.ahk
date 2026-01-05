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

if TargetHWND {

    Messenger.Listen(MyCallBackFunction)

    success := Messenger.Send(TargetHWND, "Hello from the Class Sender!", 1)
    ;Messenger.Send(Target, "Hello from the Class Sender!", 2)
    ;Messenger.Send(Target, "Hello from the Class Sender!", 3)

    if (!success)
        MsgBox "Timeout!", "SendDemo"

    Messenger.Send(TargetHWND, "IPC_EXIT", 0)

} else {
    MsgBox "Listener not found."
}

MyCallBackFunction(Text, Type, SenderHWND) {

    MsgBox("From: " SenderHWND "`n`nType: " Type "`n`nContent: " Text)

    if (Text="IPC_EXIT")
        Persistent false
}
