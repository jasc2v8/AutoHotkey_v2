#Requires AutoHotkey v2.0+
#SingleInstance Force

; --- Tray Icon ---
TraySetIcon("cmd.exe")

; --- Global Variables ---
global OriginalText := "" 
global FullPath := "No file selected..."

; --- Color Definitions ---
psBlue    := "012456"
cmdBlack  := "000000"
psWhite   := "FFFFFF"

; --- GUI Creation ---
MyGui := Gui("+Resize +MinSize520x400 +0x02000000", "Universal Script Runner v5.1")

; Top Row: Path and Selection
MyGui.Add("Text", "vTxtSelected", "Selected Script:")
EditPath := MyGui.Add("Edit", "vEditPath w520 r1 ReadOnly", FullPath)
EditPath.OnEvent("ContextMenu", ShowPathMenu)
BtnSelect := MyGui.Add("Button", "vBtnSelect x+10 w70", "Browse")
BtnReload := MyGui.Add("Button", "vBtnReload x+5 w70", "Reload")

MyGui.Add("Text", "vTxtEdit xm", "Edit Script / Output Results:")

; Middle: Themed Editor
MyGui.SetFont("s10 c" psWhite, "Consolas")
EditPreview := MyGui.Add("Edit", "vEditPreview xm w750 r22 Multi +HScroll +Background" cmdBlack)
EditPreview.OnEvent("Change", (*) => UpdateStatusBar())
EditPreview.OnEvent("ContextMenu", ShowEditorMenu)
MyGui.SetFont()

; Bottom Row: Actions
BtnClear   := MyGui.Add("Button", "vBtnClear xm w60", "Clear")
BtnSave    := MyGui.Add("Button", "vBtnSave x+8 w60", "Save")
BtnSaveAs  := MyGui.Add("Button", "vBtnSaveAs x+8 w80", "Save As...")
BtnRun     := MyGui.Add("Button", "vBtnRun x+8 w80", "Run")
BtnRunAdm  := MyGui.Add("Button", "vBtnRunAdm x+8 w110 Default", "Run as Admin")
BtnCancel  := MyGui.Add("Button", "vBtnCancel x+8 w70", "Cancel")

; Status Bar
SB := MyGui.Add("StatusBar")
SB.SetParts(100, 100)

SendMessage(0x160C, 0, 1, BtnRunAdm.Hwnd) ; BCM_SETSHIELD

; --- Context Menus ---
EditorMenu := Menu()
EditorMenu.Add("&Undo", (*) => PostMessage(0x304, 0, 0, EditPreview.Hwnd))
EditorMenu.Add()
EditorMenu.Add("Cu&t", (*) => PostMessage(0x300, 0, 0, EditPreview.Hwnd))
EditorMenu.Add("&Copy", (*) => PostMessage(0x301, 0, 0, EditPreview.Hwnd))
EditorMenu.Add("&Paste", (*) => PostMessage(0x302, 0, 0, EditPreview.Hwnd))
EditorMenu.Add()
EditorMenu.Add("Select &All", (*) => SendMessage(0x0B1, 0, -1, EditPreview.Hwnd))

PathMenu := Menu()
PathMenu.Add("&Copy Path", (*) => A_Clipboard := FullPath)

; --- Event Handlers ---
BtnSelect.OnEvent("Click", SelectFile)
BtnReload.OnEvent("Click", ReloadFile)
BtnClear.OnEvent("Click", ClearEditor)
BtnSave.OnEvent("Click", SaveFile)
BtnSaveAs.OnEvent("Click", SaveAs)
BtnRun.OnEvent("Click", (*) => ExecuteScript(false))
BtnRunAdm.OnEvent("Click", (*) => ExecuteScript(true))
BtnCancel.OnEvent("Click", (*) => ExitApp())
MyGui.OnEvent("Size", Gui_Size)

UpdateStatusBar("Ready")
MyGui.Show()

; --- Functions ---

ShowEditorMenu(*) {
    EditorMenu.Show()
}

ShowPathMenu(*) {
    PathMenu.Show()
}

Gui_Size(thisGui, MinMax, Width, Height) {
    if (MinMax = -1)
        return
        
    margin := 10, topBtnW := 70
    
    ; Stable top row resizing
    BtnReload.Move(Width - margin - topBtnW)
    BtnSelect.Move(Width - margin - (topBtnW * 2) - 5)
    
    ; Strict width calculation to prevent Browse button bleed
    pathW := Width - (topBtnW * 2) - 135
    EditPath.Move(,, pathW)
    
    ; Stable middle editor resizing
    EditPreview.Move(,, Width - (margin * 2), Height - 165)
    
    ; Bottom row positions
    yPos := Height - 65
    BtnClear.Move(margin, yPos)
    BtnSave.Move(margin + 68, yPos)
    BtnSaveAs.Move(margin + 136, yPos)
    BtnRun.Move(margin + 224, yPos)
    BtnRunAdm.Move(margin + 312, yPos)
    BtnCancel.Move(margin + 430, yPos)
    
    for ctrl in thisGui {
        if (ctrl.Hwnd != EditPreview.Hwnd)
            ctrl.Redraw()
    }
}

UpdateStatusBar(statusText := "") {
    content := EditPreview.Value
    StrReplace(content, "`n", , , &lineCount)
    lineDisplay := (content = "") ? 0 : lineCount + 1
    
    SB.SetText("Lines: " lineDisplay, 1)
    SB.SetText("Chars: " StrLen(content), 2)
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
    global OriginalText, FullPath
    if (f := FileSelect(3, , "Select Script", "All Scripts (*.ps1; *.bat; *.cmd)")) {
        FullPath := f
        EditPath.Value := FullPath
        OriginalText := FileRead(f)
        EditPreview.Value := OriginalText
        UpdateTheme(f)
    }
}

ReloadFile(*) {
    if FileExist(FullPath) {
        EditPreview.Value := FileRead(FullPath)
        UpdateTheme(FullPath)
    }
}

ClearEditor(*) {
    EditPreview.Value := ""
    UpdateStatusBar("Ready")
}

SaveFile(*) {
    global FullPath
    if (FullPath = "" || FullPath = "No file selected...") {
        SaveAs()
        return
    }
    
    try {
        FileOpen(FullPath, "w").Write(EditPreview.Value)
        UpdateStatusBar("Saved successfully")
    } catch Error as e {
        UpdateStatusBar("Save failed")
    }
}

SaveAs(*) {
    global FullPath
    if (f := FileSelect("S18", "Script.ps1", "Save As", "PowerShell (*.ps1);;Batch (*.bat; *.cmd)")) {
        FileOpen(f, "w").Write(EditPreview.Value)
        FullPath := f
        EditPath.Value := FullPath
        UpdateTheme(f)
    }
}

ExecuteScript(AsAdmin) {
    p := FullPath
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