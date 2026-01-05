; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

;#Include <RunAsAdmin>

GUID:="{5833F089-D9BF-423F-A570-F828BA1FF246}"
GUID:="{01234567-89AB-CDEF-0123-456789ABCDEF}"

Loop {
    try {

        x := ComObjActive(GUID)

        if MsgBox("Shared object key: " x.key, "AccessSharedObj", "OKCancel") = "Cancel"
        break

        x:=""

    } catch any as e{
        if MsgBox(e.Message, "AccessSharedObj", "OKCancel") = "Cancel"
            ExitApp()
    }
}
