/*
 * Script: CreateShortcut_Utility.ahk
 * Version: 1.0.3
 * Description: GUI utility to create shortcuts with executable parameters.
 */

#Requires AutoHotkey v2.0

MainGui := Gui("+AlwaysOnTop", "Shortcut Creator v1.0.3")
MainGui.SetFont("s10", "Segoe UI")

; Target EXE section
MainGui.Add("Text",, "Target Executable Path:")
TargetEdit := MainGui.Add("Edit", "w300 vTarget")
MainGui.Add("Button", "x+5 w70", "Browse").OnEvent("Click", SelectFile)

; Parameters section
MainGui.Add("Text", "xm", "Parameters / Arguments (optional):")
ArgsEdit := MainGui.Add("Edit", "w380 vArgs", "")

; Shortcut Name section
MainGui.Add("Text", "xm", "Shortcut Name (saved to Desktop):")
NameEdit := MainGui.Add("Edit", "w380 vLinkName", "New Shortcut")

; Action Button
CreateBtn := MainGui.Add("Button", "Default w120 h30 xm+130", "Create Shortcut")
CreateBtn.OnEvent("Click", ProcessShortcut)

MainGui.Show()

; --- Event Handlers ---

SelectFile(*) {
    SelectedFile := FileSelect(3,, "Select Target Executable", "Executables (*.exe; *.com; *.bat; *.cmd)")
    if (SelectedFile = "")
        return
    
    TargetEdit.Value := SelectedFile
    
    ; Auto-fill name if empty
    SplitPath(SelectedFile, &nameNoExt, , &ext)
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
        ; Parameters: Target, LinkFile, WorkingDir, Args
        FileCreateShortcut(Target, LinkPath, , Args)
        MsgBox("Shortcut created successfully with parameters!`n`nPath: " LinkPath, "Success", "Iconi")
    } catch Error as err {
        MsgBox("Failed to create shortcut.`n`nError: " err.Message, "Error", "Iconx")
    }
}