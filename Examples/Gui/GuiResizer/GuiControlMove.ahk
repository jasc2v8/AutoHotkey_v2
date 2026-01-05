;ABOUT: GuiControlFlow Move is perfect

;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921

#Requires AutoHotkey v2.0+

; make Text the width of the Gui
; make row of buttons right aligned

Escape::ExitApp()

CtrlFlow(MyGui, Controls, Layout)  {

    ;Layout := "RightLeft", "LeftRight", "Center", "Fill"

    ; CtrlFlow(MyGui, Controls, Layout, yPos) ; "yBottom, yTop, yMiddle, y")

    #Warn Unreachable, Off

    WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

    WinGetClientPos , , &OutClientWidth, &OutClientHeight, MyGui
    ;MsgBox("OutClientWidth: " . OutClientWidth . ", OutClientHeight: " . OutClientHeight)


    xGui := OutX
    yGui := OutY

    wGui := OutWidth
    hGui := OutHeight

    X_Margin := MyGui.MarginX
    Y_Margin := MyGui.MarginY

    xmGui := MyGui.MarginX
    ymGui := MyGui.MarginY

    ; for control in Controls {
    ;      ;MsgBox "Found: " control.Text
    ; }

    ;return

    ;MsgBox("MyGui.MarginX: " . MyGui.MarginX . ", MyGui.MarginY: " . MyGui.MarginY)
; MarginX = 14
; MarginY = 8


    ;Control position

    ;MyControl.Move(,,wGui-W-(X_Margin*2), hGui-H)

    ; Controls := []

    ; For Hwnd, GuiCtrlObj in MyGui {

    ;      ;MsgBox "Found Text: " GuiCtrlObj.ClassNN ", Index: " A_Index


    ;     If (SubStr(GuiCtrlObj.ClassNN, 1, 6) = "Button") {
    ;         Controls.Push(GuiCtrlObj)

    ;         ;MyText := MyGui["Cancel"]
    ;         ;MyText.Text := "Found: " . GuiCtrlObj.Text
    ;     } else if (SubStr(GuiCtrlObj.ClassNN, 1, 6) = "Static") {
    ;         ;MyText := MyGui["Cancel"]
    ;         ;MsgBox "Found Text: " GuiCtrlObj.Text ", Index: " A_Index
    ;         GuiCtrlObj.Text  := "Found: " . GuiCtrlObj.ClassNN
    ;     }

    ; }

    ;MsgBox("hGui: " . hGui . ", Y_Margin: " . Y_Margin)

    index := Controls.Length
    count := 1
    Loop {
        control := Controls[index]
        ;MsgBox "Found button: " control.Text ", Index: " index

        control.GetPos(&X, &Y, &W, &H)

        ; bottom yPos := hGui-Y_Margin-Y_Margin-H*2
        yPos := (hGui - Y_Margin*16) / 2

        ;RightLeft
        control.Move(wGui-X_Margin-count*(W+Y_Margin), OutClientHeight/2)
        
        ;LeftRight
        ;control.Move(wGui+X_Margin+count*(W+Y_Margin), hGui-Y_Margin-Y_Margin-H*2)

        count++

        index--
        if (index = 0)
            break
    }

    ;For control in Controls {
        ;MsgBox "Found button: " control.Text ", Index: " A_Index

        ;bCount := Controls.Length

        ;control.GetPos(&X, &Y, &W, &H)

        ;control.Move(wGui-W-(X_Margin*1) - (W*A_Index))
        ;control.Move(wGui-(X_Margin+(X_Margin*A_Index))-(W*A_Index))
    ;}

}

