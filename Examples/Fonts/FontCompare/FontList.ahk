#Requires AutoHotkey v2.0

global IL_Large := 0
global IL_Small := 0

; Font list
MonoSpaceFonts := [
    "Cascadia Code", "Cascadia Mono", "Consolas", "Courier", 
    "Courier New", "Lucida Console", "Lucida Sans", 
    "Microsoft Sans Serif"
]
SampleText := "The quick brown fox 0O lI1 |!j {[]} (0123456789)"

; --- Main Window Setup ---
FontGui := Gui("+Resize", "Font Comparator with Controls")
FontGui.BackColor := "White"
FontGui.SetFont("s14", "Segoe UI")

FontGui.Add("Text", "w860", "1. Select a font from the list:")

LV := FontGui.Add("ListView", "r10 w1120 Grid +ReadOnly", ["Font Name", "Live Preview"])
for FontName in MonoSpaceFonts
    LV.Add("", FontName, SampleText)

LV.ModifyCol(1, "AutoHdr")
LV.ModifyCol(2, "AutoHdr")

; --- Dynamic Sizing Controls with Up/Down ---
FontGui.Add("Text", "xm y+28", "2. Adjust Font Size:")

; Down Button (Using standard Unicode arrow)
BtnDown := FontGui.Add("Button", "x+15 w40 h40", "▼")
SizeSlider := FontGui.Add("Slider", "x+5 w430 Range8-80 ToolTipBottom", 22)
; Up Button (Using standard Unicode arrow)
BtnUp   := FontGui.Add("Button", "x+5 w40 h40", "▲")

SizeText := FontGui.Add("Text", "x+15 w110", "22 pt")

; --- Preview Area ---
FontGui.Add("GroupBox", "xm w1120 h220", "Selected Font Preview")
Preview := FontGui.Add("Text", "xp+15 yp+45 w1090 h140 Center +0x200", SampleText)

; --- Event Handlers ---
LV.OnEvent("Click", UpdateDisplay)
SizeSlider.OnEvent("Change", UpdateDisplay)

; Button Events
BtnDown.OnEvent("Click", (*) => AdjustSize(-1))
BtnUp.OnEvent("Click",   (*) => AdjustSize(1))

AdjustSize(Delta) {
    NewValue := SizeSlider.Value + Delta
    if (NewValue >= 8 && NewValue <= 80) {
        SizeSlider.Value := NewValue
        UpdateDisplay()
    }
}

UpdateDisplay(*) {
    Row := LV.GetNext()
    if (Row == 0)
        Row := 1 
    
    SelectedFont := LV.GetText(Row, 1)
    CurrentSize := SizeSlider.Value
    
    SizeText.Value := CurrentSize " pt"
    
    Preview.SetFont("s" CurrentSize, SelectedFont)
    Preview.Value := SelectedFont ": " SampleText
}

; --- Footer Buttons ---
;FontGui.SetFont("s13", "Segoe UI")
;FontGui.Add("Button", "xm w180 h50", Chr(0x1F412) " Open File")
;FontGui.Add("Button", "x+15 w180 h50", Chr(0x1F4BE) " Save File")

FontGui.Show()
UpdateDisplay()