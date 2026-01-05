oldText := 'Hello, World!'
newText := '
(
We don't need no education
We dont need no thought control
No dark sarcasm in the classroom
Teacher leave them kids alone
Hey! Teacher! Leave them kids alone!
)'
wnd := Gui()
wnd.SetFont('s16', 'Calibri')
textCtrl := wnd.AddText(, oldText)
wnd.Show()
Sleep 1000
SetTextAndResize(textCtrl, newText)
Sleep 1000
SetTextAndResize(textCtrl, oldText)
return

SetTextAndResize(textCtrl, text) {
    textCtrl.Move(,, GetTextSize(textCtrl, text)*)
    textCtrl.Value := text
    textCtrl.Gui.Show('AutoSize')

    GetTextSize(textCtrl, text) {
        static WM_GETFONT := 0x0031, DT_CALCRECT := 0x400
        hDC := DllCall('GetDC', 'Ptr', textCtrl.Hwnd, 'Ptr')
        hPrevObj := DllCall('SelectObject', 'Ptr', hDC, 'Ptr', SendMessage(WM_GETFONT,,, textCtrl), 'Ptr')
        height := DllCall('DrawText', 'Ptr', hDC, 'Str', text, 'Int', -1, 'Ptr', buf := Buffer(16), 'UInt', DT_CALCRECT)
        width := NumGet(buf, 8, 'Int') - NumGet(buf, 'Int')
        DllCall('SelectObject', 'Ptr', hDC, 'Ptr', hPrevObj, 'Ptr')
        DllCall('ReleaseDC', 'Ptr', textCtrl.Hwnd, 'Ptr', hDC)
        return [Round(width * 96/A_ScreenDPI), Round(height * 96/A_ScreenDPI)]
    }
}