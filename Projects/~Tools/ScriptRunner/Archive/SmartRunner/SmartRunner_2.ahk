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
cmdBlack  := "000000"
psWhite   := "FFFFFF"

; --- GUI Creation ---
MyGui := Gui("+Resize", "Universal Script Runner v1.4")

; Top Row: Path and Selection
MyGui.Add("Text", "vTxtSelected", "Selected Script:")
EditPath := MyGui.Add("Edit", "vEditPath w460 r1 ReadOnly", "No file selected...")
BtnSelect := MyGui.Add("Button", "vBtnSelect x+10 w80", "Browse")
BtnReload := MyGui.Add("Button", "vBtnReload x+5 w80", "Reload")

MyGui.Add("Text", "vTxtEdit xm", "Edit Script / Output Results:")

; Middle: Themed Editor
MyGui.SetFont("s10 c" psWhite, "Consolas")
EditPreview := MyGui.Add("Edit", "vEditPreview xm w750 r22 Multi +HScroll +Background" psBlue)
EditPreview.OnEvent("Change", (*) => UpdateStatusBar())
MyGui.SetFont()

; Bottom Row: Actions
BtnClear  := MyGui.Add("Button", "vBtnClear xm w100", "Clear")
BtnSaveAs := MyGui.Add("Button", "vBtnSaveAs x+10 w120", "Save As...")
BtnRunStd := MyGui.Add("Button", "vBtnRunStd x+10 w120", "Run & Capture")
BtnRunAdm := MyGui.Add("Button", "vBtnRunAdm x+10 w140 Default", "Run as Admin")
BtnCancel := MyGui.Add("Button", "vBtnCancel x+10 w100", "Cancel")

; Status Bar
SB := MyGui.Add("StatusBar")
SB.SetParts(150, 150)

SendMessage(0x160C, 0, 1, BtnRunAdm.Hwnd) ; BCM_SETSHIELD

; --- Event Handlers ---
BtnSelect.OnEvent("Click", SelectFile)
BtnReload.OnEvent("Click", ReloadFile)
BtnClear.OnEvent("Click", ClearEditor)
BtnSaveAs.OnEvent("Click", SaveAs)
BtnRunStd.OnEvent("Click", (*) => ExecuteScript(false))
BtnRunAdm.OnEvent("Click", (*) => ExecuteScript(true))
BtnCancel.OnEvent("Click", (*) => ExitApp())
MyGui.OnEvent("Size", Gui_Size)

UpdateStatusBar()
MyGui.Show()

; --- Functions ---

Gui_Size(thisGui, MinMax, Width, Height) {
    if (MinMax = -1)
        return
    margin := 10, btnW := 80
    BtnReload.Move(Width - margin - btnW)
    BtnSelect.Move(Width - margin - (btnW * 2) - 5)
    EditPath.Move(,, Width - (btnW * 2) - 130)
    EditPreview.Move(,, Width - (margin * 2), Height - 165)
    
    BtnClear.Move(, Height - 65), BtnSaveAs.Move(, Height - 65)
    BtnRunStd.Move(, Height - 65), BtnRunAdm.Move(, Height - 65), BtnCancel.Move(, Height - 65)
}

UpdateStatusBar() {
    SplitPath(EditPath.Value,,, &ext)
    mode := (StrLower(ext) = "bat" || StrLower(ext) = "cmd") ? "Mode: CMD/Batch" : "Mode: PowerShell"
    SB.SetText("Chars: " StrLen(EditPreview.Value), 1)
    SB.SetText(mode, 2)
    SB.SetText("Ready", 3)
}

UpdateTheme(FilePath) {
    SplitPath(FilePath,,, &ext)
    if (StrLower(ext) = "bat" || StrLower(ext) = "cmd") {
        EditPreview.Opt("+Background" cmdBlack)
    } else {
        EditPreview.Opt("+Background" psBlue)
    }
    EditPreview.Redraw()
    UpdateStatusBar()
}

SelectFile(*) {
    global OriginalText
    if (f := FileSelect(3, , "Select Script", "All Scripts (*.ps1; *.bat; *.cmd)")) {
        EditPath.Value := f
        OriginalText := FileRead(f)
        EditPreview.Value := OriginalText
        UpdateTheme(f)
    }
}

ReloadFile(*) {
    if FileExist(EditPath.Value) {
        EditPreview.Value := FileRead(EditPath.Value)
        UpdateTheme(EditPath.Value)
    }
}

ClearEditor(*) {
    EditPreview.Value := ""
    UpdateStatusBar()
}

SaveAs(*) {
    if (f := FileSelect("S18", "Script.ps1", "Save As", "PowerShell (*.ps1);;Batch (*.bat; *.cmd)")) {
        FileOpen(f, "w").Write(EditPreview.Value)
        EditPath.Value := f
        UpdateTheme(f)
    }
}

ExecuteScript(AsAdmin) {
    p := EditPath.Value
    if (p = "" || p = "No file selected...")
        return
    
    ; Determine if we are running a Batch file or PowerShell
    SplitPath(p,,, &ext)
    isBatch := (StrLower(ext) = "bat" || StrLower(ext) = "cmd")
    
    ; Use System Temp for Admin to avoid permission issues, User Temp for Standard
    ;tempDir := AsAdmin ? "C:\Windows\Temp" : A_Temp
    tempDir := A_Temp
    TempFile := tempDir "\script_output.txt"
    
    try {
        if FileExist(TempFile)
            FileDelete(TempFile)
    }

    EditPreview.Value := AsAdmin ? "--- RUNNING AS ADMIN ---" : "--- RUNNING ---"
    Prefix := AsAdmin ? "*RunAs " : ""
    
    try {
        if (isBatch) {
            ; Run as Command/Batch
            RunWait(Prefix 'cmd.exe /c "`"' p '`" > `"' TempFile '`" 2>&1"', , "Hide")
        } else {
            ; Run as PowerShell
            RunWait(Prefix 'cmd.exe /c powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' p '" > "' TempFile '" 2>&1', , "Hide")
        }
        
        ; Allow a moment for the file system to release the lock
        Sleep(200)
        
        if FileExist(TempFile) {
            EditPreview.Value := "--- OUTPUT ---`r`n`r`n" FileRead(TempFile)
            ; Clean up the temp file after reading
            try FileDelete(TempFile)
        } else {
            EditPreview.Value := "--- NO OUTPUT ---"
        }
    } catch Error as e {
        EditPreview.Value := "--- ERROR ---`n" e.Message
    }
}
