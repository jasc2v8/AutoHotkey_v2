/*
 * Script: CreateShortcut_Utility.ahk v1.2.0.4
 * Description: Moved Cancel button to the far right and updated alignment logic.
 */

#Requires AutoHotkey v2.0
#Include <Anchor>
;#Include OpenFileProperties.ahk

MainGui := Gui("+Resize", "Shortcut Creator v1.2.2")
MainGui.SetFont("s10", "Segoe UI")

; Set window size constraints
MainGui.Opt("+MinSize580x220 +MaxSize1280x220")

; Target Path
MainGui.Add("Text", "vTxtTarget", "Target Executable Path (or full quoted command):")
TargetEdit := MainGui.Add("Edit", "w420 vTarget")
BrowseBtn := MainGui.Add("Button", "w55 yp vBtnBrowse", "Browse")
PropsBtn := MainGui.Add("Button", "w55 yp vBtnProps", "Props")

; Parameters
MainGui.Add("Text", "xm vTxtArgs", "Parameters / Arguments (optional):")
ArgsEdit := MainGui.Add("Edit", "w420 vArgs", "")

; Shortcut Name and Save Location
MainGui.Add("Text", "xm vTxtName w180", "Shortcut Name:")
TxtLocation := MainGui.Add("Text", "x+20 vTxtLoc w200", "Save Location:")

NameEdit := MainGui.Add("Edit", "xm w180 vLinkName", "New Shortcut")
LocationDDL := MainGui.Add("DropDownList", "yp w120 vLocation Choose1", ["Desktop", "Current Directory", "Startup"])

; Action Buttons - Order: Open, Create (Default), Cancel
OpenBtn := MainGui.Add("Button", "w55 yp vBtnOpen", "Open")
CreateBtn := MainGui.Add("Button", "w55 x+55 Default vBtnCreate", "Create")
CancelBtn := MainGui.Add("Button", "w55 yp vBtnCancel", "Cancel")

; Events
BrowseBtn.OnEvent("Click", SelectFile)
PropsBtn.OnEvent("Click", PropsBtn_Click)
OpenBtn.OnEvent("Click", OpenSaveLocation)
CreateBtn.OnEvent("Click", ProcessShortcut)
CancelBtn.OnEvent("Click", (*) => ExitApp())
MainGui.OnEvent("Size", OnGui_Size)

MainGui.Show()

; --- GUI Events ---

OnGui_Size(GuiObj, MinMax, Width, Height) {
    if (MinMax = -1)
        return

    Anchor([TargetEdit, ArgsEdit, NameEdit, TxtLocation, LocationDDL],"w")

    Anchor([BrowseBtn, PropsBtn, OpenBtn, CreateBtn, CancelBtn, TxtLocation, LocationDDL], "xy")
}

; --- Functional Handlers ---

PropsBtn_Click(*) {
    ;OpenFileProperties(TargetEdit.Value)
}

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
    SelectedFile := FileSelect(3,A_ScriptDir, "Select Target Executable", "Executables (*.exe; *.com; *.bat; *.cmd)")
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