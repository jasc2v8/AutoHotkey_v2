;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <String>

#Include Anchor.ahk
;#Include <Anchor>

;; Globals

global AHK_EXE_PID := 0

; #region GUI Create
MyGuiTitle := "AutoHotkey v2 Template"
MyGui := Gui("+Resize", MyGuiTitle )
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11", "Consolas")

editBoxAhk := MyGui.AddText("w480 h24 BackgroundWhite", A_ScriptFullPath)

textWidth := 480
MyText := MyGui.Add("Text", "xm y+m h1 w" textWidth " +0x9") ; Etched horizontal line that autosizes with the GUI

MyGui.SetFont()
ButtonSelect := MyGui.AddButton("ym w75", "&Select")
ButtonOK := MyGui.AddButton("xm w75 Default", "&OK")
buttonCancel := MyGui.AddButton("yp w75", "&Cancel")

myStatusBar := myGui.Add("StatusBar")
WriteStatus "Ready."

; #region OnEvent Bindings

ButtonSelect.OnEvent("Click", Button_Click)
ButtonOK.OnEvent("Click", Button_Click)
buttonCancel.OnEvent("Click", (*) => ExitApp())
; buttonBuild.OnEvent("Click", buttonBuild_Click)
; buttonConfig.OnEvent("Click", buttonConfig_Click)
; buttonHelp.OnEvent("Click", buttonHelp_Click)
; buttonCancel.OnEvent("Click", buttonCancel_Click)

myGui.OnEvent("Close", OnGui_Close)
myGui.OnEvent('Size', Gui_Size)

; #region GUI Show
MyGui.Show()

; #region OnEvent Handlers

Gui_Size(*) {
    Anchor(editBoxAhk, "w")
    Anchor(MyText, "w")
    Anchor(ButtonSelect, "x")
    Anchor([ButtonOK, ButtonCancel], "y", true)
    ;Anchor(e2, "y")
    ;Anchor(e3, "yw")
}


Button_Click(Ctrl, Info) {

    WriteStatus Ctrl.Text

    if Ctrl.Text = "&Select"
        DoSelectFolder(Ctrl)

}

buttonCancel_Click(*) {
	WinClose()
}


OnGui_Close(*) {
    ExitApp()
}

; #region Functions

DoSelectFolder(Item) {

    ;f := FileSelect(1+2, MyText.Text,,'Text Files (*.txt)')
    f := DirSelect(MyText.Text, 1+2+4,'Select Folder')

    MsgBox f

    if (f="")
        return

    MyText.Value := f

}

WriteStatus(Text := '') {
    myStatusBar.SetText("    " . Text )
}