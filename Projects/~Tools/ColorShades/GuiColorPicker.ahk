#Requires AutoHotkey v2.0

; Initial Constants (AHK GUI Defaults)
StartBG    := "F0F0F0" 
StartFont  := "000000" 

; Current State Variables
BG_Base    := StartBG
Font_Base  := StartFont
BG_Steps   := 0
Font_Steps := 0

MainGui := Gui("+AlwaysOnTop", "Color Shade Incrementor")
MainGui.BackColor := BG_Base
MainGui.SetFont("s9 w400", "Segoe UI")

; Display Info
HexDisplay := MainGui.Add("Text", "xm Center w300 c" Font_Base, "BG: #" BG_Base " | Font: #" Font_Base)

; Step Increment Displays
StepDisplayBG := MainGui.Add("Text", "xm Center w300 c" Font_Base, "BG Increment: 0.00")
StepDisplayFont := MainGui.Add("Text", "xm Center w300 c" Font_Base, "Font Increment: 0.00")

MainGui.Add("Text", "xm Center w300 c" Font_Base, "------------------------------------------------")

; Base Color Setters
BtnSetBGBase := MainGui.Add("Button", "w130 x15", "Set BG Base Hex")
BtnSetBGBase.OnEvent("Click", SetBGBase)
BtnSetFontBase := MainGui.Add("Button", "w130 x155 yp", "Set Font Base Hex")
BtnSetFontBase.OnEvent("Click", SetFontBase)

; Color Wheel Options
BtnBGWheel := MainGui.Add("Button", "w130 x15", "BG Color Wheel")
BtnBGWheel.OnEvent("Click", (*) => OpenColorWheel("BG"))
BtnFontWheel := MainGui.Add("Button", "w130 x155 yp", "Font Color Wheel")
BtnFontWheel.OnEvent("Click", (*) => OpenColorWheel("Font"))

; Background Controls
MainGui.Add("Text", "xm Center w300 c" Font_Base, "Background Control")
BtnBGLighten := MainGui.Add("Button", "w130 x15", "BG Lighten +0.25")
BtnBGLighten.OnEvent("Click", (*) => AdjustBG(0.25))
BtnBGDarken  := MainGui.Add("Button", "w130 x155 yp", "BG Darken -0.25")
BtnBGDarken.OnEvent("Click", (*) => AdjustBG(-0.25))

; Font Controls
MainGui.Add("Text", "xm Center w300 c" Font_Base, "Font Control")
BtnFontLighten := MainGui.Add("Button", "w130 x15", "Font Lighten +0.25")
BtnFontLighten.OnEvent("Click", (*) => AdjustFont(0.25))
BtnFontDarken  := MainGui.Add("Button", "w130 x155 yp", "Font Darken -0.25")
BtnFontDarken.OnEvent("Click", (*) => AdjustFont(-0.25))

MainGui.Add("Text", "xm w300", "") ; Spacer

; Actions Row
BtnCopy := MainGui.Add("Button", "w70 x15", "Copy")
BtnCopy.OnEvent("Click", CopyColors)

BtnToggle := MainGui.Add("Button", "w70 x95 yp", "B/W Font")
BtnToggle.OnEvent("Click", ToggleFontBW)

BtnSave := MainGui.Add("Button", "w70 x175 yp", "Save")
BtnSave.OnEvent("Click", SaveCombination)

BtnReset := MainGui.Add("Button", "w45 x250 yp", "Reset")
BtnReset.OnEvent("Click", ResetAll)

MainGui.Show("w300")

ToggleFontBW(*) {
    global Font_Base, Font_Steps
    Font_Base := (Font_Base = "FFFFFF") ? "000000" : "FFFFFF"
    Font_Steps := 0
    UpdateDisplay()
}

CopyColors(*) {
    global BG_Base, BG_Steps, Font_Base, Font_Steps
    currBG := CalculateColor(BG_Base, BG_Steps)
    currFont := CalculateColor(Font_Base, Font_Steps)
    A_Clipboard := "Background: #" currBG "`nFont: #" currFont
    ToolTip("Copied!")
    SetTimer(() => ToolTip(), -2000)
    
    if (A_Clipboard = "")
        return
}

