
#Requires AutoHotkey 2+
#SingleInstance Force
#Warn Unreachable, Off

/*

*/

#Include RunShell.ahk

;Esc::ExitApp() ; will make script persistent

; This particular command hangs with RunWait (will hand with RunShell)
PiaCtlPath := "C:\Program Files\Private Internet Access\piactl.exe"

Run("C:\Program Files\Private Internet Access\pia-client.exe")
MsgBox "Start", "Start PIA"

output := RunShell(["C:\Program Files\Private Internet Access\piactl.exe", "connect"])
MsgBox output, "Connect PIA"

output := RunShell(["C:\Program Files\Private Internet Access\piactl.exe", "get", "connectionstate"])
MsgBox output, "State of PIA"

output := RunShell(["C:\Program Files\Private Internet Access\piactl.exe", "disconnect"])
MsgBox output, "Disconnect PIA"

ProcessClose("pia-client.exe")
MsgBox output, "Close PIA"

ExitApp()
