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
MyGui := Gui(, "File Select Example") ; "ToolWindow" does not have tray icon
;MyGui.Title := "New Title"
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w480", "Segouie UI")

; Add a Text control to the GUI
MySpaces := StrRepeat(" ", 240)
MyFiller := "[" . MySpaces . "]"    ; brackets are just for debugging
textBoxSelection := MyGui.Add("Text", "xm+0 ym+0", MyFiller)

; Add a Button control to the GUI
buttonFile := MyGui.Add("Button", "w64 xm", "File")  ; "x+5 y+5"
buttonFolder := MyGui.Add("Button", "x+m yp W64 Default", "Folder")
;~ buttonOpt2 := MyGui.Add("Button", "x+m yp W64 Default", "Opt2")
;~ buttonOpt3 := MyGui.Add("Button", "x+m yp W64 Default", "Opt3")
buttonCancel := MyGui.Add("Button", "x+m yp W64 Default", "Cancel")

; Assign a function to be called when the button is clicked
buttonFile.OnEvent("Click", buttonFileClicked)
buttonFolder.OnEvent("Click", buttonFolderClicked)
buttonCancel.OnEvent("Click", buttonCancelClicked)

; Show the GUI
MyGui.Show("w760 h84")

buttonFileClicked(Ctrl, Info) {

    textBoxSelection.Value := ""

    ;textBoxSelection.Text := "D:\Software\DEV\Work\AHK2\Release\DownloadControlTool\DownloadControlTool.exe"

    SelectedFile := FileSelect(1+2, , "Open a file", "Text Documents (*.txt; *.doc; *.*)")

    ;SelectedFile := textBoxSelection.Text
    ;textBoxSelection.Text := SelectedFile

    if SelectedFile = ""
    textBoxSelection.Text := "The dialog was canceled."
    else
    textBoxSelection.Text := SelectedFile


    if IsBinaryFile(SelectedFile)
        MsgBox("File is binary")
    else
        MsgBox("File is not binary")

}

buttonFolderClicked(Ctrl, Info) {

 textBoxSelection.Value := ""

 SelectedFolder := FileSelect("D", , "Select a folder")

 if SelectedFolder = ""
  textBoxSelection.Text := "The dialog was canceled."
 else
 textBoxSelection.Text := "Folder selected: " . SelectedFolder
}

buttonCancelClicked(Ctrl, Info) {
 ExitApp()
}

StrRepeat(text, times) {
 return StrReplace(Format("{:" times "}", ""), " ", text)
}
; This function is called when the window is closed
MyGui.OnEvent("Close", (*) => ExitApp())

;=====================================================

IsBinaryFile(filePath, tolerance := 5) {
    if !FileExist(filePath)
        return false

    ;MsgBox("Checking file: " . filePath) ; Debugging line to show file path
    
    file := FileOpen(filePath, "r")

    if !file
        return false

    buff := Buffer(1)

    loop tolerance {

        BytesRead := file.RawRead(buff, 1)

        if (BytesRead = 0)
            break

        byte := NumGet(buff, 0, "UChar")

        ;MsgBox(byte) ; Debugging line to show byte value

        ; byte < 9: Catches control characters except TAB (ASCII 9).
        ; byte > 126: Catches non-printable characters above standard ASCII.
        ; (byte < 32) and (byte > 13): Catches control characters between carriage return (13) and space (32), excluding TAB, LF, and CR.
        ; This logic is correct for most ASCII/UTF-8 text files. If any byte in the sample matches these conditions, the file is likely binary.

        if (byte < 9) or (byte > 126) or ((byte < 32) and (byte > 13)) {
            file.Close()
            return true
        }
    }

    file.Close()
    return false
}
