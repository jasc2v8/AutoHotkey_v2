; TITLE  :  VSCodeOpenIncludes v1.0.1.2
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Scans the script and opens all the #Include files in new editor tabs
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2+
#SingleInstance Force
#NoTrayIcon

; #region Globals


; if VSCode not active then return
if !WinActive("ahk_exe Code.exe")
    return

vsCodePath := EnvGet("LOCALAPPDATA") "\Programs\Microsoft VS Code\Code.exe"

TraySetIcon(vsCodePath)

; #region Main

;
;
;
;
;
;


#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)

/**
 * Script: Include Scanner
 * Version: 1.0.1.2
 * Description: Automatically scans the active window for #Include files.
 * Change: Updated Run command to use specific VS Code path from LOCALAPPDATA.
 */

vVersion := "1.0.1.2"
vsCodePath := EnvGet("LOCALAPPDATA") "\Programs\Microsoft VS Code\Code.exe"
Global MyGui := unset

; Run the main function immediately upon script execution
ScanAndManageIncludes()

ScanAndManageIncludes() {

    ; Ensure the editor window is selected before copyin
    if WinExist("ahk_exe Code.exe")
        WinActivate("ahk_exe Code.exe")

    ; Give the user a moment to ensure the editor is focused
    Sleep(250)
    
    ; Save clipboard to restore later
    OldClipboard := A_Clipboard
    A_Clipboard := ""
    
    ; Copy text from active window
    Send("^a")
    Sleep(50)
    Send("^c")
    
    if (!ClipWait(2))
    {
        MsgBox("Failed to copy text from the active window.")
        A_Clipboard := OldClipboard
        return
    }

    ScriptContent := A_Clipboard
    A_Clipboard := OldClipboard

    if (ScriptContent = "")
        return

    ; Pattern using continuation section to handle literal quotes/brackets safely
    Pattern := "
    (Join
    i)^\s*#Include\s+["'<]?(.+?)["'>]?\s*$
    )"
    
    IncludeList := []
    Loop parse, ScriptContent, "`n", "`r" {
        if (RegExMatch(A_LoopField, Pattern, &Match))
        {
            ExtractedPath := Match[1]
            
            ; Check for extension; append .ahk if missing
            SplitPath(ExtractedPath, , , &Ext)
            if (Ext = "")
                ExtractedPath .= ".ahk"
                
            IncludeList.Push(ExtractedPath)
        }
    }

    if (IncludeList.Length = 0)
    {
        MsgBox("No #Include directives found in the active window.")
        return
    }

    ShowIncludeGui(IncludeList)
}

ShowIncludeGui(Files) {
    Global MyGui
    
    ; If a GUI already exists (from a Reload), destroy it first
    if IsSet(MyGui)
    {
        MyGui.Destroy()
    }

    MyGui := Gui("+AlwaysOnTop", "Include Manager v" vVersion)
    MyGui.SetFont("s10", "Segoe UI")
    
    MyGui.Add("Text",, "Select files to open in VS Code:")
    
    LB := MyGui.Add("ListBox", "r10 w400 Multi", Files)
    
    BtnOpen := MyGui.Add("Button", "w100 Default", "Open Selected")
    BtnOpen.OnEvent("Click", (*) => OpenFiles(LB, false))
    
    BtnOpenAll := MyGui.Add("Button", "x+10 w100", "Open All")
    BtnOpenAll.OnEvent("Click", (*) => OpenFiles(LB, true))
    
    BtnReload := MyGui.Add("Button", "x+10 w100", "Reload")
    BtnReload.OnEvent("Click", (*) => ScanAndManageIncludes())
    
    ; Ensure script exits when GUI is closed
    MyGui.OnEvent("Close", (*) => ExitApp())
    
    MyGui.Show()

    OpenFiles(ListBoxCtrl, OpenAll := false) {
        SelectedFiles := []
        
        if (OpenAll) {
            SelectedFiles := Files
        } else {
            ; Get selected items from ListBox
            For Index in ListBoxCtrl.Value {
                SelectedFiles.Push(Files[Index])
            }
        }

        if (SelectedFiles.Length = 0)
        {
            MsgBox("Please select at least one file.")
            return
        }

        for filePath in SelectedFiles {
            ; Clean up potential AHK variables if present
            cleanPath := StrReplace(filePath, "%A_ScriptDir%", A_InitialWorkingDir)
            
            try {
                ; Using the specific vsCodePath and wrapping in quotes for safety
                Run('"' vsCodePath '" "' cleanPath '"')
            } catch {
                MsgBox("Could not find VS Code at:`n" vsCodePath "`n`nOr the file path is invalid:`n" cleanPath)
            }
        }
        
        ExitApp()
    }
}