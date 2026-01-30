
#Requires AutoHotkey v2.0+
#SingleInstance

#Include RunAdminIPC.ahk

;Persistent

ipc := RunAdminIPC()

message := ipc.Receive()

MsgBox message

;Persistent false
ExitApp



