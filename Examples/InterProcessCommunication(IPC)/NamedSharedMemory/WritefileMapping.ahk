; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\FileMapping.ahk

mapping := FileMapping("Global\AHKFileMappingObject")
mapping.Write("The data to share")
MsgBox "Now run the second script (without closing this MsgBox)"
mapping := unset

