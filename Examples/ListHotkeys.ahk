#Requires AutoHotkey 2
show := () => g.Show()
g    := Gui(, 'Hotkey')                          ; Create GUI
g.SetFont 's10'                                  ; Set font size
LB   := g.AddListBox('w230', ['F7', 'F8'])       ; Add ListBox
btn  := g.AddButton('wp Default Disabled', 'OK') ; Add button

; Events
g.OnEvent   'Escape', (gui) => gui.Hide()
LB.OnEvent  'Change', (LB, info) => btn.Enabled := True
btn.OnEvent 'Click' , btn_Click

show     ; Show the GUI

F3::show ; F3 = Show the GUI

btn_Click(btn, info) {                           ; Button was activated
 static hk
 btn.Gui.Hide
 Try Hotkey hk, 'Off'
 Hotkey hk := LB.Text, go, 'On'                  ; Define hotkey by ListBox
}

go(ThisHotkey) {                                 ; Hotkey was activated
 MsgBox ThisHotkey, 'Hotkey', 'Iconi'
}