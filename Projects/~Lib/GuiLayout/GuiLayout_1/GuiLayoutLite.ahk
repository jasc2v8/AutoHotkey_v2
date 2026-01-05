;ABOUT: GuiLayout Test

;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921

#Requires AutoHotkey v2.0+

Class GuiLayout {

    static guiX:=guiY:=guiW:=guiH:=guiMarginX:=guiMarginY:=0
    static clientW:=clientH:=clientX:=clientY:=0
    static controlX:=controlY:=controlW:=controlH:=0

    static _GetGuiPos(MyGui) {

        WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

        return {
            X: OutX,
            Y: OutY,
            W: OutWidth,
            H: OutHeight,
            mX: MyGui.MarginX,
            mY: MyGui.MarginY,
            Width: OutWidth,
            Height: OutHeight,
            MarginX: MyGui.MarginX,
            MarginY: MyGui.MarginY
        }

    }

    static _GetClientPos(MyGui) {

        WinGetClientPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

        return {
            X: OutX,
            Y: OutY,
            W: OutWidth,
            H: OutHeight,
            Width: OutWidth,
            Height: OutHeight,
        }
    }

    static _GetControlPos(MyControl) {

        MyControl.GetPos(&OutX, &OutY, &OutWidth, &OutHeight)

        return {
            X: OutX,
            Y: OutY,
            W: OutWidth,
            H: OutHeight,
            Width: OutWidth,
            Height: OutHeight,
        }
    }

    static _GetDimensions(MyGui, MyControl:=MyGui, ShowInMsgBox:=False) {

            WinGetPos &OutX, &OutY, &OutWidth, &OutHeiguiHt, MyGui

                this.guiX := OutX
                this.guiY := OutY

                this.guiW := OutWidth
                this.guiH := OutHeiguiHt

                this.guiMarginX := MyGui.MarginX
                this.guiMarginY := MyGui.MarginY

            WinGetClientPos &OutClientX, &OutClientY, &OutClientWidth, &OutClientHeight, MyGui

                this.clientW := OutClientWidth
                this.clientH := OutClientHeight

                this.clientX := OutClientX
                this.clientY := OutClientY

            MyControl.GetPos(&X, &Y, &W, &H)

                this.controlX := X
                this.controlY := Y

                this.controlW := W
                this.controlH := H

            if (ShowInMsgBox) {
                line1 :=
                line1 := "guiX: " this.guiX . ", guiY: " this.guiY . ", guiW: " this.guiW . ", guih: " this.guiH
                line2 := "guiMarginX: " this.guiMarginX . ", guiMarginY: " this.guiMarginY
                line3 := "controlX: " this.controlX . ", controlY: " this.controlY . ", controlW: " this.controlW . ", controlH: " this.controlH
                line4 := "clientX: " this.clientX . ", clientY: " this.clientY . ", clientW: " this.clientW . ", clientH: " this.clientH
                
                msg := line1 . "`n`n" line2 . "`n`n" line3 . "`n`n" line4

                MsgBox msg ", " MyControl.ClassNN, "GuiLayout.GetDimensions"
            }
    }

    ; Fill the Control to the BottomMargin
    ; BottomMargin := [Value:=0, Object:=MGui"Control Text"]
    ; if BottomMargin = 0, then fill to Gui width less margin
    static Fill(MyGui, Control, BottomMargin:=0 ) {

        if IsObject(BottomMargin) {
            BottomMargin.GetPos(&X, &Y, &W, &H)
            BottomMargin := H*2.5
        }

        this._GetDimensions(MyGui, Control, false)

        if (BottomMargin = 0)
            Control.Move(,,this.clientW-(this.guiMarginX * 2))
        else 
            Control.Move(,,this.clientW-(this.guiMarginX * 2), this.clientH-(this.guiMarginY*2) - BottomMargin)

    }

    static RowTest(MyGui, Controls, Layout) {

        Layout := Layout = '' ? "AlignLeft" : Layout

        if (Layout = "AlignLeft") {
            for MyControl in Controls
            {
                gui := this._GetGuiPos(MyGui)
                control := this._GetControlPos(MyControl)
                if (A_Index = 1)
                    MyControl.Move(0+gui.MarginX, control.Y)
                else
                    MyControl.Move(0+gui.MarginX+(control.W+gui.MarginY)*(A_Index-1), control.Y)
            }
            WinRedraw(MyGui)
            return
        }

        if (Layout = "AlignRight") {

            index := Controls.Length
            While (index > 0)
            {
                MyControl := Controls[index]
                gui := this._GetGuiPos(MyGui)
                ctrl := this._GetControlPos(MyControl)
                MyControl.Move(gui.W-gui.MarginX-(gui.MarginX/2)-A_Index*(ctrl.W+gui.MarginX))
                index--
            }
            WinRedraw(MyGui)
            return
        }

        if (Layout = "AlignCenter") {
            for MyControl in Controls
            {
                gui := this._GetGuiPos(MyGui)
                ctrl := this._GetControlPos(MyControl)
                newX := gui.W / 2 - (ctrl.W * Controls.Length - ctrl.W/2)
                MyControl.Move(newX + ((gui.mX + ctrl.W) * A_Index-1))
            }
            WinRedraw(MyGui)
            return
        }

        if (Layout = "AlignFill") {

            newX := ""

            for MyControl in Controls {

                gui := this._GetGuiPos(MyGui)
                client := this._GetGuiPos(MyGui)
                control := this._GetControlPos(MyControl)

                FillWidth := Round((client.W / Controls.Length))

                Spacer := FillWidth - control.W

                if (newX = "")
                    ; Set the horizontal position of the first button
                    newX := Spacer - gui.MarginX ; account for left and right margins
                else
                    ;Calculate the horizontal position of the next button
                    newX += (Spacer + control.W - gui.MarginX)

                MyControl.Move(newX)

            }
            WinRedraw(MyGui)
            return
        }

    }

    static Row(MyGui, Controls, Layout) {


        ; test RowX, RowY
        ;controlY := this.clientH - this.guiMarginY - this.controlH - this.guiMarginY*1.5  ; - this.clientH * 2.5 ;this.guiH ;this.clientY + this.clientH
        ;controlY := this.guiH + this.guiY + 800 ;; + this.guiH

        Layout := Layout = '' ? "AlignLeft" : Layout

        if (Layout = "AlignLeft") {
            for control in Controls
            {
                this._GetDimensions(MyGui, control, false)
                if (A_Index = 1)
                    control.Move(0+this.guiMarginX, this.controlY)
                else
                    control.Move(0+this.guiMarginX+(this.controlW+this.guiMarginY)*(A_Index-1), this.controlY)
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
                this._GetDimensions(MyGui, control, false)
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
                this._GetDimensions(MyGui,control, false)
                newX := this.guiW / 2 - (this.controlW * Controls.Length - this.controlW/2)
                control.Move(newX + ((this.guiMarginX + this.controlW) * A_Index-1))
            }
            WinRedraw(MyGui)
            return
        }

        if (Layout = "AlignFill") {

            ctrlX := ""

            for control in Controls {

                this._GetDimensions(MyGui, control, false)

                FillWidth := Round((this.clientW / Controls.Length))

                Spacer := FillWidth - this.controlW

                if (ctrlX = "")
                    ; Set the horizontal position of the first button
                    ctrlX := Spacer - this.guiMarginX ; account for left and right margins
                else
                    ;Calculate the horizontal position of the next button
                    ctrlX += (Spacer + this.controlW - this.guiMarginX)

                control.Move(ctrlX)

            }
            WinRedraw(MyGui)
            return
        }
    }   
}
GetRowArray(MyGui, ControlType:="Button") {
    Controls := []
    For GuiCtrlObj in MyGui {
        if (SubStr(GuiCtrlObj.ClassNN, 1, 6) = ControlType)
            Controls.Push(GuiCtrlObj)
    }
    return Controls
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
#Warn Unreachable, Off
#INCLUDE <DEBUG>

__GuiLayoutEx_Test() {

    ; comment to skip, comment out to run tests
    ;SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    ;Test2()
    ;Test3()

    Test1_delete() {

    }

    Test1() {

        TestNumber := 1

        ; Create the GUI, resize not used as we are just moving controls
        MyGui := Gui()
        MyGui.SetFont("s10")
        ;MyGui.Opt("-DPIScale") ; no change with or without

        MyEdit := MyGui.AddEdit("w200 r1 -VScroll", "Selected File")

        MyText := MyGui.AddText("w200 h20 Border", "Repeatedly Press ENTER...")

        MyDivider := MyGui.AddText("w100 h4 0x10 Border vDivider") ; 0x10=SS_ETCHEDHORZ

        MyButtonY := MyGui.Add("Button", "xm w100 Default vYes", "Yes")
        MyButtonN := MyGui.Add("Button", "yp w100", "No")
        MyButtonA := MyGui.Add("Button", "yp w100", "All")
        MyButtonCancel := MyGui.Add("Button", "yp w100", "Cancel").OnEvent("Click", (*) => ExitApp())
        MyGui.Show("W600 H300")

        ControlFocus(MyButtonY)


        MyButtonY.OnEvent("Click", OnButton_Click)

        ;ListControls(MyGui)

        ; MsgBox Type(MyButtonY)
        ; MsgBox Type(MyGui)
        ; MsgBox IsObject(MyButtonY)
        ; MsgBox IsNumber(MyButtonY)
        ; MsgBox Type(MyButtonY)
        

        OnButton_Click(*) {

            MyRow := GetRowArray(MyGui, "Button")
            GuiLayout.RowTest(MyGui, MyRow, "AlignRight")
            Sleep(1000)
            GuiLayout.RowTest(MyGui, MyRow, "AlignCenter")
            Sleep(1000)
            GuiLayout.RowTest(MyGui, MyRow, "AlignLeft")
            Sleep(1000)
            GuiLayout.RowTest(MyGui, MyRow, "AlignFill")

            ; ;GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "AlignRight")
            ; MyText.Text :=  "Button Layout: AlignRight.`n"
            
            return

            TestNumber++

            if (TestNumber > 5)
                ExitApp

            switch TestNumber {
                case 1:

                    ;fill to the width of the gui less margin
                    GuiLayout.Fill(MyGui, MyEdit) ; MyGui["Repeatedly Press ENTER..."])
                    GuiLayout.Fill(MyGui, MyText) ; MyGui["Repeatedly Press ENTER..."])
                    GuiLayout.Fill(MyGui, MyDivider) ; MyGui["Repeatedly Press ENTER..."])

                    GuiLayout._GetDimensions(MyGui, MyEdit, Show:=false)

                    ; extened the Divider to the gui width less margin
                    ;GuiLayout.Fill(MyGui, MyDivider, MyButtonY) ; MyGui["Repeatedly Press ENTER..."])
                    guiH := 339
                    clientH := 300
                    GuiBottomH := guiH - clientH ; 39
                    GuiBottomY := guiH - GuiBottomH

                    guiY:=346
                    clientY:=377

                    BottomMargin:=300-(30-23-35-5)
                    guiMarginY := 7
                    buttonH := 23
                    newY := GuiBottomY - (guiMarginY*2) - (buttonH*2) ;=;- guiMarginY - buttonH ;GuiLayout.guiY - (guiMarginY*8) ; - (buttonH*2)
                    ;newY := 260
                    MyDivider.Move(,newY) ; 260

                    WinRedraw(MyGui)
                    ;fill to the top of the divider, less margin
                    ;GuiLayout.Fill(MyGui, MyText, MyDivider) ;MyGui["Yes"])

                    ;fill to the top of the button control, less margin
                    ;GuiLayout.Fill(MyGui, MyText, MyButtonY) ;MyGui["Yes"])

                    ; manually set the bottom margin. guiH-(guiH-buttonH-margin-border)
                    ;GuiLayout.Fill(MyGui, MyText, BottomMargin:=300-(300-23-35-5))

                    MyText.Text :=  "Edit, Text, and Divider controls filled to Gui width.`n"
                    ;guiMarginY

                        
                case 2:
                    Row := GetRowArray(MyGui)
                    GuiLayout.Row(MyGui, Row, "AlignRight")
                    MyText.Text :=  "Button Layout: AlignRight.`n"
                    WinRedraw(MyGui)
                case 3:
                    GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "AlignCenter")
                    MyText.Text := "Button Layout: AlignCenter.`n"
                    WinRedraw(MyGui)
                case 4:
                    GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "AlignLeft")
                    MyText.Text := "Button Layout: AlignLeft.`n"
                    WinRedraw(MyGui)
                case 5:
                    GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "AlignFill")
                    MyText.Text := "Button Layout: AlignFill.`n"
                    WinRedraw(MyGui)
                default:
                    
            }

            count := count = 5 ? 1 : count + 1

            ;GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "AlignLeft")
            ;GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "AlignRight")
            ;GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "Center")

            ; ok GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["Cancel"]], "Center")
            ; ok GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"]], "Center")
            ; ok GuiLayout.Row(MyGui, [MyGui["Yes"]], "Center")

            ;GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "Fill")
            ;GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["Cancel"]], "Fill")
            ;GuiLayout.Row(MyGui, [MyGui["Yes"], MyGui["No"]], "Fill")
            ;GuiLayout.Row(MyGui, [MyGui["Yes"]], "Fill")
        }
    }
}
