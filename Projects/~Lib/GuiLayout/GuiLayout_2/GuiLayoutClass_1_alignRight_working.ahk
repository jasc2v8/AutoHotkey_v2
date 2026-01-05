;ABOUT: GuiLayout
;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921
/*
    TODO:
        AlignRight could be improved for smaller gui (400x200)
*/

#Requires AutoHotkey v2.0+

Class GuiLayout {

    RefreshOnSize := True

    GuiObj:=""
    GuiCtrl:=""

    clientWidth         := 0
    clientHeight        := 0

    Clientbottom :=0

    __New(GuiObj) {

        if Type(GuiObj) != "Gui"
            return

        this.GuiObj := GuiObj

        this.Refresh()
    }

    Refresh() {
        ; get all dims

        ; save
        ;this.clientBottom := 0
        dim := this.GetMetrics(this.GuiObj)
        
        this.GuiWidth       := dim.GuiWidth
        this.GuiHeight      := dim.GuiHeight
        this.ClientWidth    := dim.clientWidth
        this.ClientHeight   := dim.clientHeight
        this.Clientleft     := dim.clientleft
        this.Clienttop      := dim.clienttop
        this.Clientright    := dim.clientright
        this.Clientbottom   := dim.clientbottom
        this.BorderWidth    := dim.borderWidth
        this.BorderHeight   := dim.borderHeight
        this.CaptionHeight  := dim.captionHeight
        this.TotalNonClientHeight := dim.totalNonClientHeight 
        

    }

    Move(MyControl, newX:="", newY:="", newW:="", newH:="", Redraw:=False ) {

    ;TODO:
    ; if Mycontrol is String, MyControl := this.MyGui[MyControl]

        calcX := (newX = "") ? this.Pos(MyControl).ControlX : newX
        calcY := (newY = "") ? this.Pos(MyControl).ControlY : newY
        calcW := (newW = "") ? this.Pos(MyControl).ControlW : newW
        calcH := (newH = "") ? this.Pos(MyControl).ControlH : newH

        MyControl.Move(calcX, calcY, calcW, calcH)

        if (Redraw)
            WinRedraw(MyControl.Gui)

        nop:=true
    }

    Pos(ObjectOrString:="") {

        ; Update metrics for Controls that have been moved or resized
        this.Refresh()

        ; IsType() = Gui, Gui.Text, String

        if (ObjectOrString = "") {

            return this.GetMetrics(this.GuiObj)

        } else if (Type(ObjectOrString) = "String") {

            ;MsgBox "IS a string: " ObjectOrString

            this.CtrlObj := this.GuiObj[ObjectOrString]

            this.CtrlObj.GetPos(&OutX, &OutY, &OutWidth, &OutHeight)

            return {
                ControlX: OutX,
                ControlY: OutY,
                ControlW: OutWidth,
                ControlH: OutHeight,
                ControlWidth: OutWidth,
                ControlHeight: OutHeight,

                TopControlY: OutY - this.Pos().BorderWidth,
                ControlYTop: OutY - this.Pos().BorderWidth,
            }

            nop := true

        } else if  (SubStr(Type(ObjectOrString),1,4) = "Gui.") {

            ;MsgBox "Found Gui Control Object: " ObjectOrString.ClassNN

            this.CtrlObj := ObjectOrString

            this.CtrlObj.GetPos(&OutX, &OutY, &OutWidth, &OutHeight)

            return {
                ControlX: OutX,
                ControlY: OutY,
                ControlW: OutWidth,
                ControlH: OutHeight,
                ControlWidth: OutWidth,
                ControlHeight: OutHeight,
            }

        } else if (SubStr(Type(ObjectOrString),1,3) = "Gui") {

            ;MsgBox "Found Gui Object"

            this.GuiObj := ObjectOrString

        } else {
            Throw "Error unknown Parameter for ObjectOrString"
        }

            return this.GetMetrics(this.GuiObj)
  

    }

    GetControls(MyGui, ControlType:="Button") {
        Controls := []
        For GuiCtrlObj in MyGui {
            if (ControlType = '')
                Controls.Push(GuiCtrlObj)
            else if (InStr(Type(GuiCtrlObj), ControlType) != 0)
                    Controls.Push(GuiCtrlObj)
        }
        return Controls
    }

    GetMetrics(GuiObj) {

        ;RECT for Gui
        GuiRect := Buffer(16, 0)
        DllCall("GetWindowRect", "ptr", GuiObj.hwnd, "ptr", GuiRect.Ptr)
        Guileft   := NumGet(GuiRect, 0, "int")
        Guitop    := NumGet(GuiRect, 4, "int")
        Guiright  := NumGet(GuiRect, 8, "int")
        Guibottom := NumGet(GuiRect, 12, "int")

        GuiW := Guiright - Guileft
        GuiH := Guibottom - Guitop

        ; RECT for Client area
        clientRect := Buffer(16, 0)
        DllCall("GetClientRect", "ptr", GuiObj.hwnd, "ptr", clientRect.Ptr)

        clientleft   := NumGet(clientRect, 0, "int")
        clienttop    := NumGet(clientRect, 4, "int")
        clientright  := NumGet(clientRect, 8, "int")
        clientbottom := NumGet(clientRect, 12, "int")

        clientW := clientright - clientleft
        clientH := clientbottom - clienttop

        ; Get border metrics
        borderX := DllCall("GetSystemMetrics", "int", 32, "int") ; SM_CXFRAME
        borderY := DllCall("GetSystemMetrics", "int", 33, "int") ; SM_CYFRAME
        captionH := DllCall("GetSystemMetrics", "int", 4, "int")  ; SM_CYCAPTION

        ; Calculate actual differences
        borderWidth := (GuiW - clientW) // 2
        borderHeight := (GuiH - clientH - captionH) // 2

        clientBottom := clientH - borderY

        ;TODO: FIX THIS
        clientRight := clientW - borderX*5

        return {
            GuiWidth: GuiW,
            GuiHeight: GuiH,
            ClientWidth: clientW,
            ClientHeight: clientH,
            ClientLeft: clientleft,
            ClientTop: clienttop,
            ClientRight: clientright,
            ClientBottom: clientbottom,
            BorderWidth: borderWidth,
            BorderHeight: borderHeight,
            CaptionHeight: captionH,
            TotalNonClientHeight: GuiH - clientH
        }

    }

    MoveRow(Controls, Layout, newX:="", newY:="", newW:="", newH:="", Redraw:=False) {

        grui    := 0 ; this._GetGuiPos(Controls[1].Gui)
        client  := 0 ;  this._GetClientPos(Controls[1].Gui)
        ;ctrl    := this._GetControlPos(Control)

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
                grui    := 0 ;  this._GetGuiPos(MyControl.Gui)
                client  := 0 ;  this._GetClientPos(MyControl.Gui)
                ctrl    := 0 ;  this._GetControlPos(MyControl)

                leftSide := grui.MarginX+(ctrl.W+grui.MarginY)*(A_Index-1), ctrl.Y

                calcW := (newW = "") ? ctrl.W : (newW = 0) ? ctrl.W : newW ; CALC WIDTH BASED ON TEXT LENGTH???
                calcH := (newH = "") ? ctrl.H : (newH = 0) ? ctrl.H : newH
                calcX := (newX = "") ? ctrl.X : (newX = 0) ? leftSide : newX
                calcY := (newY = "") ? ctrl.Y : (newY = 0) ? client.Bottom - calcH + (grui.MarginY*2) : newY

                if (A_Index=1) {
                    xSpace := calcW  + grui.MarginX
                    xPos := grui.MarginX
                } else
                    xPos += xSpace
    
                xPos := Round(xPos)

                MyControl.Move(xPos, calcY, calcW, calcH)

                if (Redraw)
                    WinRedraw(MyControl.Gui)
            }
        }

        if (Layout = "AlignRight") {

            index := Controls.Length

            While (index > 0)
            {
                MyControl := Controls[index]

                calcX := (newX = "") ? this.Pos(MyControl).ControlX : newX
                calcY := (newY = "") ? this.Pos(MyControl).ControlY : newY
                calcW := (newW = "") ? this.Pos(MyControl).Width : newW
                calcH := (newH = "") ? this.Pos(MyControl).ControlH : newH

                if (A_Index=1) {
                    xSpace := this.Pos().ClientRight - calcW - this.Pos().Margin
                    xPos := xSpace ; Round(xSpace)
                } else
                    xPos -= calcW + this.Pos().BorderWidth

                MyControl.Move(xPos, calcY, calcW, calcH)

                if (Redraw)
                    WinRedraw(MyControl.Gui)

                index--
            }
        }

        if (Layout = "AlignCenter") {
            for MyControl in Controls
            {
                grui    := 0 ;  this._GetGuiPos(MyControl.Gui)
                client  := 0 ;  this._GetClientPos(MyControl.Gui)
                ctrl    := 0 ;  this._GetControlPos(MyControl)

                calcW := (newW = "") ? ctrl.W : (newW = 0) ? ctrl.W : newW ; CALC WIDTH BASED ON TEXT LENGTH???
                calcH := (newH = "") ? ctrl.H : (newH = 0) ? ctrl.H : newH
                calcX := (newX = "") ? ctrl.X : (newX = 0) ? newX : newX
                calcY := (newY = "") ? ctrl.Y : (newY = 0) ? client.Bottom - calcH + (grui.MarginY*2) : newY

                ;leftSide := grui.W / 2 - (ctrl.W * Controls.Length - ctrl.W/2) + ((grui.MX + ctrl.W) * A_Index-1)
                leftSide := grui.W / 2 - (calcW * Controls.Length - calcW/2) + ((grui.MX + calcW) * A_Index-1)

                if (A_Index=1) {
                    xSpace := calcW  + grui.MarginX
                    xPos := leftSide 
                } else
                    xPos += xSpace
    
                xPos := Round(xPos)

                MyControl.Move(xPos, calcY, calcW, calcH)

                if (Redraw)
                    WinRedraw(MyControl.Gui)
            }
        }

        if (Layout = "AlignFill") {

            for MyControl in Controls {

                grui    := 0 ;  this._GetGuiPos(MyControl.Gui)
                client  := 0 ;  this._GetClientPos(MyControl.Gui)
                ctrl    := 0 ;  this._GetControlPos(MyControl)

                calcW := (newW = "") ? ctrl.W : (newW = 0) ? ctrl.W : newW ; CALC WIDTH BASED ON TEXT LENGTH???
                calcH := (newH = "") ? ctrl.H : (newH = 0) ? ctrl.H : newH
                calcX := (newX = "") ? ctrl.X : (newX = 0) ? newX : newX
                calcY := (newY = "") ? ctrl.Y : (newY = 0) ? client.Bottom - calcH + (grui.MarginY*2) : newY

                maxY := client.Bottom - ctrl.H - grui.MarginY
                ;newY := client.Bottom

                Spacer := Round(client.W / Controls.Length)

                if (A_Index=1)
                    ; Set the horizontal position of the first button
                    newX := Spacer/2
                else
                    ;Calculate the horizontal position of the next button
                    newX += Spacer / 1.25 ; Spacer

                MyControl.Move(newX, calcY, calcW, calcH)

                if (Redraw)
                    WinRedraw(MyControl.Gui)

            }
        }
    }
}


