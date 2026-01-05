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
            Above   : OutY - margin,
            A       : OutY - margin,
            Below   : OutY + OutHeight + margin,
            B       : OutY + OutHeight + margin,

            Left    : OutX + margin + 0,
            L       : OutX + margin,
            Right_DEBUG   : clientRight, ; OutY - OutWidth + margin,
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

        if (Layout = "AlignLeft_gemini_works") {

            btnWidth := newW

            SideMargin := this.Pos().Left

            Step := BtnWidth + this.Pos().Margin

            Loop Controls.Length  {

                i := A_Index

                MyControl := Controls[A_Index]
                
                ctrlX := (newX = "") ? this.Pos(MyControl).X : newX
                ctrlY := (newY = "") ? this.Pos(MyControl).Y : newY
                ctrlW := (newW = "") ? this.Pos(MyControl).W : newW
                ctrlH := (newH = "") ? this.Pos(MyControl).H : newH

                XPos := SideMargin + ((i - 1) * Step)                

                MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)

            }
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
    
                xPos := Round(xPos)

                MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)
            }
        
        }

        if (Layout = "AlignRight_Gemini") {

                ; --- Constants ---
                RowWidth := this.Pos().Width
                BtnWidth := 50
                NumBtns := Controls.Length
                Gap := this.Pos().Margin*2

                ; --- Calculations  ---
                Step := BtnWidth + Gap + this.Pos().Margin
                X_N  := RowWidth - BtnWidth - this.Pos().Margin -6

                ; Loop to position the buttons
                Loop NumBtns
                {
                    i := A_Index

                    ; XPos is calculated backwards from the last button (X_N)
                    XPos := X_N - ((NumBtns - i) * Step)

                    MyControl := Controls[i]
                    
                    ctrlX := (newX = "") ? this.Pos(MyControl).X : newX
                    ctrlY := (newY = "") ? this.Pos(MyControl).Y : newY
                    ctrlW := (newW = "") ? this.Pos(MyControl).W : newW
                    ctrlH := (newH = "") ? this.Pos(MyControl).H : newH

                    ; Move the button using the calculated XPos and fixed width
                    MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)
                }
        }

        if (Layout = "AlignRight_OLD_WORKS") {

            index := Controls.Length

            While (index > 0)
            {
                MyControl := Controls[index]
                
                ctrlX := (newX = "") ? this.Pos(MyControl).X : newX
                ctrlY := (newY = "") ? this.Pos(MyControl).Y : newY
                ctrlW := (newW = "") ? this.Pos(MyControl).W : newW
                ctrlH := (newH = "") ? this.Pos(MyControl).H : newH

                if (A_Index=1) {
                    xPos := this.Pos().Right - ctrlW
                } else
                    xPos -= ctrlW + this.Pos().Margin

                xPos := Round(xPos)

                MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)

                index--
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

                xPos := Round(xPos)

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
                BlockWidth := TotalBtnW + TotalGapW ; 284
                SideMargin := (RowWidth - BlockWidth) / 2 ; 296 / 2 = 148

                ; The width of a button plus one fixed gap
                Step := BtnWidth + Gap ; 65 + 8 = 73

                ;leftSide := grui.W / 2 - (ctrl.W * Controls.Length - ctrl.W/2) + ((grui.MX + ctrl.W) * A_Index-1)
                ;leftSide := this.Pos().W / 2 - (ctrlW * Controls.Length - ctrlW/2) + ((this.Pos().Margin + ctrlW) * A_Index-1)

                if (A_Index=1) {
                    xPos := SideMargin 
                } else
                    xPos += Step
 
                MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)
            }
        }

        if (Layout = "AlignCenter_Gemini") {

            ; --- Constants ---
            RowWidth  := this.Pos().Width ;580
            BtnWidth  := newW ; 65
            NumBtns   := Controls.Length
            Gap       := this.Pos().Margin ;8

            ; --- Calculations  ---
            TotalBtnW := NumBtns * BtnWidth
            TotalGapW := (NumBtns - 1) * Gap
            BlockWidth := TotalBtnW + TotalGapW ; 284
            SideMargin := (RowWidth - BlockWidth) / 2 ; 296 / 2 = 148

            ; The width of a button plus one fixed gap
            Step := BtnWidth + Gap ; 65 + 8 = 73

            ; Loop to create and position the buttons
            Loop NumBtns
            {              
                ; Calculate the X position for the current button
                i := A_Index
                XPos := SideMargin + ((i - 1) * Step)

                ; Move the button using the calculated XPos and fixed width              
                MyControl := Controls[A_Index]

                ctrlX := (newX = "") ? this.Pos(MyControl).X : newX
                ctrlY := (newY = "") ? this.Pos(MyControl).Y : newY
                ctrlW := (newW = "") ? this.Pos(MyControl).W : newW
                ctrlH := (newH = "") ? this.Pos(MyControl).H : newH

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
            Gap := TotalSpace / (NumBtns - 1)

            SideMargin := this.Pos().Left + this.Pos().Margin + 4 ; 4=window border

            if (Gap > 2) {

                ; The width of a button plus one gap
                Step := BtnWidth + Gap 

                ; Loop to create and position the N buttons
                Loop NumBtns
                {
                    i := A_Index

                    ; XPos starts at 0 and increments by the Step amount
                    XPos := SideMargin + (i - 1) * Step 

                    MyControl := Controls[A_Index]

                    ctrlX := (newX = "") ? this.Pos(MyControl).X : newX
                    ctrlY := (newY = "") ? this.Pos(MyControl).Y : newY
                    ctrlW := (newW = "") ? this.Pos(MyControl).W : newW
                    ctrlH := (newH = "") ? this.Pos(MyControl).H : newH

                    MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)
                }

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

        TestNumber := 1

        MyGui := Gui("+Resize")
        MyGui.OnEvent("Size", Gui_Size)
        MyGui.OnEvent("Escape", (*) => ExitApp())
        MyGui.SetFont("s10")
        ;MyGui.Opt("-DPIScale") ; no change with or without

        ;MyEdit := MyGui.AddEdit("w200 r1 -VScroll vEdit", "Selected File")
        ;MyGui.AddButton("", "Open")

        MyText := MyGui.AddText("w200 h20 BackgroundSilver vText", "Drag the corners to resize the window.") ; Border for debug

        MyDivider := MyGui.AddText("w100 h4 0x10 Border vDivider") ; 0x10=SS_ETCHEDHORZ

        MyButtonYes := MyGui.AddButton("w50 Default", "Yes").OnEvent("Click", OnButton_Click)
        MyGui.AddButton("", "No")
        MyGui.AddButton("", "All")
        MyGui.AddButton("", "None")
        MyGui.AddButton("", "Open")
        MyGui.AddButton("", "Cancel").OnEvent("Click", (*) => ExitApp())

        MyGui.Show("w600 h300")
        ;MyGui.Show()
        ;MyGui.Show("AutoSize Center")

        ControlFocus(MyGui["Yes"])

        ; #region Functions
       
        OnButton_Click(*) {

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
            
                ; move the buttons to the bottom of the client area: Yes, then Cancel to the right
                ;   L.Pos() = Gui
                x:= L.Pos().Left
                y:= L.Pos().Bottom - L.Pos("Yes").H - L.Pos().Margin
                ; L.Move("Yes", x, y, ,)

                Buttons     := L.GetControls(MyGui, "Button", Exclude:="Open")

                ButtonRow   := L.MoveRow(Buttons, "CENTER", , y, w:=65, , False)

                ; Move the 'Open' button to the client top right
                y:= L.Pos().Top 
                ;x:= L.Pos().Right - L.Pos("Open").W ; - 4 ;  L.Pos().Margin
                x:= L.Pos().Right - L.Pos("Open").W
                L.Move("Open", x, y, w, )

                ; Move the divider to above the buttons and extend to the client right
                y:= L.Pos("Yes").Above - L.Pos("Divider").H
                w:= L.Pos().Right - L.Pos("Text").X
                L.Move("Divider", , y, w,)

                ; Extend Text to the client right, and to above the divider
                h:= L.Pos("Divider").Above - L.Pos().Margin ; L.Pos("Divider").H
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
