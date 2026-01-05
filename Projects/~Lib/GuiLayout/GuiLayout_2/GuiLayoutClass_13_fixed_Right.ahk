;ABOUT: GuiLayout
;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921

/*
    TODO:

        Finish AlignLeft, Right, Center, Fill
        Test all GetMetrics return{values}

        Fill(Gui, Control, FromX, ToX, FromY, ToY, FromW, ToW, FromH, ToH)
        Fill(Gui, Control, FromW, ToW, FromH, ToH)
        Fill(Gui, Control, FromW:=ControlX, ToW:=newW, FromH:=ControlH, ToH:=newH)

        D:\Software\DEV\Work\AHK2\Examples\Gui\Links\
        Resize a GUI when text changes - AutoHotkey Community
        https://www.autohotkey.com/boards/viewtopic.php?t=115745
*/

#Requires AutoHotkey v2.0+

Class GuiLayout {

    ; future AutoWidth := True

    ;TODO set this in GetMetrics
    Margin := 8
    __New(GuiObj) {

        if Type(GuiObj) != "Gui"
            return

        this.GuiObj := GuiObj
    }

    ; x,y,w,h with values relative to another control or client: Use Fill()
    ; x,y,w,h with absolute values: Use CtrlObj.Move()
    Fill(MyControl, newX:="", newY:="", fillX:="", fillY:="", Redraw:=False ) {
    ;Fill(MyControl, FillX:="", FillY:="", FillX:="", FillY:="", Redraw:=False ) {

    ;ListVars

        if (Type(MyControl) = "String")
            MyControl := this.GuiObj[MyControl]

        calcX := (newX = "")  ? this.Pos(MyControl).ControlX : newX
        calcY := (newY = "")  ? this.Pos(MyControl).ControlY : newY
        calcW := (fillX = "") ? this.Pos(MyControl).ControlW : fillX
        calcH := (fillY = "") ? this.Pos(MyControl).ControlH : fillY

        ; calculate the delta X
        if (newX != "") {

            deltaX := calcX - this.Pos(MyControl).X
            deltaY := calcY - this.Pos(MyControl).Y

            if (deltaX < 0) {
                calcX += 200 ;this.Pos(MyControl).x + this.Pos(MyControl).Width - 250
            } else {
                calcX -= this.Pos(MyControl).x + this.Pos(MyControl).Width
            }
        }

        MyControl.Move(calcX, calcY)

        ;_FillXY(MyControl, calcX, calcY)

        debug:=this.Margin
        inop:=this.Margin

        _FillWH(MyControl, fillX, fillY)

        if (Redraw)
            WinRedraw(MyControl.Gui)

        ; Inner functions:
        
        ; Change the x,y relative to another control or the client area
        _FillXY(MyControl, calcX, calcY) {
            MyControl.Move(calcX, calcY)
        }

        ; Change the width relative to another control or the client area
        _FillWH(MyControl, fillX, fillY) {

            ;TODO this check not needed
            ; if (fillX = "" && fillY = "") OR (MyControl = "")
            ;     return

            thisX := this.Pos(MyControl).ControlX
            thisY := this.Pos(MyControl).ControlY

            w := (fillX != "") ? fillX : this.Pos(MyControl).Width
            h := (fillY != "") ? fillY : this.Pos(MyControl).Height

            MyControl.Move(, , w, h)

        inop:=true
            ; newW := (fillX = "") ? "" : fillX - thisX
            ; newH := (fillY = "") ? "" : fillY - thisY

            ; ;TODO improve this?
            ; if (fillX="") AND (fillY="")
            ;     return
            ; if (fillX!="") AND (fillY="")
            ;     MyControl.Move(, , fillX, )
            ; if (fillX="") AND (fillY!="")
            ;     MyControl.Move(, , , fillY)
            ; if (fillX!="") AND (fillY!="")
            ;     MyControl.Move(, , newW, newH)
        }

        ; _H(MyControl, calcH) {
        ;     MyControl.Move(, , , calcH)
        ; }

    }

    Move(MyControl, newX:="", newY:="", newW:="", newH:="", Redraw:=False ) {

        if (Type(MyControl) = "String")
            MyControl := this.GuiObj[MyControl]

        calcX := (newX = "") ? this.Pos(MyControl).ControlX : newX
        calcY := (newY = "") ? this.Pos(MyControl).ControlY : newY
        calcW := (newW = "") ? this.Pos(MyControl).ControlW : newW
        calcH := (newH = "") ? this.Pos(MyControl).ControlH : newH

        ; calculate the delta X
        if (newX != "") {

            deltaX := calcX - this.Pos(MyControl).X
            deltaY := calcY - this.Pos(MyControl).Y

            ; if (deltaX < 0) {
            ;     calcX += this.Pos(MyControl).W + this.Margin*2 + 0 
            ; } else {
            ;     ;calcX -= this.Pos(MyControl).Width - this.Margin*1
            ; }

            calcX += this.Margin ; this.Pos(MyControl).W 

        }

        MyControl.Move(calcX, calcY)

        ;MyControl.Move(calcX, calcY, calcW, calcH)

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

        ;margin := this.Pos().Margin

        ;right := OutX + OutWidth + this.Margin
 ;MsgBox "Pos" " : " ctrlObj.Text

 ;not this is control, not client.clientRight := this.Pos(this.GuiObj).Right

        return {
            Margin:         this.Margin,

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
            Above   : OutY - this.Margin,    ; OK
            A       : OutY - this.Margin,    ; OK
            Below   : OutY + OutHeight + this.Margin,
            B       : OutY + OutHeight + this.Margin,

            Left    : OutX - this.Margin*2,  ; OK
            L       : OutX - this.Margin*2,  ; OK
            Right   : OutX + OutWidth, ;OK 
            R       : OutX + OutWidth, ;OK 
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

    GetMetrics(GuiObj:=this.GuiObj) {

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

    FillRow(Controls, Layout, newX:="", newY:="", newW:="", newH:="", Redraw:=False) {

        ; Move all controls to the same width and height
        _WH(Controls,newW, newH)
        
        ; Move controls to the new x, y position
        _XY(Controls,Layout, newX, newY)

        ; Functions
        _WH(Controls, newW, newH) {

            for MyControl in Controls
            {
                ctrlW := (newW = "") ? this.Pos(MyControl).W : newW
                ctrlH := (newH = "") ? this.Pos(MyControl).H : newH
                MyControl.Move( , , ctrlW, ctrlH)
            }
        }

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

                    MyControl.Move(xPos, ctrlY, ctrlW, ctrlH)
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

        global TestNamesMap := Map('Left', 1, 'Center', 2, 'Right', 3, 'Fill', 4)
        global TestNumber := 1

        CreateGui()
        
        ; #region Functions
       
        OnButton_Click(Ctrl, Info) {

            TestNumber := TestNamesMap[Ctrl.Text]

            MyText.Text := "Test #: " TestNumber ", Test: " Ctrl.Text " (Resize the Gui...)"
        }

        CreateGui() {
            global MyGui
            ; global MyEdit
            global MyText
            ; global MyDivider
            ; global MyButtonYes
            global ForceReDraw := False

            Scale    := .5
            maxScale := .5
            MaxW := 1920 * maxScale, MaxH := 1080 * maxScale
            MinW :=  480, MinH := 270
            newW := Round(MinW + Scale * (MaxW - MinW))
            newH := Round(MinH + Scale * (MaxH - MinH))

            MyGui := Gui("+Resize +MinSize" minW "x" minH " +MaxSize" MaxW "x" MaxH)
            ;MyGui := Gui("+Resize")
            MyGui.OnEvent("Size", Gui_Size)
            MyGui.OnEvent("Escape", (*) => ExitApp())
            ;MyGui.SetFont("s10", "Segoe UI")
            ;MyGui.Opt("-DPIScale") ; user preference

            MyEdit := MyGui.AddEdit("w100 r1 -VScroll vEdit", "Edit Control")
            MyGui.AddButton("", "Open")

            text := "Press a button to select a test, then resize the window."
            text := "Text Control"

            MyGui.SetFont("s14", "Consolas")
            MyText := MyGui.AddText("w125 h20 BackgroundSilver vText", text) ; Border for debug
            MyGui.SetFont()

            MyDivider := MyGui.AddText("w100 h4 0x10 Border vDivider") ; 0x10=SS_ETCHEDHORZ

            MyButtonYes := MyGui.AddButton("Default", "Left").OnEvent("Click", OnButton_Click)
            MyGui.AddButton("", "Center").OnEvent("Click", OnButton_Click)
            MyGui.AddButton("", "Right").OnEvent("Click", OnButton_Click)
            MyGui.AddButton("", "Fill").OnEvent("Click", OnButton_Click)
            MyGui.AddButton("", "Cancel").OnEvent("Click", (*) => ExitApp())

            MyGui.Show("w" newW " h" newH " Center")        

            ControlFocus(MyGui["Left"])

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
            
                BW := ButtonWidth := 75

                ; Move a row of buttons to the client bottom, exclude 'Open' for now.
                Buttons := L.GetControls(MyGui, "Button", Exclude:="Open")

                x:=0
                w:= ButtonWidth
                h:= 25 ; L.Pos("Cancel").H
                y:= L.Pos().Bottom - h - L.Pos().Margin

                switch TestNumber {
                    case 1:
                        L.FillRow(Buttons, "LEFT", x, y, w, h, ForceReDraw)
                    case 2:
                        L.FillRow(Buttons, "CENTER", x, y, w, h, ForceReDraw)
                    case 3:
                        L.FillRow(Buttons, "RIGHT", x, y, w, h, ForceReDraw)
                    case 4:
                        L.FillRow(Buttons, "FILL", x, y, w, h, ForceReDraw)
                }

                ; Move the divider to above the buttons and extend to the client right
                y:= L.Pos("Cancel").Above
                w:= L.Pos().Right
                L.Fill("Divider", , y, w, )

                ; Move the open button to the top right
                ; Note the use of the width of the Cancel button, not Open cause x,y changes on Open button.
                ; x:= L.Pos("Divider").Right - L.Pos("Cancel").Width + L.Pos().Margin
                ; y:= L.Pos("Edit").Top
                ; h:= L.Pos("Edit").Height+1
                ; ok MyGui["Open"].Move(x, y, ButtonWidth, h)

                ; Set the button width to match the width of the other buttons
                MyGui["Open"].Move(, , ButtonWidth, )

                ; Move the open button to the top right
                ;x:=L.Pos().Right - L.Pos("Open").Width - L.Pos().Margin*3 - 2
               x:= L.Pos("Divider").Right - L.Pos("Open").Width  - L.Margin
               ;but if left don't subtrace the button width
                ; ok x:= L.Pos("Edit").Right
                ;x:= L.Pos().Right - 40
            ;x:= L.Pos("Edit").Right ; + L.Pos("Open").Width
                ;x:= L.Pos("Divider").Right -200
                y:= L.Pos("Edit").Top ; + 25
                L.Move("Open", x, y)

                inop:=true
            return
                ; Extend the Edit to the left of the 'Open' and position to match the size of the 'Open' button
                y:= L.Pos("Open").Y 
                w:= L.Pos("Open").X - L.Pos("Edit").X - L.Pos().Margin
                L.Fill("Edit", , y, w,)
            
        ; Change L.Move to L.Fill

                ;L.Fill("Text", L.Pos("Open").X)

                ; Move the Text to below the Edit
                y:= L.Pos("Edit").Below

                ; Extend Text h to the client right, and to above the divider
                ; Must reference the Edit control whose Y position has not changed like the Text control did
                w:= L.Pos().Right - L.Pos("Text").X
                h:= L.Pos("Divider").Above - L.Pos("Edit").Below
                L.Fill("Text", , y, w, h)

                ;L.Fill("Text", L.Pos().Right, L.Pos("Divider").Above

            } finally {

                ; Unlock Window. Always call this, even if an error occurs!
                DllCall("LockWindowUpdate", "UInt", 0)                    
            }

            ; Force a repaint (optional, but ensures the new layout is drawn immediately)
            if (ForceReDraw)
                WinRedraw(GuiObj)
        }
    }
}
