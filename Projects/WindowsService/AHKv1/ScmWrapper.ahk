; TITLE:    MyScript v0.0

; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
    This is hopeful!
    
    - Admin rights required
    turn fat arrow into functions


*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; ==========================================
; Service Browser GUI using sc.exe wrappers
; AutoHotkey v2
; ==========================================

; --- sc.exe wrapper functions ---
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

; --- GUI Setup ---
grui := Gui("Service Browser")
grui.Add("Text",, "Installed Services:")
lv := grui.Add("ListView", "w500 r15", ["Service Name", "State"])

; Populate with sc query (simplified)
RefreshServices(lv)

; Buttons
grui.Add("Button", "w100", "Start").OnEvent("Click", (*) => (
    row := lv.GetNext(0, "S")
    if row {
        svcName := lv.GetText(row, 1)
        if StartService(svcName) {
            MsgBox "Service '" svcName "' started!"
            RefreshServices(lv)
        } else MsgBox "Failed to start service."
    }
))

grui.Add("Button", "w100", "Stop").OnEvent("Click", (*) => {
    row := lv.GetNext(0, "S")
    if row {
        svcName := lv.GetText(row, 1)
        if StopService(svcName) {
            MsgBox "Service '" svcName "' stopped!"
            RefreshServices(lv)
        } else MsgBox "Failed to stop service."
    }
})

grui.Add("Button", "w100", "Delete").OnEvent("Click", (*) => {
    row := lv.GetNext(0, "S")
    if row {
        svcName := lv.GetText(row, 1)
        if DeleteService(svcName) {
            MsgBox "Service '" svcName "' deleted!"
            RefreshServices(lv)
        } else MsgBox "Failed to delete service."
    }
})

grui.Add("Button", "w100", "Refresh").OnEvent("Click", (*) => RefreshServices(lv))

grui.Show()

; --- Helper to refresh service list using sc.exe ---
RefreshServices(lv) {
    lv.Delete()
    ; Run "sc query" to get all services
    output := ""
    RunWait("sc query type= service state= all", , "Hide", &output)
    ; Parse output lines
    for line in StrSplit(output, "`n") {
        if InStr(line, "SERVICE_NAME:") {
            svcName := Trim(StrReplace(line, "SERVICE_NAME:", ""))
        } else if InStr(line, "STATE") {
            state := InStr(line, "RUNNING") ? "Running" : "Stopped"
            lv.Add("", svcName, state)
        }
    }
}