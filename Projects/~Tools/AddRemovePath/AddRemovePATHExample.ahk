; TITLE  :  MyScript v0.0
; SOURCE :  Copilot, Gemini, myself. 
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
    RemoveFromUserPath leave a trailing ;
    
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;debug #Warn Unreachable, off

#Include .\AddRemovePATH.ahk

; Requires Administrator privileges

if not A_IsAdmin {
    ; Relaunch the script with Administrator privileges
    try
        Run '*RunAs "' A_ScriptFullPath '"'     
    ; Exit the current (non-admin) instance
    ExitApp
}

; ================================================================================
;   Main
; ================================================================================

DirToAddRemove := "C:\Program Files\INVALID_DIR"
;Test_UserPath(DirToAddRemove)
;Test_SystemPath(DirToAddRemove)

; ================================================================================
;   Test Functions
; ================================================================================
;

Test_SystemPath(DirToAddRemove) {

    before := GetSystemPath()

    after:= AddToSystemPath(DirToAddRemove)

    MsgBox  "Add To System Path: " DirToAddRemove "`n`n" .
            "Before:`n`n" before "`n`nAfter:`n`n" after "`n`n" .
            "Note: The change is permanent and will persist through logoff and subsequent reboots."

            before := after

    after:= RemoveFromSystemPath(DirToAddRemove)

    MsgBox  "Remove From System Path: " DirToAddRemove "`n`n" .
            "Before:`n`n" before "`n`nAfter:`n`n" after "`n`n" .
            "Note: The change is permanent and will persist through logoff and subsequent reboots."

}

Test_UserPath(DirToAddRemove) {

    before := GetUserPath()

    after:= AddToUserPath(DirToAddRemove)

    MsgBox  "Add To User Path: " DirToAddRemove "`n`n" .
            "Before:`n`n" before "`n`nAfter:`n`n" after "`n`n" .
            "Note: The change only lasts as long as the current Command Prompt or PowerShell window is open."  .
            "If you close the window, the change is gone.","Test: AddToUserPath", "Iconi"

    if (after != "Duplicate found.")
        before := after

    after:= RemoveFromUserPath(DirToAddRemove)

    MsgBox  "Remove From User Path: " DirToAddRemove "`n`n" .
            "Before:`n`n" before "`n`nAfter:`n`n" after "`n`n" .
            "Note: The change only lasts as long as the current Command Prompt or PowerShell window is open." .
            "If you close the window, the change is gone.","Test: RemoveFromUserPath", "Iconi"

}

;MsgBox "Added:`n`n" DirToAddRemove "`n`n" "User Path:`n`n" GetUserPath()

;MsgBox "Removed:`n`n" DirToAddRemove "`n`n" "User Path:`n`n" GetUserPath()



;MsgBox "result:`n`n" AddToSystemPath(DirToAdd)

ShowUserPath(Dir) {
    #Requires AutoHotkey v2.0

; Registry key for User Environment Variables
RegPath := "HKEY_CURRENT_USER\Environment"
PathName := "Path" 

try {
    ; Read the value of the 'Path' entry under the User Environment key
    UserPath := RegRead(RegPath, PathName)
    
    ; Check if the variable exists and has content
    if (UserPath != "") {
        MsgBox("🔍 **User-Specific PATH Contents**`n`n" UserPath, "User PATH", "T10")
    } else {
        ; This happens if the user has not added any custom directories to the User PATH
        MsgBox("The 'Path' variable was found but is currently empty or not explicitly set in your User Environment variables.", "User PATH Not Set", "T5")
    }

} catch as e {
    ; This catch block is for errors like the registry key not being found, 
    ; which is rare for HKCU\Environment, but good practice.
    MsgBox("Error reading User PATH from Registry:`n" e.Message, "Registry Error", "IconStop")
}
}