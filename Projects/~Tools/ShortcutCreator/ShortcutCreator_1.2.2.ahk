/*
 * Script: CreateShortcut_Utility.ahk
 * Version: 1.2.2
 * Description: Moved Cancel button to the far right and updated alignment logic.
 */

#Requires AutoHotkey v2.0

MainGui := Gui("+Resize", "Shortcut Creator v1.2.2")
MainGui.SetFont("s10", "Segoe UI")

; Set window size constraints
MainGui.Opt("+MinSize580x220 +MaxSize1280x220")

; Target Path
MainGui.Add("Text", "vTxtTarget", "Target Executable Path (or full quoted command):")
TargetEdit := MainGui.Add("Edit", "w480 vTarget")
BrowseBtn := MainGui.Add("Button", "x+5 w70 vBtnBrowse", "Browse")

; Parameters
MainGui.Add("Text", "xm vTxtArgs", "Parameters / Arguments (optional):")
ArgsEdit := MainGui.Add("Edit", "w560 vArgs", "")

; Shortcut Name and Save Location
MainGui.Add("Text", "xm vTxtName w180", "Shortcut Name:")
TxtLocation := MainGui.Add("Text", "x+20 vTxtLoc", "Save Location:")

NameEdit := MainGui.Add("Edit", "xm w180 vLinkName", "New Shortcut")
LocationDDL := MainGui.Add("DropDownList", "x+20 w150 vLocation Choose1", ["Desktop", "Current Directory", "Startup"])

; Action Buttons - Order: Open, Create (Default), Cancel
OpenBtn := MainGui.Add("Button", "w60 h30 x+20 vBtnOpen", "Open")
CreateBtn := MainGui.Add("Button", "Default w70 h30 x+10 vBtnCreate", "Create")
CancelBtn := MainGui.Add("Button", "w65 h30 x+10 vBtnCancel", "Cancel")

; Events
BrowseBtn.OnEvent("Click", SelectFile)
OpenBtn.OnEvent("Click", OpenSaveLocation)
CreateBtn.OnEvent("Click", ProcessShortcut)
CancelBtn.OnEvent("Click", (*) => ExitApp())
MainGui.OnEvent("Size", OnGui_Size)

MainGui.Show("w620 h220")

; --- GUI Events ---

OnGui_Size(GuiObj, MinMax, Width, Height) {
    if (MinMax = -1)
        return

    newWidth := Width - 30
    
    ; Top and Middle Rows
    TargetEdit.Move(,, newWidth - 75)
    BrowseBtn.Move(Width - 85)
    ArgsEdit.Move(,, newWidth)
    
    ; Button Widths and Spacing
    btnW_Create := 70
    btnW_Open   := 60
    btnW_Cancel := 65
    spacing     := 10
    
    ; Total width occupied by buttons + right margin gap
    totalBtnArea := btnW_Create + btnW_Open + btnW_Cancel + (spacing * 2)
    rightGap := 20
    
    ; Calculate remaining space for Name and DDL
    remainingWidth := newWidth - totalBtnArea - rightGap
    halfWidth := remainingWidth / 2
    
    ; Move Name field
    NameEdit.Move(,, halfWidth)
    
    ; Move "Save Location" label and DDL
    locX := 15 + halfWidth + 15
    TxtLocation.Move(locX)
    LocationDDL.Move(locX,, halfWidth)
    
    ; Anchor buttons to the far right in order: Open, Create, Cancel
    OpenBtn.Move(Width - (btnW_Create + btnW_Open + btnW_Cancel + 35))
    CreateBtn.Move(Width - (btnW_Create + btnW_Cancel + 25))
    CancelBtn.Move(Width - 85)
}

; --- Functional Handlers ---

GetTargetDir() {
    switch LocationDDL.Text {
        case "Desktop": 
            return A_Desktop
        case "Current Directory": 
            return A_ScriptDir
        case "Startup": 
            return A_Startup
        default: 
            return A_Desktop
    }
}

OpenSaveLocation(*) {
    Run(GetTargetDir())
}

SelectFile(*) {
    SelectedFile := FileSelect(3,, "Select Target Executable", "Executables (*.exe; *.com; *.bat; *.cmd)")
    if (SelectedFile = "")
        return
    
    TargetEdit.Value := SelectedFile
    
    SplitPath(SelectedFile, &nameNoExt)
    NameEdit.Value := nameNoExt
}

ProcessShortcut(*) {
    RawInput := Trim(TargetEdit.Value)
    Args := ArgsEdit.Value
    LinkName := NameEdit.Value
    
    if (RawInput = "")
        return

    FinalTarget := ""
    FinalArgs := Args

    if (SubStr(RawInput, 1, 1) = '"') {
        EndQuotePos := InStr(RawInput, '"', , 2)
        if (EndQuotePos > 0) {
            FinalTarget := SubStr(RawInput, 2, EndQuotePos - 2)
            ExtraArgs := Trim(SubStr(RawInput, EndQuotePos + 1))
            if (ExtraArgs != "")
                FinalArgs := ExtraArgs . (Args != "" ? " " . Args : "")
        } else {
            FinalTarget := Trim(RawInput, '"')
        }
    } else {
        FinalTarget := RawInput
    }

    if !FileExist(FinalTarget) {
        MsgBox("The target executable path does not exist.`n`nPath: " FinalTarget, "Path Error", "Iconx")
        return
    }

    SplitPath(FinalTarget,, &WorkingDir)
    SaveDir := GetTargetDir()
    LinkPath := SaveDir "\" LinkName ".lnk"

    if FileExist(LinkPath) {
        Result := MsgBox("A shortcut named '" LinkName "' already exists.`nDo you want to overwrite it?", "Confirm Overwrite", "YesNo Icon? Default2")
        if (Result = "No")
            return
    }

    try {
        FileCreateShortcut(FinalTarget, LinkPath, WorkingDir, FinalArgs)
        MsgBox("Shortcut created successfully!", "Success", "Iconi")
    } catch Error as err {
        MsgBox("Failed to create shortcut.`n`nError: " err.Message, "Error", "Iconx")
    }
}