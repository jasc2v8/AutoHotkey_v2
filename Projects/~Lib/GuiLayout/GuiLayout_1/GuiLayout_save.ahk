;ABOUT: GuiLayout Test

;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921

#Requires AutoHotkey v2.0+

Class GuiLayoutEx {

    static guiX:=guiY:=guiW:=guiH:=guiMarginX:=guiMarginY:=0
    static clientW:=clientH:=clientX:=clientY:=0
    static controlX:=controlY:=controlW:=controlH:=0

    static _GetDimensions(MyGui, MyControl:=MyGui) {

            WinGetPos &OutX, &OutY, &OutWidth, &OutHeiguiHt, MyGui

                this.guiX := OutX
                this.guiY := OutY

                this.guiW := OutWidth
                this.guiH := OutHeiguiHt

                this.guiMarginX := MyGui.MarginX
                this.guiMarginY := MyGui.MarginY

            WinGetClientPos &OutClientX, &OutClientY, &OutClientWidth, &OutClientHeiguiHt, MyGui

                this.clientW := OutClientWidth
                this.clientH := OutClientHeiguiHt

                this.clientX := OutClientX
                this.clientY := OutClientY

            MyControl.GetPos(&X, &Y, &W, &H)

                this.controlX := X
                this.controlY := Y

                this.controlW := W
                this.controlH := H

            ;MsgBox( "guiX: " this.guiX . ", guiY: " this.guiY . ", guiW: " this.guiW . ", guih: " this.guiH . "`n`n"
            ;   "controlX: " this.controlX . ", controlY: " this.controlY . ", controlW: " this.controlW . ", controlH: " this.controlH)

    }

    ; Fill the Control to the BottomMargin
    ; BottomMargin := [Value:=0, Object:=MGui"Control Text"]
    ; if BottomMargin = 0, then fill to Gui width less margin
    static Fill(MyGui, Control, BottomMargin:=0 ) {

        if IsObject(BottomMargin) {
            BottomMargin.GetPos(&X, &Y, &W, &H)
            BottomMargin := H*2.5
        }

        this._GetDimensions(MyGui, Control)

        if (BottomMargin = 0)
            Control.Move(,,this.clientW-(this.guiMarginX * 2))
        else 
            Control.Move(,,this.clientW-(this.guiMarginX * 2), this.clientH-(this.guiMarginY*2) - BottomMargin)

    }

    static Row(MyGui, Controls, Layout) {

        Layout := Layout = '' ? "AlignLeft" : Layout

        if (Layout = "AlignLeft") {
            for control in Controls
            {
                this._GetDimensions(MyGui,control)
                if (A_Index = 1)
                    control.Move(0+this.guiMarginX)
                else
                    control.Move(0+this.guiMarginX+(this.controlW+this.guiMarginY)*(A_Index-1))
            }
            WinRedraw(MyGui)
            return
        }

        if (Layout = "AlignRight") {

            count := 1
            index := Controls.Length
            Loop
            {
                control := Controls[index]
                this._GetDimensions(MyGui, control)
                control.Move(this.guiW-this.guiMarginX-(this.guiMarginX/2)-count*(this.controlW+this.guiMarginX))
                count++
                index--
                if (index = 0)
                    break
            }
            WinRedraw(MyGui)
            return
        }

        if (Layout = "AlignCenter") {
            for control in Controls
            {
                this._GetDimensions(MyGui,control)
                newX := this.guiW / 2 - (this.controlW * Controls.Length - this.controlW/2)
                control.Move(newX + ((this.guiMarginX + this.controlW) * A_Index-1))
            }
            WinRedraw(MyGui)
            return
        }

        if (Layout = "AlignFill") {

            for control in Controls {

                this._GetDimensions(MyGui, control)

                FillWidth := Round(this.clientW / (Controls.Length * 2)) / 2

                control.Move(((this.controlW + FillWidth + this.guiMarginX-(this.guiMarginX/2)) * A_Index - 1))

            }
            WinRedraw(MyGui)
            return
        }
    }   
}

