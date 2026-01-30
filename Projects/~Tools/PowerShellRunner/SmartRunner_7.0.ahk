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
MyGui := Gui("+Resize +MinSize520x400 +0x02000000", "Universal Script Runner v7.0.0")

; --- Menus ---
FileMenu := Menu()
FileMenu.Add("&Open`tCtrl+O", (*) => SelectFile())
FileMenu.Add("&Reload`tCtrl+R", (*) => ReloadFile())
FileMenu.Add("&Save`tCtrl+S", (*) => SaveFile())
FileMenu.Add("Save &As...", (*) => SaveAs())
FileMenu.Add()
FileMenu.Add("Stay on &Top", ToggleAlwaysOnTop)
FileMenu.Add()
FileMenu.Add("E&xit", (*) => ExitApp())

HelpMenu := Menu()
HelpMenu.Add("&List Keys", ShowKeys)

Menus := MenuBar()
Menus.Add("&File", FileMenu)
Menus.Add("&Help", HelpMenu)
MyGui.MenuBar := Menus

; Top Row: Path Display
EditPath := MyGui.Add("Edit", "vEditPath xm w760 r1 -WantReturn", FullPath)
EditPath.OnEvent("ContextMenu", ShowPathMenu)
EditPath.OnEvent("Focus", (*) => SendMessage(0x0B1, 0, -1, EditPath.Hwnd)) ; Select all on focus

; Middle Label
MyGui.Add("Text", "vTxtEdit xm y+10", "Edit Script / Output Results:")

; Middle: Themed Editor
MyGui.SetFont("s10 c" psWhite, "Consolas")
EditPreview := MyGui.Add("Edit", "vEditPreview xm w780 r24 Multi +HScroll +Background" cmdBlack)
EditPreview.OnEvent("Change", (*) => UpdateStatusBar())
EditPreview.OnEvent("ContextMenu", ShowEditorMenu)
MyGui.SetFont()

; Bottom Row: Actions
BtnClear   := MyGui.Add("Button", "vBtnClear xm w60", "Clear")
BtnRun     := MyGui.Add("Button", "vBtnRun w80", "Run")
BtnRunAdm  := MyGui.Add("Button", "vBtnRunAdm w110 Default", "Run as Admin")
BtnCancel  := MyGui.Add("Button", "vBtnCancel w70", "Cancel")

; Status Bar
SB := MyGui.Add("StatusBar")
SB.SetParts(100, 100)

SendMessage(0x160C, 0, 1, BtnRunAdm.Hwnd) ; BCM_SETSHIELD

; --- Hotkeys ---
#HotIf WinActive("ahk_id " MyGui.Hwnd)
^s::SaveFile()
^o::SelectFile()
^r::ReloadFile()
F5::ExecuteScript(false)
^F5::ExecuteScript(true)

; Capture Enter in the Path box
$Enter::
{
    if (MyGui.FocusedCtrl = EditPath) {
        LoadManualPath()
    } else {
        Send("{Enter}")
    }
}
#HotIf

; --- Event Handlers ---
BtnClear.OnEvent("Click", ClearEditor)
BtnRun.OnEvent("Click", (*) => ExecuteScript(false))
BtnRunAdm.OnEvent("Click", (*) => ExecuteScript(true))
BtnCancel.OnEvent("Click", (*) => ExitApp())
MyGui.OnEvent("Size", Gui_Size)
MyGui.OnEvent("DropFiles", OnDropFiles)

UpdateStatusBar("Ready")
MyGui.Show("w800 Center")

; --- Functions ---

OnDropFiles(GuiObj, GuiCtrl, FileArray, X, Y) {
    droppedFile := FileArray[1]
    EditPath.Value := droppedFile
    LoadManualPath()
}

LoadManualPath() {
    ; Sanitize input: remove quotes and trim whitespace
    path := Trim(StrReplace(EditPath.Value, '"', ""))
    EditPath.Value := path
    
    if !FileExist(path) {
        SoundBeep(750, 200)
        UpdateStatusBar("File not found")
        return
    }

    try {
        scriptData := FileRead(path)
        EditPreview.Value := scriptData
        UpdateTheme(path)
        ScrollPathToEnd()
        UpdateStatusBar("File loaded")
        EditPreview.Focus() ; Move focus to the editor after loading
    } catch {
        SoundBeep(750, 200)
        UpdateStatusBar("Error reading file")
    }
}

