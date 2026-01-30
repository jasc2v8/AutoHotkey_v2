
#Requires AutoHotkey v2.0+
#SingleInstance

#Include RunAdminIPC.ahk

ipc := RunAdminIPC()

ipc.Send("Hello World")
