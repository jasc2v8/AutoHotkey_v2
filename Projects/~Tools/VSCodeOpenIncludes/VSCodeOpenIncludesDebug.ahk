; TITLE  :  VSCodeOpenIncludes v1.0.0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Scans the script and opens all the #Include files in new editor tabs
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2+
#SingleInstance Force
#NoTrayIcon

#Include <String>
#Include <RunLib>

;; Globals

global AHK_EXE_PID := 0

global runner:=RunLib()

; #region GUI Create
MyGuiTitle := "AutoHotkey v2 Template"
MyGui := Gui(, MyGuiTitle )
MyGui.BackColor := "7DA7CA" ; Steel Blue +2.5 Glaucous ; BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11", "Consolas")

MyEdit := MyGui.AddText("w480 h24 BackgroundWhite", "D:\Software\DEV\Work\AHK2\Projects\~Tools\SearchBarReset\SearchBarReset.ahk")

textWidth := 480
MyText := MyGui.Add("Text", "xm y+m h1 w" textWidth " +0x9") ; Etched horizontal line that autosizes with the GUI

MyGui.SetFont()
ButtonSelect := MyGui.AddButton("ym w75", "&Select").OnEvent("Click", Button_Click)
ButtonOK := MyGui.AddButton("xm w75 Default", "&OK").OnEvent("Click", Button_Click)
buttonCancel := MyGui.AddButton("yp w75", "&Cancel").OnEvent("Click", (*) => ExitApp())

myStatusBar := myGui.Add("StatusBar")
WriteStatus "Ready."

; #region OnEvent Bindings

; buttonBuild.OnEvent("Click", buttonBuild_Click)
; buttonConfig.OnEvent("Click", buttonConfig_Click)
; buttonHelp.OnEvent("Click", buttonHelp_Click)
; buttonCancel.OnEvent("Click", buttonCancel_Click)

myGui.OnEvent("Close", OnGui_Close)

; #region GUI Show
MyGui.Show()

; #region OnEvent Handlers

Button_Click(Ctrl, Info) {

    WriteStatus Ctrl.Text

    if Ctrl.Text = "&Select"
        DoSelectFolder(Ctrl)

    if Ctrl.Text = "&OK"
        runner.Run("%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe," MyEdit.Text)    
}

buttonCancel_Click(*) {
	WinClose()
}


OnGui_Close(*) {
    ExitApp()
}

; #region Functions

DoSelectFolder(Item) {

    SplitPath(MyEdit.Text,,&Dir)

    f := FileSelect(1+2, Dir,,'AHK Script Files (*.ahk)')
    ;f := DirSelect(MyText.Text, 1+2+4,'Select Folder')

    MsgBox f

    if (f="")
        return

    MyEdit.Text := f

    runner.Run("%LOCALAPPDATA%\Programs\Microsoft VS Code\Code.exe," MyEdit.Text)

}

WriteStatus(Text := '') {
    myStatusBar.SetText("    " . Text )
}