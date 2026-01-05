
#Requires AutoHotkey v2.0+

    GetGuiAndClientPos(aGui) {

        WinGetPos(,, &GuiWidth, &GuiHeight, aGui.Hwnd)

        aGui.GetclientPos(,, &clientWidth, &clientHeight)

        BorderX := (GuiWidth - clientWidth) // 2    ; 8
        BorderY := BorderX
        BorderW := BorderX
        BorderH := BorderX

        clientTop       :=0 ; always
        clientLeft      :=0 ; always
        clientBottom    := clientHeight - BorderH
        clientRight     := borderW + clientWidth
        clientRightAlt  := GuiWidth - BorderX

        clientMaxW := clientWidth - borderW - borderW
        clientMaxH := clientHeight - borderH

        nop:=true

        return { 
            GuiWidth: GuiWidth,
            GuiHeight: GuiHeight,

            clientWidth: clientWidth,
            clientHeight: clientHeight,

            clientMaxW: clientMaxW,
            clientMaxH: clientMaxH,

            clientTop: clientTop,
            clientLeft: clientLeft,
            clientBottom: clientBottom,
            clientRight: clientRight,
            clientRightAlt: clientRightAlt,



            BorderX: BorderX,
            BorderY: BorderY,
            BorderW: BorderW,
            BorderH: BorderH,
        }
    }

    GetMetrics(GuiObj) {

        ;RECT for Gui
        GuiRect := Buffer(16, 0)
        DllCall("GetWindowRect", "ptr", GuiObj.hwnd, "ptr", GuiRect.Ptr)
        Guileft   := NumGet(GuiRect, 0, "int")
        Guitop    := NumGet(GuiRect, 4, "int")
        Guiright  := NumGet(GuiRect, 8, "int")
        Guibottom := NumGet(GuiRect, 12, "int")

        GuiW := Guiright - Guileft
        GuiH := Guibottom - Guitop

        ; RECT for Client area
        clientRect := Buffer(16, 0)
        DllCall("GetClientRect", "ptr", GuiObj.hwnd, "ptr", clientRect.Ptr)

        clientleft   := NumGet(clientRect, 0, "int")
        clienttop    := NumGet(clientRect, 4, "int")
        clientright  := NumGet(clientRect, 8, "int")
        clientbottom := NumGet(clientRect, 12, "int")

        clientW := clientright - clientleft
        clientH := clientbottom - clienttop

        ; Get border metrics
        borderX := DllCall("GetSystemMetrics", "int", 32, "int") ; SM_CXFRAME
        borderY := DllCall("GetSystemMetrics", "int", 33, "int") ; SM_CYFRAME
        captionH := DllCall("GetSystemMetrics", "int", 4, "int")  ; SM_CYCAPTION

        ; Calculate actual differences
        borderWidth := (GuiW - clientW) // 2
        borderHeight := (GuiH - clientH - captionH) // 2

        clientBottom := clientH - borderY

        ;TODO: FIX THIS
        clientRight := clientW - borderX*5

        return {
            GuiWidth: GuiW,
            GuiHeight: GuiH,
            ClientWidth: clientW,
            ClientHeight: clientH,
            ClientW: clientW,
            ClientH: clientH,
            ClientLeft: clientleft,
            ClientTop: clienttop,
            ClientRight: clientright,
            ClientBottom: clientbottom,
            ClientL: clientleft,
            ClientT: clienttop,
            ClientR: clientright,
            ClientB: clientbottom,
            BorderWidth: borderWidth,
            BorderHeight: borderHeight,
            BorderW: borderWidth,
            BorderH: borderHeight,
            CaptionHeight: captionH,
            TotalNonClientHeight: GuiH - clientH
        }

    }

; If run directly, execute the following block of code
If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    MyFunction__Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

#SingleInstance Force
#Warn Unreachable, Off
#esc::ExitApp

MyFunction__Tests() {

    ; comment to skip, comment out to run tests
    ;SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    ;Test2()
    ;Test3()

    Test1() {
        MyGui := Gui("+Resize")
        MyGui.OnEvent("Size", Gui_Size)
        MyGui.OnEvent("Escape", (*) => ExitApp())
        MyGui.SetFont("s10")
        ;MyGui.Opt("-DPIScale") ; no change with or without

        MyGui.AddText("w50 BackgroundYellow vText", "")
        MyGui.AddButton("Default", "OK").OnEvent("Click", OnButton_Click)
        MyGui.Show("w600 h300")

;        ControlFocus(MyGui["Yes"])

        ; #region Functions
       
        OnButton_Click(*) {

        }

        Gui_Size(GuiObj, MinMax, Width, Height) {

            ; If minimized, skip
            If (MinMax = -1)
                return

            ; LOCK the window (Stop all redrawing)
            DllCall("LockWindowUpdate", "UInt", GuiObj.Hwnd)

            try {

                pos := GetGuiAndClientPos(MyGui)

                MyGui["Text"].Move(,,pos.ClientRight -75)

                dim := GetMetrics(MyGui)

                MyGui["OK"].Move(dim.ClientLeft+150)

            } finally {

                ; Unlock Window. Always call this, even if an error occurs!
                DllCall("LockWindowUpdate", "UInt", 0)
                
                ; Force a repaint (optional, but ensures the new layout is drawn immediately)
                WinRedraw(GuiObj)
            }
        }
    }
}
