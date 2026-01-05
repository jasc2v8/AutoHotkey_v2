;ABOUT: GuiLayout
;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921

/*
    TODO:
        Use and fix if needed.
        
        D:\Software\DEV\Work\AHK2\Examples\Gui\Links\
        Resize a GUI when text changes - AutoHotkey Community
        https://www.autohotkey.com/boards/viewtopic.php?t=115745
*/

#Requires AutoHotkey v2.0+
#Include <Debug>

Class GuiLayout {

    Border := 0 ; 10
    Margin := 0 ; 10
    
    GuiObj := ""

    GlobalRedraw := False
    static GlobalResize := False

    __New(GuiObj:="") {

        if (Type(GuiObj) != "Gui" OR GuiObj = "")
            Throw "Requires a Gui Object for the parameter."

        this.GuiObj := GuiObj
        this.Border := this.GetClientPos(GuiObj).Border
        this.Margin := this.GetClientPos(GuiObj).Margin
    }

    ; x,y with absolute values.
    ; w,h with values relative to another control or client area.
    MoveFill(MyControl, newX:="", newY:="", newW:="", newH:="", Redraw:=False ) {
        
        X := (newX = "") ? this.Pos(MyControl).X : newX
        Y := (newY = "") ? this.Pos(MyControl).Y : newY
        W := (newW = "") ? this.Pos(MyControl).Width : newW
        H := (newH = "") ? this.Pos(MyControl).Height : newH

        Redraw := (this.GlobalRedraw) ? True : False

        if (Type(MyControl) = "String")
            MyControl := this.GuiObj[MyControl]

        X := (X < this.Pos().Left) ? this.Pos().Left : X
        X := (X > this.Pos().Right) ? this.Pos().Right : X

        calcX := (newX != "" AND newX > this.Pos(MyControl).X) ? X - this.Pos(MyControl).Width : X

        this.Move(MyControl, calcX, Y,,, Redraw)

        if (newW = "") AND (newH = "")
            return

        newW  := (newW > this.Pos().Width) ? this.Pos().Width : newW
        calcW := newW - this.Pos(MyControl).X
        calcW := (calcW < this.Pos().Left) ? this.Pos().Left : calcW

        ; fill h to the newH = .Above, .Below, .Top, .Bottom
        calcH := (newH != "") ? newH - this.Pos(MyControl).Y : this.Pos(MyControl).Height
        MyControl.Move(, , calcW, calcH)

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
            ;return this.GetControlPos(this.GuiObj[GuiOrControl])
            return this.GetControlPos(GuiOrControl)

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

            Left    : OutX - this.Margin,  ; Cancel
            L       : OutX - this.Margin,  ; Cancel
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

        guiWidth := guiRight - guiLeft
        guiHeight := guiBottom - guiTop

        ; RECT for Client area
        clientRect := Buffer(16, 0)
        DllCall("GetClientRect", "ptr", GuiObj.hwnd, "ptr", clientRect.Ptr)

        clientRectLeft   := NumGet(clientRect, 0, "int")
        clientRectTop    := NumGet(clientRect, 4, "int")
        clientRectRight  := NumGet(clientRect, 8, "int")
        clientRectBottom := NumGet(clientRect, 12, "int")

        clientRectWidth := clientRectRight - clientRectLeft
        clientRectHeight := clientRectBottom - clientRectTop

        ; Get border metrics
        windowBorderX := DllCall("GetSystemMetrics", "int", 32, "int") ; SM_CXFRAME       ; 4
        windowBorderY := DllCall("GetSystemMetrics", "int", 33, "int") ; SM_CYFRAME       ; 4
        windowCaptionH := DllCall("GetSystemMetrics", "int", 4, "int") ; SM_CYCAPTION    ; 23

        ; calculate actual differences
        guiBorderWidth  := (guiWidth - clientRectWidth) // 2 +2                   ; 10
        guiBorderHeight := (guiHeight - clientRectHeight - windowCaptionH) // 2 +2 ; 10

        ;bottomBorder := guiBottom - clientRectBottom
        ;bottomBorder := guiBottom - clientRectBottom  - clientRectBottom ; 10
       ; BottomBorder    : bottomBorder,

        border  := guiBorderWidth ; 10
        margin  := guiBorderWidth - 1 ; 10-1=9

;Debug.ListVars("title", , "clientRectBottom, guiBorderHeight, margin", clientRectWidth, clientRectHeight, margin)
;Debug.ListVars("title", , "clientRectBottom, guiBorderHeight, guiWidth, guiHeight, margin", clientRectBottom, guiBorderHeight, guiWidth, guiHeight, margin)
        nop:=true

        return {

            Border  : border,

            Margin  : margin,

            Left    : clientRectLeft + border,
            Right   : clientRectWidth - border,
            Top     : border,
            Bottom  : clientRectBottom - guiBorderHeight - margin,

            L       : windowBorderX + border,
            R       : clientRectWidth - border,
            T       : border,
            B       : clientRectBottom - guiBorderHeight - margin,

            Width   : clientRectWidth - border,
            Height  : clientRectHeight - border,
            W       : clientRectWidth - border,
            H       : clientRectHeight - border,

            CenterX : (clientRectWidth - border) //2,
            CenterY : (clientRectHeight - border) //2,

            RectLeft    : clientRectLeft,
            RectRight   : clientRectRight,
            RectTop     : clientRectTop,
            RectBottom  : clientRectBottom,
            RectWidth   : clientRectWidth,
            RectHeight  : clientRectHeight,

        }

    }

    GetGuiPos(GuiObj:=this.GuiObj) {

        ;RECT for Gui
        guiRect := Buffer(16, 0)
        DllCall("GetWindowRect", "ptr", GuiObj.hwnd, "ptr", guiRect.Ptr)
        guiRectLeft   := NumGet(guiRect, 0, "int")
        guiRectTop    := NumGet(guiRect, 4, "int")
        guiRectRight  := NumGet(guiRect, 8, "int")
        guiRectBottom := NumGet(guiRect, 12, "int")

        guiWidth := guiRectRight - guiRectLeft
        guiHeight := guiRectBottom - guiRectTop

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
        windowBorderX  := DllCall("GetSystemMetrics", "int", 32, "int") ; SM_CXFRAME       ; 4
        windowBorderY  := DllCall("GetSystemMetrics", "int", 33, "int") ; SM_CYFRAME       ; 4
        windowCaptionH := DllCall("GetSystemMetrics", "int", 4, "int") ; SM_CYCAPTION    ; 23

        ; ctrlulate actual differences
        guiBorderWidth  := (guiWidth - clientRectW) // 2                    ; 8 
        guiBorderHeight := (guiHeight - clientRectH - windowCaptionH) // 2  ; 8

        border  := guiBorderWidth ; 10
        margin  := guiBorderWidth - 1 ; 10-1=9

        Top     := guiRectTop       ;guiBorderHeight
        Bottom  := guiRectBottom    ; clientRectH - windowBorderY*2
        Left    := guiRectLeft      ; + guiBorderWidth + windowBorderX
        Right   := guiRectRight     ;clientRectRight - windowBorderX - guiBorderWidth*2

        T       := guiRectTop
        B       := guiRectBottom
        L       := guiRectLeft
        R       := guiRectRight     ; clientRectW - windowBorderX*2

        Height  := guiHeight    ;clientRectH - guiBorderHeight
        Width   := guiWidth     ;clientRectW - guiBorderWidth - guiBorderWidth
        H       := guiHeight    ; - guiBorderHeight
        W       := guiWidth     ;clientRectW - guiBorderWidth - guiBorderWidth

        return {

            Border: border,
            Margin: margin,

            WindowBorderX:   windowBorderX,
            WindowBorderY:   windowBorderY,
            WindowCaptionH:  windowCaptionH,

            BorderHeight: guiBorderHeight,
            BorderWidth:  guiBorderWidth,
            BH:           guiBorderHeight,
            BW:           guiBorderWidth,

            X:      guiRectLeft,
            Y:      guiRectTop,

            Width:  guiWidth,
            Height: guiHeight,
            Left:   guiRectLeft,
            Right:  guiRectRight,
            Top:    guiRectTop,
            Bottom: guiRectBottom,
            
            W:      guiWidth,
            H:      guiHeight,
            L:      guiRectLeft,
            R:      guiRectRight,
            T:      guiRectTop,
            B:      guiRectBottom,

            RectLeft    : guiRectLeft,
            RectRight   : guiRectRight,
            RectTop     : guiRectTop,
            RectBottom  : guiRectBottom,
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

        grui:= this.GuiObj

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
;
If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    __GuiLayout_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

#SingleInstance Force
#Warn Unreachable, Off
#esc::ExitApp

__GuiLayout_Test() {

    ; comment to skip, comment out to run tests
    SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    Test2()
    Test3()

    Test1() {
        myGui := Gui()
        myGui.OnEvent("Escape", Button_Click)

        myGui.Title:="GuiLayout Test# 1"
        myGui.SetFont("s10 cBlue w400", "Consolas")
        myGui.BackColor:="Silver"
        myGui.Show("w450 h350")

        L := GuiLayout(myGui)

        pos := L.Pos("Client")

        text :=
            "`n`n" .
            "Show(w450, h350)"       "`n`n" .
            "Width  : " pos.Width    "`n" .
            "Height : " pos.Height   "`n" .
            "Border : " pos.Border   "`n" .
            "Margin : " pos.Margin   "`n" .
            "Left   : " pos.Left     "`n" .
            "Right  : " pos.Right    "`n" .
            "Top    : " pos.Top      "`n" .
            "Bottom : " pos.Bottom   "`n" .
            "CenterX: " pos.CenterX  "`n" .
            "CenterY: " pos.CenterY  "`n`n" 

        ;MsgBox text

        myGui.AddText("", text)
        myGui.AddButton("Default", "OK").OnEvent("Click", Button_Click)
        
        x:= L.Pos().Right - L.Pos("OK").Width
        y:= L.Pos().Bottom - L.Pos("OK").Height
        ; TODO FIX y:= L.Pos().Bottom - L.Pos(myGui["OK"]).Height
        ; TODO FIX y:= L.Pos().Bottom - L.Pos(ButtonOK).Height
        myGui["OK"].Move(x,y)
        
        ; why doesn't Persistent work in Test1, but OK in Test2?
        While WinActive(myGui)
            Sleep(100)

        Button_Click(*){
            WinClose(myGui)
            return
        }
    }

    Test2() {

        ; not needed yet it remains persistent, not sure why: Persistent True

        ; Test all Metric functions
        myGui := Gui("-Resize", "GuiLayoutClass Test# 2")
        G:= myGui
        C:= "Client"
        myGui.OnEvent("Escape", Button_Click)
        myGui.BackColor:= "4682B4" ; Steel Blue

        myGui.SetFont("s10 cWhite", "Consolas")
        myX1abel:= myGui.AddText("xm w500", "Blue  : Client CenterX")
        myY1abel:= myGui.AddText("xm w500", "Yellow: Client CenterY")
        myGui.SetFont()

        myX1 := myGui.AddText("w2 h300 BackgroundBlue", "")
        myY1 := myGui.AddText("w300 h3 BackgroundYellow", "")

        L := GuiLayout(myGui)

        ;myButtonCancel := myGui.AddButton("Default", "Cancel")
        ;myButtonCancel.OnEvent("Click", (*) => ExitApp())
        ;myButtonCancel.Move( L.Pos().Left, L.Pos().Bottom)
        ButtonOK := myGui.AddButton("Default", "OK")
        ButtonOK.OnEvent("Click", Button_Click)

        myGui.Show("w450 h350")

        x:= L.Pos().Right - L.Pos("OK").Width
        y:= L.Pos().Bottom - L.Pos("OK").Height
        ; TODO FIX y:= L.Pos().Bottom - L.Pos(myGui["OK"]).Height
        ; TODO FIX y:= L.Pos().Bottom - L.Pos(ButtonOK).Height

        ButtonOK.Move(x,y)

        Button_Click(*){
            WinClose(myGui)
            return
        }

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

        y:= L.Pos(G).Top - L.Pos(G).Margin
        h:= L.Pos(G).Height - L.Pos(G).Top + L.Pos(G).Margin*2
        y:= L.Pos(G).Top

        h:= L.Pos(G).Height - L.Pos(G).Top
        h:= L.Pos(C).Height - L.Pos(C).Top ; (myGui).Height, should be ClientHeight (WithBorder)
        h:= L.Pos(C).Height - L.Pos(C).Top + L.Pos(C).Margin*2 ; ClientHeight (WithBorder)
     
        x:= L.Pos(C).CenterX
        y:= L.Pos(C).Top
        h:= L.Pos(C).Bottom
        myX1.Move(x, y, , h)  ;Blue

        ;myY1.Move(L.Pos(C).Left, L.Pos(C).CenterY, L.Pos(C).Width, )  ;Yellow
        L.MoveFill(myY1, L.Pos(C).Left, L.Pos(C).CenterY, L.Pos(C).Width, )  ;Yellow

        While WinActive(myGui)
            Sleep(100)
    }
}

Test3() {

    global TestNamesMap := Map('Left', 1, 'Center', 2, 'Right', 3, 'Fill', 4)
    global TestNumber := 1

    if FileExist("Resize.tmp")
        FileDelete("Resize.tmp")
    FileAppend("False", "Resize.tmp")

    CreateGui()  
    MsgBox("Controls are added at default positions.`n`nPress Enter to demo the Layout.", "GuiLayout Test")
    WinClose(MyGui)

    if FileExist("Resize.tmp")
        FileDelete("Resize.tmp")
    FileAppend("True", "Resize.tmp")

    CreateGui()

    ; #region Functions

    OnClose(*) {
        if FileExist("Resize.tmp")
            FileDelete("Resize.tmp")
    }

    OnEscape_Click(*) {
            WinClose(MyGui)
        return
    }

    OnButton_Click(Ctrl, *) {

        if (Ctrl.Text = "Cancel") {
            WinClose(MyGui)
            return
        }
    
        TestNumber := TestNamesMap[Ctrl.Text]

        MyText.Text := "Test #: " TestNumber ", Test: " Ctrl.Text " (Resize the Gui...)"
    }

    CreateGui() {
        global MyGui, MyEdit, MyText, MyDivider, MyButtonYes
        global ForceReDraw := False
        global Resize:=false

        Scale    := .5
        maxScale := .5
        MaxW := 1920 * maxScale, MaxH := 1080 * maxScale
        MinW :=  480, MinH := 270
        newW := Round(MinW + Scale * (MaxW - MinW))
        newH := Round(MinH + Scale * (MaxH - MinH))

        MyGui := Gui("+Resize +MinSize" minW "x" minH " +MaxSize" MaxW "x" MaxH)
        ;MyGui := Gui("+Resize")
        MyGui.OnEvent("Size", Gui_Size)
        MyGui.OnEvent("Close", OnClose)

        MyGui.OnEvent("Escape", OnEscape_Click)

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
        MyGui.AddButton("", "Cancel").OnEvent("Click", OnButton_Click)

        MyGui.Show("w" newW " h" newH " Center")        

        ControlFocus(MyGui["Left"])

    }

    Gui_Size(GuiObj, MinMax, Width, Height) {
    global ReSize
    global MyDivider

        ; If minimized, skip
        If (MinMax = -1)
            return

        if (FileRead("Resize.tmp") != "True")
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

            x:= L.Pos().Left ;0
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
            x:= L.Pos().Left
            y:= L.Pos("Cancel").Above
            w:= L.Pos().Right
            L.MoveFill("Divider", x, y, w, ) ; MyDivider
            ; ok L.MoveFill(MyDivider, x, y, w, ) ; MyDivider

            ; Set 'Open' width to match the width of the other buttons
            MyGui["Open"].Move(, , ButtonWidth, )

            ; Move 'Open' to the right of the Client and to the same Y as the 'Edit'
            x:= L.Pos().Right ; - L.Pos("Open").Width ; - L.Margin ;-L.Border*4
            ; This also works to the right of the control
            ;x:= L.Pos("Divider").Right - L.Pos("Open").Width - L.Margin
            y:= L.Pos("Edit").Top
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