CtrlFlow_OLD(MyGui, MyControl)  {

    WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

    xGui := OutX
    yGui := OutY

    wGui := OutWidth
    hGui := OutHeight

    X_Margin := MyGui.MarginX
    Y_Margin := MyGui.MarginY

    xmGui := MyGui.MarginX
    ymGui := MyGui.MarginY

;MsgBox("MyGui.MarginX: " . MyGui.MarginX . ", MyGui.MarginY: " . MyGui.MarginY)
; MarginX = 14
; MarginY = 8


    ;Control position

    ;MyControl.Move(,,wGui-W-(X_Margin*2), hGui-H)

    Controls := []

    For Hwnd, GuiCtrlObj in MyGui {

         ;MsgBox "Found Text: " GuiCtrlObj.ClassNN ", Index: " A_Index


        If (SubStr(GuiCtrlObj.ClassNN, 1, 6) = "Button") {
            Controls.Push(GuiCtrlObj)

            ;MyText := MyGui["Cancel"]
            ;MyText.Text := "Found: " . GuiCtrlObj.Text
        } else if (SubStr(GuiCtrlObj.ClassNN, 1, 6) = "Static") {
            ;MyText := MyGui["Cancel"]
            ;MsgBox "Found Text: " GuiCtrlObj.Text ", Index: " A_Index
            GuiCtrlObj.Text  := "Found: " . GuiCtrlObj.ClassNN
        }

    }

    index := Controls.Length
    count := 1
    Loop {
        control := Controls[index]
        ;MsgBox "Found button: " control.Text ", Index: " index

        control.GetPos(&X, &Y, &W, &H)

        ;RightLeft
        control.Move(wGui-X_Margin-count*(W+Y_Margin), hGui-Y_Margin-Y_Margin-H*2)
        
        ;LeftRight
        ;control.Move(wGui+X_Margin+count*(W+Y_Margin), hGui-Y_Margin-Y_Margin-H*2)

        count++

        index--
        if (index = 0)
            break
    }

    For control in Controls {
        ;MsgBox "Found button: " control.Text ", Index: " A_Index

        ;bCount := Controls.Length

        ;control.GetPos(&X, &Y, &W, &H)

        ;control.Move(wGui-W-(X_Margin*1) - (W*A_Index))
        ;control.Move(wGui-(X_Margin+(X_Margin*A_Index))-(W*A_Index))
    }

}

; CtrlFlow(MyGui, MyControl) {

;     WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

;     xGui := OutX
;     yGui := OutY

;     wGui := OutWidth
;     hGui := OutHeight

;     X_Margin := MyGui.MarginX
;     Y_Margin := MyGui.MarginY

;     xmGui := MyGui.MarginX
;     ymGui := MyGui.MarginY

;     MyControl.GetPos(&X, &Y, &W, &H)

;     MyControl.Move(, hGui-(Y_Margin*10),,)
; }

CtrlFillWidth(MyGui, MyControl)  {

    WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

    xGui := OutX
    yGui := OutY

    wGui := OutWidth
    hGui := OutHeight

    X_Margin := MyGui.MarginX
    Y_Margin := MyGui.MarginY

    xmGui := MyGui.MarginX
    ymGui := MyGui.MarginY

    ;Control position
    MyControl.GetPos(&X, &Y, &W, &H)

    MyControl.Move(,,wGui-W-(X_Margin*2), hGui-H)

    ; Controls := []

    ; For Hwnd, GuiCtrlObj in MyGui {

    ;     ;MsgBox "Control Class #" A_Index ": " GuiCtrlObj.ClassNN ", Text: " GuiCtrlObj.Text

    ;     If (SubStr(GuiCtrlObj.ClassNN, 1, 6) = "Button") {
    ;         Controls.Push(GuiCtrlObj)
    ;     }

    ; }

    ; ; Now, ButtonControls array contains all button control objects
    ; ; You can iterate through this array to access each button
    ; For control in Controls {
    ;     ;MsgBox "Found button: " control.Text ", Index: " A_Index
    ;     control.Move(, hGui-(Y_Margin*10),,)
    ; }

}
;-------------------------------------------------------------------------------
; Summary:  Moves Gui Controls without requiring the Gui to be redrawn.
; Returns:  The Gui control moved.
; Library:  Gui.ahk

; ButtonYes ButtonNo ButtonCancel
;                                    ButtonYes ButtonNo ButtonCancel

CtrlMove(MyGui, MyCtrl, X, Y) {

    ; Gui position
    WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

    xGui := OutX
    yGui := OutY

    wGui := OutWidth
    hGui := OutHeight

    X_Margin := MyGui.MarginX
    Y_Margin := MyGui.MarginY

    xmGui := MyGui.MarginX
    ymGui := MyGui.MarginY

    ;Control position
    MyCtrl.GetPos(&X, &Y, &W, &H)

    ;MsgBox "X-Margin: " . X_Margin . " pixels`nY-Margin: " . Y_Margin . " pixels"

    ;MyCtrl.Move(wGui, hGui)

    MyCtrl.Move(X, hGui-Y_Margin-Y_Margin-H*2)
}

