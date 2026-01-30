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
TraySetIcon("cmd.exe")

; --- Global Variables ---
global OriginalText := "" 

; --- Color Definitions ---
psBlue    := "012456"
cmdBlack  := "000000"
psWhite   := "FFFFFF"

; --- GUI Creation ---
MyGui := Gui("+Resize", "Universal Script Runner v2.2")

; Top Row: Path and Selection
MyGui.Add("Text", "vTxtSelected", "Selected Script:")
; SS_PATHELLIPSIS (+0x8000) automatically handles path shortening
EditPath := MyGui.Add("Edit", "vEditPath w520 r1 ReadOnly +0x8000", "No file selected...")
BtnSelect := MyGui.Add("Button", "vBtnSelect x+10 w80", "Browse")
BtnReload := MyGui.Add("Button", "vBtnReload x+5 w80", "Reload")

MyGui.Add("Text", "vTxtEdit xm", "Edit Script / Output Results:")

; Middle: Themed Editor
MyGui.SetFont("s10 c" psWhite, "Consolas")
EditPreview := MyGui.Add("Edit", "vEditPreview xm w750 r22 Multi +HScroll +Background" cmdBlack)
EditPreview.OnEvent("Change", (*) => UpdateStatusBar())
EditPreview.OnEvent("ContextMenu", ShowContextMenu)
MyGui.SetFont()

; Bottom Row: Actions
BtnClear  := MyGui.Add("Button", "vBtnClear xm w100", "Clear")
BtnSaveAs := MyGui.Add("Button", "vBtnSaveAs x+10 w120", "Save As...")
BtnRunStd := MyGui.Add("Button", "vBtnRunStd x+10 w120", "Run (Standard)")
BtnRunAdm := MyGui.Add("Button", "vBtnRunAdm x+10 w140 Default", "Run as Admin")
BtnCancel := MyGui.Add("Button", "vBtnCancel x+10 w100", "Cancel")

; Status Bar
SB := MyGui.Add("StatusBar")
SB.SetParts(120, 120)

SendMessage(0x160C, 0, 1, BtnRunAdm.Hwnd) ; BCM_SETSHIELD

; --- Context Menu ---
EditorMenu := Menu()
EditorMenu.Add("&Undo", (*) => PostMessage(0x304, 0, 0, EditPreview.Hwnd))
EditorMenu.Add()
EditorMenu.Add("Cu&t", (*) => PostMessage(0x300, 0, 0, EditPreview.Hwnd))
EditorMenu.Add("&Copy", (*) => PostMessage(0x301, 0, 0, EditPreview.Hwnd))
EditorMenu.Add("&Paste", (*) => PostMessage(0x302, 0, 0, EditPreview.Hwnd))
EditorMenu.Add()
EditorMenu.Add("Select &All", (*) => SendMessage(0x0B1, 0, -1, EditPreview.Hwnd))

; --- Event Handlers ---
BtnSelect.OnEvent("Click", SelectFile)
BtnReload.OnEvent("Click", ReloadFile)
BtnClear.OnEvent("Click", ClearEditor)
BtnSaveAs.OnEvent("Click", SaveAs)
BtnRunStd.OnEvent("Click", (*) => ExecuteScript(false))
BtnRunAdm.OnEvent("Click", (*) => ExecuteScript(true))
BtnCancel.OnEvent("Click", (*) => ExitApp())
MyGui.OnEvent("Size", Gui_Size)

UpdateStatusBar("Ready")
MyGui.Show()

; --- Functions ---

ShowContextMenu(*) {
    EditorMenu.Show()
}

Gui_Size(thisGui, MinMax, Width, Height) {
    if (MinMax = -1)
        return
        
    margin := 10, btnW := 80
    
    ; Top Row Resizing
    BtnReload.Move(Width - margin - btnW)
    BtnSelect.Move(Width - margin - (btnW * 2) - 5)
    EditPath.Move(,, Width - (btnW * 2) - 130)
    
    ; Editor Resizing
    EditPreview.Move(,, Width - (margin * 2), Height - 165)
    
    ; Bottom Button Positioning
    yPos := Height - 65
    BtnClear.Move(margin, yPos)
    BtnSaveAs.Move(margin + 110, yPos)
    BtnRunStd.Move(margin + 240, yPos)
    BtnRunAdm.Move(margin + 370, yPos)
    BtnCancel.Move(margin + 520, yPos)
    
    ; Redraw Loop for all controls
    for ctrl in thisGui {
        ctrl.Redraw()
    }
}

UpdateStatusBar(statusText := "") {
    content := EditPreview.Value
    StrReplace(content, "`n", , , &lineCount)
    lineDisplay := (content = "") ? 0 : lineCount + 1
    
    SB.SetText("Chars: " StrLen(content), 1)
    SB.SetText("Lines: " lineDisplay, 2)
    if (statusText != "")
        SB.SetText(statusText, 3)
}

UpdateTheme(FilePath) {
    SplitPath(FilePath,,, &ext)
    if (StrLower(ext) = "bat" || StrLower(ext) = "cmd") {
        EditPreview.Opt("+Background" cmdBlack)
        TraySetIcon("cmd.exe")
        SendMessage(0x80, 0, LoadPicture("cmd.exe", "Icon1 w16 h16", &imgType), MyGui.Hwnd)
    } else {
        EditPreview.Opt("+Background" psBlue)
        TraySetIcon("powershell_ise.exe")
        SendMessage(0x80, 0, LoadPicture("powershell_ise.exe", "Icon1 w16 h16", &imgType), MyGui.Hwnd)
    }
    EditPreview.Redraw()
    UpdateStatusBar("Ready")
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
    UpdateStatusBar("Ready")
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
    
    UpdateStatusBar("Running...")
    
    SplitPath(p,,, &ext)
    isBatch := (StrLower(ext) = "bat" || StrLower(ext) = "cmd")
    
    TempFile := A_Temp "\script_output.txt"
    
    try {
        if FileExist(TempFile)
            FileDelete(TempFile)
    }

    EditPreview.Value := AsAdmin ? "--- RUNNING AS ADMIN ---" : "--- RUNNING ---"
    Prefix := AsAdmin ? "*RunAs " : ""
    
    try {
        if (isBatch) {
            RunWait(Prefix 'cmd.exe /c "`"' p '`" > `"' TempFile '`" 2>&1"', , "Hide")
        } else {
            RunWait(Prefix 'cmd.exe /c powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' p '" > "' TempFile '" 2>&1', , "Hide")
        }
        
        Sleep(250)
        
        if FileExist(TempFile) {
            EditPreview.Value := "--- OUTPUT ---`r`n`r`n" FileRead(TempFile)
            UpdateStatusBar("Ready")
            try FileDelete(TempFile)
        } else {
            EditPreview.Value := "--- NO OUTPUT ---"
            UpdateStatusBar("Ready")
        }
    } catch Error as e {
        EditPreview.Value := "--- ERROR ---`n" e.Message
        UpdateStatusBar("Error")
    }
}
