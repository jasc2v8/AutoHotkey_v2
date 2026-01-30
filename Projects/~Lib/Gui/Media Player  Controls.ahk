; Gemini

#Requires AutoHotkey v2.0

Esc::ExitApp

; Global variables separated as requested
global IL_Large := 0
global IL_Small := 0

MediaGui := Gui("+AlwaysOnTop -Caption +Border", "Media Controller")
MediaGui.BackColor := "1A1A1A" ; Dark background

; Set font for the icons
MediaGui.SetFont("s16 cWhite", "Segoe MDL2 Assets")

; Add the controls
BtnBack := MediaGui.Add("Text", "w40 h40 Center +0x200", Chr(0xE892))
BtnPlay := MediaGui.Add("Text", "x+10 w40 h40 Center +0x200", Chr(0xE768)) ; Play icon
BtnNext := MediaGui.Add("Text", "x+10 w40 h40 Center +0x200", Chr(0xE893))
BtnMute := MediaGui.Add("Text", "x+30 w40 h40 Center +0x200", Chr(0xE995))

; Example of how to toggle Play/Pause via code
BtnPlay.OnEvent("Click", TogglePlay)

TogglePlay(Ctrl, *) {
    static playing := false
    playing := !playing
    ; Switch between Play (0xE768) and Pause (0xE769)
    Ctrl.Value := playing ? Chr(0xE769) : Chr(0xE768)
}

MediaGui.Show()