ToggleAlwaysOnTop(ItemName, ItemPos, MyMenu) {
    if (MyMenu.IsChecked(ItemName)) {
        MyMenu.Uncheck(ItemName)
        MyGui.Opt("-AlwaysOnTop")
    } else {
        MyMenu.Check(ItemName)
        MyGui.Opt("+AlwaysOnTop")
    }
}

ShowKeys(*) {
    ShortcutText := "
    (
    Keyboard Shortcuts:

    Ctrl + O : Open File
    Ctrl + R : Reload File
    Ctrl + S : Save File
    F5 : Run Script
    Ctrl + F5 : Run as Admin
    Enter (in path box) : Load Path
    Drag & Drop : Load File
    )"
    MsgBox(ShortcutText, "Shortcut Keys")
}

ShowEditorMenu(*) {
    EditorMenu := Menu()
    EditorMenu.Add("&Undo", (*) => PostMessage(0x304, 0, 0, EditPreview.Hwnd))
    EditorMenu.Add()
    EditorMenu.Add("Cu&t", (*) => PostMessage(0x300, 0, 0, EditPreview.Hwnd))
    EditorMenu.Add("&Copy", (*) => PostMessage(0x301, 0, 0, EditPreview.Hwnd))
    EditorMenu.Add("&Paste", (*) => PostMessage(0x302, 0, 0, EditPreview.Hwnd))
    EditorMenu.Add()
    EditorMenu.Add("Select &All", (*) => SendMessage(0x0B1, 0, -1, EditPreview.Hwnd))
    EditorMenu.Show()
}

ShowPathMenu(*) {
    PathMenu := Menu()
    PathMenu.Add("&Copy Path", (*) => A_Clipboard := EditPath.Value)
    PathMenu.Add("&Open File Location", (*) => Run('explorer.exe /select,"' EditPath.Value '"'))
    PathMenu.Show()
}

Gui_Size(thisGui, MinMax, Width, Height) {
    if (MinMax = -1)
        return
        
    margin := 10
    scrollBarWidth := 20
    
    EditPath.Move(,, Width - (margin * 2) - scrollBarWidth)
    EditPreview.Move(,, Width - (margin * 2), Height - 165)
    
    yPos := Height - 65
    BtnClear.Move(margin, yPos)
    BtnRun.Move(margin + 75, yPos)
    BtnRunAdm.Move(margin + 170, yPos)
    BtnCancel.Move(margin + 295, yPos)
    
    ScrollPathToEnd()
    
    for ctrl in thisGui {
        if (ctrl is Gui.Button) {
            ctrl.Redraw()
        }
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

ScrollPathToEnd() {
    SendMessage(0x00B1, -1, -1, EditPath.Hwnd) ; EM_SETSEL
    SendMessage(0x00B7, 0, 0, EditPath.Hwnd)   ; EM_SCROLLCARET
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
    
    currentPath := EditPath.Value
    startDir := ""
    if (currentPath != "" && currentPath != "No file selected...") {
        SplitPath(currentPath,, &dir)
        if (DirExist(dir))
            startDir := dir
    }

    if (f := FileSelect(3, startDir, "Select Script", "All Scripts (*.ps1; *.bat; *.cmd)")) {
        FullPath := f
        EditPath.Value := FullPath
        ScrollPathToEnd()
        OriginalText := FileRead(f)
        EditPreview.Value := OriginalText
        UpdateTheme(f)
    }
}

ReloadFile(*) {
    pathToCheck := EditPath.Value
    if FileExist(pathToCheck) {
        EditPreview.Value := FileRead(pathToCheck)
        UpdateTheme(pathToCheck)
        ScrollPathToEnd()
    }
}

ClearEditor(*) {
    EditPreview.Value := ""
    UpdateStatusBar("Ready")
}

SaveFile(*) {
    pathToCheck := EditPath.Value
    if (pathToCheck = "" || pathToCheck = "No file selected...") {
        SaveAs()
        return
    }
    
    try {
        FileOpen(pathToCheck, "w").Write(EditPreview.Value)
        UpdateStatusBar("Saved successfully")
    } catch {
        UpdateStatusBar("Save failed")
    }
}

SaveAs(*) {
    global FullPath
    if (f := FileSelect("S18", "Script.ps1", "Save As", "PowerShell (*.ps1);;Batch (*.bat; *.cmd)")) {
        FileOpen(f, "w").Write(EditPreview.Value)
        FullPath := f
        EditPath.Value := FullPath
        ScrollPathToEnd()
        UpdateTheme(f)
    }
}

ExecuteScript(AsAdmin) {
    p := EditPath.Value
    if (p = "" || p = "No file selected..." || !FileExist(p))
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