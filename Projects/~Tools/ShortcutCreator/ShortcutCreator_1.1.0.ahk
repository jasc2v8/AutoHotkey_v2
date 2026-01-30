/*
 * Script: CreateShortcut_Utility.ahk
 * Version: 1.1.0
 * Description: GUI utility to create shortcuts with selectable save locations.
 */

#Requires AutoHotkey v2.0

MainGui := Gui("+AlwaysOnTop +Resize", "Shortcut Creator v1.1.0")
MainGui.SetFont("s10", "Segoe UI")

; Set window size constraints
MainGui.Opt("+MinSize500x220 +MaxSize1280x220")

; Target Path
MainGui.Add("Text", "vTxt1", "Target Executable Path:")
TargetEdit := MainGui.Add("Edit", "w480 vTarget")
BrowseBtn := MainGui.Add("Button", "x+5 w70 vBtnBrowse", "Browse")

; Parameters
MainGui.Add("Text", "xm vTxt2", "Parameters / Arguments (optional):")
ArgsEdit := MainGui.Add("Edit", "w560 vArgs", "")

; Shortcut Name
MainGui.Add("Text", "xm vTxt3 w280", "Shortcut Name:")
MainGui.Add("Text", "x+20 vTxt4", "Save Location:")

NameEdit := MainGui.Add("Edit", "xm w280 vLinkName", "New Shortcut")
LocationDDL := MainGui.Add("DropDownList", "x+20 w260 vLocation Choose1", ["Desktop", "Current Directory", "Startup"])

; Action Button
CreateBtn := MainGui.Add("Button", "Default w120 h30 xm vBtnCreate", "Create Shortcut")

; Events
BrowseBtn.OnEvent("Click", SelectFile)
CreateBtn.OnEvent("Click", ProcessShortcut)
MainGui.OnEvent("Size", OnGui_Size)

MainGui.Show("w590 h220")

; --- GUI Events ---

OnGui_Size(GuiObj, MinMax, Width, Height) {
    ; MinMax = -1: The window is minimized.
    if (MinMax = -1)
        return

    newWidth := Width - 30
    halfWidth := (newWidth / 2) - 10
    
    TargetEdit.Move(,, newWidth - 75)
    BrowseBtn.Move(Width - 85)
    
    ArgsEdit.Move(,, newWidth)
    
    ; Split row for Name and Location
    NameEdit.Move(,, halfWidth)
    LocationDDL.Move(halfWidth + 40,, halfWidth)
    
    CreateBtn.Move((Width / 2) - 60)
}

; --- Functional Handlers ---

SelectFile(*) {
    SelectedFile := FileSelect(3,, "Select Target Executable", "Executables (*.exe; *.com; *.bat; *.cmd)")
    if (SelectedFile = "")
        return
    
    TargetEdit.Value := SelectedFile
    
    SplitPath(SelectedFile, &nameNoExt)
    NameEdit.Value := nameNoExt
}

ProcessShortcut(*) {
    Target := TargetEdit.Value
    Args := ArgsEdit.Value
    LinkName := NameEdit.Value
    
    if (Target = "")
        return

    ; Determine Save Path
    switch LocationDDL.Text {
        case "Desktop": 
            SaveDir := A_Desktop
        case "Current Directory": 
            SaveDir := A_ScriptDir
        case "Startup": 
            SaveDir := A_Startup
        default: 
            SaveDir := A_Desktop
    }

    LinkPath := SaveDir "\" LinkName ".lnk"

    try {
        FileCreateShortcut(Target, LinkPath, , Args)
        MsgBox("Shortcut created successfully!`n`nLocation: " SaveDir, "Success", "Iconi")
    } catch Error as err {
        MsgBox("Failed to create shortcut.`n`nError: " err.Message, "Error", "Iconx")
    }
}