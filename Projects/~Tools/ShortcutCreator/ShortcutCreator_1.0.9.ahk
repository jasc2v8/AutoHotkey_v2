/*
 * Script: CreateShortcut_Utility.ahk
 * Version: 1.0.9
 * Description: GUI utility with restricted vertical resizing and expanded horizontal range.
 */

#Requires AutoHotkey v2.0

MainGui := Gui("+AlwaysOnTop +Resize", "Shortcut Creator v1.0.9")
MainGui.SetFont("s10", "Segoe UI")

; Set window size constraints as requested
MainGui.Opt("+MinSize500x220 +MaxSize1280x220")

; Add controls
MainGui.Add("Text", "vTxt1", "Target Executable Path:")
TargetEdit := MainGui.Add("Edit", "w480 vTarget")
BrowseBtn := MainGui.Add("Button", "x+5 w70 vBtnBrowse", "Browse")

MainGui.Add("Text", "xm vTxt2", "Parameters / Arguments (optional):")
ArgsEdit := MainGui.Add("Edit", "w560 vArgs", "")

MainGui.Add("Text", "xm vTxt3", "Shortcut Name (saved to Desktop):")
NameEdit := MainGui.Add("Edit", "w560 vLinkName", "New Shortcut")

CreateBtn := MainGui.Add("Button", "Default w120 h30 xm vBtnCreate", "Create Shortcut")

; Events
BrowseBtn.OnEvent("Click", SelectFile)
CreateBtn.OnEvent("Click", ProcessShortcut)
MainGui.OnEvent("Size", OnGui_Size)

; Initial show
MainGui.Show("w590 h220")

; --- GUI Events ---

OnGui_Size(GuiObj, MinMax, Width, Height) {
    ; MinMax = -1: The window is minimized.
    if (MinMax = -1)
        return

    newWidth := Width - 30
    
    TargetEdit.Move(,, newWidth - 75)
    BrowseBtn.Move(Width - 85)
    
    ArgsEdit.Move(,, newWidth)
    NameEdit.Move(,, newWidth)
    
    ; Center the Create button horizontally
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
    LinkPath := A_Desktop "\" LinkName ".lnk"

    if (Target = "")
        return

    try {
        FileCreateShortcut(Target, LinkPath, , Args)
        MsgBox("Shortcut created successfully!", "Success", "Iconi")
    } catch Error as err {
        MsgBox("Failed to create shortcut.`n`nError: " err.Message, "Error", "Iconx")
    }
}