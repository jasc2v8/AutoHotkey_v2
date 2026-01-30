#Requires AutoHotkey v2.0
#SingleInstance Force

try TraySetIcon("shell32.dll", 297)

/**
 * Script Merger v1.0.1.6
 * Updated: Increased vertical offset for the checkbox row.
 */

; GUI Creation
MyGui := Gui("+Resize +MinSize460x420", "Script Merger v1.0.1.6")
MyGui.BackColor := "72A0C1" ; AirSuperiorityBlue
MyGui.SetFont("s10", "Segoe UI")

; Events
MyGui.OnEvent("Size", Gui_Size)
MyGui.OnEvent("DropFiles", Gui_DropFiles)

MyGui.Add("Text", "w440 vTitleText", "Select and order the AHK v2 scripts to combine:")
FileList := MyGui.Add("ListBox", "r10 w440 vSelectedFiles")

; Top Row Buttons
BtnAdd := MyGui.Add("Button", "y+15 w70 vBtnAdd", "Add")
BtnAdd.OnEvent("Click", AddFiles)

BtnClear := MyGui.Add("Button", "x+8 yp w70 vBtnClear", "Clear")
BtnClear.OnEvent("Click", (*) => FileList.Delete())

BtnDelete := MyGui.Add("Button", "x+8 yp w85 vBtnDelete", "Delete Item")
BtnDelete.OnEvent("Click", RemoveSelected)

BtnUp := MyGui.Add("Button", "x+8 yp w70 vBtnUp", "Up")
BtnUp.OnEvent("Click", MoveUp)

BtnDown := MyGui.Add("Button", "x+8 yp w70 vBtnDown", "Down")
BtnDown.OnEvent("Click", MoveDown)

; Options - Moved down slightly (y+15 instead of y+12)
ChkRemoveInclude := MyGui.Add("Checkbox", "xm y+15 vRemoveInclude Checked", "Comment out #Include directives")
ChkStripComments := MyGui.Add("Checkbox", "x+20 yp vStripComments", "Strip all comments")

; Bottom Row Buttons
BtnMerge := MyGui.Add("Button", "Default w140 xm y+12 vBtnMerge", "Merge and Save As...")
BtnMerge.OnEvent("Click", MergeScripts)

BtnFolder := MyGui.Add("Button", "x+10 yp w100 vBtnFolder", "Open Folder")
BtnFolder.OnEvent("Click", OpenSelectedDir)

BtnCancel := MyGui.Add("Button", "x+10 yp w90 vBtnCancel", "Cancel")
BtnCancel.OnEvent("Click", (*) => ExitApp())

MyGui.Show()

; --- Functions ---

Gui_Size(GuiObj, WindowMinMax, Width, Height) {
    if (WindowMinMax = -1)
        return

    ; Reposition ListBox
    GuiObj["TitleText"].Move(,, Width - 20)
    GuiObj["SelectedFiles"].Move(,, Width - 20, Height - 155)

    ; Calculate Y Positions
    BtnY := Height - 118   ; Top buttons stay here
    OptY := Height - 78    ; Checkboxes moved down slightly
    MergeY := Height - 42  ; Bottom buttons stay here

    ; Move controls
    Controls := ["BtnAdd", "BtnClear", "BtnDelete", "BtnUp", "BtnDown", "RemoveInclude", "StripComments", "BtnMerge", "BtnFolder", "BtnCancel"]
    
    GuiObj["BtnAdd"].Move(, BtnY)
    GuiObj["BtnClear"].Move(, BtnY)
    GuiObj["BtnDelete"].Move(, BtnY)
    GuiObj["BtnUp"].Move(, BtnY)
    GuiObj["BtnDown"].Move(, BtnY)
    
    GuiObj["RemoveInclude"].Move(, OptY)
    GuiObj["StripComments"].Move(, OptY)
    
    GuiObj["BtnMerge"].Move(, MergeY)
    GuiObj["BtnFolder"].Move(Width - 210, MergeY)
    GuiObj["BtnCancel"].Move(Width - 100, MergeY)

    ; Force Redraw
    for Name in Controls {
        Hwnd := GuiObj[Name].Hwnd
        DllCall("user32\InvalidateRect", "Ptr", Hwnd, "Ptr", 0, "Int", 1)
        DllCall("user32\UpdateWindow", "Ptr", Hwnd)
    }
}

