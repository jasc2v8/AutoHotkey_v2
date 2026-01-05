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

        ; W := (OutWidth  = "") ? OutX : OutWidth
        ; H := (OutHeight = "") ? OutY : OutHeight

        ; OutWidth := OutX
        ; OutHeight := OutY

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

    ; Fill the Control to the BottomMargin
    ; BottomMargin := [Value:=0, Object:=MGui"Control Text"]
    ; if BottomMargin = 0, then fill to Gui width less margin
    static Fill(MyGui, Control, Right:=0, Bottom:=0 ) {

        if IsSet(Bottom) AND IsObject(Bottom) {
            Bottom.GetPos(&X, &Y, &W, &H)
            Bottom := H*2.5
        }

        ;this._GetDimensions(MyGui, Control, false)
        gui := this._GetGuiPos(MyGui)
        client := this._GetClientPos(Control)
        ctrl := this._GetControlPos(Control)

        if (Right = 0) {
            NewWidth:= gui.W-(gui.MarginX * 3) -4 ; lines
        } else { 
            NewWidth := gui.W-(gui.MarginX*3) - Right
        } 

        if (Bottom = 0) {
            NewBottom := gui.H-gui.mY-32-gui.mY-gui.mY ; 32 is TitleBar
        } else { 
            NewBottom := gui.H-(gui.MarginY*2) - Bottom
        } 
       
        ;Control.Move(,,gui.W-(gui.MarginX * 2))
        Control.Move(,,NewWidth, NewBottom) ;320

        nop:=true
    }

    static Row(MyGui, Controls, Layout) {

        ; Just check the first letter
        switch SubStr(Layout,1,1) {
            case 'L':
                Layout := "AlignLeft"
            case 'C':
                Layout := "AlignCenter"
            case 'R':
                Layout := "AlignRight"
            case 'F':
                Layout := "AlignFill"
            default:
                Layout := "AlignLeft"             
        }

        if (Layout = "AlignLeft") {
            for MyControl in Controls
            {
                gui := this._GetGuiPos(MyGui)
                ctrl := this._GetControlPos(MyControl)
                ;if (A_Index = 1)
                    ;MyControl.Move(0+gui.MarginX, control.Y)
                ;else
                    MyControl.Move(0+gui.MarginX+(ctrl.W+gui.MarginY)*(A_Index-1), ctrl.Y)
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
    
    static GetControls(MyGui, ControlType:="Button") {
        Controls := []
        For GuiCtrlObj in MyGui {
            if (ControlType = '')
                Controls.Push(GuiCtrlObj)
        else if (InStr(Type(GuiCtrlObj), ControlType) != 0)
                    Controls.Push(GuiCtrlObj)
            }
        return Controls
    }
}


; GetRowArray(MyGui, ControlType:="Button") {
;     Controls := []
;     For GuiCtrlObj in MyGui {
;         if (SubStr(GuiCtrlObj.ClassNN, 1, 6) = ControlType)
;             Controls.Push(GuiCtrlObj)
;     }
;     return Controls
; }

ListControls(MyGui, ControlType:='') {

    Controls := []

    For GuiCtrlObj in MyGui {

        ; if not specified, return all controls
        if (ControlType = '')
            Controls.Push(GuiCtrlObj)

        ; else return the specified controls
        else if (SubStr(GuiCtrlObj.ClassNN, 1, 6) = ControlType)
            Controls.Push(GuiCtrlObj)
    }

    Text :=""

    For control in Controls {

        ;MsgBox( "Index   : " A_Index "`nFound : " control.ClassNN "`nText  : " control.Text "`nvName : " control.Name)

        ; Text := "Index : " A_Index "`n" .
        ;         "Found : " control.ClassNN "`n" .
        ;         "Type  : " Type(control) "`n" .
        ;         "Text  : " control.Text "`n" .
        ;         "vName : " control.Name

        Text .= A_Index ", " .
                control.ClassNN ", " .
                Type(control) ", " .
                control.Text ", " .
                control.Name "`n`n"
    }
    MsgBox(Text, "List Controls")
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
    SoundBeep(), ExitApp()

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

            ; MyRow := GetRowArray(MyGui, "Button")
            ; GuiLayout.RowTest(MyGui, MyRow, "AlignRight")
            ; Sleep(1000)
            ; GuiLayout.RowTest(MyGui, MyRow, "AlignCenter")
            ; Sleep(1000)
            ; GuiLayout.RowTest(MyGui, MyRow, "AlignLeft")
            ; Sleep(1000)
            ; GuiLayout.RowTest(MyGui, MyRow, "AlignFill")

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
                    ; Row := GetRowArray(MyGui)
                    ; GuiLayout.Row(MyGui, Row, "AlignRight")
                    ; MyText.Text :=  "Button Layout: AlignRight.`n"
                    ; WinRedraw(MyGui)
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
