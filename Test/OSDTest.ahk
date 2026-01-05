;Source: https://www.autohotkey.com/board/topic/9327-a-handy-dialogue-technique-and-colorful-msgboxs
#Requires Autohotkey v2
#SingleInstance Force
#NoTrayIcon
MyGui := Gui()
MyGui.Opt("+AlwaysOnTop -Caption +ToolWindow")  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
MyGui.BackColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
MyGui.SetFont("s32")  ; Set a large font size (32-point).
CoordText := MyGui.Add("Text", "cLime", "XXXXX YYYYY")  ; XX & YY serve to auto-size the window.
; Make all pixels of this color transparent and make the text itself translucent (150):
WinSetTransColor(MyGui.BackColor " 150", MyGui)
SetTimer(UpdateOSD, 200)
UpdateOSD()  ; Make the first update immediate rather than waiting for the timer.
MyGui.Show("x0 y400 NoActivate")  ; NoActivate avoids deactivating the currently active window.

UpdateOSD(*)
{
    MouseGetPos &MouseX, &MouseY
    CoordText.Value := "X" MouseX ", Y" MouseY
}
