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
        ;clientRight := grui.W - (grui.MX*2) - (grui.MX*2) + 4
        clientRight := OutWidth - grui.MarginX*2
        ;clientBottom :=	grui.H - TitleBar - (grui.MY*2) - (grui.MY*2) + 4
        ;clientBottom :=	grui.H - TitleBar - (grui.MY*4) + 4
        clientBottom :=	OutHeight - grui.TitleBarHeight - grui.MarginY

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

    ; ""=same W/H, 0=max W/H, >0=new W/H (default=0)
    static ControlMove(Control, oldX:=-1, oldY:=-1, oldW:=-1, oldH:=-1) {

        if NOT IsObject(Control)
             return false

    ;MsgBox IsObject(Control) ;Control.Gui.Hwnd

        grui    := this._GetGuiPos(Control.Gui)
        client  := this._GetClientPos(Control.Gui)
        ctrl    := this._GetControlPos(Control)

        oldX := (oldX=-1) ? ctrl.X : oldX
        oldY := (oldY=-1) ? ctrl.Y : oldY
        oldW := (oldW =-1) ? ctrl.Width : oldW
        oldH := (oldH = -1) ? ctrl.Height : oldH

        newX := (oldX>0) ? oldX : client.Right
        newY := (oldY>0) ? oldY : client.Bottom - grui.MarginY*2

        newW := (oldW>0) ? oldW : client.Width - grui.MarginX*2
        newH := (oldH>0) ? oldH : client.Bottom
            
        Control.Move(newX, newY, newW, newH)

        WinRedraw(Control)
    }

    ;static GetRow(MyGui, ControlType:="Button", Align:="Right", IncludeMargins:="True") {
    static GetRow(MyGui, ControlType:="Button") {

        ; Get all the desired controls in the gui
        ; ClassNNs := WinGetControls([WinTitle, WinText, ExcludeTitle, ExcludeText])
        MyControls := []
        For GuiCtrlObj in MyGui {
            ; Option to get all controls in the gui
            if (ControlType = '')
                 MyControls.Push(GuiCtrlObj)
            ; Else get the designated control
            else if (InStr(Type(GuiCtrlObj), ControlType) != 0)
                    MyControls.Push(GuiCtrlObj)
        }

        return MyControls
        ;?
        ;ClassNNs := WinGetControls([WinTitle, WinText, ExcludeTitle, ExcludeText])
        ;HWNDs := WinGetControlsHwnd([WinTitle, WinText, ExcludeTitle, ExcludeText])


        ; Get positions
        ; WinGetPos &GuiX, &GuiY, &GuiWidth, &GuiHeight, MyGui
        ;WinGetClientPos &ClientX, &ClientY, &ClientWidth, &ClientHeight, MyGui
        ;MyControl.GetPos(&ControlX, &ControlY, &ControlWidth, &ControlHeight)
        ;ControlGetPos [&ControlX, &ControlY, &ControlWidth, &ControlHeight, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
        ;MyGui.GetPos([&GuiX, &GuiY, &GuiWidth, &GuiHeight])
        ;MyGui.GetClientPos([&ClientX, &ClientY, &ClientWidth, &ClientHeight])

        ; Calculate client x, y, w, h, Left, Right, Top, Bottom

       ;return {
            ;Gui: MyGui,
            ;Align: Align,
            ;X: OutX,
            ;Y: OutY,
            ;W: OutWidth,
            ;H: OutHeight,
            ;Width: OutWidth,
            ;Height: OutHeight,
            ; Left: 0,
            ; Right: 0,
            ; Top: 0,
            ; Bottom: 0,
            ; L: 0,
            ; R: 0,
            ; T: 0,
            ; B: 0,
            ; ClientWidth: ClientWidth,
            ; ClientHeight: ClientHeight,
            ; ClientTop: 0,
            ; ClientBottom: 0,
            ; CW: ClientWidth,
            ; CH: ClientHeight,
            ; CT: 0,
            ; CB: 0,
            ; GuiX: GuiX,
            ; GuiY: GuiY,
            ; GuiWidth: GuiWidth,
            ; GuiHeight: GuiHeight,
            ; GuiW: GuiWidth,
            ; GuiH: GuiHeight,
            ; GuiMarginX: MyGui.MarginX,
            ; GuiMarginY: MyGui.MarginY,
            ; GuiMX: MyGui.MarginX,
            ; GuiMY: MyGui.MarginY,
        ;}
    }

    ;GuiLayout.MoveControl()
    ; Fill the Control to the x, y, w, h
    ; if W="" then don't change width. if W=0 then fill to max width
    ; if H="" then don't change height. if H=0 then fill to max height
    ; if X or Y="" then dont change, else move to the X,Y position
    ; ""=same W/H, 0=max W/H, >0=new W/H (default="")
    static MoveControl(MyControl, newX:="", newY:="", newW:="", newH:="", Redraw:=False ) {
        
        grui    := this._GetGuiPos(MyControl.Gui)
        client  := this._GetClientPos(MyControl.Gui)
        ctrl    := this._GetControlPos(MyControl)

        calcW := (newW = "") ? ctrl.W : (newW = 0) ? client.Width - grui.MarginX*2 : newW
        calcH := (newH = "") ? ctrl.H : (newH = 0) ? client.Bottom - grui.MarginY*2 : newH
        calcX := (newX = "") ? ctrl.X : (newX = 0) ? newX : newX
        calcY := (newY = "") ? ctrl.Y : (newY = 0) ? newY : newY

        calcH := (newH = "") ? ctrl.H : newH - grui.MarginY*2

        MyControl.Move(calcX, calcY, calcW, calcH)

        if (Redraw)
            WinRedraw(MyControl.Gui)
    

        ; if IsSet(Height) AND IsObject(Height) {            
        ;     Height.GetPos(&X, &Y, &W, &H)
        ;     ;Height := H * 2.5
        ;     ;Height := grui.H-(grui.MarginY*2) - H*5
        ;     Height := client.Bottom-grui.MarginY-ctrl.H-grui.MarginY-grui.TitleBarHeight
        ;     Height := Y - grui.MarginY*2
        ;     OutputDebug X ", " Y ", " W ", " H
        ; }

        ; if (Width = 0) {
        ;     NewWidth:= client.Right
        ; } else { 
        ;     ;NewWidth := grui.W-(grui.MarginX*3) - Width
        ;     NewWidth := Width
        ; } 

        ; if (Height = 0) {
        ;     NewHeight := client.Bottom - grui.MarginY
        ; } else { 
        ;     ;NewHeight := grui.H-(grui.MarginY*2) - Height
        ;     NewHeight := Height
        ; } 
       
        ; if (Width>=0) AND (Height>=0) {
        ;     MyControl.Move(,,NewWidth, NewHeight)     ; 0=max W/H, >0=new W/H
        ; }
        ; if (Width>=0) AND (Height<0) {
        ;     MyControl.Move(,,NewWidth)                ; 0=max W/H, >0=new W/H
        ; } 

        ; if (Width<0) AND (Height>=0) {
        ;     MyControl.Move(,,, NewHeight)             ; 0=max W/H, >0=new W/H
        ; }

        ; if (Width<0) AND (Height<0) {               ; <0=same W/H
        ;     inop:=true
        ; } 

        nop:=true
    }

    ;GuiLayout.MoveRow()
    ; ""=same W/H, 0=max W/H, >0=new W/H (default="")
    static MoveRow(Controls, Layout, newX:="", newY:="", newW:="", newH:="", Redraw:=False) {

        grui    := this._GetGuiPos(Controls[1].Gui)
        client  := this._GetClientPos(Controls[1].Gui)
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
                grui := this._GetGuiPos(MyControl.Gui)
                client := this._GetClientPos(MyControl.Gui)
                ctrl := this._GetControlPos(MyControl)

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

                grui    := this._GetGuiPos(MyControl.Gui)
                client  := this._GetClientPos(MyControl.Gui)
                ctrl    := this._GetControlPos(MyControl)

                calcW := (newW = "") ? ctrl.W : (newW = 0) ? ctrl.W : newW ; CALC WIDTH BASED ON TEXT LENGTH???
                calcH := (newH = "") ? ctrl.H : (newH = 0) ? ctrl.H : newH
                calcX := (newX = "") ? ctrl.X : (newX = 0) ? newX : newX
                calcY := (newY = "") ? ctrl.Y : (newY = 0) ? client.Bottom - calcH + (grui.MarginY*2) : newY

                if (A_Index=1) {
                    xSpace := calcW  + grui.MarginX
                    xPos := client.Right - calcW + grui.MarginX - 0
                } else
                    xPos -= xSpace
    
                xPos := Round(xPos)

                MyControl.Move(xPos, calcY, calcW, calcH)

                if (Redraw)
                    WinRedraw(MyControl.Gui)

                index--
            }
        }

        if (Layout = "AlignCenter") {
            for MyControl in Controls
            {
                grui := this._GetGuiPos(MyControl.Gui)
                client := this._GetClientPos(MyControl.Gui)
                ctrl := this._GetControlPos(MyControl)

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

                grui    := this._GetGuiPos(MyControl.Gui)
                client  := this._GetClientPos(MyControl.Gui)
                ctrl    := this._GetControlPos(MyControl)

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

    ; ""=same W/H, 0=max W/H, >0=new W/H (default="")
;     static Move(Controls, newX:="", newY:="", newW:="", newH:="", Redraw:=False) {

; ;MsgBox Type(Controls)

;         if Type(Controls) = "Array" {
;             for ctrl in Controls
;                 ctrl.Move(x, y, w, h)
;         }

;          }
    
    static Move_OLD(MyGui, MyControl, x:="", y:="", w:="", h:="") {
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
            if (GuiCtrlObj.Type = ControlType)
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
    __GuiLayout_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

#SingleInstance Force
#Warn Unreachable, Off
#INCLUDE <DEBUG>
#esc::Exit

__GuiLayout_Test() {

    ; comment to skip, comment out to run tests
    ;SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    ;Test2()
    ;Test3()

    Test1() {

        TestNumber := 1

        MyGui := Gui("+Resize")
        MyGui.OnEvent("Size", Gui_Size)
        MyGui.OnEvent("Escape", (*) => ExitApp())
        MyGui.SetFont("s10")
        ;MyGui.Opt("-DPIScale") ; no change with or without

        ;MyGui.Opt("-Caption")
        ClientW := 600
        ClientH := 300

        MyEdit := MyGui.AddEdit("w200 r1 -VScroll vEdit", "Selected File")

        MyText := MyGui.AddText("w200 h20 BackgroundSilver vText", "Repeatedly Press ENTER...") ; Border for debug

        MyDivider := MyGui.AddText("w100 h4 0x10 Border vDivider") ; 0x10=SS_ETCHEDHORZ

        MyGui.AddButton("Default", "Yes")
        MyGui.AddButton("", "No")
        MyGui.AddButton("", "All")
        MyGui.AddButton("", "None")
        ;MyGui.AddButton("", "Oops") ; breaks Center alignment
        MyGui.AddButton("", "Cancel").OnEvent("Click", (*) => ExitApp())

    ;MyGui.AddText("w" ClientW-20 " h" ClientH-20 " x8 y8 Border BackgroundWhite BackgroundTrans")

        MyGui.Show("W600 H300")

        ControlFocus(MyGui["Yes"])

        MyGui["Yes"].OnEvent("Click", OnButton_Click)
       

        OnButton_Click(*) {

            ; GetMappedValue(n) {
            ;     if (n < 1)
            ;         return -1  ; or some default/error value
            ;     rangeSize := 10
            ;     baseOffset := 0
            ;     return ((n - 1) // rangeSize) * 2 + baseOffset
            ; }

            ; ; Example usage:
            ; msg :=""
            ; Loop 50 {
            ;     n := A_Index
            ;     val := GetMappedValue(n)
            ;     msg .= "n: " n " → " val "`n"
            ; }
            ; MsgBox msg

;object or ClassNN?

            ; Move the button row to the client bottom, and set the width of the butons
            Buttons := GuiLayout.GetControls(MyGui, "Button")
            ButtonRow := GuiLayout.MoveRow(Buttons, "Center", 0, 0, w:=65, 0, True)

           ; GuiLayout.Fill(Control, Width:=0, Height:=0 )

            ; Move the divider to the top of the Buttons and fill to the client width
            MyGui["Yes"].GetPos(&X, &Y, &W, &H)
            Y := Y - MyGui.MarginY*2
            GuiLayout.MoveControl(MyDivider, newX:="", newY:=Y, newW:=0, newH:="", Redraw:=False)

            ; ?MyGuiClient.GetPos(&X, &Y, &W, &H) ; instead of w:=0

            ; Fill the Text to the client with and to top of the divider
            MyDivider.GetPos(&X, &Y, &W, &H)
            newH := Y - MyGui.MarginY*4
            GuiLayout.MoveControl(MyGui["Text"], , , newW:=0, newH, Redraw:=True)

            ; Fill the edit to the client width
            GuiLayout.MoveControl(MyGui["Edit"], , , newW:=0, , Redraw:=false)

        ;ButtonRow := GuiLayout.RowTest(Buttons, "Right", 0, 80, 70, 10, True)

            ;static MoveRow(Controls, Layout, x:="", y:="", w:="", h:="")
            ; ""=same W/H, 0=max W/H, >0=new W/H (default="")
            ;ButtonRow := GuiLayout.Move(Buttons, x:="", Buttons.ClientBottom, w:="", h:="")

        }
        Gui_Size(GuiObj, MinMax, Width, Height) {

            ; LOCK the window (Stop all redrawing)
            ;DllCall("LockWindowUpdate", "UInt", GuiObj.Hwnd)

            try {
                ; If minimized, skip
                If (MinMax = -1)
                    return

                ; Move the button row to the client bottom, and set the width of the butons
                Buttons := GuiLayout.GetControls(MyGui, "Button")
                ButtonRow := GuiLayout.MoveRow(Buttons, "Center", 0, 0, w:=65, 0, True)

            ; GuiLayout.Fill(Control, Width:=0, Height:=0 )

                ; Move the divider to the top of the Buttons and fill to the client width
                MyGui["Yes"].GetPos(&X, &Y, &W, &H)
                Y := Y - MyGui.MarginY*2
                GuiLayout.MoveControl(MyDivider, newX:="", newY:=Y, newW:=0, newH:="", Redraw:=False)

                ; ?MyGuiClient.GetPos(&X, &Y, &W, &H) ; instead of w:=0

                ; Fill the Text to the client with and to top of the divider
                MyDivider.GetPos(&X, &Y, &W, &H)
                newH := Y - MyGui.MarginY*4
                GuiLayout.MoveControl(MyGui["Text"], , , newW:=0, newH, Redraw:=True)

                ; Fill the edit to the client width
                GuiLayout.MoveControl(MyGui["Edit"], , , newW:=0, , Redraw:=false)

            } finally {
    
                ;Sleep 10

                ; *** 2. UNLOCK the window (Resume redrawing) ***
                ; Always call this, even if an error occurs!
                ;DllCall("LockWindowUpdate", "UInt", 0)
                
                ; Force a repaint (optional, but ensures the new layout is drawn immediately)
                ;GuiObj.Redraw()
            }
        }
    }
}