RemoveSelected(*) {
    if (FileList.Value != 0) {
        FileList.Delete(FileList.Value)
    }
}

OpenSelectedDir(*) {
    Idx := FileList.Value
    Items := ControlGetItems(FileList.Hwnd)
    
    if (Idx = 0 || Items.Length = 0) {
        MsgBox("Please select a file from the list first.", "No Selection", "Icon!")
        return
    }
    
    SplitPath(Items[Idx], , &OutDir)
    Run(OutDir)
}

Gui_DropFiles(GuiObj, GuiCtrl, FileArray, *) {
    for FilePath in FileArray {
        if (StrLower(SubStr(FilePath, -4)) = ".ahk") {
            FileList.Add([FilePath])
        }
    }
}

AddFiles(*) {
    Selected := FileSelect("M3", , "Select AHK scripts", "AutoHotkey Files (*.ahk)")
    if !Selected
        return
    
    for FilePath in Selected
        FileList.Add([FilePath])
}

MoveUp(*) {
    Idx := FileList.Value
    if (Idx <= 1)
        return
    
    Items := ControlGetItems(FileList.Hwnd)
    CurrentItem := Items[Idx]
    Items.RemoveAt(Idx)
    Items.InsertAt(Idx - 1, CurrentItem)
    
    FileList.Delete()
    FileList.Add(Items)
    FileList.Value := Idx - 1
}

MoveDown(*) {
    Idx := FileList.Value
    Items := ControlGetItems(FileList.Hwnd)
    if (Idx = 0 || Idx = Items.Length)
        return
    
    CurrentItem := Items[Idx]
    Items.RemoveAt(Idx)
    Items.InsertAt(Idx + 1, CurrentItem)
    
    FileList.Delete()
    FileList.Add(Items)
    FileList.Value := Idx + 1
}

MergeScripts(*) {
    Saved := MyGui.Submit(false)
    AllFiles := ControlGetItems(FileList.Hwnd)
    
    if (AllFiles.Length = 0) {
        MsgBox("Please add some files first!", "Empty List", "Icon!")
        return
    }

    SavePath := FileSelect("S16", "Combined_Scripts.ahk", "Save Combined Script", "AutoHotkey Files (*.ahk)")
    if !SavePath
        return

    if FileExist(SavePath)
        FileDelete(SavePath)

    CombinedContent := ""
    if (!Saved.StripComments) {
        CombinedContent := "; Combined Script - Generated on " A_Now "`n"
        CombinedContent .= "; Version: 1.0.1.6`n`n"
    }
    
    HasRequires := false
    HasSingleInstance := false
    FileCounter := 0

    for FilePath in AllFiles {
        ScriptContent := FileRead(FilePath)
        
        if (ScriptContent = "")
            return

        FileCounter++
        
        if (Saved.StripComments) {
            ScriptContent := RegExReplace(ScriptContent, "s)/\*.*?\*/", "")
        }

        ProcessedContent := ""
        Loop Parse, ScriptContent, "`n", "`r" {
            Line := A_LoopField
            
            if (Saved.StripComments) {
                Line := RegExReplace(Line, "m)\s*;.*$", "")
            }

            if (Saved.StripComments && Trim(Line) == "")
                continue

            if RegExMatch(Line, "i)^\s*#Requires") {
                if (HasRequires) {
                    if (Saved.StripComments) {
                        continue
                    }
                    Line := "; [Duplicate Removed] " . Line
                } else {
                    HasRequires := true
                }
            }
            else if RegExMatch(Line, "i)^\s*#SingleInstance") {
                if (HasSingleInstance) {
                    if (Saved.StripComments) {
                        continue
                    }
                    Line := "; [Duplicate Removed] " . Line
                } else {
                    HasSingleInstance := true
                }
            }
            else if (Saved.RemoveInclude && RegExMatch(Line, "i)^\s*#Include")) {
                if (Saved.StripComments) {
                    continue
                }
                Line := "; [Include Removed] " . Line
            }
            
            ProcessedContent .= Line . "`n"
        }

        if (!Saved.StripComments) {
            CombinedContent .= "; #region " FileCounter " . --- Start of: " FilePath " ---`n"
        }
        
        CombinedContent .= ProcessedContent . "`n"
        
        if (!Saved.StripComments) {
            CombinedContent .= "; #endregion --- End of: " FilePath " ---`n`n"
        }
    }

    FileAppend(CombinedContent, SavePath)
    SoundBeep(750, 200)
}