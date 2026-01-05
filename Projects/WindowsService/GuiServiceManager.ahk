; TITLE:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <GuiLayout>

; ==========================================
; Windows Service Browser grui
; AutoHotkey v2
; ==========================================

; --- Helper functions (CreateService, DeleteService, StartService, StopService) ---
; Assume you already have those defined from earlier steps.

CreateService(serviceName, displayName, exePath) {
    ; Open Service Control Manager
    scm := DllCall("advapi32\OpenSCManagerW"
        , "ptr", 0
        , "ptr", 0
        , "uint", 0xF003F  ; SC_MANAGER_ALL_ACCESS
        , "ptr")

    if !scm {
        MsgBox "Failed to open SCM"
        return false
    }

    ; Create the service
    svc := DllCall("advapi32\CreateServiceW"
        , "ptr", scm
        , "wstr", serviceName
        , "wstr", displayName
        , "uint", 0xF01FF   ; SERVICE_ALL_ACCESS
        , "uint", 0x10      ; SERVICE_WIN32_OWN_PROCESS
        , "uint", 0x2       ; SERVICE_AUTO_START
        , "uint", 0x1       ; SERVICE_ERROR_NORMAL
        , "wstr", exePath
        , "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0
        , "ptr")

    if !svc {
        MsgBox "Failed to create service"
        DllCall("advapi32\CloseServiceHandle", "ptr", scm)
        return false
    }

    ; Cleanup
    DllCall("advapi32\CloseServiceHandle", "ptr", svc)
    DllCall("advapi32\CloseServiceHandle", "ptr", scm)
    return true
}

DeleteService(serviceName) {
    scm := DllCall("advapi32\OpenSCManagerW"
        , "ptr", 0
        , "ptr", 0
        , "uint", 0xF003F
        , "ptr")

    if !scm {
        MsgBox "Failed to open SCM"
        return false
    }

    svc := DllCall("advapi32\OpenServiceW"
        , "ptr", scm
        , "wstr", serviceName
        , "uint", 0xF01FF
        , "ptr")

    if !svc {
        MsgBox "Failed to open service"
        DllCall("advapi32\CloseServiceHandle", "ptr", scm)
        return false
    }

    result := DllCall("advapi32\DeleteService", "ptr", svc)
    DllCall("advapi32\CloseServiceHandle", "ptr", svc)
    DllCall("advapi32\CloseServiceHandle", "ptr", scm)

    return result != 0
}

; ================================
; Windows Service Control Functions
; AutoHotkey v2
; ================================

StartService(serviceName) {
    scm := DllCall("advapi32\OpenSCManagerW"
        , "ptr", 0
        , "ptr", 0
        , "uint", 0xF003F  ; SC_MANAGER_ALL_ACCESS
        , "ptr")

    if !scm {
        MsgBox "Failed to open SCM"
        return false
    }

    svc := DllCall("advapi32\OpenServiceW"
        , "ptr", scm
        , "wstr", serviceName
        , "uint", 0xF01FF   ; SERVICE_ALL_ACCESS
        , "ptr")

    if !svc {
        MsgBox "Failed to open service"
        DllCall("advapi32\CloseServiceHandle", "ptr", scm)
        return false
    }

    result := DllCall("advapi32\StartServiceW"
        , "ptr", svc
        , "uint", 0
        , "ptr", 0)

    DllCall("advapi32\CloseServiceHandle", "ptr", svc)
    DllCall("advapi32\CloseServiceHandle", "ptr", scm)

    return result != 0
}

StopService(serviceName) {
    scm := DllCall("advapi32\OpenSCManagerW"
        , "ptr", 0
        , "ptr", 0
        , "uint", 0xF003F
        , "ptr")

    if !scm {
        MsgBox "Failed to open SCM"
        return false
    }

    svc := DllCall("advapi32\OpenServiceW"
        , "ptr", scm
        , "wstr", serviceName
        , "uint", 0xF01FF
        , "ptr")

    if !svc {
        MsgBox "Failed to open service"
        DllCall("advapi32\CloseServiceHandle", "ptr", scm)
        return false
    }

    ; SERVICE_CONTROL_STOP = 0x1
    ; SERVICE_STATUS struct is expected, but we can pass a buffer
    ;VarSetCapacity(status, 36, 0) ; enough for SERVICE_STATUS
    status := Buffer(36, 0)
    result := DllCall("advapi32\ControlService"
        , "ptr", svc
        , "uint", 0x1
        , "ptr", &status)

    DllCall("advapi32\CloseServiceHandle", "ptr", svc)
    DllCall("advapi32\CloseServiceHandle", "ptr", scm)

    return result != 0
}

