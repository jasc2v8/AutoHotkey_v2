#Requires AutoHotkey v2.0
#SingleInstance Off

; Version 1.0.0.22

; Initial Constants (AHK GUI Defaults)
StartBG    := "F0F0F0" 
StartFont  := "000000" 

; Handle command line arguments for positioning
SpawnX := (A_Args.Length >= 1) ? A_Args[1] : "Center"
SpawnY := (A_Args.Length >= 2) ? A_Args[2] : "Center"

; Current State Variables
BG_Base    := StartBG
Font_Base  := StartFont
BG_Steps   := 0
Font_Steps := 0
Font_Weight := 400

MainGui := Gui("+AlwaysOnTop", "Color Shades")
MainGui.BackColor := BG_Base
MainGui.SetFont("s9 w" Font_Weight, "Segoe UI")

; Display Info
HexDisplay := MainGui.Add("Text", "xm Center w300 c" Font_Base, "BG: #" BG_Base " | Font: #" Font_Base)

; Step Increment Displays
StepDisplayBG := MainGui.Add("Text", "xm Center w300 c" Font_Base, "BG Increment: 0.00")

MainGui.Add("Text", "xm w290 h1 0x10") ; Spacer

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
BtnFontNormal := MainGui.Add("Button", "w85 x15", "Normal")
BtnFontNormal.OnEvent("Click", (*) => SetFontWeight(400))
BtnFontBold := MainGui.Add("Button", "w85 x110 yp", "Bold")
BtnFontBold.OnEvent("Click", (*) => SetFontWeight(700))
BtnFontBW := MainGui.Add("Button", "w85 x205 yp", "Black/White")
BtnFontBW.OnEvent("Click", ToggleFontBW)

MainGui.Add("Text", "xm w290 h1 0x10", "") ; Spacer

; Actions Row (All buttons w56)
BtnCopy := MainGui.Add("Button", "w56 x5", "Copy")
BtnCopy.OnEvent("Click", CopyColors)

BtnSaveAs := MainGui.Add("Button", "w56 x65 yp", "Save")
BtnSaveAs.OnEvent("Click", SaveAsCombination)

BtnClone := MainGui.Add("Button", "w56 x125 yp", "Clone")
BtnClone.OnEvent("Click", CloneInstance)

BtnReset := MainGui.Add("Button", "w56 x185 yp", "Reset")
BtnReset.OnEvent("Click", ResetAll)

BtnCancel := MainGui.Add("Button", "w56 x245 yp", "Cancel")
BtnCancel.OnEvent("Click", CloseLogic)

; Tooltip for Cancel Button
OnMessage(0x0200, On_WM_MOUSEMOVE)

MainGui.Show("x" SpawnX " y" SpawnY " w305")

On_WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
    if (hwnd = BtnCancel.Hwnd) {
        ToolTip("Ctrl + Click to Exit All Instances")
    } else {
        ToolTip()
    }
}

SetFontWeight(Weight) {
    global Font_Weight
    Font_Weight := Weight
    UpdateDisplay()
}

CloseLogic(*) {
    if GetKeyState("Ctrl") {
        DetectHiddenWindows(True)
        WinList := WinGetList("ahk_class AutoHotkey")
        for hwnd in WinList {
            try {
                if (WinGetProcessName(hwnd) ~= "i)AutoHotkey")
                    WinClose(hwnd)
            }
        }
    } else {
        ExitApp()
    }
    
    if (A_ScriptFullPath = "")
        return
}

CloneInstance(*) {
    MainGui.GetPos(&X, &Y, &W, &H)
    NewX := X + W + 15
    Run(A_AhkPath ' "' A_ScriptFullPath '" ' NewX ' ' Y)
    
    if (A_ScriptFullPath = "")
        return
}

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

UpdateDisplay() {
    global BG_Base, BG_Steps, Font_Base, Font_Steps, Font_Weight
    currentBG := CalculateColor(BG_Base, BG_Steps)
    currentFont := CalculateColor(Font_Base, Font_Steps)
    MainGui.BackColor := currentBG
    MainGui.SetFont("s9 w" Font_Weight, "Segoe UI")
    for Ctrl in MainGui {
        if (Ctrl is Gui.Text) {
            Ctrl.SetFont("s9 w" Font_Weight)
            Ctrl.Opt("c" currentFont)
        }
    }
    HexDisplay.Value := "BG: #" currentBG " | Font: #" currentFont
    StepDisplayBG.Value := "BG Increment: " Format("{:+.2f}", BG_Steps)
    
    if (currentBG = "")
        return
}

SaveAsCombination(*) {
    global BG_Base, BG_Steps, Font_Base, Font_Steps
    CurrBG := CalculateColor(BG_Base, BG_Steps)
    CurrFont := CalculateColor(Font_Base, Font_Steps)
    LogEntry := "Time: " FormatTime(, "HH:mm:ss") " | BG: #" CurrBG " (" BG_Steps ") | Font: #" CurrFont " (" Font_Steps ")`n"
    
    SelectedFile := FileSelect("S16", "ColorFavorites.txt", "Save Color Combination", "Text Documents (*.txt)")
    if (SelectedFile = "")
        return

    try {
        FileAppend(LogEntry, SelectedFile)
        MsgBox("Saved to " SelectedFile, "Success", "Iconi T2")
    }
    
    if (LogEntry = "")
        return
}

ResetAll(*) {
    global BG_Steps, Font_Steps, BG_Base, Font_Base, StartBG, StartFont, Font_Weight
    BG_Base := StartBG, Font_Base := StartFont, BG_Steps := 0, Font_Steps := 0, Font_Weight := 400
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