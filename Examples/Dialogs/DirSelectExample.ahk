#Requires AutoHotkey v2.0

/**
 * MODERN FOLDER SELECTOR EXAMPLE
 * * In AHK v2, using FileSelect with the "D" (Directory) option invokes 
 * the modern IFileOpenDialog interface rather than the old 'folder tree' view.
 */

global IL_Large := 0
global IL_Small := 0

; Create a demo GUI
MyGui := Gui(, "Modern Dialog Demo")
MyGui.SetFont("s11", "Segoe UI")

MyGui.Add("Text", "w400", "Current Selection:")
ResultEdit := MyGui.Add("Edit", "w400 r2 ReadOnly", "None selected")

BtnBrowse := MyGui.Add("Button", "w150 h40", "Select Folder")
BtnBrowse.OnEvent("Click", ShowModernDialog)

MyGui.Show()

ShowModernDialog(*) {
    ; Option "D" = Select Folder
    ; Option "3" = Create button + must exist
    SelectedFolder := FileSelect("D 3", A_ProgramFiles, "Select Your App Directory")
    
    if SelectedFolder != "" {
        ResultEdit.Value := SelectedFolder
    } else {
        MsgBox("Dialog was cancelled.", "Notice", "Iconi")
    }
}