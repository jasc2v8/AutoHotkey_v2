#Requires AutoHotkey v2.0

; Global variables separated on two lines as requested
global IL_Large := 0
global IL_Small := 0

; Cleaned list (removed duplicates and non-monospace fonts like Microsoft Sans Serif)
MonoSpaceFonts := ["Cascadia Code", "Cascadia Mono", "Consolas", "Courier New", "Lucida Console"]
SampleText := "The quick brown fox 0O lI1 |!j {[]} (0123456789)"

FontGui := Gui("+Resize", "Monospace Font Comparator")
FontGui.SetFont("s11", "Segoe UI")

FontGui.Add("Text", "w600", "Comparing Monospace Fonts (System Defaults):")

; Create ListView with two columns
LV := FontGui.Add("ListView", "r12 w800 Grid +ReadOnly", ["Font Name", "Live Preview (Size 12)"])

; Populate the list
for FontName in MonoSpaceFonts {
    LV.Add("", FontName, SampleText)
}

; Use a custom draw-like approach or simply apply fonts to individual rows 
; Note: Standard AHK ListView applies one font to all rows. 
; To actually *see* the difference, we will use a selection-based previewer below.

FontGui.Add("GroupBox", "xm w780 h100", "Selected Font Preview")
Preview := FontGui.Add("Text", "xp+10 yp+30 w760 h50 Center +0x200", SampleText)

; Event: When user clicks a row, update the preview font
LV.OnEvent("Click", UpdatePreview)

UpdatePreview(GuiCtrl, RowNumber) {
    if (RowNumber == 0)
        return
    
    SelectedFont := GuiCtrl.GetText(RowNumber, 1)
    Preview.SetFont("s16", SelectedFont)
    Preview.Value := SelectedFont ": " SampleText
}

; Add your requested buttons for context
FontGui.Add("Button", "xm w100", Chr(0x1F412) " Open File")
FontGui.Add("Button", "x+10 w100", Chr(0x1F4BE) " Save")

FontGui.Show()

; Set initial focus
UpdatePreview(LV, 1)
