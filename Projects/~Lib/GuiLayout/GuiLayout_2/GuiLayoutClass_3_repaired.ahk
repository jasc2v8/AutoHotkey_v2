;ABOUT: GuiLayout
;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921
/*
    TODO:
        AlignRight could be improved for smaller gui (400x200)
*/

#Requires AutoHotkey v2.0+

Class GuiLayout {

    RefreshOnSize := True
    BorderWidthAdjust := 8

    GuiObj:=""
    GuiCtrl:=""

    clientWidth         := 0
    clientHeight        := 0

    clientbottom :=0

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
        this.clientWidth    := dim.clientWidth
        this.clientHeight   := dim.clientHeight
        this.clientleft     := dim.clientleft
        this.clienttop      := dim.clienttop
        this.clientright    := dim.clientright
        this.clientbottom   := dim.clientbottom
        this.BorderWidth    := dim.borderWidth
        this.BorderHeight   := dim.borderHeight
        this.CaptionHeight  := dim.captionHeight

    }

    Move(MyControl, newX:="", newY:="", newW:="", newH:="", Redraw:=False ) {

        if (Type(MyControl) = "String")
            MyControl := this.GuiObj[MyControl]

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

            ;TODO: TEST ALL OF THESE
                Above   : OutY - this.BorderHeight,
                A       : OutY - this.BorderHeight,
                Below   : OutY + OutHeight + this.BorderHeight,
                B       : OutY + OutHeight + this.BorderHeight,

                Left    : OutX - this.BorderWidth*2, ; 2:=gui left border + border width
                L       : OutX - this.BorderWidth,
                Right   : OutY + OutWidth + this.BorderWidth,
                R       : OutY + OutWidth + this.BorderWidth,
                Top     : OutY,
                T       : OutY,
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

    GetControls(MyGui, ControlType:="Button", Exclude:="") {

    noop:=true

        Controls := []
        for GuiCtrlObj in MyGui {
            if (Exclude != '') AND (GuiCtrlObj.Text !="") AND (InStr(Exclude, GuiCtrlObj.Text))
                continue
            if (ControlType = '')
                Controls.Push(GuiCtrlObj)
            else if (InStr(Type(GuiCtrlObj), ControlType) != 0)
                    Controls.Push(GuiCtrlObj)
        }
        return Controls
    }

    GetGuiAndclientPos(aGui) {

        WinGetPos(,, &GuiWidth, &GuiHeight, aGui.Hwnd)

        aGui.GetclientPos(,, &clientWidth, &clientHeight)

        BorderX := (GuiWidth - clientWidth) // 2    ; 8
        BorderY := BorderX
        BorderW := BorderX
        BorderH := BorderX

        clientTop       :=0 ; always
        clientLeft      :=0 ; always
        clientBottom    := clientHeight - BorderH
        clientRight     := borderW + clientWidth
        clientRightAlt  := GuiWidth - BorderX

        clientMaxW := clientWidth - borderW - borderW
        clientMaxH := clientHeight - borderH

        nop:=true

        return { 
            GuiWidth: GuiWidth,
            GuiHeight: GuiHeight,

            clientWidth: clientWidth,
            clientHeight: clientHeight,

            clientMaxW: clientMaxW,
            clientMaxH: clientMaxH,

            clientTop: clientTop,
            clientLeft: clientLeft,
            clientBottom: clientBottom,
            clientRight: clientRight,
            clientRightAlt: clientRightAlt,



            BorderX: BorderX,
            BorderY: BorderY,
            BorderW: BorderW,
            BorderH: BorderH,
        }
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

        clientTop               := 0 + borderHeight
        clientTopNoBorder       := 0
        clientBottom            := clientH - borderY
        clientBottomNoBorder    := clientH
        clientLeft              := clientLeft + borderWidth
        clientLeftNoBorder      := 0
        clientRight             := clientW - borderWidth - borderWidth
        clientRightNoBorder     := clientW

        clientHeight            := clientH - borderHeight
        clientHeightNoBorder    := clientH
        clientWidth             := clientW - borderWidth - borderWidth
        clientWidthNoBorder     := clientW

        return {
            GuiWidth:       GuiW,
            GuiHeight:      GuiH,
            GuiLeft:        Guileft,
            GuiRight:       Guiright,
            GuiTop:         Guitop,
            GuiBottom:      Guibottom,

            BorderX:        borderX,
            BorderY:        borderY,
            BorderWidth:    borderWidth,
            BorderHeight:   borderHeight,
            BorderW:        borderWidth,
            BorderH:        borderHeight,
            CaptionHeight:  captionH,
             
            ClientWidth:    clientW,
            ClientHeight:   clientH,
            ClientW:        clientW,
            ClientH:        clientH,

            ClientBottom:   clientbottom,
            ClientLeft:     clientleft,
            ClientRight:    clientright,
            ClientTop:      clientTop,

            ClientB:        clientbottom,
            ClientL:        clientleft,
            ClientR:        clientright,
            ClientT:        clienttop,

            ClientWidthNoBorder:    clientWidthNoBorder,
            ClientHeightNoBorder:   clientHeightNoBorder,
            ClientWNoBorder:        clientWidthNoBorder,
            ClientHNoBorder:        clientHeightNoBorder,

            ClientBottomNoBorder:   clientbottomNoBorder,
            ClientLeftNoBorder:     clientleftNoBorder,
            ClientRightNoBorder:    clientrightNoBorder,
            ClientTopNoBorder:      clienttopNoBorder,

            ClientBNoBorder:        clientbottomNoBorder,
            ClientLNoBorder:        clientleftNoBorder,
            ClientTNoBorder:        clienttopNoBorder,
            ClientRNoBorder:        clientrightNoBorder,

        }

    }

    GetMetrics_NEW(GuiObj) {

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
            ClientW: clientW,
            ClientH: clientH,
            ClientLeft: clientleft,
            ClientTop: clienttop,
            ClientRight: clientright,
            ClientBottom: clientbottom,
            ClientL: clientleft,
            ClientT: clienttop,
            ClientR: clientright,
            ClientB: clientbottom,
            BorderWidth: borderWidth,
            BorderHeight: borderHeight,
            BorderW: borderWidth,
            BorderH: borderHeight,
            CaptionHeight: captionH,
            TotalNonClientHeight: GuiH - clientH
        }

    }

    GetMetrics_OLD(GuiObj) {

        ;RECT for Gui
        GuiRect := Buffer(16, 0)
        DllCall("GetWindowRect", "ptr", GuiObj.hwnd, "ptr", GuiRect.Ptr)
        Guileft   := NumGet(GuiRect, 0, "int")
        Guitop    := NumGet(GuiRect, 4, "int")
        Guiright  := NumGet(GuiRect, 8, "int")
        Guibottom := NumGet(GuiRect, 12, "int")

        GuiW := Guiright - Guileft
        GuiH := Guibottom - Guitop

        ; RECT for client area
        clientRect := Buffer(16, 0)
        DllCall("GetclientRect", "ptr", GuiObj.hwnd, "ptr", clientRect.Ptr)

        clientleft   := NumGet(clientRect, 0, "int")
        clienttop    := NumGet(clientRect, 4, "int")
        clientright  := NumGet(clientRect, 8, "int")
        clientbottom := NumGet(clientRect, 12, "int")

        clientW := clientright - clientleft
        clientH := clientbottom - clienttop

        ; Get border metrics
        borderX  := DllCall("GetSystemMetrics", "int", 32, "int") ; SM_CXFRAME
        borderY  := DllCall("GetSystemMetrics", "int", 33, "int") ; SM_CYFRAME
        captionH := DllCall("GetSystemMetrics", "int", 4, "int")  ; SM_CYCAPTION

        ; Calculate actual differences
        borderWidth := (GuiW - clientW) // 2
        borderHeight := (GuiH - clientH - captionH) // 2

        clientTop               := 0 + borderHeight
        clientTopNoBorder       := 0
        clientBottom            := clientH - borderY
        clientBottomNoBorder    := clientH
        clientLeft              := clientLeft + borderWidth
        clientLeftNoBorder      := 0
        clientRight             := clientW - borderWidth - borderWidth
        clientRightNoBorder     := clientW

        clientHeight            := clientH - borderHeight
        clientHeightNoBorder    := clientH
        clientWidth             := clientW - borderWidth - borderWidth
        clientWidthNoBorder     := clientW

        return {
            GuiWidth:       GuiW,
            GuiHeight:      GuiH,
            GuiLeft:        Guileft,
            GuiRight:       Guiright,
            GuiTop:         Guitop,
            GuiBottom:      Guibottom,

            BorderX:        borderX,
            BorderY:        borderY,
            BorderWidth:    borderWidth,
            BorderHeight:   borderHeight,
            BorderW:        borderWidth,
            BorderH:        borderHeight,
            CaptionHeight:  captionH,
             
            ClientWidth:    clientW,
            ClientHeight:   clientH,
            ClientW:        clientW,
            ClientH:        clientH,

            ClientBottom:   clientbottom,
            ClientLeft:     clientleft,
            ClientRight:    clientright,
            ClientTop:      clientTop,

            ClientB:        clientbottom,
            ClientL:        clientleft,
            ClientR:        clientright,
            ClientT:        clienttop,

            ClientWidthNoBorder:    clientWidthNoBorder,
            ClientHeightNoBorder:   clientHeightNoBorder,
            ClientWNoBorder:        clientWidthNoBorder,
            ClientHNoBorder:        clientHeightNoBorder,

            ClientBottomNoBorder:   clientbottomNoBorder,
            ClientLeftNoBorder:     clientleftNoBorder,
            ClientRightNoBorder:    clientrightNoBorder,
            ClientTopNoBorder:      clienttopNoBorder,

            ClientBNoBorder:        clientbottomNoBorder,
            ClientLNoBorder:        clientleftNoBorder,
            ClientTNoBorder:        clienttopNoBorder,
            ClientRNoBorder:        clientrightNoBorder,

        }

    }

    MoveRow(Controls, Layout, newX:="", newY:="", newW:="", newH:="", Redraw:=False) {

        grui    := 0 ; this._GetGuiPos(Controls[1].Gui)
        client  := 0 ;  this._GetclientPos(Controls[1].Gui)
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
                client  := 0 ;  this._GetclientPos(MyControl.Gui)
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
                calcW := (newW = "") ? this.Pos(MyControl).ControlW : newW
                calcH := (newH = "") ? this.Pos(MyControl).ControlH : newH

                if (A_Index=1) {
                    xSpace := calcX ; this.Pos().clientRight ; - calcW ; - this.Pos().BorderWidth
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
                client  := 0 ;  this._GetclientPos(MyControl.Gui)
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
                client  := 0 ;  this._GetclientPos(MyControl.Gui)
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

    Test2() {
        MyGui := Gui("")
        L := GuiLayout(MyGui)
        bWidth := L.Pos().BorderWidth
        bHeight := L.Pos().BorderHeight
        nop:=true
    }
    Test1() {
        global MyGui

        TestNumber := 1

        MyGui := Gui("+Resize")
        MyGui.OnEvent("Size", Gui_Size)
        MyGui.OnEvent("Escape", (*) => ExitApp())
        MyGui.SetFont("s10")
        ;MyGui.Opt("-DPIScale") ; no change with or without

        MyEdit := MyGui.AddEdit("w200 r1 -VScroll vEdit", "Selected File")
        MyGui.AddButton("", "Open")

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

            ; MyGui.GetclientPos(,, &clientWidth, &clientHeight)
            ; WinGetPos(,, &TotalWidth, &TotalHeight, MyGui.Hwnd)
            ; MsgBox  "Screen (Gui)     : " TotalWidth "x" TotalHeight "`n`n" .
            ;         "client (Controls): " clientWidth "x" clientHeight

            ; msgbox InStr(Exclude, GuiCtrlObj.Text)

        nop:=true

            ; MsgBox Type(MyGui) ", " Type(MyText) ", " Type(MyString)
                
            ; MsgBox MyText.ClassNN

            ; MyText.GetPos(&X, &Y, &Width, &Height)
            ; MsgBox "Width: " Width

        }

        Gui_Size(GuiObj, MinMax, Width, Height) {

        ;return
            ; If minimized, skip
            If (MinMax = -1)
                return

            ; LOCK the window (Stop all redrawing)
            DllCall("LockWindowUpdate", "UInt", GuiObj.Hwnd)

            try {

                ; Create an alias for brevity
                L := GuiLayout(MyGui)
            
    
                        
                ; cw:= L.Pos().clientWidth
                ; bx:= L.Pos().BorderWidth*3
                ; newW := cw - bx ; L.Pos().clientWidth - L.Pos().BorderWidth*3
                ; newW := L.Pos().clientWidth - L.Pos().BorderWidth*2 - L.Pos().BorderWidthAdjust
                ; newW := L.Pos().clientRight ; - L.Pos().BorderWidthAdjust

                ; newH := L.Pos().clientBottom - L.Pos().BorderWidth - 130 ;Adjust*4

    ;MyTestDivider := MyGui.AddText("x12 y130 w" newW " h" newH " BackgroundRed Border vTEST") ; 0x10=SS_ETCHEDHORZ

                ;MyTestDivider.GetPos(&X, &Y, &Width, &Height)

                    ;MyGui["TEST"].GetPos(&X, &Y, &Width, &Height)

               ; newH := L.Pos().clientBottom - Y ; L.Pos().BorderWidthAdjust*4


                ;
                ; First move Open, then move button row to client right, fill divider and text to client right, fill edit to left of open
                ;

                ; Get the buttons to layout in a row.
                Buttons := L.GetControls(MyGui, "Button", Exclude:="Open")

                ; Move Button row to the bottom of the client area
                ;+++++++++
                ; clientWidth and clientBottom should include the borders, still have to calc controlW and H
                ; newX := L.Pos().clientWidth  - L.Pos("Cancel").ControlW - L.Pos().BorderWidth
                ; newY := L.Pos().clientBottom - L.Pos("Cancel").ControlH
                ;+++++++++
                newX := L.Pos().clientWidth  - L.Pos().BorderWidth - L.Pos("Cancel").ControlW - L.Pos().BorderWidth
                newY := L.Pos().clientBottom - L.Pos().BorderH - L.Pos("Cancel").ControlH
                ButtonRow   := L.MoveRow(Buttons, "Right", newX , newY, w:=65, , False)

                ; Move the Open Button to the right of the client area
                L.Move("Open", L.Pos().clientWidth  - L.Pos().BorderWidth - L.Pos("Open").ControlW, L.Pos("Edit").ControlY)

                ; Move Divider to above the Button row and fill to client width
                ;L.Move("Divider", , L.Pos("Cancel").Above, L.Pos().clientRight)

                ;+++++++++
                ; clientWidth should include the borders so this calc is not necessary
                ;+++++++++

                newW:= L.Pos().clientWidth  - L.Pos().BorderWidth - 14 ; 12=RightMargin + 4 pixels
                ;newW:= 616-16-8-8-4 ; 580
                ;newX:= -12
                L.Move("Divider", , L.Pos("Cancel").Above, newW) ; 580

                ; Move Text to below the Edit, Fill X to the Divider top, and Fill Y to the left of the Open button
                newW := L.Pos().clientRight
                newH := L.Pos("Divider").Above - L.Pos("Edit").Below
                L.Move("Text",, y:=L.Pos("Edit").Below, newW, newH)

                ; Fill Edit to the left of the Open button
                newW := L.Pos("Open").Left
                L.Move("Edit", , , newW)

                cw:=L.Pos().clientWidth ; 600 ok
                cr:=L.Pos().clientRight ; 584 sb 600

                nop:=true

                ;********************Left and Right Margins ********************
                cX := L.Pos("Edit").ControlX
                gX := L.Pos().clientLeft
                LeftMargin := cX - gX       ; 12 = the default X margin when a control is added without an X parameter

                cW := L.Pos().clientWidth
                gW := L.Pos().GuiWidth
                RightMargin := gW - cW      ; 16 = the difference betweed the gui and client width

                ; ok MsgBox LeftMargin " : " RightMargin 
                ;********************Left and Right Margins ********************

                cW := 50
                cH := L.Pos().clientHeight - 8
                cX := L.Pos().clientWidth - 125
                cY := L.Pos().clientTop
                clientHeightBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundYellow Center", "#1 w" cW " h" cH)

                cX := 12 ; L.Pos().clientWidth - 125
                ;cY := L.Pos().clientTop
                ;cY:= L.Pos("Divider").Above - 8 ; 20 ;  - 8
                cY:= L.Pos("Text").ControlY + L.Pos("Text").ControlH //2
                cW := L.Pos().clientWidth - L.Pos().BorderWidth - 4 - cX
                cH := 20 ; L.Pos().clientHeight - 8
                clientWidthBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundYellow Center", "#2 w" cW " h" cH)

            } finally {

                ; Unlock Window. Always call this, even if an error occurs!
                DllCall("LockWindowUpdate", "UInt", 0)
                
                ; Force a repaint (optional, but ensures the new layout is drawn immediately)
                WinRedraw(GuiObj)
            }
        }
    }
}
