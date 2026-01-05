; TITLE:    MyScript v0.0

; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; ==========================================
; Service Control via sc.exe (AHK v2)
; ==========================================

CreateService(serviceName, exePath, startType := "auto") {
    cmd := Format('sc create "{}" binPath= "{}" start= {}', serviceName, exePath, startType)
    return RunWait(cmd, , "Hide") = 0
}

StartService(serviceName) {
    cmd := Format('sc start "{}"', serviceName)
    return RunWait(cmd, , "Hide") = 0
}

StopService(serviceName) {
    cmd := Format('sc stop "{}"', serviceName)
    return RunWait(cmd, , "Hide") = 0
}

DeleteService(serviceName) {
    cmd := Format('sc delete "{}"', serviceName)
    return RunWait(cmd, , "Hide") = 0
}

;
;   Example
;

exePath := "C:\Path\To\MyScript.exe"

if CreateService("MyAHKService", exePath)
    MsgBox "Service created successfully!"
else
    MsgBox "Failed to create service."

if StartService("MyAHKService")
    MsgBox "Service started!"
else
    MsgBox "Failed to start service."

; Later:
; StopService("MyAHKService")
; DeleteService("MyAHKService")
