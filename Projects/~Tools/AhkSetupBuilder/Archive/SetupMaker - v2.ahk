#Requires AutoHotkey v2.0

; Directives, keywords
#SingleInstance Force
#NoTrayIcon

; --- Start of Version Info Block ---
;@Ahk2Exe-Set ProductName, Gui Example
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-Set LegalCopyright, © 2025 jasc2v8
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Gui Example
;@Ahk2Exe-Set OriginalFilename, GuiExample.exe
; --- End of Version Info Block ---


; Create a new Gui object
MyGui := Gui(, "Setup Maker") ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w480", "Segouie UI")

buttonSelectExe := MyGui.Add("Button", "w76 h24 xm ym", "Select EXE")  ; "x+5 y+5"
editBoxExe := MyGui.Add("Edit", "yp w640 h24")

buttonSelectIss := MyGui.Add("Button", "w76 h24 xm", "Select ISS")  ; "x+5 y+5"
editBoxIss := MyGui.Add("Edit", "yp w640 h24")

MyDividerLine := StrRepeat("_", 103)
MyGui.Add("Text", "xm", MyDividerLine)
buttonMake := MyGui.Add("Button", "xm y+18 w76 h24", "Make")  ; "x+5 y+5"
buttonExplore := MyGui.Add("Button", "yp w76 h24", "Explore")
buttonCancel := MyGui.Add("Button", "yp w76 h24 Default", "Cancel")

; OnEvent Handlers
buttonSelectExe.OnEvent("Click", buttonSelectExeClicked)
buttonSelectIss.OnEvent("Click", buttonSelectIssClicked)
buttonMake.OnEvent("Click", buttonMakeClicked)
buttonCancel.OnEvent("Click", buttonCancelClicked)

; Show the GUI
MyGui.Show("w760 h152")

buttonSelectExeClicked(Ctrl, Info) {
    editBoxExe.Text := ""

    SelectedFile := FileSelect(1+2, , "Open EXE file", "EXE Files (*.exe)")

    if SelectedFile = ""
        editBoxExe.Text := "" ;"The dialog was canceled."
    else
        editBoxExe.Text := SelectedFile
}

buttonSelectIssClicked(Ctrl, Info) {
    editBoxIss.Text := ""

    SelectedFile := FileSelect(1+2, , "Open ISS file", "ISS Files (*.iss)")

    if SelectedFile = ""
        editBoxIss.Text := ""
    else
        editBoxIss.Text := SelectedFile
}

buttonMakeClicked(Ctrl, Info) {



}

buttonFolderClicked(Ctrl, Info) {

 editBoxExe.Value := ""

 SelectedFolder := FileSelect("D", , "Select a folder")

 if SelectedFolder = ""
  editBoxExe.Text := "The dialog was canceled."
 else
 editBoxExe.Text := "Folder selected: " . SelectedFolder
}

buttonCancelClicked(Ctrl, Info) {
 ExitApp()
}

StrRepeat(text, times) {
 return StrReplace(Format("{:" times "}", ""), " ", text)
}
; This function is called when the window is closed
MyGui.OnEvent("Close", (*) => ExitApp())

