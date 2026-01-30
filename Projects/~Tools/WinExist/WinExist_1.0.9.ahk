; TITLE   : WinExist
; SOURCE  : jasc2v8
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : 

/*
  TODO:

*/
; Version v1.0.9
#Requires AutoHotkey 2+
#SingleInstance Force
TraySetIcon("shell32.dll", 24) ; Blue circle with white ?


MainGui := Gui("+AlwaysOnTop", "WinExist Checker")
MainGui.SetFont("s9", "Segoe UI")

MainGui.Add("Text",, "Enter Window Title / AHK Class:")
; Added default title "AhkLauncher"
EditTitle := MainGui.Add("Edit", "w300 vWinTitle", "AhkLauncher")

MainGui.Add("Text",, "SetTitleMatchMode:")
DdlMatchMode := MainGui.Add("DropDownList", "Choose2 vMatchMode", ["1 (Starts with)", "2 (Contains)", "3 (Exact)", "RegEx"])

CbHidden := MainGui.Add("Checkbox", "vDetectHidden", "DetectHiddenWindows")

BtnCheck := MainGui.Add("Button", "Default w80", "Check")
BtnCheck.OnEvent("Click", CheckWindow)

; Add Status Bar
SB := MainGui.Add("StatusBar")
SB.SetText(" Ready")

; Move the GUI to (100, 100)
MainGui.Show("x100 y100")

CheckWindow(*) {
    Saved := MainGui.Submit(false)
    
    ; Extract the correct mode from the string
    SelectedMode := (Saved.MatchMode = "RegEx") ? "RegEx" : SubStr(Saved.MatchMode, 1, 1)
    
    ; Apply Settings
    DetectHiddenWindows(Saved.DetectHidden)
    SetTitleMatchMode(SelectedMode)
    
    if (Saved.WinTitle = "")
        return

    if WinExist(Saved.WinTitle)
    {
        SB.SetText(" Status: EXISTS (" . Saved.WinTitle . ")")
        SB.SetIcon("shell32.dll", 295) ; Green check icon
    }
    else
    {
        SB.SetText(" Status: NOT FOUND (" . Saved.WinTitle . ")")
        SB.SetIcon("shell32.dll", 132) ; Red X icon
    }
}

GuiClose(*) {
    ExitApp()
}