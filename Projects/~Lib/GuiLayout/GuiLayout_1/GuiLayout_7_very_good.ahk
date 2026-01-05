;ABOUT: GuiLayout
;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921
/*
    TODO:
        AlignRight could be improved for smaller gui (400x200)
*/

#Requires AutoHotkey v2.0+

Class GuiLayout {

    static _GetGuiPos(MyGui) {

        WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

        WinGetClientPos , &clientY, , , MyGui

        titleBarHeight := clientY - OutY - MyGui.MarginY

        return {
            X: OutX,
            Y: OutY,
            W: OutWidth,
            H: OutHeight,
            Width: OutWidth,
            Height: OutHeight,
            MX: MyGui.MarginX,
            MY: MyGui.MarginY,
            MarginX: MyGui.MarginX,
            MarginY: MyGui.MarginY,
            TitleBarHeight: titleBarHeight ; 200 
        }
    }

    static _GetClientPos(MyGui) {

        WinGetClientPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

        grui := this._GetGuiPos(MyGui)
        titleBar := OutY - grui.Y - grui.MY
        clientRight := grui.W - (grui.MX*2) - (grui.MX*2) + 4
        ;clientBottom :=	grui.H - TitleBar - (grui.MY*2) - (grui.MY*2) + 4
        ;clientBottom :=	grui.H - TitleBar - (grui.MY*4) + 4
        clientBottom :=	OutHeight ; - TitleBar - (grui.MY*4) + 4

        return {
            X: OutX,
            Y: OutY,
            W: OutWidth,
            H: OutHeight,
            Width: OutWidth,
            Height: OutHeight,
            Right: clientRight,
            Bottom: clientBottom,
            R: clientRight,
            B: clientBottom

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
            MX: OutX - 4,
            MY: OutY,
            MarginX: OutX - 4,
            MarginY: OutY
        }
    }

    ; Fill the Control to the BottomMargin
    ; BottomMargin := [Value:=0, Object:=MGui"Control Text"]
    ; if BottomMargin = 0, then fill to Gui width less margin
    static Fill(MyGui, Control, Width:=0, Height:=0 ) {
        
        grui    := this._GetGuiPos(MyGui)
        client  := this._GetClientPos(MyGui)
        ctrl    := this._GetControlPos(Control)

        if IsSet(Height) AND IsObject(Height) {
            
            Height.GetPos(&X, &Y, &W, &H)
            ;Height := H * 2.5
            ;Height := grui.H-(grui.MarginY*2) - H*5
            Height := client.Bottom-grui.MarginY-ctrl.H-grui.MarginY-grui.TitleBarHeight
            Height := Y - grui.MarginY*2

            OutputDebug X ", " Y ", " W ", " H
        }

        if (Width = 0) {
            NewWidth:= client.Right
        } else { 
            ;NewWidth := grui.W-(grui.MarginX*3) - Width
            NewWidth := Width
        } 

        if (Height = 0) {
            NewHeight := client.Bottom - grui.MarginY
        } else { 
            ;NewHeight := grui.H-(grui.MarginY*2) - Height
            NewHeight := Height
        } 
       
        if (Width>=0) AND (Height>=0) {
            Control.Move(,,NewWidth, NewHeight)     ; 0=max W/H, >0=new W/H
        }
        if (Width>=0) AND (Height<0) {
            Control.Move(,,NewWidth)                ; 0=max W/H, >0=new W/H
        } 

        if (Width<0) AND (Height>=0) {
            Control.Move(,,, NewHeight)             ; 0=max W/H, >0=new W/H
        }

        if (Width<0) AND (Height<0) {               ; <0=same W/H
            inop:=true
        } 

        nop:=true
    }

    static Row(MyGui, Controls, Layout, Y:=0) {

        grui    := this._GetGuiPos(MyGui)
        client  := this._GetClientPos(MyGui)

        if (Y <= 0)
            nop:=true
        else if (Y=0)
            newY := client.Bottom
        else
            newY := Y

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
                grui := this._GetGuiPos(MyGui)
                ctrl := this._GetControlPos(MyControl)
                client := this._GetClientPos(MyGui)

                newX := grui.MarginX+(ctrl.W+grui.MarginY)*(A_Index-1), ctrl.Y

                newY := Y
                maxY := client.Bottom - ctrl.H - grui.MarginY

                if (Y<0)
                    MyControl.Move(newX)
                else if (Y=0)
                    MyControl.Move(newX, maxY)
                else
                    MyControl.Move(newX, newY)
            }
            WinRedraw(MyGui)
            return
        }

        if (Layout = "AlignRight") {

            index := Controls.Length
            While (index > 0)
            {
                MyControl := Controls[index]

                grui := this._GetGuiPos(MyGui)
                client := this._GetClientPos(MyGui)
                ctrl := this._GetControlPos(MyControl)

                newX := grui.W-grui.MarginX-(grui.MarginX/2)-A_Index*(ctrl.W+grui.MarginX)

                newY := Y
                maxY := client.Bottom - ctrl.H - grui.MarginY

                if (Y<0)
                    MyControl.Move(newX)
                else if (Y=0)
                    MyControl.Move(newX, maxY)
                else
                    MyControl.Move(newX, newY)

                index--
            }
            WinRedraw(MyGui)
            return
        }

        if (Layout = "AlignCenter") {
            for MyControl in Controls
            {
                ctrl := this._GetControlPos(MyControl)

                grui := this._GetGuiPos(MyGui)
                client := this._GetClientPos(MyGui)
                ctrl := this._GetControlPos(MyControl)

                newX := grui.W / 2 - (ctrl.W * Controls.Length - ctrl.W/2) + ((grui.MX + ctrl.W) * A_Index-1)

                newY := Y
                maxY := client.Bottom - ctrl.H - grui.MarginY

                if (Y<0)
                    MyControl.Move(newX)
                else if (Y=0)
                    MyControl.Move(newX, maxY)
                else
                    MyControl.Move(newX, newY)
            }
            WinRedraw(MyGui)
            return
        }

        if (Layout = "AlignFill") {

            for MyControl in Controls {

                grui := this._GetGuiPos(MyGui)
                client := this._GetClientPos(MyGui)
                ctrl := this._GetControlPos(MyControl)

                maxY := client.Bottom - ctrl.H - grui.MarginY
                newY := client.Bottom

                Spacer := Round(client.W / Controls.Length)

                if (A_Index=1)
                    ; Set the horizontal position of the first button
                    newX := Spacer/2
                else
                    ;Calculate the horizontal position of the next button
                    newX += Spacer / 1.25 ; Spacer

                if (Y<0)
                    MyControl.Move(newX)
                else if (Y=0)
                    MyControl.Move(newX, maxY)
                else
                    MyControl.Move(newX, newY)

            }
            WinRedraw(MyGui)
            return
        }

    }
    
    static Move(MyGui, MyControl, x:="", y:="", w:="", h:="") {
        ; -1=same W/H, 0=max W/H, >0=new W/H (default=0)
        ; ""=same W/H, 0=max W/H, >0=new W/H (default=0)

        grui := this._GetGuiPos(MyGui)
        client := this._GetClientPos(MyGui)
        ctrl := this._GetControlPos(MyControl)

        if (y=0) {
            maxY := client.Bottom-grui.MarginY-ctrl.H-grui.MarginY-grui.TitleBarHeight ; client.Bottom - grui.TitleBarHeight - ctrl.H
        }

        MyControl.Move(, maxY, , )


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

    For ctrl in Controls {

        ;MsgBox( "Index   : " A_Index "`nFound : " ctrl.ClassNN "`nText  : " ctrl.Text "`nvName : " ctrl.Name)

        ; Text := "Index : " A_Index "`n" .
        ;         "Found : " ctrl.ClassNN "`n" .
        ;         "Type  : " Type(ctrl) "`n" .
        ;         "Text  : " ctrl.Text "`n" .
        ;         "vName : " ctrl.Name

        Text .= A_Index ", " .
                ctrl.ClassNN ", " .
                Type(ctrl) ", " .
                ctrl.Text ", " .
                ctrl.Name "`n`n"
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

                    ;fill to the width of the grui less margin
                    GuiLayout.Fill(MyGui, MyEdit) ; MyGui["Repeatedly Press ENTER..."])
                    GuiLayout.Fill(MyGui, MyText) ; MyGui["Repeatedly Press ENTER..."])
                    GuiLayout.Fill(MyGui, MyDivider) ; MyGui["Repeatedly Press ENTER..."])

                    GuiLayout._GetDimensions(MyGui, MyEdit, Show:=false)

                    ; extened the Divider to the grui width less margin
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
