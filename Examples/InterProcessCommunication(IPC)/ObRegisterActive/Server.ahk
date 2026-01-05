#Requires AutoHotkey v2

#Include <RunAsAdmin>
#Include RotCom.ahk

global dict := ComObject("Scripting.Dictionary")
dict["msg"] := "Hello from ADMIN"
dict["count"] := 1

server := RotServer("AHK.Shared.Dictionary", dict)

MsgBox "SERVER RUNNING`nCookie=" server.Cookie "`nKeep this window open."

Loop
    Sleep 1000