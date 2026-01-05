;ABOUT: GuiLayout
;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921

/*
    TODO:

        Test all GetMetrics return{values}

        D:\Software\DEV\Work\AHK2\Examples\Gui\Links\
        Resize a GUI when text changes - AutoHotkey Community
        https://www.autohotkey.com/boards/viewtopic.php?t=115745
*/

#Requires AutoHotkey v2.0+

Class GuiLayout {

    Margin := 8
    GuiObj := ""

    GlobalRedraw := False

    __New(GuiObj:="") {

        if (Type(GuiObj) != "Gui" OR GuiObj = "")
            Throw "Requires a Gui Object for the parameter."

        this.GuiObj := GuiObj
    }

    ; x,y with absolute values.
    ; w,h with values relative to another control or client area.
    MoveFill(MyControl, newX:="", newY:="", newW:="", newH:="", Redraw:=False ) {

        Redraw := (this.GlobalRedraw) ? True : False

        if (Type(MyControl) = "String")
            MyControl := this.GuiObj[MyControl]

        ; x := (newX = "") ? this.Pos(MyControl).X : newX -= this.Pos(MyControl).X + this.Pos(MyControl).W + this.Margin*2
        ; MyControl.Move(x,,,,)

        ; y := (newY = "") ? this.Pos(MyControl).Y : newY += this.Pos(MyControl).ControlHeight
        ; MyControl.Move( ,y,,,)

        this.Move(MyControl, newX, newY,,, Redraw)

        if (newW = "") AND (newH = "")
            return

        w := (newW != "") ? newW : this.Pos(MyControl).Width +this.Margin*2
        ;MyControl.Move(, , w, )

        h := (newH != "") ? newH - this.Pos(MyControl).ControlY : this.Pos(MyControl).ControlHeight
        ;MyControl.Move(, , , h)

        MyControl.Move(, , w, h)

        if (Redraw)
            WinRedraw(MyControl.Gui)
    }
    
    ; Move x,y to absolute coordinates
    Move(MyControl, newX:="", newY:="", newW:="", newH:="", Redraw:=False ) {

        Redraw := (this.GlobalRedraw) ? True : False

        if (Type(MyControl) = "String")
            MyControl := this.GuiObj[MyControl]

        calcX := (newX = "") ? this.Pos(MyControl).ControlX : newX
        calcY := (newY = "") ? this.Pos(MyControl).ControlY : newY
        calcW := (newW = "") ? this.Pos(MyControl).ControlW : newW
        calcH := (newH = "") ? this.Pos(MyControl).ControlH : newH

        MyControl.Move(calcX, calcY)

        if (Redraw)
            WinRedraw(MyControl.Gui)
    }

    Pos(GuiOrControl:="") {

        if (GuiOrControl = "") {

            ;return this.GetMetrics(this.GuiObj)
            ;return this.GetGuiPos(this.GuiObj[GuiOrControl])
            return this.GetClientPos(this.GuiObj)

        } else if (SubStr(Type(GuiOrControl),1,4) = "Gui.") {

            ;ctrlObj := GuiOrControl
            return this.GetControlPos(this.GuiObj[GuiOrControl])

        } else if (SubStr(Type(GuiOrControl),1,3) = "Gui") {

            this.GuiObj:= GuiOrControl

            ;return this.GetMetrics(this.GuiObj)
            return this.GetGuiPos(this.GuiObj)

        } else if (Type(GuiOrControl) = "String") {

            switch GuiOrControl {
                case "G", "Gui":
                    return this.GetGuiPos(this.GuiObj)
                case "C", "Client":
                    return this.GetClientPos(this.GuiObj)
                default:
                    return this.GetControlPos(this.GuiObj[GuiOrControl])

                ;ctrlObj := this.GuiObj[GuiOrControl]
                    
            }
        } else {
            Throw "Error unknown Parameter for GuiOrControl"
        }

        ; ctrlObj.GetPos(&OutX, &OutY, &OutWidth, &OutHeight)

        ; return {
        ;     Margin:         this.Margin,

        ;     X:              OutX,
        ;     Y:              OutY,
        ;     Width:          OutWidth,
        ;     Height:         OutHeight,
        ;     W:              OutWidth,
        ;     H:              OutHeight,

        ;     ControlX:       OutX,
        ;     ControlY:       OutY,
        ;     ControlW:       OutWidth,
        ;     ControlH:       OutHeight,
        ;     ControlWidth:   OutWidth,
        ;     ControlHeight:  OutHeight,

        ; ;TODO: TEST ALL OF THESE
        ;     Above   : OutY - this.Margin,    ; Cancel
        ;     A       : OutY - this.Margin,    ; Cancel
        ;     Below   : OutY + OutHeight + this.Margin,
        ;     B       : OutY + OutHeight + this.Margin,

        ;     Left    : OutX - this.Margin*2,  ; Cancel
        ;     L       : OutX - this.Margin*2,  ; Cancel
        ;     Right   : OutX + OutWidth + this.Margin, ;Cancel 
        ;     R       : OutX + OutWidth, ;Cancel 
        ;     Top     : OutY,
        ;     T       : OutY,
        ;     Bottom  : OutY + OutHeight,
        ;     B       : OutY + OutHeight,
        ; }
    }

    GetControls(MyGui, ControlType:="Button", Exclude:="") {
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

    GetControlPos(GtrlObj) {

        GtrlObj.GetPos(&OutX, &OutY, &OutWidth, &OutHeight)

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
            Above   : OutY - this.Margin,    ; Cancel
            A       : OutY - this.Margin,    ; Cancel
            Below   : OutY + OutHeight + this.Margin,
            B       : OutY + OutHeight + this.Margin,

            Left    : OutX - this.Margin*2,  ; Cancel
            L       : OutX - this.Margin*2,  ; Cancel
            Right   : OutX + OutWidth + this.Margin, ;Cancel 
            R       : OutX + OutWidth, ;Cancel 
            Top     : OutY,
            T       : OutY,
            Bottom  : OutY + OutHeight,
            B       : OutY + OutHeight,
        }
    }

    GetClientPos(GuiObj:=this.GuiObj) {

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
        windowCaptionH := DllCall("GetSystemMetrics", "int", 4, "int") ; SM_CYCAPTION    ; 23

        ; calculate actual differences
        guiBorderWidth  := (guiW - clientRectW) // 2                    ; 8 
        guiBorderHeight := (guiH - clientRectH - windowCaptionH) // 2  ; 8

        nop:=true

        return {

            Border  : windowBorderX,

            Margin  : this.Margin, ; margin between controls (would have to show/hide gui, measure, then show again. Maybe future.)

            Top     : clientRectTop + this.Margin, ; - guiBorderHeight,
            Bottom  : clientRectBottom - this.Margin*2 - windowBorderY*4,
            Left    : clientRectLeft + guiBorderWidth + windowBorderX,
            Right   : clientRectRight - windowBorderX - guiBorderWidth*2,

            T       : guiBorderHeight,
            B       : clientRectH - windowBorderY*2,
            L       : clientRectLeft + guiBorderWidth,
            R       : clientRectW - windowBorderX*2,

            Height  : clientRectH - this.Margin - windowBorderY*2,
            Width   : clientRectW - guiBorderWidth - guiBorderWidth,
            H       : clientRectH - guiBorderHeight,
            W       : clientRectW - guiBorderWidth - guiBorderWidth,

            TopNoBorder       : 0,
            BottomNoBorder    : clientRectH,
            LeftNoBorder      : clientRectLeft,
            RightNoBorder     : clientRectW,
            HeightNoBorder    : clientRectH,
            WidthNoBorder     : clientRectW,

        }

    }

    GetGuiPos(GuiObj:=this.GuiObj) {

        ;RECT for Gui
        guiRect := Buffer(16, 0)
        DllCall("GetWindowRect", "ptr", GuiObj.hwnd, "ptr", guiRect.Ptr)
        guiLeft   := NumGet(guiRect, 0, "int")
        guiTop    := NumGet(guiRect, 4, "int")
        guiRight  := NumGet(guiRect, 8, "int")
        guiBottom := NumGet(guiRect, 12, "int")

        guiWidth := guiRight - guiLeft
        guiHeight := guiBottom - guiTop

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
        windowCaptionH := DllCall("GetSystemMetrics", "int", 4, "int") ; SM_CYCAPTION    ; 23

        ; ctrlulate actual differences
        guiBorderWidth  := (guiWidth - clientRectW) // 2                    ; 8 
        guiBorderHeight := (guiHeight - clientRectH - windowCaptionH) // 2  ; 8

        ; Client dimensions
        margin  := this.Margin ; margin between controls (would have to show/hide gui, measure, then show again. Maybe future.)

        Top     := guiTop       ;guiBorderHeight
        Bottom  := guiBottom    ; clientRectH - windowBorderY*2
        Left    := guiLeft      ; + guiBorderWidth + windowBorderX
        Right   := guiRight     ;clientRectRight - windowBorderX - guiBorderWidth*2

        T       := guiTop
        B       := guiBottom
        L       := guiLeft
        R       := guiRight     ; clientRectW - windowBorderX*2

        Height  := guiHeight    ;clientRectH - guiBorderHeight
        Width   := guiWidth     ;clientRectW - guiBorderWidth - guiBorderWidth
        H       := guiHeight    ; - guiBorderHeight
        W       := guiWidth     ;clientRectW - guiBorderWidth - guiBorderWidth

        return {

            WindowBorderX:   windowBorderX,
            WindowBorderY:   windowBorderY,
            WindowCaptionH:  windowCaptionH,

            BorderHeight: guiBorderHeight,
            BorderWidth:  guiBorderWidth,
            BH:           guiBorderHeight,
            BW:           guiBorderWidth,

            Margin: margin,

            X:      guiLeft,
            Y:      guiTop,

            Width:  guiWidth,
            Height: guiHeight,
            Left:   guiLeft,
            Right:  guiRight,
            Top:    guiTop,
            Bottom: guiBottom,
            
            W:      guiWidth,
            H:      guiHeight,
            L:      guiLeft,
            R:      guiRight,
            T:      guiTop,
            B:      guiBottom,
        }

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
        windowCaptionH := DllCall("GetSystemMetrics", "int", 4, "int") ; SM_CYCAPTION    ; 23

        ; ctrlulate actual differences
        guiBorderWidth  := (guiW - clientRectW) // 2                    ; 8 
        guiBorderHeight := (guiH - clientRectH - windowCaptionH) // 2  ; 8

        ; Client dimensions
        margin  := this.Margin ; margin between controls (would have to show/hide gui, measure, then show again. Maybe future.)

        Top     := guiBorderHeight
        Bottom  := clientRectH - windowBorderY*2
        Left    := clientRectLeft + guiBorderWidth + windowBorderX
        Right   := clientRectRight - windowBorderX - guiBorderWidth*2

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

            windowBorderX:   windowBorderX,
            windowBorderY:   windowBorderY,
            windowCaptionH:  windowCaptionH,

            guiBorderHeight: guiBorderHeight,
            guiBorderWidth:  guiBorderWidth,

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
            ClientHeight:   clientRectH,
            ClientBottom:   clientRectBottom,
            ClientLeft:     clientRectLeft,
            ClientRight:    clientRectRight,
            ClientTop:      clientRectTop,
            
            ClientWidthNoBorder:    clientWidthNoBorder,
            ClientHeightNoBorder:   clientHeightNoBorder,
            ClientBottomNoBorder:   ClientBottomNoBorder,
            ClientLeftNoBorder:     CientLeftNoBorder,
            ClientRightNoBorder:    ClientRightNoBorder,
            ClientTopNoBorder:      ClientTopNoBorder,
        }

    }

    FillRow(Controls, Layout, newX:="", newY:="", newW:="", newH:="", Redraw:=False) {

        Redraw := (this.GlobalRedraw) ? True : False

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
    Test2()
    ;Test3()

    Test1() {

        ;myGui := Gui("+Resize")
        myGui := Gui()
        myGui.OnEvent("Escape", (*) => ExitApp())

        myGui.SetFont("s12 cBlue w400", "Consolas")
        myGui.BackColor:="Silver"
        myGui.Show("w450 h350")

        L := GuiLayout(myGui)

        pos := L.Pos() ; .Top

        text :=
            "Width : " pos.Width    "`n`n" .
            "Height: " pos.Height   "`n`n" .
            "Border: " pos.Border   "`n`n" .
            "Margin: " pos.Margin   "`n`n" .
            "Left  : " pos.Left     "`n`n" .
            "Right : " pos.Right    "`n`n" .
            "Top   : " pos.Top      "`n`n" .
            "Bottom: " pos.Bottom   "`n`n"

        MsgBox text
    }


    Test3() {

        global TestNamesMap := Map('Left', 1, 'Center', 2, 'Right', 3, 'Fill', 4)
        global TestNumber := 1

        CreateGui()
        
        ; #region Functions
       
        OnButton_Click(Ctrl, Info) {

            ; WS_THICKFRAME := 0x40000
            ; WS_BORDER := 0x00800000
            ; WinSetStyle("+" WS_BORDER, "ahk_id " MyGui.Hwnd)

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
            ;MyGui.BackColor := "4682B4" ; Steel Blue

            MyEdit := MyGui.AddEdit("w100 r1 -VScroll vEdit", "Edit Control")
            MyGui.AddButton("", "Open")

            text := "Press a button to select a test, then resize the window."
            text := "Text Control"

            MyGui.SetFont("s14", "Consolas")
            MyText := MyGui.AddText("w125 h20 BackgroundSilver vText", text) ; Border for debug
            MyGui.SetFont()

            MyDivider := MyGui.AddText("w100 h2 BackgroundBlack  vDivider")

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

                ; User preferences
                L.GlobalRedraw := True           
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

                ; Move 'Divider' above the buttons and extend width to the client right
                y:= L.Pos("Cancel").Above
                w:= L.Pos().Right
                L.MoveFill("Divider", , y, w, )

                ; Set 'Open' to match the width of the other buttons
                MyGui["Open"].Move(, , ButtonWidth, )

                ; Move 'Open' to the right of the 'Divider', and to the same Y as the 'Edit'
                x:= L.Pos("Divider").Right - L.Pos("Open").Width  - L.Margin
                ; This also works to the right of the client
                ;x:= L.Pos().Right - L.Pos("Open").Width + L.Pos().WindowBorderX
                y:= L.Pos("Edit").Top
                ;L.Move("Open", x, y)
                L.MoveFill("Open", x, y)

                ; Position 'Edit' at the same Y as 'Open', and Extend the width to the left of 'Open'.
                y:= L.Pos("Open").Top
                w:= L.Pos("Open").Left
                L.MoveFill("Edit", , y, w, )
            
                ; Move 'Text' below 'Edit', fill width to the client right and height to above the 'Divider'
                y:= L.Pos("Edit").Below
                w:= L.Pos().Right
                h:= L.Pos("Divider").Above
                L.MoveFill("Text", , y, w, h)
 
            } finally {

                ; Unlock Window. Always call this, even if an error occurs!
                DllCall("LockWindowUpdate", "UInt", 0)                    
            }

            ; Force a repaint (optional, but ensures the new layout is drawn immediately)
            if (ForceReDraw)
                WinRedraw(GuiObj)
        }
    }
    
    Test2() {

        ; Test all Metric functions
        myGui := Gui("+Resize")
        G:= myGui
        C:= "Client"
        myGui.OnEvent("Escape", (*) => ExitApp())
        myGui.BackColor:= "4682B4" ; Steel Blue

        myGui.SetFont("s10 cwHITE", "Consolas")
        myX1label:= myGui.AddText("  w500", "X1 = Gui    = Silver")
        myX2abel:= myGui.AddText("xm w500", "X2 = Gui    = Blue")
        myYlabel:= myGui.AddText("xm w500", "Y1 = Client = Red")
        myY2abel:= myGui.AddText("xm w500", "Y2 = Client = Yellow")
        ;myXLabel.Move(5,5)
        ;myYLabel.Move(5,25)
        myGui.SetFont()

        myX1 := myGui.AddText("w2 h300 BackgroundSilver", "")
        myX2 := myGui.AddText("w2 h300 BackgroundBlue", "")
        myY1 := myGui.AddText("w300 h3 BackgroundRed", "")
        myY2 := myGui.AddText("w300 h3 BackgroundYellow", "")

        ;myText := myGui.AddText("w20 h10 BackgroundYellow", "Text")
        myButtonCancel := myGui.AddButton("", "Cancel").OnEvent("Click", (*) => ExitApp())
        myGui.Show("w600 h400")

        L := GuiLayout(myGui)

        gh:= L.Pos(myGui).Height
        gw:= L.Pos(myGui).Width
        gl:= L.Pos(myGui).Left
        gr:= L.Pos(myGui).Right
        gt:= L.Pos(myGui).Top
        gb:= L.Pos(myGui).Bottom

        clientWidth         := L.Pos(C).Width
        clientHeight        := L.Pos(C).Height
        clientTop           := L.Pos(C).Top
        clientBottom        := L.Pos(C).Bottom
        clientLeft          := L.Pos(C).Left
        clientRight         := L.Pos(C).Right
        clientWidthNoBorder := L.Pos(C).WidthNoBorder
nop:=true
;ListVars
;return
        ; clientWidthNoBorder := L.Pos().ClientWidthNoBorder
        ; clientHeightNoBorder := L.Pos().ClientHeightNoBorder
        ; clientBottomNoBorder := L.Pos().ClientBottomNoBorder
        ; clientLeftNoBorder := L.Pos().ClientLeftNoBorder
        ; clientRightNoBorder := L.Pos().ClientRightNoBorder
        ; clientTopNoBorder := L.Pos().ClientTopNoBorder
        windowCaptionH:= L.Pos(G).windowCaptionH
        ; a:=L.Pos(myGui).guiBorderHeight
        ; guiBorderWidth:=L.Pos(myGui).guiBorderWidth
        guiHeight:=L.Pos(G).Height
        ; d:=L.Pos(myGui).guiLeft
        ; e:=L.Pos(myGui).guiRight
        guiTop:=L.Pos(G).Top
        guiBottom:=L.Pos(G).Bottom
        guiWidth:=L.Pos(G).Width

     ; i:=L.Pos(myText).Margin
        ; j:=L.Pos(myText).Height
        ; k:=L.Pos(myText).Width
        ; l:=L.Pos(myText).Left
        ;m:=L.Pos(myText).Top
        ;n:=L.Pos(myText).Right
        ;o:=L.Pos(myText).Bottom  

        guiHeightY := guiBottom-guiTop
        guiCenterY:= guiBottom-guiTop/2
        guiDeltaY:= guiHeightY-guiCenterY

        guiWidth := guiBottom-guiTop

        guiCenterX:= guiWidth/2
        guiCenterY:= guiHeight/2

        clientCenterX:= clientWidth/2
        clientCenterY:= clientHeight/2

        t1:=guiTop-guiCenterY

        x:= guiWidth / 2  - 12 ; (tw / 2) - 16 - 12 ;(guiBorderWidth*2
        y:= guiHeight / 2 -24 ;-54 = invisible bottom - 24 

        ; myX1label:= myGui.AddText("" , "X1 = Gui    = Silver")
        ; myX2abel:= myGui.AddText("xm", "X2 = Gui    = Blue")
        ; myYlabel:= myGui.AddText("xm", "Y1 = Client = Red")
        ; myY2abel:= myGui.AddText("xm", "Y2 = Client = Yellow")
        ;myXLabel.Move(5,5)

        y:= L.Pos(G).Top - L.Pos(G).Margin
        h:= L.Pos(G).Height - L.Pos(G).Top + L.Pos(G).Margin*2
        y:= L.Pos(G).Top

        h:= L.Pos(G).Height - L.Pos(G).Top
        h:= L.Pos(C).Height - L.Pos(C).Top ; (myGui).Height, should be ClientHeight (WithBorder)
        h:= L.Pos(C).Height - L.Pos(C).Top + L.Pos(C).Margin*2 ; ClientHeight (WithBorder)
     
        text := myX1label.Text "  x=guiCenterX, y=(myGui).ClientTop" 
        myX1label.Text := text ; "1234567890123456789012345678901234567890" ; "x=guiCenterX, y=(myGui).ClientTop" 
        ;myX2abel:= myGui.AddText("xm", "X2 = Gui    = Blue")

        y:= L.Pos(C).Top
        h:= L.Pos(C).Height
        x:= L.Pos(C).Left
        x:= L.Pos(C).Right + 12
        x:= -1 ;L.Pos(G).Right-50
        myX1.Move(x   , y, , h)  ;Silver
        ;myX1.Move(guiCenterX   , y, , h)  ;Silver
        myX2.Move(clientCenterX, y, , h)  ;Blue

        myY1.Move(L.Pos(C).Left, guiCenterY, L.Pos(C).Width, )  ;Red
        myY2.Move(L.Pos(C).Left, clientCenterY, L.Pos(C).Width, )  ;Yellow

; ListVars
return
        cW:=L.Pos(C).Width
        cH:=L.Pos(c).Height
        cL:=L.Pos(c).Left
        cT:=L.Pos(c).Top
        
        ; ListVars
        ; return
        tW:=L.Pos("Text").Width
        tH:=L.Pos("Text").Height
        tL:=L.Pos("Text").Left
        tT:=L.Pos("Text").Top

        bW:=L.Pos(myButtonCancel).Width
        bH:=L.Pos(myButtonCancel).Height
        bL:=L.Pos(myButtonCancel).Left
        bT:=L.Pos(myButtonCancel).Top

        myText.Move(cl, ct, cw, ch)
        
    ListVars
    return
        
        x:= cw / 2  - (tw / 2) - 16 - 12 ;(guiBorderWidth*2
        y:= ch / 2  - (th / 2) - 23 ;windowCaptionH
        w:= cw / 4
        h:= ch / 4
        myText.Move(x, y, w, h)


        Left := L.Pos("Text").Left
        Right := L.Pos("Text").Right
        Top := L.Pos("Text").Top
        Bottom := L.Pos("Text").Bottom
        Width := L.Pos("Text").Width
        Height := L.Pos("Text").Height
        
        ListVars
        ;L.MoveFill("Text", x, y, fx, fy)



        nop:=true
    }
}