; Enumerate services
EnumServices() {
    
    scm := DllCall("advapi32\OpenSCManagerW"
        , "ptr", 0
        , "ptr", 0
        , "uint", 0x04  ; SC_MANAGER_ENUMERATE_SERVICE (0x4)
        , "ptr")

    if (scm = 0) {
        MsgBox "Failed to open SCM"
        return []
    }

    ; Query services
    ; Using EnumServicesStatusExW
    ; First call to get buffer size
    bufSize := 0, bytesNeeded := 0, servicesReturned := 0, resume:=0
    DllCall("advapi32\EnumServicesStatusExW"
        , "ptr", scm
        , "uint", 0
        , "uint", 0x30   ; dwServiceType (SERVICE_WIN32) ; SERVICE_WIN32, SERVICE_STATE_ALL
        , "uint", 0x3   ; dwServiceState (SERVICE_STATE_ALL)
        , "ptr", 0
        , "uint", bufSize
        , "uintP", &bytesNeeded
        , "uintP", &servicesReturned
        , "ptr", 0
        , "int", 0)

    ;bufSize := needed
    buf := Buffer(bufSize, 0)

    ok := DllCall("advapi32\EnumServicesStatusExW"
        , "ptr", scm
        , "uint", 0
        , "uint", 0x30
        , "uint", 0x3
        , "ptr", buf
        , "uint", bufSize
        , "uintP", &bytesNeeded
        , "uintP", &servicesReturned
        , "uintP", &resume
        , "ptr", 0
        , "int", 0)

    services := []
    if ok {
        offset := 0
        loop servicesReturned {
            ; SERVICE_STATUS_PROCESS struct is embedded
            ; Each entry is ENUM_SERVICE_STATUS_PROCESSW
            ; We’ll extract ServiceName and DisplayName
            svcName := StrGet(NumGet(buf, offset, "ptr"), "UTF-16")
            dispName := StrGet(NumGet(buf, offset+8, "ptr"), "UTF-16")
            state := NumGet(buf, offset+16+4, "uint") ; dwCurrentState
            statusText := (state=0x4) ? "Running" : (state=0x1 ? "Stopped" : "Other")
            services.Push({name: svcName, display: dispName, state: statusText})
            offset += A_PtrSize*2 + 36 ; rough struct size
        }
    }

    DllCall("advapi32\CloseServiceHandle", "ptr", scm)
    return services
}

; Requires Administrator privileges
full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\\ S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp  ; Exit the current, non-elevated instance
}

; --- grui Setup ---
grui := Gui()
grui.Title := "Service Browser"
grui.OnEvent("Close", (*)=>ExitApp())
grui.Add("Text",, "Installed Services:")
lv := grui.Add("ListView", "w500 r20", ["Service Name", "Display Name", "State"])

; Populate list
; svcArray:= EnumServices()
; MsgBox svcArray.Length

for svc in EnumServices() {
    lv.Add("", svc.name, svc.display, svc.state)
}

; Buttons

grui.Add("Button", "w100", "Start").OnEvent("Click", StartSelectedService)
grui.Add("Button", "w100", "Stop").OnEvent("Click", StopSelectedService)
grui.Add("Button", "w100", "Delete").OnEvent("Click", DeleteSelectedService)
grui.Add("Button", "w100", "Cancel").OnEvent("Click", (*) => (ExitApp()))


; Double-click to toggle start/stop
lv.OnEvent("DoubleClick", ListViewDoubleClick)

ListViewDoubleClick(ctrl, row) {
        svcName := ctrl.GetText(row, 1)
    state := ctrl.GetText(row, 3)
    if (state = "Running") {
        StopService(svcName)
        ctrl.Modify(row, , , , "Stopped")
    } else {
        StartService(svcName)
        ctrl.Modify(row, , , , "Running")
    }
}

grui.Show()

L:= GuiLayout(grui)

Buttons:= L.GetControls(grui, ControlType:="Button", Exclude:="")

            x:= L.Pos().Left ;0
            w:= 100
            h:= 25 ; L.Pos("Cancel").H
            y:= L.Pos().Bottom - L.Pos("Cancel").Height

;MsgBox "y: " L.Pos().Bottom ", " L.Margin

L.FillRow(Buttons, "center", x, y, w, h)


; #region Functions



StartSelectedService(ctrl, info) {
    ; Get selected (not just focused) row
    row := lv.GetNext(0, "S")
    if !row {
        MsgBox "Select a service in the list first."
        return
    }

    svcName := lv.GetText(row, 1)  ; column 1 = service name
    if !svcName {
        MsgBox "Could not read service name from the selected row."
        return
    }

    ; Try to start; report basic success/failure
    if StartService(svcName) {
        MsgBox "Service '" svcName "' started!"
        ; Optional: update state column immediately
        lv.Modify(row, , , , "Running")
    } else {
        ; Show last error to help diagnose (permissions, service type, etc.)
        err := DllCall("GetLastError", "uint")
        MsgBox "Failed to start '" svcName "'. Error: " err
    }
}

StopSelectedService(ctrl, info) {
    row := lv.GetNext(0, "F")
    if (row != "") {
        svcName := lv.GetText(row, 1)
        if StopService(svcName)
            MsgBox "Service '" svcName "' stopped!"
        else
            MsgBox "Failed to stop service."
    }
}

DeleteSelectedService(ctrl, info) {
        row := lv.GetNext(0, "F")
        if row {
        svcName := lv.GetText(row, 1)
        if DeleteService(svcName)
            MsgBox "Service '" svcName "' deleted!"
        else
            MsgBox "Failed to delete service."
    }
}