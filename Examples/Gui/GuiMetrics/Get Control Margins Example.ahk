
#Requires AutoHotkey v2.0

#SingleInstance Force
#Warn Unreachable, Off
#esc::ExitApp

;#Include <WinAPI> ; optional if you have helper wrappers

GetControlMargins(hwndCtrl) {
    static TMT_CONTENTMARGINS := 3602
    static BP_PUSHBUTTON := 1, PBS_NORMAL := 1

    hTheme := DllCall("uxtheme\OpenThemeData", "ptr", hwndCtrl, "wstr", "Button", "ptr")
    if !hTheme {
        MsgBox "Failed to open theme"
        return
    }

    margins := Buffer(16, 0) ; MARGINS struct: 4 x int
    hr := DllCall("uxtheme\GetThemeMargins", "ptr", hTheme, "ptr", 0, "int", BP_PUSHBUTTON, "int", PBS_NORMAL,
        "int", TMT_CONTENTMARGINS, "ptr", 0, "ptr", margins)

    DllCall("uxtheme\CloseThemeData", "ptr", hTheme)

    if hr != 0 {
        MsgBox "GetThemeMargins failed: " hr
        return
    }

    left   := NumGet(margins, 0, "int")
    right  := NumGet(margins, 4, "int")
    top    := NumGet(margins, 8, "int")
    bottom := NumGet(margins, 12, "int")

    return {left: left, right: right, top: top, bottom: bottom}
}

; Example usage:
MyGui := Gui()
MyGui.OnEvent("Escape", (*)=>ExitApp())

txt := MyGui.Add("Text", "w100 h30", "Test")
btn := MyGui.Add("Button", "w100 h30", "Test")
btn.Gui.Show()

margins := GetControlMargins(txt.Hwnd)
MsgBox "Text Margins:`nLeft: " margins.left "`nRight: " margins.right "`nTop: " margins.top "`nBottom: " margins.bottom

margins := GetControlMargins(btn.Hwnd)
MsgBox "Button Margins:`nLeft: " margins.left "`nRight: " margins.right "`nTop: " margins.top "`nBottom: " margins.bottom

return

SetTimer () => (
    margins := GetControlMargins(btn.Hwnd),
    ToolTip "Margins:`nLeft: " margins.left "`nRight: " margins.right "`nTop: " margins.top "`nBottom: " margins.bottom
), -1000