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

;WORKS FILE BUT REQUIRES ADMIN FOR Global filemapping!

;global mapping := FileMapping("Global\AHKFileMappingObject")

 mapping := FileMapping("Global\AHKFileMappingObject")
message:= ""

SetTimer(ReadMap, 1000)

ReadMap() {


    message := mapping.Read()

    if (message = "TERMINATE")
        SetTimer , 0

    if (message != "") {
        ;MsgBox(message)
        FileAppend("[" message "]" "`n", "D:\FileMapping.txt")
    }


}


    mapping := unset

