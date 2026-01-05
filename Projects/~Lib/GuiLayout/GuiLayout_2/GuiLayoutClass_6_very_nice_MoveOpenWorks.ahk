;ABOUT: GuiLayout
;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921
/*
    TODO:
        AlignRight could be improved for smaller gui (400x200)
*/

#Requires AutoHotkey v2.0+

Class GuiLayout {

    RefreshOnSize := True
    guiBorderWidthAdjust := 8

    GuiObj:=""
    GuiCtrl:=""

    clientWidth         := 0
    clientHeight        := 0

    bottom :=0

    __New(GuiObj) {

        if Type(GuiObj) != "Gui"
            return

        this.GuiObj := GuiObj

        this.Refresh()
    }

    Refresh() {
        ; get all dims

        ; save
        ;this.Bottom := 0
        dim := this.GetMetrics(this.GuiObj)
        
        ; this.guiWidth       := dim.guiWidth
        ; this.guiHeight      := dim.guiHeight
        ; this.clientWidth    := dim.clientWidth
        ; this.clientHeight   := dim.clientHeight
        ; this.left     := dim.left
        ; this.clienttop      := dim.clienttop
        ; this.right    := dim.right
        ; this.bottom   := dim.bottom
        ; this.guiBorderWidth    := dim.guiBorderWidth
        ; this.BorderHeight   := dim.guiBorderHeight
        ; this.windowCaptionHeight  := dim.windowCaptionHeight

    }

    Move(MyControl, newX:="", newY:="", newW:="", newH:="", Redraw:=False ) {

        if (Type(MyControl) = "String")
            MyControl := this.GuiObj[MyControl]

    nop1 :=Type(MyControl)

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

    nop2 :=Type(ObjectOrString)

        if (ObjectOrString = "") {

            return this.GetMetrics(this.GuiObj)

        } else if (SubStr(Type(ObjectOrString),1,4) = "Gui.") {

            ctrlObj := ObjectOrString

        } else if (SubStr(Type(ObjectOrString),1,3) = "Gui") {

            this.GuiObj:= ObjectOrString

            return this.GetMetrics(this.GuiObj)

        } else if (Type(ObjectOrString) = "String") {
            
            ctrlObj := this.GuiObj[ObjectOrString]

        } else {
            Throw "Error unknown Parameter for ObjectOrString"
        }

        ctrlObj.GetPos(&OutX, &OutY, &OutWidth, &OutHeight)

        margin := this.Pos().Margin

        return {
            X:              OutX,
            Y:              OutY,
            W:              OutWidth,
            H:              OutHeight,

            ControlX:       OutX,
            ControlY:       OutY,
            ControlW:       OutWidth,
            ControlH:       OutHeight,
            ControlWidth:   OutWidth,
            ControlHeight:  OutHeight,

        ;TODO: TEST ALL OF THESE
            Above   : OutY - margin,
            A       : OutY - margin,
            Below   : OutY + OutHeight + margin,
            B       : OutY + OutHeight + margin,

            Left    : OutX - margin + 0,
            L       : OutX - margin,
            Right   : OutY + OutWidth + margin,
            R       : OutY + OutWidth + margin,
            Top     : OutY,
            T       : OutY,
        }
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

        WinGetPos(,, &guiWidth, &guiHeight, aGui.Hwnd)

        aGui.GetclientPos(,, &clientWidth, &clientHeight)

        windowBorderX := (guiWidth - clientWidth) // 2    ; 8
        windowBorderY := windowBorderX
        BorderW := windowBorderX
        BorderH := windowBorderX

        clientTop       :=0 ; always
        Left      :=0 ; always
        Bottom    := clientHeight - BorderH
        Right     := borderW + clientWidth
        RightAlt  := guiWidth - windowBorderX

        clientMaxW := clientWidth - borderW - borderW
        clientMaxH := clientHeight - borderH

        nop:=true

        return { 
            guiWidth: guiWidth,
            guiHeight: guiHeight,

            clientWidth: clientWidth,
            clientHeight: clientHeight,

            clientMaxW: clientMaxW,
            clientMaxH: clientMaxH,

            clientTop: clientTop,
            Left: Left,
            Bottom: Bottom,
            Right: Right,
            RightAlt: RightAlt,

            windowBorderX: windowBorderX,
            windowBorderY: windowBorderY,
            BorderW: BorderW,
            BorderH: BorderH,
        }
    }

    GetMetrics(GuiObj) {

        ;RECT for Gui
        guiRect := Buffer(16, 0)
        DllCall("GetWindowRect", "ptr", GuiObj.hwnd, "ptr", guiRect.Ptr)
        guiLeft   := NumGet(guiRect, 0, "int")
        guiTop    := NumGet(guiRect, 4, "int")
        guiRight  := NumGet(guiRect, 8, "int")
        guiBottom := NumGet(guiRect, 12, "int")

        guiW := guiRight - guiLeft
        guiH := guiBottom - guiTop

        ; RECT for Client area
        clientRect := Buffer(16, 0)
        DllCall("GetClientRect", "ptr", GuiObj.hwnd, "ptr", clientRect.Ptr)

        clientLeft   := NumGet(clientRect, 0, "int")
        clientTop    := NumGet(clientRect, 4, "int")
        clientRight  := NumGet(clientRect, 8, "int")
        clientBottom := NumGet(clientRect, 12, "int")

        clientW := clientRight - clientLeft
        clientH := clientBottom - clientTop

        ; Get border metrics
        windowBorderX := DllCall("GetSystemMetrics", "int", 32, "int") ; SM_CXFRAME       ; 4
        windowBorderY := DllCall("GetSystemMetrics", "int", 33, "int") ; SM_CYFRAME       ; 4
        windowCaptionH := DllCall("GetSystemMetrics", "int", 4, "int")  ; SM_CYCAPTION    ; 23

        ; Calculate actual differences
        guiBorderWidth := (guiW - clientW) // 2                    ; 8 
        guiBorderHeight := (guiH - clientH - windowCaptionH) // 2  ; 8

        ; Client dimensions
        margin  := 8 ; margin between controls (would have to show/hide gui, measure, then show again. Maybe future.)

        Top     := guiBorderHeight
        Bottom  := clientH - windowBorderY*2
        Left    := clientLeft + guiBorderWidth + windowBorderX
        Right   := clientW - windowBorderX*2

        T       := guiBorderHeight
        B       := clientH - windowBorderY*2
        L       := clientLeft + guiBorderWidth
        R       := clientW - windowBorderX*2

        Height  := clientH - guiBorderHeight
        Width   := clientW - guiBorderWidth - guiBorderWidth
        H       := clientH - guiBorderHeight
        W       := clientW - guiBorderWidth - guiBorderWidth

        ClientTop               := guiBorderHeight
        ClientTopNoBorder       := 0
        ClientBottom            := clientH - windowBorderY*2
        ClientBottomNoBorder    := clientH
        ClientLeft              := clientLeft + guiBorderWidth + windowBorderX
        CientLeftNoBorder       := clientLeft
        ClientRight             := clientW - windowBorderX*2
        ClientRightNoBorder     := clientW

        ClientHeight            := clientH - guiBorderHeight
        ClientHeightNoBorder    := clientH
        ClientWidth             := clientW - guiBorderWidth - guiBorderWidth
        ClientWidthNoBorder     := clientW

        return {
            guiWidth:       guiW,
            guiHeight:      guiH,
            guiLeft:        guiLeft,
            guiRight:       guiRight,
            guiTop:         guiTop,
            guiBottom:      guiBottom,
            
            Margin:         margin,

            Width:      clientW,
            Height:     clientH,
            W:          clientW,
            H:            clientH,

            Bottom:   bottom,
            Left:     left,
            Right:    right,
            Top:      clientTop,

            B:        bottom,
            L:        left,
            R:        right,
            T:        clientTop,

            ClientWidthNoBorder:    clientWidthNoBorder,
            ClientHeightNoBorder:   clientHeightNoBorder,
            ClientBottomNoBorder:   ClientBottomNoBorder,
            ClientLeftNoBorder:     CientLeftNoBorder,
            ClientRightNoBorder:    ClientRightNoBorder,
            ClientTopNoBorder:      ClientTopNoBorder,
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
                    xSpace := calcX ; this.Pos().Right ; - calcW ; - this.Pos().guiBorderWidth
                    xPos := xSpace ; Round(xSpace)
                } else
                    xPos -= calcW + this.Pos().guiBorderWidth

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
                ;TODO FIX
                leftSide :=  0 ;grui.W / 2 - (calcW * Controls.Length - calcW/2) + ((grui.MX + calcW) * A_Index-1)

                if (A_Index=1) {
                    xSpace := calcW  + 0 ; grui.MarginX
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
        bWidth := L.Pos().guiBorderWidth
        bHeight := L.Pos().BorderHeight
        nop:=true
    }
    Test1() {
        ; Windows border default width = 4
        ; Windows Control default margin = 7

        TestNumber := 1

        MyGui := Gui("+Resize")
        MyGui.OnEvent("Size", Gui_Size)
        MyGui.OnEvent("Escape", (*) => ExitApp())
        MyGui.SetFont("s10")
        ;MyGui.Opt("-DPIScale") ; no change with or without

        ;MyEdit := MyGui.AddEdit("w200 r1 -VScroll vEdit", "Selected File")
        ;MyGui.AddButton("", "Open")

        MyText := MyGui.AddText("w200 h20 BackgroundSilver vText", "Repeatedly Press ENTER...") ; Border for debug

        MyDivider := MyGui.AddText("w100 h4 0x10 Border vDivider") ; 0x10=SS_ETCHEDHORZ

        MyButtonYes := MyGui.AddButton("w50 Default", "Yes").OnEvent("Click", OnButton_Click)
        ;MyGui.AddButton("", "No")
        ;MyGui.AddButton("", "All")
        ;MyGui.AddButton("", "None")
        MyGui.AddButton("", "Open")
        MyGui.AddButton("x+8 w50", "Cancel").OnEvent("Click", (*) => ExitApp())

        MyGui.Show("w600 h300")
        ;MyGui.Show()
        ;MyGui.Show("AutoSize Center")

        ControlFocus(MyGui["Yes"])

        ; #region Functions
       
        OnButton_Click(*) {

            ; L := GuiLayout(MyGui)

            ; ; move the buttons to the bottom of the client area: Yes, then Cancel to the right
            ; ;   L.Pos() = Gui
            ; x:= L.Pos().Left
            ; y:= L.Pos().Bottom - L.Pos("Yes").H - L.Pos().Margin
            ; L.Move("Yes", x, y, ,)

            ; x+= L.Pos("Yes").W + L.Pos().Margin
            ; ;y:= same
            ; L.Move("Cancel", x, y, ,)

            ; ; Move the divider to above the buttons and extend to the client right
            ; y:= L.Pos("Yes").Above - L.Pos("Divider").H
            ; w:= L.Pos().Right - L.Pos("Text").X
            ; L.Move("Divider", , y, w,)

            ; ; Extend Text to the client right, and to above the divider
            ; h:= L.Pos("Divider").Above - L.Pos().Margin ; L.Pos("Divider").H
            ; L.Move("Text", , , w, h)

        }

        Gui_Size(GuiObj, MinMax, Width, Height) {

            ; If minimized, skip
            If (MinMax = -1)
                return

            ; LOCK the window (Stop all redrawing)
            DllCall("LockWindowUpdate", "UInt", GuiObj.Hwnd)

            try {

                ; Create an alias for brevity
                L := GuiLayout(MyGui)
            
                ; move the buttons to the bottom of the client area: Yes, then Cancel to the right
                ;   L.Pos() = Gui
                ;x:= L.Pos().Left
                ;y:= L.Pos().Bottom - L.Pos("Yes").H - L.Pos().Margin
                ;L.Move("Yes", x, y, ,)

                x:=0
                w:= 100 ; L.Pos("Yes").W
                h:= L.Pos("Open").H ; 50
                ;y:= L.Pos().Bottom - L.Pos("Yes").H - L.Pos().Margin
                y:= L.Pos().Bottom - h - L.Pos().Margin

                ; Move a row of buttons to the client bottom, exclude 'Open' for now.
                Buttons := L.GetControls(MyGui, "Button", Exclude:="Open")
                L.MoveRow(Buttons, "CENTER", x, y, w, h, False)

                ; x+= L.Pos("Yes").W + L.Pos().Margin
                ; ;y:= same
                ; L.Move("Cancel", x, y, ,)

                ; Move the open button to the top right
                x:= L.Pos().Right - L.Pos("Open").W ; - L.Pos().Margin
                y:= L.Pos().Top
                L.Move("Open", x, y,)

                ; Move the divider to above the buttons and extend to the client right
                y:= L.Pos("Yes").Above - L.Pos("Divider").H
                w:= L.Pos("Text").Right - L.Pos("Text").Left    ;  - L.Pos().Left
                w:= L.Pos("Open").Left - L.Pos().Left    ;  - L.Pos().Left
                L.Move("Divider", , y, w,)

                ; Extend Text to the client right, and to above the divider
                h:= L.Pos("Divider").Above - L.Pos().Margin ; L.Pos("Divider").H
                w:= L.Pos("Open").Left - L.Pos().Left
                L.Move("Text", , , w, h)

            } finally {

                    ; Unlock Window. Always call this, even if an error occurs!
                    DllCall("LockWindowUpdate", "UInt", 0)
                    
                    ; Force a repaint (optional, but ensures the new layout is drawn immediately)
                    WinRedraw(GuiObj)
            }
        }
    }
}
