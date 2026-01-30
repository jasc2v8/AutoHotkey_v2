; Version: 2.1.5
#Requires AutoHotkey v2+

/**
 * Anchor() - Positions and resizes controls.
 * @param CtrlObj {Gui.Control|Array} A single control object or an Array of control objects.
 * @param a {String} Anchor string: "x", "y", "w", "h".
 * @param r {Boolean} Whether to redraw (default false).
 */
Anchor(CtrlObj, a := "", r := false) {
    static controls := Map()
    
    ; Export map for Reset function
    Anchor.Storage := controls

    if (CtrlObj is Array) {
        for ctrl in CtrlObj {
            Anchor(ctrl, a, r)
        }
        return
    }

    try {
        CtrlObj.Gui.GetClientPos(,, &gw, &gh)
    } catch {
        return
    }

    ; If not tracked, record current state and original GUI size
    if !controls.Has(CtrlObj) {
        if (gw = 0 || gh = 0)
            return
            
        CtrlObj.GetPos(&x, &y, &w, &h)
        controls[CtrlObj] := {x:x, y:y, w:w, h:h, gw:gw, gh:gh}
        return
    }

    info := controls[CtrlObj]
    dx := gw - info.gw
    dy := gh - info.gh
    
    nx := info.x + (InStr(a, "x") ? dx : 0)
    ny := info.y + (InStr(a, "y") ? dy : 0)
    nw := info.w + (InStr(a, "w") ? dx : 0)
    nh := info.h + (InStr(a, "h") ? dy : 0)

    CtrlObj.Move(nx, ny, nw, nh)
    
    if (r) {
        DllCall("InvalidateRect", "Ptr", CtrlObj.Hwnd, "Ptr", 0, "Int", 1)
    }
}

/**
 * Anchor_Reset() - Clears saved positions for specific controls or all controls.
 * @param CtrlObj {Gui.Control|Array|String} Control(s) to reset. If "All", clears everything.
 */
Anchor_Reset(CtrlObj := "All") {
    if !HasProp(Anchor, "Storage")
        return

    if (CtrlObj = "All") {
        Anchor.Storage.Clear()
    } else if (CtrlObj is Array) {
        for ctrl in CtrlObj {
            if Anchor.Storage.Has(ctrl)
                Anchor.Storage.Delete(ctrl)
        }
    } else if (IsObject(CtrlObj)) {
        if Anchor.Storage.Has(CtrlObj)
            Anchor.Storage.Delete(CtrlObj)
    }
}

; --- Example Implementation ---

; MyGui := Gui("+Resize", "Anchor v2.1.4")
; MyGui.SetFont("s10", "Segoe UI")

; MainEdit := MyGui.Add("Edit", "w300 h200")
; Btn1 := MyGui.Add("Button", "x160 y210 w60", "Save")
; Btn2 := MyGui.Add("Button", "x230 y210 w60", "Reset Pos")

; ; Setup the event
; MyGui.OnEvent("Size", MyGui_Size)
; Btn2.OnEvent("Click", (*) => Anchor_Reset("All"))

; MyGui.Show()

; MyGui_Size(GuiObj, MinMax, Width, Height) {
;     if (MinMax = -1)
;     return
    
;     Anchor(MainEdit, "wh", true)
;     Anchor([Btn1, Btn2], "xy")
; }