CtrlMove_OLD(MyGui, MyCtrl, xGuiRight:=0, xGuiTop:=0) {

    ; Gui position
    WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

    xGui := OutX
    yGui := OutY

    wGui := OutWidth
    hGui := OutHeight

    X_Margin := MyGui.MarginX
    Y_Margin := MyGui.MarginY

    xmGui := MyGui.MarginX
    ymGui := MyGui.MarginY

    ;Control position
    MyCtrl.GetPos(&X, &Y, &bWidth, &bHeight)

    ;MsgBox "X-Margin: " . X_Margin . " pixels`nY-Margin: " . Y_Margin . " pixels"

    ; assumes all buttons have same width
    MyButtonCancel.GetPos(&X, &Y, &bWidth, &bHeight)
    MyButtonCancel.Move(wGui-bWidth-xmGui,,,)

    ; if buttons different width, need to compensate
    MyButtonCancel.GetPos(&X, &Y, &bWidth, &bHeight)
    MyButtonMove.Move(wGui-(bWidth*2)-xmGui,,,)

}
; --- Event Callback Function ---
GuiSize(MyGui, MinMax, Width, Height) {

    ; MinMax = -1 means the window was minimized. No action is needed.
    if MinMax == -1
        return

    ; Reposition and resize the Edit control.
    ; Width and Height contain the new dimensions of the client area.
    ; We set the width and height of the Edit control to match the GUI's new size.
    ;MyEdit.Move(,, Width, Height)

    X_Margin := MyGui.MarginX
    Y_Margin := MyGui.MarginY

    ;MsgBox "X-Margin: " . X_Margin . " pixels`nY-Margin: " . Y_Margin . " pixels"

    ; assumes all buttons have same width
    MyButtonCancel.GetPos(&X, &Y, &bWidth, &bHeight)
    MyButtonCancel.Move(Width-bWidth-X_Margin,,,)

    ;MyButtonMove.GetPos(&X, &Y, &bWidth, &bHeight)
    MyButtonMove.Move(Width-(bWidth*2)-X_Margin,,,)

}


ListControls(MyGui) {

    Controls := []

    For Hwnd, GuiCtrlObj in MyGui {

        ;MsgBox "Control Class #" A_Index ": " GuiCtrlObj.ClassNN ", Text: " GuiCtrlObj.Text

        If (SubStr(GuiCtrlObj.ClassNN, 1, 6) = "Button") {
            Controls.Push(GuiCtrlObj)
        }

    }

    ; Now, ButtonControls array contains all button control objects
    ; You can iterate through this array to access each button
    For control in Controls {
        MsgBox "Found button: " control.Text ", Index: " A_Index
    }
}
; #region Tests

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    __DoTests_GuiControlMove()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

#SingleInstance Force

