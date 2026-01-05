; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

Loop {

    IB := InputBox("Message: ", "FileMapControl")

    if (IB.Result = "Cancel")
        break

    RegWrite IB.Value, "REG_SZ", "HKEY_CURRENT_USER\SOFTWARE\AHKScripts", "IpcRegistryService"
}
