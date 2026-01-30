/*
 * Script: CreateShortcut_Utility.ahk
 * Version: 1.1.9
 * Description: Automatically parses complex quoted strings into Target and Args.
 */

#Requires AutoHotkey v2.0

MainGui := Gui("+Resize", "Shortcut Creator v1.1.9")
MainGui.SetFont("s10", "Segoe UI")

; Set window size constraints
MainGui.Opt("+MinSize550x220 +MaxSize1280x220")

; Target Path
MainGui.Add("Text", "vTxtTarget", "Target Executable Path (or full quoted command):")
TargetEdit := MainGui.Add("Edit", "w480 vTarget")
BrowseBtn := MainGui.Add("Button", "x+5 w70 vBtnBrowse", "Browse")

; Parameters
MainGui.Add("Text", "xm vTxtArgs", "Parameters / Arguments (optional):")
ArgsEdit := MainGui.Add("Edit", "w560 vArgs", "")

; Shortcut Name and Save Location
MainGui.Add("Text", "xm vTxtName w200", "Shortcut Name:")
TxtLocation := MainGui.Add("Text", "x+20 vTxtLoc", "Save Location:")

NameEdit := MainGui.Add("Edit", "xm w200 vLinkName", "New Shortcut")
LocationDDL := MainGui.Add("DropDownList", "x+20 w160 vLocation Choose1", ["Desktop", "Current Directory", "Startup"])

; Action Buttons
OpenBtn := MainGui.Add("Button", "w60 h30 x+20 vBtnOpen", "Open")
CreateBtn := MainGui.Add("Button", "Default w70 h30 x+10 vBtnCreate", "Create")

; Events
BrowseBtn.OnEvent("Click", SelectFile)
OpenBtn.OnEvent("Click", OpenSaveLocation)
CreateBtn.OnEvent("Click", ProcessShortcut)
MainGui.OnEvent("Size", OnGui_Size)

MainGui.Show("w590 h220")

; --- GUI Events ---

OnGui_Size(GuiObj, MinMax, Width, Height) {
    if (MinMax = -1)
        return

    newWidth := Width - 30
    
    TargetEdit.Move(,, newWidth - 75)
    BrowseBtn.Move(Width - 85)
    ArgsEdit.Move(,, newWidth)
    
    createBtnWidth := 70
    openBtnWidth := 60
    btnSpacing := 10
    totalBtnWidth := createBtnWidth + openBtnWidth + btnSpacing
    rightSideGap := 20
    
    remainingWidth := newWidth - totalBtnWidth - rightSideGap - 10
    halfWidth := remainingWidth / 2
    
    NameEdit.Move(,, halfWidth)
    
    locX := 15 + halfWidth + 15
    TxtLocation.Move(locX)
    LocationDDL.Move(locX,, halfWidth)
    
    OpenBtn.Move(Width - 155)
    CreateBtn.Move(Width - 85)
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

    ; Detect if input starts with a quote (complex path)
    if (SubStr(RawInput, 1, 1) = '"') {
        ; Find the closing quote for the EXE
        EndQuotePos := InStr(RawInput, '"', , 2)
        if (EndQuotePos > 0) {
            FinalTarget := SubStr(RawInput, 2, EndQuotePos - 2)
            ; Everything after the second quote is added to existing Args
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