__DoTests_GuiControlMove() {

    ; comment to skip, comment out to run tests
    ;SoundBeep(), ExitApp()

    ; comment out tests to skip:
    ;Test1()
    ;Test2()
    ;Test3()
    ;Test4()
    Test5()

    ; test methods

    Test1() {
        global MyGui, MyEdit, MyButtonCancel, MyButtonMove

        ; Open the Gui, press [Move], resize the Gui, note the Cancel button moved to the right side of the Gui.
        
        MyGui := Gui("+Resize","My Test Gui") ;"+Resize"
        MyGui.SetFont("s12")

        ; Add an Edit control to the GUI. Give it a name for easy referencing.
        MyEdit := MyGui.Add("Edit", "w400 h100")
        MyButtonCancel := MyGui.Add("Button", "w100", "Cancel")
        MyButtonMove := MyGui.Add("Button", "yp w100", "Move")

        ; Register events
        ;MyGui.OnEvent("Size", GuiSize)
        MyButtonMove.OnEvent("Click", OnButtonMove_Click)
        MyButtonCancel.OnEvent("Click", (*) => ExitApp())

        ; Show the GUI.
        MyGui.Show()

        OnButtonMove_Click(*) {
            MyGui.OnEvent("Size", GuiSize)
        }

        DoNothing(*) {
        }

    }
    Test2() {
        global MyGui, MyEdit, MyButtonCancel, MyButtonMove

        ; Create the GUI, resizing not needed as we are just moving a control
        MyGui := Gui() ;"+Resize"
        MyGui.SetFont("s11")

        ; Add an Edit control to the GUI. Give it a name for easy referencing.
        MyEdit := MyGui.Add("Edit", "w400 h100")
        MyButtonCancel := MyGui.Add("Button", "xp w100", "Cancel")
        MyButtonMove := MyGui.Add("Button", "yp w100", "Move")

        ; Register events
        MyGui.OnEvent("Size", GuiSize)
        MyButtonMove.OnEvent("Click", OnButtonMove_Click)
        MyButtonCancel.OnEvent("Click", (*) => ExitApp())

        ; Show the GUI.
        MyGui.Show()

        MyEdit.Text .= "Note the Cancel button moved to the right side of the Gui.`r`n"

        OnButtonMove_Click(*) {
            MyEdit.Text .= "Not Implemented.`r`n"
        }
    }
    Test3() {
        global MyGui, MyEdit, MyButtonCancel, MyButtonMove

        ; Create the GUI, resizing not needed as we are just moving a control

        MyGui := Gui() ;"+Resize"
        MyGui.SetFont("s11")

        ; Add an Edit control to the GUI. Give it a name for easy referencing.
        MyEdit := MyGui.Add("Edit", "w1 h100")
        MyButtonCancel := MyGui.Add("Button", "xp w100", "Cancel")
        MyButtonMove := MyGui.Add("Button", "yp w100", "Move")

        ; Register events
        MyButtonMove.OnEvent("Click", OnButtonMove_Click)
        MyButtonCancel.OnEvent("Click", (*) => ExitApp())

        ; Show the GUI.
        MyGui.Show()


        OnButtonMove_Click(*) {
            CtrlMove_OLD(MyGui, MyButtonCancel)
            MyEdit.Text .= "Note the Cancel button moved to the right side of the Gui.`r`n"
        }



    }

    Test4() {
        global MyGui, MyEdit, MyButtonCancel, MyButtonMove

        ; Create the GUI, resizing not needed as we are just moving a control

        MyGui := Gui() ;"+Resize"
        MyGui.SetFont("s11")

        ; Add an Edit control to the GUI. Give it a name for easy referencing.
        ;MyEdit := MyGui.Add("Edit", "w10 h100")
        MyText := MyGui.AddText("w10 h100 Border vMyText")

        MyButtonY := MyGui.Add("Button", "xm w100 Default", "Yes").OnEvent("Click", OnButtonMove_Click)
        MyButtonN := MyGui.Add("Button", "yp w100", "No")
        MyButtonA := MyGui.Add("Button", "yp w100", "All")
        MyButtonCancel := MyGui.Add("Button", "yp w100", "Cancel").OnEvent("Click", (*) => ExitApp())
 
        ; Register events

        ; Show the GUI.
        MyGui.Show("W800 H400")

        ;MsgBox("MyGui: " MyGui["Yes"].Text)


        ;ListControls(MyGui)

        OnButtonMove_Click(*) {

            CtrlFillWidth(MyGui, MyText) 

            ;CtrlFlow(MyGui, MyButtonCancel)
            ;CtrlFlow(MyGui, [MyButtonY, MyButtonN, MyButtonA, MyButtonCancel], "RightLeft")
            CtrlFlow(MyGui, [MyGui["Yes"], MyGui["No"], MyGui["All"], MyGui["Cancel"]], "LeftRight")

            ;CtrlMove_OLD(MyGui, MyButtonCancel)
            ;MyEdit.Text .= "Note the Cancel button moved to the right side of the Gui.`r`n"
        }



    }

    Test5() {

        MyGui := Gui(,"My Test Gui")
        MyGui.OnEvent("Size", GuiSize)
        ;MyGui.SetFont("s11")

        MyText := MyGui.AddText("w400 h200 Border", "YPOS")

        ;MyButtonMove := MyGui.Add("Button", "xm w100", "Move")
        ;MyButtonCancel := MyGui.Add("Button", "yp w100 Default", "Cancel").OnEvent("Click", (*) => ExitApp())

 
        MyGui.Show()

        GuiSize(*) {

            X_Margin := MyGui.MarginX
            Y_Margin := MyGui.MarginY

            WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

            WinGetClientPos , , &OutClientWidth, &OutClientHeight, MyGui

            ; MsgBox(
            ;     "W: " OutWidth . ", H: " OutHeight "`n`nClientW: " OutClientWidth ", ClientH: " OutClientHeight "`n`n"
            ;     "xM: " MyGui.MarginX . ", yM: " MyGui.MarginY)


            MyText.GetPos(&X, &Y, &W, &H)

            ;Move Top of Control to Top Left of Client Area
            MyText.Move(0, 0)
            Sleep(1000)

            MyText.Move(X_Margin, 0)
            Sleep(1000)

            ;Move Top of Control to Top Rigt of Client Area
            MyText.Move( OutClientWidth - W)
            Sleep(1000)

            MyText.Move( OutClientWidth - X_Margin - W)
            Sleep(1000)

            ;Move Bottom of Control to Bottom Right of Client Area
            MyText.Text := "Move Bottom of Control to Bottom Right of Client Area"
            MyText.Move(OutClientWidth - W, OutClientHeight - H)
            Sleep(1000)

            ;MyText.Move(OutClientWidth - X_Margin - W, OutClientHeight - Y_Margin - H)
            MyText.Move(OutClientWidth - W, OutClientHeight - H - Y_Margin)
            Sleep(1000)

            ;Move Bottom of Control to Bottom Left of Client Area
            MyText.Text := "Move Bottom of Control to Bottom Left of Client Area"
            MyText.Move(0, OutClientHeight - H)
            Sleep(1000)

            MyText.Move(0, OutClientHeight - H - Y_Margin)
            Sleep(1000)

    }
}
}