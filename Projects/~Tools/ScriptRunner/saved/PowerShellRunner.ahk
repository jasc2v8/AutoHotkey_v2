; TITLE  :  RunPS v1.0
; SOURCE :  Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force

; --- Tray Icon ---
TraySetIcon("powershell_ise.exe", 1)

; --- Global Variables ---
global OriginalText := "" 

; --- Color Definitions ---
psBlue    := "012456"
psWhite   := "FFFFFF"

; --- GUI Creation ---
MyGui := Gui("+Resize", "PowerShell Editor & Runner v1.0")

; Top Row: Path and Selection
MyGui.Add("Text", "vTxtSelected", "Selected Script:")
EditPath := MyGui.Add("Edit", "vEditPath w460 r1 ReadOnly", "No file selected...")
BtnSelect := MyGui.Add("Button", "vBtnSelect x+10 w80", "Browse")
BtnReload := MyGui.Add("Button", "vBtnReload x+5 w80", "Reload")

MyGui.Add("Text", "vTxtEdit xm", "Edit Script / Output Results:")

; Middle: PowerShell-themed Editor
MyGui.SetFont("s10 c" psWhite, "Consolas")
EditPreview := MyGui.Add("Edit", "vEditPreview xm w680 r22 Multi +HScroll +Background" psBlue)
MyGui.SetFont()

; Bottom Row: Actions
BtnClear  := MyGui.Add("Button", "vBtnClear xm w100", "Clear")
BtnSaveAs := MyGui.Add("Button", "vBtnSaveAs x+10 w120", "Save As...")
BtnRunStd := MyGui.Add("Button", "vBtnRunStd x+10 w120", "Run (Standard)")
BtnRunAdm := MyGui.Add("Button", "vBtnRunAdm x+10 w140 Default", "Run as Admin")
BtnCancel := MyGui.Add("Button", "vBtnCancel x+10 w100", "Cancel")

; Add UAC Shield icon
SendMessage(BCM_SETSHIELD:=0x160C, 0, 1, BtnRunAdm.Hwnd)

; Initialize buttons as disabled
BtnReload.Enabled := false
BtnSaveAs.Enabled := false
BtnRunStd.Enabled := false
BtnRunAdm.Enabled := false

; --- Event Handlers ---
BtnSelect.OnEvent("Click", SelectFile)
BtnReload.OnEvent("Click", ReloadFile)
BtnClear.OnEvent("Click", ClearEditor)
BtnSaveAs.OnEvent("Click", SaveAs)
BtnRunStd.OnEvent("Click", (*) => ExecuteScript(false))
BtnRunAdm.OnEvent("Click", (*) => ExecuteScript(true))
BtnCancel.OnEvent("Click", SafeExit)
MyGui.OnEvent("Close", SafeExit)
MyGui.OnEvent("Size", Gui_Size)

MyGui.Show()

; --- Functions ---

Gui_Size(thisGui, MinMax, Width, Height) {
    if (MinMax = -1)
        return
    margin := 10, btnW := 80
    
    ; Top Row
    BtnReload.Move(Width - margin - btnW)
    BtnSelect.Move(Width - margin - (btnW * 2) - 5)
    EditPath.Move(,, Width - (btnW * 2) - 130)
    
    ; Editor
    EditPreview.Move(,, Width - (margin * 2), Height - 140)
    
    ; Bottom Row
    BtnClear.Move(, Height - 40)
    BtnSaveAs.Move(, Height - 40)
    BtnRunStd.Move(, Height - 40)
    BtnRunAdm.Move(, Height - 40)
    BtnCancel.Move(, Height - 40)
}

ClearEditor(*) {
    global OriginalText
    if (EditPreview.Value != "" && EditPreview.Value != OriginalText) {
        if (MsgBox("Clear the editor? Unsaved changes will be lost.", "Clear", "YesNo Icon!") = "No")
            return
    }
    EditPreview.Value := ""
    
    ; Disable execution and save buttons because there is no content
    BtnSaveAs.Enabled := BtnRunStd.Enabled := BtnRunAdm.Enabled := false
}

SafeExit(*) {
    global OriginalText
    if (EditPreview.Value != "" && EditPreview.Value != OriginalText) {
        if (MsgBox("You have unsaved changes. Exit anyway?", "Unsaved Changes", "YesNo Icon? Default2") = "No")
            return
    }
    ExitApp()
}

SelectFile(*) {
    global OriginalText
    if (f := FileSelect(3, , "Select a PowerShell Script", "Scripts (*.ps1)")) {
        EditPath.Value := f
        OriginalText := FileRead(f)
        EditPreview.Value := OriginalText
        
        ; Enable all action buttons
        BtnReload.Enabled := BtnSaveAs.Enabled := BtnRunStd.Enabled := BtnRunAdm.Enabled := true
    }
}

ReloadFile(*) {
    global OriginalText
    if !FileExist(EditPath.Value) || (EditPreview.Value != OriginalText && MsgBox("Discard changes?", "Reload", "YesNo") = "No")
        return
    
    EditPreview.Value := OriginalText := FileRead(EditPath.Value)
    
    ; Re-enable buttons in case they were disabled by a Clear
    BtnSaveAs.Enabled := BtnRunStd.Enabled := BtnRunAdm.Enabled := true
    
    ToolTip("Reloaded"), SetTimer(() => ToolTip(), -2000)
}

SaveAs(*) {
    global OriginalText
    if (f := FileSelect("S18", "Script.ps1", "Save As", "Scripts (*.ps1)")) {
        try {
            FileOpen(f, "w").Write(EditPreview.Value)
            OriginalText := EditPreview.Value, EditPath.Value := f
            
            ; Ensure buttons are enabled after saving
            BtnReload.Enabled := BtnSaveAs.Enabled := BtnRunStd.Enabled := BtnRunAdm.Enabled := true
            
            ToolTip("Saved"), SetTimer(() => ToolTip(), -2000)
        }
    }
}

ExecuteScript(AsAdmin) {
    if (p := EditPath.Value) = "" || p = "No file selected..."
        return
    
    TempFile := A_Temp "\ps_output.txt"
    try FileDelete(TempFile)
    
    EditPreview.Value := AsAdmin ? "--- RUNNING AS ADMIN ---" : "--- RUNNING ---"
    Prefix := AsAdmin ? "*RunAs " : ""
    
    try {
        RunWait(Prefix 'cmd.exe /c powershell.exe -ExecutionPolicy Bypass -File "' p '" > "' TempFile '" 2>&1', , "Hide")
        EditPreview.Value := FileExist(TempFile) ? "--- OUTPUT ---`r`n`r`n" FileRead(TempFile) : "--- NO OUTPUT ---"
    } catch Error as e {
        EditPreview.Value := "--- ERROR ---`n" e.Message
    }
}