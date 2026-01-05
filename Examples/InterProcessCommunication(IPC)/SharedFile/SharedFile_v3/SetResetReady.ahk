; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

;#Include <String>
#Include <SharedFile>

; #region Globals
;global SF := SharedFile("Server")
global filePath := "D:\SetResetReady.txt"

; #region GUI Create
MyGuiTitle := "AutoHotkey v2 Template"
MyGui := Gui(, MyGuiTitle )
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11", "Consolas")

MyEdit := MyGui.AddEdit("w480 h24 BackgroundWhite", filePath)

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


; create the file
if !FileExist(filePath)
    FileAppend("", filePath)

; show attributes
ShowAttributes(filePath)


; #region OnEvent Handlers

ShowAttributes(filePath) {
    if (FileExist(filePath))
        WriteStatus "Attrib: " FileGetAttrib(filePath)
    else
        WriteStatus "File not found."
}

Button_Click(Ctrl, Info) {

    WriteStatus Ctrl.Text

    if Ctrl.Text = "&Select"
        DoSelectFolder(Ctrl)

    filePath:= MyEdit.Text
    
    FileSetAttrib "^A", filePath


    ShowAttributes(filePath)

}

buttonCancel_Click(*) {
	WinClose()
}


OnGui_Close(*) {
    ExitApp()
}

; #region Functions

DoSelectFolder(Item) {

    f := FileSelect(1+2, MyText.Text,,'Text Files (*.txt)')

    MsgBox f

    if (f="")
        return

    MyText.Value := f

}

WriteStatus(Text := '') {
    myStatusBar.SetText("    " . Text )
}