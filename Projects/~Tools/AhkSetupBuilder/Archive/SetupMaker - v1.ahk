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

editBoxExe := MyGui.Add("Edit", "xm+0 ym+0 w640 h24", "D:\Software\DEV\Work\AHK2\Projects\SetupMaker\SetupMaker.exe")
buttonSelectExe := MyGui.Add("Button", "w76 h24 yp", "Select Exe")  ; "x+5 y+5"

editBoxIss := MyGui.Add("Edit", "xm w640 h24")
buttonSelectIss := MyGui.Add("Button", "w76 h24 yp", "Select Iss")  ; "x+5 y+5"

; Add Button controls to the GUI
buttonCancel := MyGui.Add("Button", "xm+648 w76 h24 Default", "Cancel")
buttonFile := MyGui.Add("Button", "xp-82 w76 h24", "Make")  ; "x+5 y+5"
; buttonFolder := MyGui.Add("Button", "x+m yp W64 Default", "Folder")
;~ buttonOpt2 := MyGui.Add("Button", "x+m yp W64 Default", "Opt2")
;~ buttonOpt3 := MyGui.Add("Button", "x+m yp W64 Default", "Opt3")

; Assign a function to be called when the button is clicked
buttonFile.OnEvent("Click", buttonFileClicked)
;buttonFolder.OnEvent("Click", buttonFolderClicked)
buttonCancel.OnEvent("Click", buttonCancelClicked)

; Show the GUI
MyGui.Show("w760 h116")

buttonFileClicked(Ctrl, Info) {

editBoxExe.Value := ""

SelectedFile := FileSelect(1+2, , "Open a file", "Text Documents (*.txt; *.doc)")

if SelectedFile = ""
 editBoxExe.Text := "The dialog was canceled."
else
 editBoxExe.Text := "File selected: " . SelectedFile

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

