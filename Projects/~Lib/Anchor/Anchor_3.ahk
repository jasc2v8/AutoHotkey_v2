; Version: 2.0.5
#Requires AutoHotkey v2.0

/**
 * Anchor() - Positions and resizes controls based on GUI size changes.
 * @param CtrlObj {Gui.Control|Array} A single control object or an Array of control objects.
 * @param a {String} Anchor string: "x", "y", "w", "h" (can be combined like "xywh").
 * @param r {Boolean} Whether to redraw the control (default false).
 */
Anchor(CtrlObj, a := "", r := false) {
    static controls := []
    
    ; Handle Arrays for grouping
    if (CtrlObj is Array) {
        for ctrl in CtrlObj {
            Anchor(ctrl, a, r)
        }
        return
    }

    ; Logic for individual control
    try {
        CtrlObj.Gui.GetClientPos(,, &gw, &gh)
    } catch {
        return
    }

    ; Search for existing control data in the Array
    foundInfo := ""
    for index, info in controls {
        if (info.ptr = CtrlObj.Hwnd) {
            foundInfo := info
            break
        }
    }

    ; If not found, register the control and STOP (don't move it yet)
    if (foundInfo = "") {
        CtrlObj.GetPos(&x, &y, &w, &h)
        controls.Push({ptr: CtrlObj.Hwnd, x:x, y:y, w:w, h:h, gw:gw, gh:gh})
        return
    }

    ; Calculate change relative to the GUI size when the control was registered
    dx := gw - foundInfo.gw
    dy := gh - foundInfo.gh
    
    nx := foundInfo.x + (InStr(a, "x") ? dx : 0)
    ny := foundInfo.y + (InStr(a, "y") ? dy : 0)
    nw := foundInfo.w + (InStr(a, "w") ? dx : 0)
    nh := foundInfo.h + (InStr(a, "h") ? dy : 0)

    CtrlObj.Move(nx, ny, nw, nh)
    
    if (r) {
        ; Use DllCall since Gui.Redraw() does not exist
        DllCall("InvalidateRect", "Ptr", CtrlObj.Hwnd, "Ptr", 0, "Int", 1)
    }
}

;Anchor_Example()

; --- Example Implementation ---

Anchor_Example() {

    MyGui := Gui("+Resize", "Anchor v2.0.5")
    MyGui.SetFont("s10", "Segoe UI")

    MainEdit := MyGui.Add("Edit", "w300 h200")
    Btn1 := MyGui.Add("Button", "x160 y210 w60", "Save")
    Btn2 := MyGui.Add("Button", "x230 y210 w60", "Cancel")
    Btn2.OnEvent("Click", (*) => ExitApp())

    BtnGroup := [Btn1, Btn2]

    ; IMPORTANT: Show the GUI first so GetClientPos returns correct values
    MyGui.Show()

    ; Now initialize the Anchor positions
    ;Anchor(MainEdit)
    ;Anchor(BtnGroup)

    MyGui.OnEvent("Size", MyGui_Size)

    MyGui_Size(GuiObj, MinMax, Width, Height) {
        if (MinMax = -1)
        return
        
        Anchor(MainEdit, "wh", true)
        Anchor(BtnGroup, "xy")
    }
}