; 
; #region Tests

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    __GuiLayout_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

#SingleInstance Force
#Warn Unreachable, Off
#INCLUDE <DEBUG>
#esc::ExitApp

__GuiLayout_Test() {

    ; comment to skip, comment out to run tests
    ;SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    ;Test2()
    ;Test3()

    Test1() {
        global MyGui

        TestNumber := 1

        MyGui := Gui("+Resize")
    ;MyGui.OnEvent("Size", Gui_Size)
        MyGui.OnEvent("Escape", (*) => ExitApp())
        MyGui.SetFont("s10")
        ;MyGui.Opt("-DPIScale") ; no change with or without

        MyEdit := MyGui.AddEdit("w200 r1 -VScroll vEdit", "Selected File")

        MyText := MyGui.AddText("w200 h20 BackgroundSilver vText", "Repeatedly Press ENTER...") ; Border for debug

        MyDivider := MyGui.AddText("w100 h4 0x10 Border vDivider") ; 0x10=SS_ETCHEDHORZ

        MyButtonYes := MyGui.AddButton("Default", "Yes")
        MyGui.AddButton("", "No")
        MyGui.AddButton("", "All")
        MyGui.AddButton("", "None")
        ;MyGui.AddButton("", "Oops") ; breaks Center alignment
        MyGui.AddButton("", "Cancel").OnEvent("Click", (*) => ExitApp())

        MyGui.Show("w600 h300")
        ;MyGui.Show()
        ;MyGui.Show("AutoSize Center")

        ControlFocus(MyGui["Yes"])

        MyGui["Yes"].OnEvent("Click", OnButton_Click)

        ; #region Functions
       
        OnButton_Click(*) {

            L := GuiLayout(MyGui)


        ;DEBUG FIX THIS!
        newY := L.Pos().ClientBottom - 40
            ;newY := 200

            ; Move Button row to the bottom of the client area
            Buttons     := L.GetControls(MyGui, "Button")
            ButtonRow   := L.MoveRow(Buttons, "Right", , newY, w:=65, , False)

        newY := L.Pos("Cancel").TopControlY

            ; Move Divider to the top of the Button row
            L.Move(MyGui["Divider"], , L.Pos("Cancel").TopControlY, L.Pos().ClientRight, )

        newH := L.Pos("Divider").TopControlY - L.Pos("Text").ControlY

            ; Fill Text to the top of the Divider
            L.Move(MyGui["Text"], x:="", y:="", w:=L.Pos(MyGui).ClientRight, newH)

            ; Fill  Edit to the top of the Divider
            ;newH := L.Pos("Divider").TopControlY - L.Pos("Text").ControlY
            L.Move(MyGui["Edit"], x:="", y:="", w:=L.Pos(MyGui).ClientRight,)

        nop:=true

            ; Type(MyGui)  = 'Gui'
            ; Type(MyText) = 'Gui.Text'

            ;MyString:="Test String"

            ; Gui, Gui.Text, String
            ; MsgBox Type(MyGui) ", " Type(MyText) ", " Type(MyString)

            ; ;not an object MsgBox IsObject(MyText)
            ; if SubStr(Type(MyText),1,4) = "Gui."
            ;     MsgBox "Is a Gui control"

            ; if (MyGui="")
            ;     MsgBox "Empty"
            ; else
            ;     MsgBox "Not Empty"

            ; if MyText is Object
            ;     MsgBox "yes"
                
            ; MsgBox MyText.ClassNN

            ; MyText.GetPos(&X, &Y, &Width, &Height)
            ; MsgBox "Width: " Width

            ; test := L.GetMetrics(MyText)

            ; ok test := L.Pos(MyText).ControlWidth
            ;MsgBox test

            ; YES test := L.Pos(MyGui).GuiWidth
            ; NO  test := L.Pos().GuiWidth
            ;MsgBox test

            ; ok test := MyText.Name


            ;CtrlObj := this.GuiObj[ObjectOrString]

            ; MsgBox L.clientWidth "x" L.clientHeight
            ; MsgBox L.Pos("Yes").clientWidth "x" L.Pos("Yes").clientHeight
            ; MsgBox L.Pos(MyGui["Yes"]).clientWidth
            ; dim :=L.Pos("Yes")
            ; MsgBox dim.clientWidth

            ;var1 := L.Pos().ClientRight

        }

        Gui_Size(GuiObj, MinMax, Width, Height) {

            ; LOCK the window (Stop all redrawing)
            DllCall("LockWindowUpdate", "UInt", GuiObj.Hwnd)

            try {
                ; If minimized, skip
                If (MinMax = -1)
                    return

                /*
                    GuiLayoutExample.txt
                    --------------------
                    Gui Top
                    Client Top      = Start of Client Height
                    ControlsTop 	= includes margin
                    ControlsBottom  = includes margin
                    Client Bottom   = Endof Client Height
                    Gui Bottom

                */
                ; Get the buttons to layout in a row.
                ; Optionally: Buttons := [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["None"], MyGui["Cancel"]]
            ;Buttons := GuiLayout.GetControls(GuiObj, "Button")

                ; L := GuiLayout
                ; L.GC  GetControls
                ; L.MC	MoveControl
                ; L.MR	MoveRow
                ; L.GP	GetGuiPos       "Gui Position"
                ; L.GPC	GetClientPos    "Gui Position Client"
                ; L.CP	GetControlPos   "Client Position"

                L := GuiLayout
                Buttons := L.GetControls(GuiObj, "Button")
                
                ; ?MyGuiClient.GetPos(&X, &Y, &W, &H) ; instead of Y=0
                ;MyGui.GetPos(&X, &Y, &Width, &Height)
                ;MyGui.GetClientPos(&X, &Y, &Width, &Height)
                ;clientBottom :=	OutHeight - grui.TitleBarHeight - grui.MarginY
                ;newY := Height - 32 - GuiObj.MarginY

                ; Get the Y position of the client bottom
                client := L._GetClientPos(GuiObj)
                ; client.Bottom := client.Bottom - GuiObj.MarginY
                newY := client.Bottom - GuiObj.MarginY
            
                ; Move the button row to the client bottom, and set the width of the butons
                ;TODO: fix this so the param can be empty and not change that value
                ButtonRow   := L.MoveRow(Buttons, "Center", , newY, w:=65, , False)
                ;ButtonRow.Y?

                ; Move the divider to the top of the Buttons and fill to the client width
                ;GuiObj["Yes"].GetPos(&X, &Y, &W, &H)
                ;Y := Y - GuiObj.MarginY*2

                ctrl := L._GetControlPos(GuiObj["Yes"])
                newY := ctrl.Y - GuiObj.MarginY
                newW := client.Width - GuiObj.MarginX*2
            ;GuiLayout.MoveControl(MyDivider, newX:="", newY, newW:=0, newH:="", Redraw:=False)
            ;GuiLayout.Move(MyDivider, , newY, newW, , Redraw:=False)

                ; ?MyGuiClient.GetPos(&X, &Y, &W, &H) ; instead of w:=0

                ; Fill the Text to the client with and to top of the divider
                ; GetPos(MyDivider).Y?
                ;MyDivider.GetPos(&X, &Y, &W, &H)
                ;newH := Y - GuiObj.MarginY*4

                ctrl := L._GetControlPos(GuiObj["Yes"])
                newW := client.Width - GuiObj.MarginX*2
                newH := ctrl.Y - GuiObj.MarginY*4
                ; grui.RightMargin := MyGui.MarginY * 4?
                L.MoveControl(GuiObj["Text"], , , newW, newH, Redraw:=False)

                ; Fill the edit to the client width
                L.MoveControl(GuiObj["Edit"], , , newW, , Redraw:=false)

            } finally {

                ; Unlock Window. Always call this, even if an error occurs!
                DllCall("LockWindowUpdate", "UInt", 0)
                
                ; Force a repaint (optional, but ensures the new layout is drawn immediately)
                WinRedraw(GuiObj)
            }
        }
    }
}
