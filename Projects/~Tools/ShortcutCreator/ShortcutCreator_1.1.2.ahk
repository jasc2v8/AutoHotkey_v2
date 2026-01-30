/*
 * Script: CreateShortcut_Utility.ahk
 * Version: 1.1.2
 * Description: GUI utility with improved spacing and dynamic label positioning.
 */

#Requires AutoHotkey v2.0

MainGui := Gui("+AlwaysOnTop +Resize", "Shortcut Creator v1.1.2")
MainGui.SetFont("s10", "Segoe UI")

; Set window size constraints
MainGui.Opt("+MinSize500x220 +MaxSize1280x220")

; Target Path
MainGui.Add("Text", "vTxtTarget", "Target Executable Path:")
TargetEdit := MainGui.Add("Edit", "w480 vTarget")
BrowseBtn := MainGui.Add("Button", "x+5 w70 vBtnBrowse", "Browse")

; Parameters
MainGui.Add("Text", "xm vTxtArgs", "Parameters / Arguments (optional):")
ArgsEdit := MainGui.Add("Edit", "w560 vArgs", "")

; Shortcut Name and Save Location
MainGui.Add("Text", "xm vTxtName w220", "Shortcut Name:")
TxtLocation := MainGui.Add("Text", "x+20 vTxtLoc", "Save Location:")

NameEdit := MainGui.Add("Edit", "xm w220 vLinkName", "New Shortcut")
LocationDDL := MainGui.Add("DropDownList", "x+20 w180 vLocation Choose1", ["Desktop", "Current Directory", "Startup"])

; Narrower Action Button with more space
CreateBtn := MainGui.Add("Button", "Default w80 h30 x+30 vBtnCreate", "Create")

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
    
    ; Top and Middle Rows
    TargetEdit.Move(,, newWidth - 75)
    BrowseBtn.Move(Width - 85)
    ArgsEdit.Move(,, newWidth)
    
    ; Bottom Row Logic
    btnWidth := 80
    spacing := 30 ; Increased space between DDL and Button
    
    ; Calculate widths for Name and DDL (sharing remaining space)
    ; Total width - button - spacing - margin - gap between Name and DDL
    remainingWidth := newWidth - btnWidth - spacing - 10
    halfWidth := remainingWidth / 2
    
    ; Move Name field
    NameEdit.Move(,, halfWidth)
    
    ; Move "Save Location" label and DDL
    locX := 15 + halfWidth + 15
    TxtLocation.Move(locX)
    LocationDDL.Move(locX,, halfWidth)
    
    ; Anchor Create button to the far right
    CreateBtn.Move(Width - 95)
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