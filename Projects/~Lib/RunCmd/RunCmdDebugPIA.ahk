
#Requires AutoHotkey 2.0+
#SingleInstance Force
#Warn Unreachable, Off

/*

*/

#Include RunCMD.ahk

;Esc::ExitApp() ; will make script persistent

; This particular command hangs with RunWait (will hand with RunCMD)
PiaCtlPath := "C:\Program Files\Private Internet Access\piactl.exe"

Run("C:\Program Files\Private Internet Access\pia-client.exe")
MsgBox "Start", "Start PIA"

output := RunCMD(["C:\Program Files\Private Internet Access\piactl.exe", "connect"])
MsgBox output, "Connect PIA"

output := RunCMD(["C:\Program Files\Private Internet Access\piactl.exe", "get", "connectionstate"])
MsgBox output, "State of PIA"

output := RunCMD(["C:\Program Files\Private Internet Access\piactl.exe", "disconnect"])
MsgBox output, "Disconnect PIA"

ProcessClose("pia-client.exe")
MsgBox output, "Close PIA"

ExitApp()
