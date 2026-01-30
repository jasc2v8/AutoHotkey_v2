#Requires AutoHotkey v2+

/**
 * Toggles the system cursor between Busy (IDC_WAIT) and Default.
 * @param {Boolean} On - Pass true to show wait cursor, false to restore.
 */
ShowWaitCursor(On := true) {
    if (On) {
        ; IDC_WAIT = 32514
        hCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32514, "Ptr")
        ; Set the system arrow (32512) to the wait cursor
        DllCall("SetSystemCursor", "Ptr", hCursor, "UInt", 32512)
    } else {
        ; Restore all system cursors to defaults
        DllCall("SystemParametersInfo", "UInt", 0x57, "UInt", 0, "Ptr", 0, "UInt", 0)
    }
}
