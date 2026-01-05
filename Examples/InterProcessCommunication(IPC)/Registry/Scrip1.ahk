; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

largeString := "abcdefghijklmnopqustuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
largeString .= largeString
largeString .= largeString
largeString .= largeString
largeString .= largeString
largeString .= largeString
largeString .= largeString
largeString .= largeString
largeString .= largeString

;RegWrite "I am doing this", "REG_SZ", "HKEY_CURRENT_USER\SOFTWARE\AHKScripts", "Script1"

RegWrite largeString, "REG_SZ", "HKEY_CURRENT_USER\SOFTWARE\AHKScripts", "Script1"

