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

grui:=Gui()
grui.Title:="ListenGui"
;grui.Show("w300 h100")
grui.Show("Hide")
;WinSetTitle("ListenGui", grui.Hwnd)

Persistent ; Required for Sender to find Listener

; Start listening and define what to do with the data
Messenger.Listen(MyCallBackFunction)

MyCallBackFunction(Text, Type, SenderHWND) {

    MsgBox("From: " SenderHWND "`n`nType: " Type "`n`nContent: " Text)

    if (Text="IPC_EXIT")
        ExitApp()
}