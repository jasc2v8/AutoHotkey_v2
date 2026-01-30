#Requires AutoHotkey v2.0
#SingleInstance Force

/**
 * Script Merger v1.0.0.7
 * Updated: MinSize changed to 420x460 and swapped Open Folder/Cancel buttons.
 */

; GUI Creation with updated MinSize
MyGui := Gui("+Resize +MinSize420x460", "Script Merger v1.0.0.7")
MyGui.SetFont("s10", "Segoe UI")

; Events
MyGui.OnEvent("Size", Gui_Size)
MyGui.OnEvent("DropFiles", Gui_DropFiles)

MyGui.Add("Text", "w400 vTitleText", "Select and order the AHK v2 scripts to combine:")
FileList := MyGui.Add("ListBox", "r10 w400 vSelectedFiles")

; Top Row Buttons
BtnAdd := MyGui.Add("Button", "y+10 w65 vBtnAdd", "Add")
BtnAdd.OnEvent("Click", AddFiles)

BtnClear := MyGui.Add("Button", "x+5 yp w65 vBtnClear", "Clear")
BtnClear.OnEvent("Click", (*) => FileList.Delete())

BtnDelete := MyGui.Add("Button", "x+5 yp w85 vBtnDelete", "Delete Item")
BtnDelete.OnEvent("Click", RemoveSelected)

BtnUp := MyGui.Add("Button", "x+5 yp w65 vBtnUp", "Up")
BtnUp.OnEvent("Click", MoveUp)

BtnDown := MyGui.Add("Button", "x+5 yp w65 vBtnDown", "Down")
BtnDown.OnEvent("Click", MoveDown)

; Options
ChkRemoveInclude := MyGui.Add("Checkbox", "xm vRemoveInclude Checked", "Comment out #Include directives")
ChkStripComments := MyGui.Add("Checkbox", "x+15 vStripComments", "Strip all comments")

; Bottom Row Buttons - Rearranged: Merge | Folder | Cancel
BtnMerge := MyGui.Add("Button", "Default w140 xm vBtnMerge", "Merge and Save As...")
BtnMerge.OnEvent("Click", MergeScripts)

BtnFolder := MyGui.Add("Button", "x+10 w100 vBtnFolder", "Open Folder")
BtnFolder.OnEvent("Click", OpenSelectedDir)

BtnCancel := MyGui.Add("Button", "x+10 w90 vBtnCancel", "Cancel")
BtnCancel.OnEvent("Click", (*) => ExitApp())

MyGui.Show()

; --- Functions ---

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

Gui_Size(GuiObj, WindowMinMax, Width, Height) {
    if (WindowMinMax = -1)
        return

    GuiObj["TitleText"].Move(,, Width - 20)
    GuiObj["SelectedFiles"].Move(,, Width - 20, Height - 175)

    BtnY := Height - 145
    OptY := Height - 110
    MergeY := Height - 70
    
    GuiObj["BtnAdd"].Move(, BtnY)
    GuiObj["BtnClear"].Move(, BtnY)
    GuiObj["BtnDelete"].Move(, BtnY)
    GuiObj["BtnUp"].Move(, BtnY)
    GuiObj["BtnDown"].Move(, BtnY)
    
    GuiObj["RemoveInclude"].Move(, OptY)
    GuiObj["StripComments"].Move(, OptY)
    
    ; Move Bottom Row - Merge | Folder | Cancel
    GuiObj["BtnMerge"].Move(, MergeY)
    GuiObj["BtnFolder"].Move(Width - 210, MergeY)
    GuiObj["BtnCancel"].Move(Width - 100, MergeY)
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

    CombinedContent := "; Combined Script - Generated on " A_Now "`n"
    CombinedContent .= "; Version: 1.0.0.7`n`n"
    
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
                    Line := "; [Duplicate Removed] " . Line
                } else {
                    HasRequires := true
                }
            }
            else if RegExMatch(Line, "i)^\s*#SingleInstance") {
                if (HasSingleInstance) {
                    Line := "; [Duplicate Removed] " . Line
                } else {
                    HasSingleInstance := true
                }
            }
            else if (Saved.RemoveInclude && RegExMatch(Line, "i)^\s*#Include")) {
                Line := "; [Include Removed] " . Line
            }
            
            ProcessedContent .= Line . "`n"
        }

        CombinedContent .= "; #region " FileCounter " . --- Start of: " FilePath " ---`n"
        CombinedContent .= ProcessedContent . "`n"
        CombinedContent .= "; #endregion --- End of: " FilePath " ---`n`n"
    }

    FileAppend(CombinedContent, SavePath)
    
    Result := MsgBox("Successfully merged " AllFiles.Length " scripts!`n`nWould you like to open the folder?", "Success", "YesNo IconI")
    if (Result = "Yes") {
        SplitPath(SavePath, , &OutDir)
        Run(OutDir)
    }
}