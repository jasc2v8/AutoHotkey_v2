;ABOUT: GuiLayout
;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921

/*
    TODO:
        Minimum Gui Width = btnWidth + Margin * Buttons.Count
        
        Finish AlignLeft, Right, Center, Fill
        Test all GetMetrics return{values}

        D:\Software\DEV\Work\AHK2\Examples\Gui\Links\
        Resize a GUI when text changes - AutoHotkey Community
        https://www.autohotkey.com/boards/viewtopic.php?t=115745
*/

#Requires AutoHotkey v2.0+

Class GuiLayout {

    __New(GuiObj) {

        if Type(GuiObj) != "Gui"
            return

        this.GuiObj := GuiObj
    }

    Move(MyControl, newX:="", newY:="", newW:="", newH:="", Redraw:=False ) {

        if (Type(MyControl) = "String")
            MyControl := this.GuiObj[MyControl]

        ctrlX := (newX = "") ? this.Pos(MyControl).ControlX : newX
        ctrlY := (newY = "") ? this.Pos(MyControl).ControlY : newY
        ctrlW := (newW = "") ? this.Pos(MyControl).ControlW : newW
        ctrlH := (newH = "") ? this.Pos(MyControl).ControlH : newH

        MyControl.Move(ctrlX, ctrlY, ctrlW, ctrlH)

        if (Redraw)
            WinRedraw(MyControl.Gui)
    }

    Pos(GuiOrControl:="") {

        if (GuiOrControl = "") {

            return this.GetMetrics(this.GuiObj)

        } else if (SubStr(Type(GuiOrControl),1,4) = "Gui.") {

            ctrlObj := GuiOrControl

        } else if (SubStr(Type(GuiOrControl),1,3) = "Gui") {

            this.GuiObj:= GuiOrControl

            return this.GetMetrics(this.GuiObj)

        } else if (Type(GuiOrControl) = "String") {
            
            ctrlObj := this.GuiObj[GuiOrControl]

        } else {
            Throw "Error unknown Parameter for GuiOrControl"
        }

        ctrlObj.GetPos(&OutX, &OutY, &OutWidth, &OutHeight)

        margin := this.Pos().Margin

 ;MsgBox "Pos" " : " ctrlObj.Text

 clientRight := this.Pos(this.GuiObj).Right

        return {
            Margin:         margin,

            X:              OutX,
            Y:              OutY,
            Width:          OutWidth,
            Height:         OutHeight,
            W:              OutWidth,
            H:              OutHeight,

            ControlX:       OutX,
            ControlY:       OutY,
            ControlW:       OutWidth,
            ControlH:       OutHeight,
            ControlWidth:   OutWidth,
            ControlHeight:  OutHeight,

        ;TODO: TEST ALL OF THESE
            Above   : OutY - margin,    ; OK
            A       : OutY - margin,    ; OK
            Below   : OutY + OutHeight + margin,
            B       : OutY + OutHeight + margin,

            Left    : OutX - margin*2,  ; OK
            L       : OutX - margin*2,  ; OK
            Right   : clientRight, ; OutY - OutWidth + margin,
            R       : OutY - OutWidth + margin,
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

        clientRectLeft   := NumGet(clientRect, 0, "int")
        clientRectTop    := NumGet(clientRect, 4, "int")
        clientRectRight  := NumGet(clientRect, 8, "int")
        clientRectBottom := NumGet(clientRect, 12, "int")

        clientRectW := clientRectRight - clientRectLeft
        clientRectH := clientRectBottom - clientRectTop

        ; Get border metrics
        windowBorderX := DllCall("GetSystemMetrics", "int", 32, "int") ; SM_CXFRAME       ; 4
        windowBorderY := DllCall("GetSystemMetrics", "int", 33, "int") ; SM_CYFRAME       ; 4
        windowCaptionH := DllCall("GetSystemMetrics", "int", 4, "int")  ; SM_CYCAPTION    ; 23

        ; ctrlulate actual differences
        guiBorderWidth  := (guiW - clientRectW) // 2                    ; 8 
        guiBorderHeight := (guiH - clientRectH - windowCaptionH) // 2  ; 8

        ; Client dimensions
        margin  := 8 ; margin between controls (would have to show/hide gui, measure, then show again. Maybe future.)

        Top     := guiBorderHeight
        Bottom  := clientRectH - windowBorderY*2
        Left    := clientRectLeft + guiBorderWidth + windowBorderX
        Right   := clientRectRight - windowBorderY - guiBorderWidth*2

        T       := guiBorderHeight
        B       := clientRectH - windowBorderY*2
        L       := clientRectLeft + guiBorderWidth
        R       := clientRectW - windowBorderX*2

        Height  := clientRectH - guiBorderHeight
        Width   := clientRectW - guiBorderWidth - guiBorderWidth
        H       := clientRectH - guiBorderHeight
        W       := clientRectW - guiBorderWidth - guiBorderWidth

        ClientTop               := guiBorderHeight
        ClientTopNoBorder       := 0
        ClientBottom            := clientRectH - windowBorderY*2
        ClientBottomNoBorder    := clientRectH
        ClientLeft              := clientRectLeft + guiBorderWidth + windowBorderX
        CientLeftNoBorder       := clientRectLeft
        ClientRight             := clientRectW - windowBorderY - guiBorderWidth*2
        ClientRightNoBorder     := clientRectW

        ClientHeight            := clientRectH - guiBorderHeight
        ClientHeightNoBorder    := clientRectH
        ClientWidth             := clientRectW - guiBorderWidth - guiBorderWidth - windowBorderY
        ClientWidthNoBorder     := clientRectW

        return {

            Margin:         margin,
            guiWidth:       guiW,
            guiHeight:      guiH,
            guiLeft:        guiLeft,
            guiRight:       guiRight,
            guiTop:         guiTop,
            guiBottom:      guiBottom,
            
            Margin:         margin,

            Width:          ClientWidth,
            Height:         ClientHeight,
            W:              ClientWidth,
            H:              ClientHeight,

            Bottom:         ClientBottom,
            Left:           ClientLeft,
            Right:          ClientRight,
            Top:            ClientTop,

            B:        ClientBottom,
            L:        ClientLeft,
            R:        ClientRight,
            T:        ClientTop,

            ClientWidth:    clientRectW,
            
            ClientWidthNoBorder:    clientWidthNoBorder,
            ClientHeightNoBorder:   clientHeightNoBorder,
            ClientBottomNoBorder:   ClientBottomNoBorder,
            ClientLeftNoBorder:     CientLeftNoBorder,
            ClientRightNoBorder:    ClientRightNoBorder,
            ClientTopNoBorder:      ClientTopNoBorder,
        }

    }

    MoveRow(Controls, Layout, newX:="", newY:="", newW:="", newH:="", Redraw:=False) {

        ; 1. Move all controls to the same width.

        _W(Controls,newW)

        _XY(Controls,Layout, newX, newY)

        _H(Controls,newH)

        if (Redraw)
            WinRedraw(this.GuiObj)

        return

        _W(Controls,newW) {

            for MyControl in Controls
            {
                ;ctrlX := (newX = "") ? this.Pos(MyControl).X : newX
                ;ctrlY := (newY = "") ? this.Pos(MyControl).Y : newY
                ctrlW := (newW = "") ? this.Pos(MyControl).W : newW
                ;ctrlH := (newH = "") ? this.Pos(MyControl).H : newH

                MyControl.Move(, , ctrlW, ,)
            }

        }

        ; 2. Move x,y   Move the controls to the x,y position, the apply the Layout (L/R/C/F).

        _XY(Controls,Layout, newX, newY) {

            ; Just check the first letter: Left, Center, Right, Fill
            switch StrUpper(SubStr(Layout,1,1)) {
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
                    ctrlX := newX
                    ctrlY := newY
                    ctrlW := this.Pos(MyControl).W
                    ctrlH := this.Pos(MyControl).H

                    if (A_Index=1) {
                        xPos := this.Pos().Left
                    } else
                        xPos += ctrlW + this.Pos().Margin

                    MyControl.Move(xPos, ctrlY, , )
                }
            
            }

            if (Layout = "AlignRight") {

                startCount := Controls.Length + 1

                Loop Controls.Length
                {
                    index := startCount - A_Index

                    MyControl := Controls[index]
                    
                    ctrlX := newX
                    ctrlY := newY
                    ctrlW := this.Pos(MyControl).W
                    ctrlH := this.Pos(MyControl).H

                    if (A_Index=1) {
                        xPos := this.Pos().Right - ctrlW
                    } else
                        xPos -= ctrlW + this.Pos().Margin

                    MyControl.Move(xPos, ctrlY, , )
                }
            }

            if (Layout = "AlignCenter") {

                for MyControl in Controls
                {

                    ctrlX := newX
                    ctrlY := newY
                    ctrlW := this.Pos(MyControl).W
                    ctrlH := this.Pos(MyControl).H

                    RowWidth  := this.Pos().Width
                    BtnWidth  := newW
                    NumBtns   := Controls.Length
                    Gap       := this.Pos().Margin

                    TotalBtnW := NumBtns * BtnWidth
                    TotalGapW := (NumBtns - 1) * Gap
                    BlockWidth := TotalBtnW + TotalGapW
                    SideMargin := (RowWidth - BlockWidth) / 2
                    Step := BtnWidth + Gap

                    if (A_Index=1) {
                        xPos := SideMargin 
                    } else
                        xPos += Step
    
                    MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)
                }
            }

            if (Layout = "AlignFill") {

                ; --- Constants ---
                BtnWidth := newW ; this.Pos(Controls[1]).W
                RowWidth := this.Pos().Width - BtnWidth
                NumBtns := Controls.Length

                ; --- Calculations (The Formulas) ---
                TotalBtnW := NumBtns * BtnWidth
                TotalSpace := RowWidth - TotalBtnW
                ; Doesn't work for only one button, but not going to fix that.
                Gap := (NumBtns = 1) ? TotalSpace : TotalSpace / (NumBtns - 1)

                ; Offset from the client left edge
                SideMargin := this.Pos().Left + this.Pos().Margin + (4 * Controls.Length-1)

                ; The width of a button plus one gap
                Step := BtnWidth + Gap 

                ; Loop to create and position the N buttons
                Loop NumBtns
                {
                    i := A_Index

                    XPos := SideMargin + (i - 1) * Step 

                    MyControl := Controls[A_Index]

                    ctrlX := newX
                    ctrlY := newY
                    ctrlW := this.Pos(MyControl).W
                    ctrlH := this.Pos(MyControl).H

                    MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)
                }
            }

        }
        ; 3. Move H     Move all controls to the same height.

        _H(Controls,newH) {

            for MyControl in Controls
            {
                ctrlX := this.Pos(MyControl).X
                ctrlY := this.Pos(MyControl).Y
                ctrlW := this.Pos(MyControl).W
                ctrlH := (newH = "") ? this.Pos(MyControl).H : newH

                MyControl.Move(, , , ctrlH)
            }

        }

        ; Just check the first letter: Left, Center, Right, Fill
        switch StrUpper(SubStr(Layout,1,1)) {
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
                ctrlX := (newX = "") ? this.Pos(MyControl).X : newX
                ctrlY := (newY = "") ? this.Pos(MyControl).Y : newY
                ctrlW := (newW = "") ? this.Pos(MyControl).W : newW
                ctrlH := (newH = "") ? this.Pos(MyControl).H : newH

                if (A_Index=1) {
                    xPos := this.Pos().Left
                } else
                    xPos += ctrlW + this.Pos().Margin

                MyControl.Move(xPos, ctrlY, , )
            }
        
        }

        if (Layout = "AlignRight") {

            startCount := Controls.Length + 1

            Loop Controls.Length
            {
                index := startCount - A_Index

                MyControl := Controls[index]
                
                ctrlX := (newX = "") ? this.Pos(MyControl).X : newX
                ctrlY := (newY = "") ? this.Pos(MyControl).Y : newY
                ctrlW := (newW = "") ? this.Pos(MyControl).W : newW
                ctrlH := (newH = "") ? this.Pos(MyControl).H : newH

                if (A_Index=1) {
                    xPos := this.Pos().Right - ctrlW
                } else
                    xPos -= ctrlW + this.Pos().Margin

                MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)
            }
        }

        if (Layout = "AlignCenter") {

            for MyControl in Controls
            {

                ctrlX := (newX = "") ? this.Pos(MyControl).X : newX
                ctrlY := (newY = "") ? this.Pos(MyControl).Y : newY
                ctrlW := (newW = "") ? this.Pos(MyControl).W : newW
                ctrlH := (newH = "") ? this.Pos(MyControl).H : newH

                RowWidth  := this.Pos().Width
                BtnWidth  := newW
                NumBtns   := Controls.Length
                Gap       := this.Pos().Margin

                TotalBtnW := NumBtns * BtnWidth
                TotalGapW := (NumBtns - 1) * Gap
                BlockWidth := TotalBtnW + TotalGapW
                SideMargin := (RowWidth - BlockWidth) / 2
                Step := BtnWidth + Gap

                if (A_Index=1) {
                    xPos := SideMargin 
                } else
                    xPos += Step
 
                MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)
            }
        }

        if (Layout = "AlignFill") {

            ; --- Constants ---
            BtnWidth := newW ; this.Pos(Controls[1]).W
            RowWidth := this.Pos().Width - BtnWidth
            NumBtns := Controls.Length

            ; --- Calculations (The Formulas) ---
            TotalBtnW := NumBtns * BtnWidth
            TotalSpace := RowWidth - TotalBtnW
            ; Doesn't work for only one button, but not going to fix that.
            Gap := (NumBtns = 1) ? TotalSpace : TotalSpace / (NumBtns - 1)

            ; Offset from the client left edge
            SideMargin := this.Pos().Left + this.Pos().Margin + (4 * Controls.Length-1)

            ; The width of a button plus one gap
            Step := BtnWidth + Gap 

            ; Loop to create and position the N buttons
            Loop NumBtns
            {
                i := A_Index

                XPos := SideMargin + (i - 1) * Step 

                MyControl := Controls[A_Index]

                ctrlX := (newX = "") ? this.Pos(MyControl).X : newX
                ctrlY := (newY = "") ? this.Pos(MyControl).Y : newY
                ctrlW := (newW = "") ? this.Pos(MyControl).W : newW
                ctrlH := (newH = "") ? this.Pos(MyControl).H : newH

                MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)
            }
        }

        if (Redraw)
            WinRedraw(this.GuiObj)
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

        MyGui := Gui("+Resize")
        MyGui.OnEvent("Size", Gui_Size)
        MyGui.OnEvent("Escape", (*) => ExitApp())
        MyGui.SetFont("s10")
        ;MyGui.Opt("-DPIScale") ; no change with or without

        MyEdit := MyGui.AddEdit("w200 r1 -VScroll vEdit", "Selected File")
        MyGui.AddButton("", "Open")

        MyText := MyGui.AddText("w200 h20 BackgroundSilver vText", "Drag the corners to resize the window.") ; Border for debug

        MyDivider := MyGui.AddText("w100 h4 0x10 Border vDivider") ; 0x10=SS_ETCHEDHORZ

        MyButtonYes := MyGui.AddButton("w50 Default", "Yes").OnEvent("Click", OnButton_Click)
        MyGui.AddButton("", "No")
        MyGui.AddButton("", "All")
        MyGui.AddButton("", "None")
        MyGui.AddButton("w50", "Cancel").OnEvent("Click", (*) => ExitApp())

        MyGui.Show("w600 h300")
        ;MyGui.Show()
        ;MyGui.Show("AutoSize Center")

        ControlFocus(MyGui["Yes"])

        global TestNumber := 1

        MyText.Text := "Test Number (LEFT, CENTER, RIGHT, FILL): " TestNumber

        ; #region Functions
       
        OnButton_Click(*) {

            TestNumber := (TestNumber = 4) ? 1 : TestNumber+1

            MyText.Text := "Test Number (LEFT, CENTER, RIGHT, FILL): " TestNumber

            ; TEST ROW ALIGNMENT AND METRICS RETUR {VALUES}

            ; L := GuiLayout(MyGui)

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
            
                ; Move a row of buttons to the client bottom, exclude 'Open' for now.
                Buttons := L.GetControls(MyGui, "Button", Exclude:="Open")
                ;Buttons := L.GetControls(MyGui, "Button")

                x:=0
                y:= L.Pos().Bottom - L.Pos("Yes").H - L.Pos().Margin
                w:= 100 ; L.Pos("Yes").W
                h:= 75 ; L.Pos("Yes").H

        ;TestNumber := 1

                switch TestNumber {
                    case 1:
                        L.MoveRow(Buttons, "LEFT", x, y, w, h, False)
                    case 2:
                        L.MoveRow(Buttons, "CENTER", x, y, w, h, False)
                    case 3:
                        L.MoveRow(Buttons, "RIGHT", x, y, w, h, False)
                    case 4:
                        L.MoveRow(Buttons, "FILL", x, y, w, h, False)
                }

        ;return

                ; Move the 'Open' button to the client top right
                x:= L.Pos().Right - L.Pos("Open").W - L.Pos().Margin
                y:= L.Pos().Top
                L.Move("Open", x, y, w, h)

                ; Extend the Edit to the left of the 'Open' and position to match the size of the 'Open' button
                ;x:= no change
                y:= L.Pos().Top + 2
                w:= L.Pos("Open").Left
                ;h:= no change
                L.Move("Edit", , y, w, )

                ; Move the divider to above the buttons and extend to the client right
                y:= L.Pos("Yes").Above - L.Pos("Divider").H
                w:= L.Pos().Right - L.Pos("Text").X
                L.Move("Divider", , y, w,)

                ; Move the Text to below the Edit
                ; Need to move this to get the new Y position
                y:= L.Pos("Edit").Below ; - L.Pos("Text").H
                ;w:= L.Pos("Open").Left ; - L.Pos("Text").X
                w:= L.Pos().Right ; - L.Pos("Text").X
                L.Move("Text", , y, w, ) ; h=196

                ; Extend Text to the client right, and to above the divider
                ;y:= L.Pos("Edit").Below ; - L.Pos("Text").H
                ;w:= L.Pos("Open").Left ; - L.Pos("Text").X
                ;w:= L.Pos().Right ; - L.Pos("Text").X

                d1:= L.Pos("Text").Y
                d2:= L.Pos("Divider").Above
                d3:= L.Pos("Divider").Y
                d4:= L.Pos("Divider").Below

                h:= L.Pos("Divider").Above - L.Pos("Text").Y
                L.Move("Text", , , , h) ; h=196

           } finally {

                    ; Unlock Window. Always call this, even if an error occurs!
                    DllCall("LockWindowUpdate", "UInt", 0)
                    
                    ; Force a repaint (optional, but ensures the new layout is drawn immediately)
                    WinRedraw(GuiObj)
            }
        }
    }
}
