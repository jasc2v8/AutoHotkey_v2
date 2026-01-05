#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#Requires AutoHotkey v2.0

/*

1. Run the script in DEBUG mode to see the OutputDebug window.
2. Press the unknown key.
3. Press F12 (default in the script below) to view the Key History window.
4. Look for the row showing your keypress.
5. Press Esc to uninstall the KeybdHook and exit (normally uninstalled by AHK)

5. KeyHistory Window:
VK:         The low level VK code
SC:         The scan code (USE THIS ONE e.g. $*SC121:)
Type:       h=hex, a=ascii or ansi?
Up/Dn:      u/d = up/down
Elapsed:    Self-explanatory
Key:        Self-explanatory
Window:     Self-explanatory

$*SC121::  This defines the hotkey scan code 121 (hex).
            AutoHotkey automatically handles the extended prefix (E0) when 
            you use the SC notation for an extended key that is typically known to use it.
            The key associated with E021 is often the Forward key (or sometimes the Play/Pause key,
            depending on the keyboard).

* (wildcard modifier): Allows the hotkey to fire even if 
    modifier keys (like Ctrl, Alt, Shift, or Win) are held down.

$ (non-executing modifier): This is important for keys that you want to trap and 
    prevent from performing their native function (like sending the key itself).
    It is highly recommended to use this when intercepting low-level keys.

*/

InstallKeybdHook

; You can add a hotkey to display the history, e.g. F12
F12::KeyHistory

; This is the Cal key on the MSI TYPEMAN CD108 keyboard
$*SC121::
{
    ; This code runs when the key with scan code 021 (with the extended prefix E0) is pressed.
    ; The key for E021 is typically the Forward key on a multimedia keyboard.
    OutputDebug("Key SC021 (E021) was pressed.")
}


; Ctrl-Left Click maybe used for AhkLauncher
^LButton::
{
    OutputDebug("Ctrl-Left Mouse button Click was pressed.`n")
}

Esc::
{
    ; This code runs when the key with scan code 021 (with the extended prefix E0) is pressed.
    ; The key for E021 is typically the Forward key on a multimedia keyboard.
    MsgBox("You pressed the Escape key!`n`nPress OK to Uninstall KeybdHood and exit...")
    InstallKeybdHook(false)
    ExitApp
}