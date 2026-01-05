; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
WORKS FILE BUT REQUIRES ADMIN FOR Global filemapping!
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include .\FileMapping.ahk

;global mapping := FileMapping("Local\AHKFileMappingObject")
mapping := FileMapping("Global\AHKFileMappingObject")

Loop {

    IB := InputBox("Message: ", "FileMapControl")

    if (IB.Result = "Cancel")
        break

    mapping.Write(IB.Value)
}

mapping := unset

