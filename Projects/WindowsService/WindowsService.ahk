; TITLE:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; ================================
; Windows Service Helper Functions
; AutoHotkey v2
; ================================

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
    status:=Buffer(36,0)
    result := DllCall("advapi32\ControlService"
        , "ptr", svc
        , "uint", 0x1
        , "ptr", &status)

    DllCall("advapi32\CloseServiceHandle", "ptr", svc)
    DllCall("advapi32\CloseServiceHandle", "ptr", scm)

    return result != 0
}

; ================================
;   Usage Example
; ================================

; Compile your script to EXE first!
exePath := "C:\Path\To\MyScript.exe"

if CreateService("MyAHKService", "My AutoHotkey v2 Service", exePath)
    MsgBox "Service created successfully!"
else
    MsgBox "Service creation failed."

; To delete later:
; DeleteService("MyAHKService")


; Start the service
if StartService("MyAHKService")
    MsgBox "Service started successfully!"
else
    MsgBox "Failed to start service."

; Stop the service
if StopService("MyAHKService")
    MsgBox "Service stopped successfully!"
else
    MsgBox "Failed to stop service."