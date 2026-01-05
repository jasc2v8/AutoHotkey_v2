#Requires AutoHotkey v2.0
#SingleInstance Force
;#NoTrayIcon

;DEBUG
#Include <Debug>
Escape::ExitApp()

    class MyGuiClass {
        gui := unset
        Result := ""

        __New(Text:="", Title:="") {

            this.gui := Gui("+ToolWindow")
            this.gui.Title := Title

            MyText := this.gui.AddText("w150 h60 vMyText")

            ; Attach event handlers using ObjBindMethod or Fat Arrow Functions
            ButtonOK := this.gui.AddButton("xm yp+100 w75 Default", "OK")
            
            this.gui.AddButton("yp w75", "Cancel").OnEvent("Click", ObjBindMethod(this, "_OnClick" ))

            ; ok this.gui["OK"].OnEvent("Click", ObjBindMethod(this, "OnClick"))
            ButtonOK.OnEvent("Click", ObjBindMethod(this, "_OnClick"))

            if (Text != "") {
                ;this.gui["MyText"].Text := Text
                MyText := Text
                ;this.gui.Show("w200 h150")
                ;this.gui.Show()
            }
            this.Show(Text, Title)
        }

        _OnClick(Ctrl, Info) {
            this.Result := Ctrl.Text
            this.gui.Hide()
        }

        Show(Text:="", Title:="") {
            if (Title != "")
                this.gui.Title := Title
            this.gui.Show()
            this.gui["MyText"].Text := Text
            WinWaitNotActive(this.gui.Hwnd)
            return this.Result
        }

    }

    ;set the font, colors, icon, and sound when created
    ;MB := MyGuiClass("Matrix", "my text", "my title", Buttons, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt
    ;MB.Theme := "Matrix"
    ;MB.Buttons :=
    ;MB.FontSize :=
    ;MB.FontName :=
    ;MB.FontColor :=
    ;MB.GuiOpt :=
    ;MB.GuiBackcolor :=
    ;MB.TextOpt :=
    ;MB.IconFile :=
    ;MB.IconNumber :=
    ;MB.SoundFile :=

    MB := MyGuiClass()

    MB := MyGuiClass("my text", "my title")

    ;if (MB.Result = "OK")
    ;    MsgBox "Button Clicked: " MB.Result

    ;Show Text, Title
    returnValue := MB.Show("Press OK to continue...", "New Title")
    
    MB.Show("returnValue: " returnValue, "Return Value")

    MB.Show("Press OK to close.", "End of Demo")

    ; if (MB.Result = "OK")
    ;     MB.Show("Button Clicked: " MB.Result)

    ;myGui2 := MyGuiClass("Button Clicked: " myGui.Result)

    ;WinWaitNotActive(myGui.gui.Hwnd)

    ;MsgBox  Type(myGui)
    MB := MyGui2 := unset
