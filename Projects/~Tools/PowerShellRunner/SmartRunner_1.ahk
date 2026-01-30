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
MyGui := Gui("+Resize", "Universal Script Runner v1.2")

; Top Row: Path and Selection
MyGui.Add("Text", "vTxtSelected", "Selected Script:")
EditPath := MyGui.Add("Edit", "vEditPath w460 r1 ReadOnly", "No file selected...")
BtnSelect := MyGui.Add("Button", "vBtnSelect x+10 w80", "Browse")
BtnReload := MyGui.Add("Button", "vBtnReload x+5 w80", "Reload")

MyGui.Add("Text", "vTxtEdit xm", "Edit Script / Output Results:")

; Middle: Themed Editor (Defaults to Blue)
MyGui.SetFont("s10 c" psWhite, "Consolas")
EditPreview := MyGui.Add("Edit", "vEditPreview xm w750 r22 Multi +HScroll +Background" psBlue)
MyGui.SetFont()

; Bottom Row: Actions
BtnClear  := MyGui.Add("Button", "vBtnClear xm w100", "Clear")
BtnSaveAs := MyGui.Add("Button", "vBtnSaveAs x+10 w120", "Save As...")
BtnRunStd := MyGui.Add("Button", "vBtnRunStd x+10 w120", "Run & Capture")
BtnRunAdm := MyGui.Add("Button", "vBtnRunAdm x+10 w140 Default", "Run as Admin")
BtnCancel := MyGui.Add("Button", "vBtnCancel x+10 w100", "Cancel")

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

MyGui.Show()

; --- Functions ---

Gui_Size(thisGui, MinMax, Width, Height) {
    if (MinMax = -1)
        return
    margin := 10, btnW := 80
    BtnReload.Move(Width - margin - btnW)
    BtnSelect.Move(Width - margin - (btnW * 2) - 5)
    EditPath.Move(,, Width - (btnW * 2) - 130)
    EditPreview.Move(,, Width - (margin * 2), Height - 140)
    
    BtnClear.Move(, Height - 40), BtnSaveAs.Move(, Height - 40)
    BtnRunStd.Move(, Height - 40), BtnRunAdm.Move(, Height - 40), BtnCancel.Move(, Height - 40)
}

UpdateTheme(FilePath) {
    SplitPath(FilePath,,, &ext)
    if (StrLower(ext) = "bat" || StrLower(ext) = "cmd") {
        EditPreview.Opt("+Background" cmdBlack)
    } else {
        EditPreview.Opt("+Background" psBlue)
    }
    EditPreview.Redraw()
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
}

SaveAs(*) {
    if (f := FileSelect("S18", "Script.ps1", "Save As", "PowerShell (*.ps1);;Batch (*.bat; *.cmd)")) {
        FileOpen(f, "w").Write(EditPreview.Value)
        EditPath.Value := f
        UpdateTheme(f)
    }
}

ExecuteScript_TempFile(AsAdmin) {
    ScriptContent := EditPreview.Value
    if (ScriptContent = "")
        return
    
    SplitPath(EditPath.Value,,, &ext)
    ext := StrLower(ext)
    isBatch := (ext = "bat" || ext = "cmd")

    actualExt := isBatch ? "bat" : "ps1"
    TempScript := A_Temp "\TempRunner." actualExt
    TempOut := A_Temp "\script_output.txt"
    
    try {
        if FileExist(TempScript)
            FileDelete(TempScript)
        if FileExist(TempOut)
            FileDelete(TempOut)
            
        FileAppend(ScriptContent, TempScript)
        Prefix := AsAdmin ? "*RunAs " : ""
        
        if (isBatch) {
            ; Enhanced quoting to prevent "File Not Found" errors
            RunWait(Prefix 'cmd.exe /c `"" TempScript "`" > `"" TempOut "`" 2>&1', , "Hide")
        } else {
            psCmd := 'PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {& `"' TempScript '`" | Out-File -FilePath `"' TempOut '`" -Encoding utf8}"'
            RunWait(Prefix . psCmd, , "Hide")
        }
        
        Sleep(150) ; Buffer for file handle release
        
        if FileExist(TempOut) {
            OutText := FileRead(TempOut)
            EditPreview.Value := ScriptContent "`r`n`r`n--- OUTPUT ---`r`n" OutText
        } else {
            EditPreview.Value := ScriptContent "`r`n`r`n--- ERROR ---`nCapture failed. Check for anti-virus interference."
        }
    } catch Error as e {
        EditPreview.Value := ScriptContent "`r`n`r`n--- ERROR ---`n" e.Message
    }
}

ExecuteScript(AsAdmin) {
    ScriptContent := EditPreview.Value
    if (ScriptContent = "")
        return
    
    SplitPath(EditPath.Value,,, &ext)
    ext := StrLower(ext)
    isBatch := (ext = "bat" || ext = "cmd")

    actualExt := isBatch ? "bat" : "ps1"
    TempScript := A_Temp "\TempRunner." actualExt
    
    try {
        if FileExist(TempScript)
            FileDelete(TempScript)
        FileAppend(ScriptContent, TempScript)
        
        Prefix := AsAdmin ? "*RunAs " : ""
        OutText := ""

        if (AsAdmin) {
            ; Admin mode still requires a file because we cannot pipe directly from an elevated process
            TempOut := A_Temp "\script_output.txt"
            if FileExist(TempOut)
                FileDelete(TempOut)
            
            if (isBatch) {
                RunWait(Prefix 'cmd.exe /c `"" TempScript "`" > `"" TempOut "`" 2>&1', , "Hide")
            } else {
                psCmd := 'PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {& `"' TempScript '`" | Out-File -FilePath `"' TempOut '`" -Encoding utf8}"'
                RunWait(Prefix . psCmd, , "Hide")
            }
            
            Sleep(150)
            if FileExist(TempOut) {
                OutText := FileRead(TempOut)
                FileDelete(TempOut)
            }
        } else {
            ; Standard mode: Use COM to capture stream directly (No temp file needed for output)
            shell := ComObject("WScript.Shell")
            if (isBatch) {
                exec := shell.Exec(A_ComSpec " /c `"" TempScript "`"")
            } else {
                exec := shell.Exec("powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"" TempScript "`"")
            }
            OutText := exec.StdOut.ReadAll()
        }

        if (OutText != "") {
            EditPreview.Value := ScriptContent "`r`n`r`n--- OUTPUT ---`r`n" OutText
        } else {
            EditPreview.Value := ScriptContent "`r`n`r`n--- OUTPUT ---`r`n[No output returned from script]"
        }

    } catch Error as e {
        EditPreview.Value := ScriptContent "`r`n`r`n--- ERROR ---`n" e.Message
    }
}