ListControls(MyGui, ControlType:='') {

    Controls := []

    For GuiCtrlObj in MyGui {

        if (ControlType = '')
            Controls.Push(GuiCtrlObj)

        else if (SubStr(GuiCtrlObj.ClassNN, 1, 6) = ControlType) {
            Controls.Push(GuiCtrlObj)
        }

    }

    For control in Controls {
        ;MsgBox( "Index   : " A_Index "`nFound : " control.ClassNN "`nText  : " control.Text "`nvName : " control.Name)

        Text := "Index : " A_Index "`n" .
                "Found : " control.ClassNN "`n" .
                "Type  : " Type(control) "`n" .
                "Text  : " control.Text "`n" .
                "vName : " control.Name

        MsgBox(Text, "List Controls")
    }
}
; #region Tests

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    __GuiLayoutEx_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

#SingleInstance Force

__GuiLayoutEx_Test() {

    ; comment to skip, comment out to run tests
    SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    ;Test2()
    ;Test3()

    Test1() {

        ; Create the GUI, resize not used as we are just moving controls

        global count := 1

        MyGui := Gui()
        MyGui.SetFont("s10")
        ;MyGui.Opt("-DPIScale") ; no change with or without

        MyEdit := MyGui.AddEdit("w200 r1 -VScroll", "Selected File")

        MyText := MyGui.AddText("w200 h20 Border", "Repeatedly Press ENTER...")

        MyButtonY := MyGui.Add("Button", "xm w100 Default vYes", "Yes")
        MyButtonN := MyGui.Add("Button", "yp w100", "No")
        MyButtonA := MyGui.Add("Button", "yp w100", "All")
        MyButtonCancel := MyGui.Add("Button", "yp w100", "Cancel").OnEvent("Click", (*) => ExitApp())
        MyGui.Show("W600 H300")

        PostMessage(EM_SETSEL:=0xB1, -1, 0, MyEdit.Hwnd) ; Deselect all text

        MyButtonY.OnEvent("Click", OnButton_Click)

        ListControls(MyGui)

        ; MsgBox Type(MyButtonY)
        ; MsgBox Type(MyGui)
        ; MsgBox IsObject(MyButtonY)
        ; MsgBox IsNumber(MyButtonY)
        ; MsgBox Type(MyButtonY)
        

        OnButton_Click(*) {

            switch count {
                case 1:

                    ;fill to the width of the gui less margin
                    GuiLayoutEx.Fill(MyGui, MyEdit) ; MyGui["Repeatedly Press ENTER..."])

                    ;fill to the top of the button control, less margin
                    GuiLayoutEx.Fill(MyGui, MyText, MyButtonY) ;MyGui["Yes"])

                    ; manually set the bottom margin. guiH-(guiH-buttonH-margin-border)
                    ;GuiLayoutEx.Fill(MyGui, MyText, BottomMargin:=300-(300-23-35-5))

                    MyText.Text :=  "Edit and Text controls filled to Gui width.`n"
                    WinRedraw(MyGui)
                case 2:
                    GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "AlignRight")
                    MyText.Text :=  "Button Layout: AlignRight.`n"
                    WinRedraw(MyGui)
                case 3:
                    GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "Center")
                    MyText.Text := "Button Layout: Center.`n"
                    WinRedraw(MyGui)
                case 4:
                    GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "AlignLeft")
                    MyText.Text := "Button Layout: AlignLeft.`n"
                    WinRedraw(MyGui)
                case 5:
                    GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "Fill")
                    MyText.Text := "Button Layout: Fill.`n"
                    WinRedraw(MyGui)
                default:
                    
            }

            count := count = 5 ? 1 : count + 1

            ;GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "AlignLeft")
            ;GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "AlignRight")
            ;GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "Center")

            ; ok GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["Cancel"]], "Center")
            ; ok GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"]], "Center")
            ; ok GuiLayoutEx.Row(MyGui, [MyGui["Yes"]], "Center")

            ;GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "Fill")
            ;GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["Cancel"]], "Fill")
            ;GuiLayoutEx.Row(MyGui, [MyGui["Yes"], MyGui["No"]], "Fill")
            ;GuiLayoutEx.Row(MyGui, [MyGui["Yes"]], "Fill")
        }
    }
}
