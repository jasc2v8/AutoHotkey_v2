;ABOUT: Initial version

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#Include "Class_MBox.ahk"

global MyGui

Test_GuiOpt()
ExitApp()

; __New(Text,Title,Buttons,Size,Opt,BackColor,TextOpt,TextFontOpt,ButtonFontOpt,IconOpt,SoundOpt)

Title := '' ; A_ScriptName

;MB := MBox("my text","my title",,"300,100,,")
;MB := MBox("my text",Title,,"200,600,40,40")
MB := MBox("my text","my title","Default &OK, &Abort, &Cancel, AlignRight","300,100,,",,,,"s14,Consolas","s8,Times")
MB.Show()

MB := MBox("my text","my title",,"300,100,,",,,,"s14,Consolas")
MB.Show()

MB := MBox("my text","my title",,"300,100,,",,,,"","s14,Consolas")
MB.Show()

;TODO: Size "200,100,," is ok, but "200,100" is not

;MB.Show("different text", "different title")


Test_GuiOpt() {

    MyGui := Gui("+Owner")
    MyGui.AddText(,"Owner")
    ;MyGui.AddButton(,"Default &OK").OnEvent("Click", (*)=>ExitApp)
    ;MyGui.AddButton("Default","&OK").OnEvent("Click", Button_Click)
    MyGui.AddButton("Default","&OK").OnEvent("Click", Button_Click2)
    MyGui.Show("x10 y10 w300 h100")
    WinWaitNotActive(MyGui.Hwnd)


    }
    Button_Click(*) {
        MyPopUp := Gui()
        MyPopUp.Opt("+Owner")
        MyPopUp.AddText(,"Pop Up")
        ;MyGui.AddButton(,"Default &OK").OnEvent("Click", (*)=>ExitApp)
        ;MyPopUp.AddButton(,"Default &OK").OnEvent("Click", MyPopUp.Destroy())
        ;MyGui.AddButton("Default","&OK").OnEvent("Click", Button_Click)
        MyPopUp.Show("x20 y20 w100 h50")
        WinWaitNotActive(MyPopUp.Hwnd)

    }
    Button_Click2(*) {
    Title := "Test GuiOpt"
        Buttons := "Default &OK, &Cancel, AlignCenter"
        ; TextFont := "Default"
        ; ButtonFont := "Default"
        Opt := "+Owner"
        ;Opt := "Border"
        Text := "GuiOpt: " Opt
        MB := MBox(Text, Title, Buttons,,Opt)
        r := MB.Show()
        ;(r = "&OK") ? nop:=true : ExitApp()
    }
 