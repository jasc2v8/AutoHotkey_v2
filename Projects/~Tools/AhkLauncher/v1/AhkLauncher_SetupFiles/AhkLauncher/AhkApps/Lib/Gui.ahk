;ABOUT: GuiControlMove WORKS!
;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921

#Requires AutoHotkey v2.0+

#Include <CustomMsgBox> ; for debugging

;-------------------------------------------------------------------------------
; TODO   :  See GuiResizerLite.ahk: controls[btn1, btn2, btn3]
; Summary:  Moves Gui Controls without requiring the Gui to be redrawn.
; Returns:  The Gui control moved.
; Library:  Gui.ahk
CtrlMove(MyGui, MyCtrl, xGuiRight:=0, xGuiTop:=0) {

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
    MyCtrl.GetPos(&X, &Y, &bWidth, &bHeight)
    MyCtrl.Move(wGui-bWidth-xmGui*2.5,,,)

    ;DEBUG-----------------------------------------------------
    ;MsgBoxList(,"wGui", wGui, "bWidth", bWidth, "xmGui", xmGui)
    OutputDebug("wGui: " wGui ", bWidth: " bWidth ", xmGui: " xmGui ", MATH: " wGui-bWidth-xmGui)
    OutputDebug("OutWidth: " OutWidth ", bWidth: " bWidth ", xmGui: " xmGui ", MATH: " wGui-bWidth-xmGui)

    ; if buttons different width, need to compensate
    ;MyButtonCancel.GetPos(&X, &Y, &bWidth, &bHeight)
    ;MyButtonMove.Move(wGui-(bWidth*2)-xmGui,,,)

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
; #region Tests

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    __DoTests_GuiControlMove()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

#SingleInstance Force

__DoTests_GuiControlMove() {

    Run_Tests := true ; false

    if !Run_Tests
        SoundBeep(), ExitApp()

    ; comment out tests to skip:
    ;Test1()
    ;Test2()
    Test3()

    ; test methods

    Test1() {
        global MyGui, MyEdit, MyButtonCancel, MyButtonMove

        ; Create the GUI, resizing not needed as we are just moving a control
        MyGui := Gui() ;"+Resize"
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

            ; not exist MyGui.Redraw()

            ; no WinRedraw(MyGui.Hwnd)
            ; yes but very noticable
            ; no effect SetWinDelay -1
            WinMinimize(MyGui)
            WinRestore(MyGui)
            ; no effect SetWinDelay 100

            ; NO hide/show
            ;MyGui.Hide()
            ;MyGui.Show()

            ; WinMove
            ; NO:
            ; X_Margin := MyGui.MarginX
            ; Y_Margin := MyGui.MarginY
            ; WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui
            ; WinMove(OutX+10, OutY+10, OutWidth, OutHeight,MyGui)
            
            
            ;MyGui.OnEvent("Size", DoNothing)

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
        MyGui := Gui("+AlwaysOnTop") ;"+Resize"
        MyGui.SetFont("s11")

        ; Add an Edit control to the GUI. Give it a name for easy referencing.
        MyEdit := MyGui.Add("Edit", "w400 h100")
        MyButtonCancel := MyGui.Add("Button", "xp w100", "Cancel")
        MyButtonMove := MyGui.Add("Button", "yp w100", "Move")

        ; Register events
        ;MyGui.OnEvent("Size", GuiSize)
        MyButtonMove.OnEvent("Click", OnButtonMove_Click)
        MyButtonCancel.OnEvent("Click", (*) => ExitApp())

        ; Show the GUI.
        MyGui.Show()

        MyEdit.Text .= "Press the Move button to move the Cancel button to the right side of the Gui.`r`n"

        OnButtonMove_Click(*) {
            ;MyEdit.Text .= "Not Implemented.`r`n"

            CtrlMove(MyGui, MyButtonCancel)

        }



    }
}