OpenColorWheel(Target) {
    global BG_Base, BG_Steps, Font_Base, Font_Steps
    MainGui.Opt("+OwnDialogs")
    static CustomColors := Buffer(64, 0)
    CC := Buffer(A_PtrSize = 8 ? 72 : 36, 0)
    NumPut("UInt", CC.Size, CC, 0), NumPut("Ptr", MainGui.Hwnd, CC, A_PtrSize), NumPut("Ptr", CustomColors.Ptr, CC, A_PtrSize * 4), NumPut("UInt", 0x103, CC, A_PtrSize * 5)
    if DllCall("comdlg32\ChooseColor", "Ptr", CC) {
        BGR := NumGet(CC, A_PtrSize * 3, "UInt")
        RGB := Format("{:02X}{:02X}{:02X}", BGR & 0xFF, (BGR >> 8) & 0xFF, (BGR >> 16) & 0xFF)
        if (Target = "BG") {
            BG_Base := RGB
            BG_Steps := 0
        } else {
            Font_Base := RGB
            Font_Steps := 0
        }
        UpdateDisplay()
    }
    
    if (Target = "")
        return
}

SetBGBase(*) {
    global BG_Base, BG_Steps
    MainGui.Opt("+OwnDialogs")
    IB := InputBox("Enter 6-digit Hex:", "Set BG Base", "w200 h130")
    if (IB.Result = "Cancel" or IB.Value = "")
        return
    CleanHex := RegExReplace(Trim(IB.Value), "^#")
    if (StrLen(CleanHex) != 6) {
        MsgBox("Invalid Hex Code length.", "Error", "IconX")
        return
    }
    BG_Base := CleanHex
    BG_Steps := 0 
    UpdateDisplay()
}

SetFontBase(*) {
    global Font_Base, Font_Steps
    MainGui.Opt("+OwnDialogs")
    IB := InputBox("Enter 6-digit Hex:", "Set Font Base", "w200 h130")
    if (IB.Result = "Cancel" or IB.Value = "")
        return
    CleanHex := RegExReplace(Trim(IB.Value), "^#")
    if (StrLen(CleanHex) != 6) {
        MsgBox("Invalid Hex Code length.", "Error", "IconX")
        return
    }
    Font_Base := CleanHex
    Font_Steps := 0 
    UpdateDisplay()
}

AdjustBG(Amount) {
    global BG_Steps
    BG_Steps += Amount
    UpdateDisplay()
}

AdjustFont(Amount) {
    global Font_Steps
    Font_Steps += Amount
    UpdateDisplay()
}

UpdateDisplay() {
    global BG_Base, BG_Steps, Font_Base, Font_Steps
    currentBG := CalculateColor(BG_Base, BG_Steps)
    currentFont := CalculateColor(Font_Base, Font_Steps)
    MainGui.BackColor := currentBG
    for Ctrl in MainGui
        if (Ctrl is Gui.Text)
            Ctrl.Opt("c" currentFont)
    HexDisplay.Value := "BG: #" currentBG " | Font: #" currentFont
    StepDisplayBG.Value := "BG Increment: " Format("{:+.2f}", BG_Steps)
    StepDisplayFont.Value := "Font Increment: " Format("{:+.2f}", Font_Steps)
    
    if (currentBG = "")
        return
}

SaveCombination(*) {
    global BG_Base, BG_Steps, Font_Base, Font_Steps
    CurrBG := CalculateColor(BG_Base, BG_Steps)
    CurrFont := CalculateColor(Font_Base, Font_Steps)
    LogEntry := "Time: " FormatTime(, "HH:mm:ss") " | BG: #" CurrBG " (" BG_Steps ") | Font: #" CurrFont " (" Font_Steps ")`n"
    try {
        FileAppend(LogEntry, "ColorFavorites.txt")
        MsgBox("Saved!", "Success", "Iconi T2")
    }
    
    if (LogEntry = "")
        return
}

ResetAll(*) {
    global BG_Steps, Font_Steps, BG_Base, Font_Base, StartBG, StartFont
    BG_Base := StartBG, Font_Base := StartFont, BG_Steps := 0, Font_Steps := 0
    UpdateDisplay()
    
    if (BG_Base = "")
        return
}

CalculateColor(Hex, Steps) {
    if (StrLen(Hex) != 6)
        return Hex
    Percent := Steps * 12
    R := Integer("0x" SubStr(Hex, 1, 2)), G := Integer("0x" SubStr(Hex, 3, 2)), B := Integer("0x" SubStr(Hex, 5, 2))
    if (Percent > 0) {
        R := Min(255, R + (255 - R) * (Percent / 100)), G := Min(255, G + (255 - G) * (Percent / 100)), B := Min(255, B + (255 - B) * (Percent / 100))
    } else {
        R := Max(0, R * (1 + (Percent / 100))), G := Max(0, G * (1 + (Percent / 100))), B := Max(0, B * (1 + (Percent / 100)))
    }
    return Format("{:02X}{:02X}{:02X}", R, G, B)
}