; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
#Requires AutoHotkey v2.0

MyGui := Gui("Resize")

; Request the GUI to be 400 pixels wide and 300 pixels high (Outer Dimensions)
MyGui.Show("w400 h300")

; We must retrieve the values AFTER the Gui has been shown.
GuiW := MyGui.Width
GuiH := MyGui.Height
ClientW := MyGui.ClientWidth
ClientH := MyGui.ClientHeight

MsgBox("--- Dimensions of the Gui Object ---"
    . "`nOuter Width (Gui.W): " GuiW
    . "`nOuter Height (Gui.H): " GuiH
    . "`n------------------------------------"
    . "`nClient Width: " ClientW
    . "`nClient Height: " ClientH
    . "`n"
    . "`nDifference (Borders/Title Bar):"
    . "`nWidth Diff: " (GuiW - ClientW) " pixels"
    . "`nHeight Diff: " (GuiH - ClientH) " pixels")