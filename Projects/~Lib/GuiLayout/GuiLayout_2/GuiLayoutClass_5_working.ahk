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

        if (ObjectOrString = "") {

            return this.GetMetrics(this.GuiObj)

        } else if (Type(ObjectOrString) = "String") {

            this.CtrlObj := this.GuiObj[ObjectOrString]

            this.CtrlObj.GetPos(&OutX, &OutY, &OutWidth, &OutHeight)

            margin := this.Pos().Margin

            return {
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

                Left    : OutX - margin,
                L       : OutX - margin,
                Right   : OutY + OutWidth + margin,
                R       : OutY + OutWidth + margin,
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

        left   := NumGet(clientRect, 0, "int")
        clienttop    := NumGet(clientRect, 4, "int")
        right  := NumGet(clientRect, 8, "int")
        bottom := NumGet(clientRect, 12, "int")

        clientW := right - left
        clientH := bottom - clienttop

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
        Left    := Left + guiBorderWidth
        Right   := clientW - windowBorderX*2

        T       := guiBorderHeight
        B       := clientH - windowBorderY*2
        L       := Left + guiBorderWidth
        R       := clientW - windowBorderX*2

        Height  := clientH - guiBorderHeight
        Width   := clientW - guiBorderWidth - guiBorderWidth
        H       := clientH - guiBorderHeight
        W       := clientW - guiBorderWidth - guiBorderWidth

        clientTop               := 0 + guiBorderHeight
        clientTopNoBorder       := 0
        Bottom            := clientH - windowBorderY*2
        BottomNoBorder    := clientH
        Left              := Left + guiBorderWidth
        LeftNoBorder      := 0
        Right             := clientW - windowBorderX*2
        RightNoBorder     := clientW

        clientHeight            := clientH - guiBorderHeight
        clientHeightNoBorder    := clientH
        clientWidth             := clientW - guiBorderWidth - guiBorderWidth
        clientWidthNoBorder     := clientW

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
            T:        clienttop,

            ClientWidthNoBorder:    clientWidthNoBorder,
            ClientHeightNoBorder:   clientHeightNoBorder,

            BottomNoBorder:   bottomNoBorder,
            LeftNoBorder:     leftNoBorder,
            RightNoBorder:    rightNoBorder,
            ClientTopNoBorder:      clienttopNoBorder,
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
        bWidth := L.Pos().guiBorderWidth
        bHeight := L.Pos().BorderHeight
        nop:=true
    }
    Test1() {
        ; Windows border default width = 4
        ; Windows Control default margin = 7

        TestNumber := 1

        MyGui := Gui("-Resize")
        ;MyGui.OnEvent("Size", Gui_Size)
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
        ;MyGui.AddButton("", "Oops") ; breaks Center alignment
        MyGui.AddButton("x+8 w50", "Cancel").OnEvent("Click", (*) => ExitApp())

        MyGui.Show("w600 h300")
        ;MyGui.Show()
        ;MyGui.Show("AutoSize Center")

        ControlFocus(MyGui["Yes"])

        ; #region Functions
       
        OnButton_Click(*) {

            L := GuiLayout(MyGui)
            ; ok := L.Pos(MyText).ControlWidth
            ; ok v := L.Pos("Text").ControlWidth
            ; ok v := L.Pos(MyGui["Text"]).ControlWidth
            ; ok v := L.ClientWidth
            ;MsgBox v

            ; 4 : 4 : 8 : 8
            ;MsgBox L.Pos().windowBorderX " : " L.Pos().windowBorderY " : " L.Pos().guiBorderWidth " : " L.Pos().BorderHeight


            /*
                Text control    : w:= L.Pos().Right - RightMargin
                Button control  : x:= L.Pos().ClientWidth - L.Pos("Yes").ControlWidth  - L.Pos().guiBorderWidth

            */

            ;MsgBox L.Pos("Text").ControlX

            ; 12 = the default X margin when a control is added without an X parameter (4 border + 8 margin)

            ; This calculates the actual left border/margin
            cX := L.Pos("Text").ControlX
            gX := L.Pos().Left
            ;LeftMargin := cX - gX       ; 4 = window border

            ; cW := L.Pos().clientWidth
            ; gW := L.Pos().guiWidth
            ; RightMargin := gW - cW   

            ; 12 = 4 + 8
            ;v1 :=LeftMargin+ L.Pos().guiBorderWidth
            ;v2 := L.Pos().windowBorderX + L.Pos().guiBorderWidth
            ;MsgBox v1 " : " v2

            ; move the buttons to the bottom of the client area
            ;x:= L.Pos().Right - L.Pos("Yes").ControlWidth
            ;x:= L.Pos().Left + L.Pos().guiBorderWidth/2 ; margin = 4?

            x:= L.Pos().Left ; + L.Pos().windowBorderX ; windowBorderX = 4
            ;x:= L.Pos().LeftNoBorder + L.Pos().windowBorderX + L.Pos().guiBorderWidth

            y:= L.Pos().Bottom - L.Pos("Yes").ControlH - L.Pos().Margin
            L.Move("Yes", x, y, ,)

            w:= L.Pos().Right - L.Pos("Text").ControlX
            L.Move("Text", , , w,)
            L.Move("Divider", , , w,)

            x:= L.Pos().Right - L.Pos("Yes").ControlWidth
            ; - RightMargin
            ;L.Move("Yes", x, , ,)

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

            ; If minimized, skip
            If (MinMax = -1)
                return

            ; LOCK the window (Stop all redrawing)
            DllCall("LockWindowUpdate", "UInt", GuiObj.Hwnd)

            try {

                ; Create an alias for brevity
                L := GuiLayout(MyGui)
            
    
                        
                ; cw:= L.Pos().clientWidth
                ; bx:= L.Pos().guiBorderWidth*3
                ; newW := cw - bx ; L.Pos().clientWidth - L.Pos().guiBorderWidth*3
                ; newW := L.Pos().clientWidth - L.Pos().guiBorderWidth*2 - L.Pos().guiBorderWidthAdjust
                ; newW := L.Pos().Right ; - L.Pos().guiBorderWidthAdjust

                ; newH := L.Pos().Bottom - L.Pos().guiBorderWidth - 130 ;Adjust*4

    ;MyTestDivider := MyGui.AddText("x12 y130 w" newW " h" newH " BackgroundRed Border vTEST") ; 0x10=SS_ETCHEDHORZ

                ;MyTestDivider.GetPos(&X, &Y, &Width, &Height)

                    ;MyGui["TEST"].GetPos(&X, &Y, &Width, &Height)

               ; newH := L.Pos().Bottom - Y ; L.Pos().guiBorderWidthAdjust*4


                ;
                ; First move Open, then move button row to client right, fill divider and text to client right, fill edit to left of open
                ;

                ; Get the buttons to layout in a row.
                Buttons := L.GetControls(MyGui, "Button", Exclude:="Open")

                ; Move Button row to the bottom of the client area
                ;+++++++++
                ; clientWidth and Bottom should include the borders, still have to calc controlW and H
                ; newX := L.Pos().clientWidth  - L.Pos("Cancel").ControlW - L.Pos().guiBorderWidth
                ; newY := L.Pos().Bottom - L.Pos("Cancel").ControlH
                ;+++++++++
                newX := L.Pos().clientWidth  - L.Pos().guiBorderWidth - L.Pos("Cancel").ControlW - L.Pos().guiBorderWidth
                newY := L.Pos().Bottom - L.Pos().BorderH - L.Pos("Cancel").ControlH
                ButtonRow   := L.MoveRow(Buttons, "Right", newX , newY, w:=65, , False)

                ; Move the Open Button to the right of the client area
                L.Move("Open", L.Pos().clientWidth  - L.Pos().guiBorderWidth - L.Pos("Open").ControlW, L.Pos("Edit").ControlY)

                ; Move Divider to above the Button row and fill to client width
                ;L.Move("Divider", , L.Pos("Cancel").Above, L.Pos().Right)

                ;+++++++++
                ; clientWidth should include the borders so this calc is not necessary
                ;+++++++++

                newW:= L.Pos().clientWidth  - L.Pos().guiBorderWidth - 14 ; 12=RightMargin + 4 pixels
                ;newW:= 616-16-8-8-4 ; 580
                ;newX:= -12
                L.Move("Divider", , L.Pos("Cancel").Above, newW) ; 580

                ; Move Text to below the Edit, Fill X to the Divider top, and Fill Y to the left of the Open button
                newW := L.Pos().Right
                newH := L.Pos("Divider").Above - L.Pos("Edit").Below
                L.Move("Text",, y:=L.Pos("Edit").Below, newW, newH)

                ; Fill Edit to the left of the Open button
                newW := L.Pos("Open").Left
                L.Move("Edit", , , newW)

                cw:=L.Pos().clientWidth ; 600 ok
                cr:=L.Pos().Right ; 584 sb 600

                nop:=true

                ;********************Left and Right Margins ********************
                cX := L.Pos("Edit").ControlX
                gX := L.Pos().Left
                LeftMargin := cX - gX       ; 12 = the default X margin when a control is added without an X parameter

                cW := L.Pos().clientWidth
                gW := L.Pos().guiWidth
                RightMargin := gW - cW      ; 16 = the difference betweed the gui and client width

                ; ok MsgBox LeftMargin " : " RightMargin 
                ;********************Left and Right Margins ********************

                cW := 50
                cH := L.Pos().clientHeight - 8
                cX := L.Pos().clientWidth - 125
                cY := L.Pos().clientTop
                ;clientHeightBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundYellow Center", "#1 w" cW " h" cH)

                cX := 12 ; L.Pos().clientWidth - 125
                ;cY := L.Pos().clientTop
                ;cY:= L.Pos("Divider").Above - 8 ; 20 ;  - 8
                cY:= L.Pos("Text").ControlY + L.Pos("Text").ControlH //2
                cW := L.Pos().clientWidth - L.Pos().guiBorderWidth - 4 - cX
                cH := 20 ; L.Pos().clientHeight - 8
                ;clientWidthBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundYellow Center", "#2 w" cW " h" cH)

            } finally {

                ; Unlock Window. Always call this, even if an error occurs!
                DllCall("LockWindowUpdate", "UInt", 0)
                
                ; Force a repaint (optional, but ensures the new layout is drawn immediately)
                WinRedraw(GuiObj)
            }
        }
    }
}
