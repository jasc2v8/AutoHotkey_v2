
/************************************************************************
 * @description 
 * @author 
 * @date 2025/09/16
 * @version 0.0.1
 ***********************************************************************/

#Requires AutoHotkey v2.0+

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
MyGui.BackColor := "4682B4" ; Steel Blue

MyGui.SetFont("S11 CBlack w480", "Segouie UI")

; Add a text control for instructions
myGui.AddText("xm ym", "Select a file:")

MyGui.SetFont("S11", "Consolas")
; Add an Edit control for displaying the selected file path
filePathEdit := myGui.AddEdit("xm y+5 w600", "")

MyGui.SetFont()
myGui.AddButton("x+m yp w75", "Browse").OnEvent("Click", SelectFile)

myGui.AddText("xm w522 h0 Hidden")
myGui.AddButton("yp w75", "OK").OnEvent("Click", SubmitFile)
myGui.AddButton("yp w75", "Cancel").OnEvent("Click", (*) => ExitApp())


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
