
/************************************************************************
 * @description 
 * @author 
 * @date 2025/09/16
 * @version 0.0.1
 ***********************************************************************/

#Requires AutoHotkey v2.0

#SingleInstance force

; --- Tray Icon Menu Setup ---
TrayMenu := A_TrayMenu
TrayMenu.Delete()
TrayMenu.Add()
TrayMenu.Add("Exit", (*) => ExitApp())
TrayMenu.Default := "Exit"
TrayMenu.ClickCount := 1

;MsgBox("Script running. Right-click tray icon for menu.")
; --- End of Tray Icon Menu Setup ---

; Create a new Gui object
myGui := Gui()
myGui.Title := "File Selector"

; Add a text control for instructions
myGui.Add("Text", "xm ym", "Select a file:")

; Add an Edit control for displaying the selected file path
filePathEdit := myGui.Add("Edit", "xm y+5 w300", "")

; Add a Button to open the file selection dialog
myGui.Add("Button", "x+5 yp w80", "Browse").OnEvent("Click", SelectFile)

; Add an OK button
myGui.Add("Button", "xm y+10 w80", "OK").OnEvent("Click", SubmitFile)

; Show the GUI
myGui.Show()

SelectFile(Ctrl, Info) {
    global filePathEdit
    selectedFile := FileSelect()
    if (selectedFile != "") {
        filePathEdit.Value := selectedFile
    }
}

SubmitFile(Ctrl, Info) {
    global filePathEdit
    MsgBox("Selected file: " . filePathEdit.Value)
    ; You can add further actions here, e.g., process the selected file
    myGui.Destroy() ; Close the GUI after submission
}

ShowGui() {
	try myGui.Show()
}
HideGui() {
	try myGui.Hide()
}
