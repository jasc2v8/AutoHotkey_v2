#Requires AutoHotkey v2.0

; --- Admin Rights Check ---
if !A_IsAdmin {
    try {
        if A_IsCompiled
            Run('*RunAs "' A_ScriptFullPath '" /restart')
        else
            Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
    }
    ExitApp()
}

TraySetIcon("shell32.dll", 45)

global IL_Large := 0
global IL_Small := 0

; --- UI Setup ---
InstallGui := Gui(, "AHK Zip Installer (Admin)")
InstallGui.BackColor := "White"
InstallGui.SetFont("s12", "Segoe UI")

InstallGui.Add("Text", "w700", "1. Select ZIP Package:")
ZipPath := InstallGui.Add("Edit", "w550 r1 ReadOnly", "")
BtnBrowse := InstallGui.Add("Button", "x+8 w140 h35", Chr(0x1F441) " Browse...")

InstallGui.Add("Text", "xm y+18", "2. Install to Folder:")
DestPath := InstallGui.Add("Edit", "w550 r1", A_ProgramFiles "\MyNewApp")
BtnFolder := InstallGui.Add("Button", "x+8 w140 h35", Chr(0x1F441) " Folder...")

; --- Options ---
InstallGui.SetFont("s11")
CreateShortcut := InstallGui.Add("Checkbox", "xm y+15 Checked", "Create Desktop Shortcut")
LaunchAfter    := InstallGui.Add("Checkbox", "xm Checked", "Launch application after install")

ViewReadme     := InstallGui.Add("Checkbox", "x+60 yp-26 Checked", "View Readme file after install")
CloseFinished  := InstallGui.Add("Checkbox", "xp y+5 Checked", "Close installer when finished")

; --- Progress Bar ---
InstallGui.SetFont("s12")
ProgBar := InstallGui.Add("Progress", "xm y+20 w700 h20 -Smooth +0x8", 0)

; --- Log Window (MAX HEIGHT: r22) ---
InstallGui.SetFont("s9", "Consolas")
LogWin := InstallGui.Add("Edit", "xm w700 r22 ReadOnly +VScroll", "Log initialized...`r`n")

; --- Action Buttons ---
InstallGui.SetFont("s12", "Segoe UI")
InstallBtn := InstallGui.Add("Button", "xm y+15 w140 h50 Default", Chr(0x1F4E5) " Install")
ExportBtn  := InstallGui.Add("Button", "x+10 w140 h50", Chr(0x1F4BE) " Export Log")
ClearBtn   := InstallGui.Add("Button", "x+10 w140 h50", Chr(0x1F5D1) " Clear Log")
CancelBtn  := InstallGui.Add("Button", "x+10 w140 h50", Chr(0x274C) " Cancel")

; Hidden Open Folder Button (reveals on success)
OpenFolderBtn := InstallGui.Add("Button", "xm y+10 w140 h50 Hidden", Chr(0x1F441) " Open Folder")

; --- Bottom Status Bar ---
InstallGui.SetFont("s11", "Segoe UI")
StatusText := InstallGui.Add("Text", "xm y+15 w550 cGray", "Ready to install.")
InstallGui.SetFont("s8 cGray")
InstallGui.Add("Text", "x620 yp+5 w80 Right", "v1.1.8") 

; --- Events ---
BtnBrowse.OnEvent("Click", SelectZipManual)
BtnFolder.OnEvent("Click", SelectFolderModern)
InstallBtn.OnEvent("Click", StartInstallation)
ExportBtn.OnEvent("Click", ExportLogFile)
ClearBtn.OnEvent("Click", (*) => (LogWin.Value := "Log cleared...`r`n", AddLog("Ready.")))
CancelBtn.OnEvent("Click", (*) => ExitApp()) 
OpenFolderBtn.OnEvent("Click", (*) => Run(DestPath.Value))
InstallGui.OnEvent("Close", (*) => ExitApp())
InstallGui.OnEvent("Escape", (*) => ExitApp())

AddLog(Txt) {
    LogWin.Value .= Txt "`r`n"
    SendMessage(0x0115, 7, 0, LogWin.Hwnd, "User32.dll")
}

SelectZipManual(*) {
    f := FileSelect(3,, "Select ZIP Package", "ZIP Archives (*.zip; *.7z)")
    if f {
        ZipPath.Value := f
        AddLog("Selected ZIP: " f)
    }
}

SelectFolderModern(*) {
    SelectedDir := FileSelect("D 3", A_ProgramFiles, "Select Destination Folder")
    if SelectedDir {
        DestPath.Value := SelectedDir
        AddLog("Destination: " SelectedDir)
    }
}

ExportLogFile(*) {
    SavePath := FileSelect("S16", "InstallLog.txt", "Save Log As", "Text Documents (*.txt)")
    if SavePath {
        if FileExist(SavePath)
            FileDelete(SavePath)
        FileAppend(LogWin.Value, SavePath)
        MsgBox("Log exported successfully.", "Success", "Iconi")
    }
}

StartInstallation(*) {
    if !ZipPath.Value {
        MsgBox("Please select a ZIP file first.", "Error", "Icon!")
        return
    }

    StatusText.Value := "Extracting... please wait."
    InstallBtn.Enabled := false
    SendMessage(0x040A, 1, 50, ProgBar.Hwnd) 

    try {
        if !DirExist(DestPath.Value)
            DirCreate(DestPath.Value)

        shell := ComObject("Shell.Application")
        zipFolder := shell.NameSpace(ZipPath.Value)
        destFolder := shell.NameSpace(DestPath.Value)
        
        items := zipFolder.Items
        AddLog("Extracting " items.Count " items...")

        for item in items {
            AddLog("File: " item.Name)
            destFolder.CopyHere(item, 4 | 16)
        }

        exeName := ""
        Loop Files, DestPath.Value "\*.exe" {
            exeName := A_LoopFileName
            if CreateShortcut.Value
                FileCreateShortcut(A_LoopFileFullPath, A_Desktop "\" A_LoopFileName ".lnk")
            break 
        }

        batContent := "@echo off`ntitle Uninstaller`necho Deleting shortcut...`nif exist `"%A_Desktop%\" exeName ".lnk`" del `"%A_Desktop%\" exeName ".lnk`"`necho Deleting files...`ntimeout /t 1 /nobreak > nul`nrd /s /q `"" DestPath.Value "`"`necho Done.`npause"
        FileOpen(DestPath.Value "\uninstall.bat", "w").Write(batContent)

        if ViewReadme.Value {
            Loop Files, DestPath.Value "\*.*" {
                if (InStr(A_LoopFileName, "read") && InStr(A_LoopFileName, "me")) {
                    Run(A_LoopFileFullPath)
                    break
                }
            }
        }

        SendMessage(0x040A, 0, 0, ProgBar.Hwnd) 
        ProgBar.Opt("-0x8") 
        ProgBar.Value := 100
        StatusText.SetFont("cGreen Bold")
        StatusText.Value := Chr(0x2714) " Installation Successful!"
        OpenFolderBtn.Visible := true

        if LaunchAfter.Value && exeName != ""
            Run(DestPath.Value "\" exeName)

        if CloseFinished.Value
            SetTimer(() => ExitApp(), -3000)
        
    } catch Error as err {
        SendMessage(0x040A, 0, 0, ProgBar.Hwnd)
        MsgBox("Failed: " err.Message, "Error", "IconX")
        StatusText.Value := "Failed."
    }
    InstallBtn.Enabled := true
}

InstallGui.Show()