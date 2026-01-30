; Version: 2.1.3
#Requires AutoHotkey v2.0

/**
 * Anchor() - Positions and resizes controls.
 * @param CtrlObj {Gui.Control|Array} A single control object or an Array of control objects.
 * @param a {String} Anchor string: "x", "y", "w", "h".
 * @param r {Boolean} Whether to redraw (default false).
 */
Anchor(CtrlObj, a := "", r := false) {
    static controls := Map() ; Using Map for more reliable object tracking
    
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

    ; Move using native v2 method
    CtrlObj.Move(nx, ny, nw, nh)
    
    if (r) {
        ; Use InvalidateRect for cleaner redraw
        DllCall("InvalidateRect", "Ptr", CtrlObj.Hwnd, "Ptr", 0, "Int", 1)
    }
}

; --- Testing Example ---

; MyGui := Gui("+Resize", "Anchor v2.1.3 - Testing")
; MyGui.SetFont("s10", "Segoe UI")

; MainEdit := MyGui.Add("Edit", "w300 h200", "If I don't move, something is very wrong.")
; Btn1 := MyGui.Add("Button", "x160 y210 w60", "Save")
; Btn2 := MyGui.Add("Button", "x230 y210 w60", "Cancel")

; ; Setup the event
; MyGui.OnEvent("Size", MyGui_Size)

; ; Show the GUI
; MyGui.Show()

; MyGui_Size(GuiObj, MinMax, Width, Height) {
;     if (MinMax = -1)
;     return
    
;     ; The first time this is called (on Show), it registers the positions.
;     ; On every drag, it updates them.
;     Anchor(MainEdit, "wh", true)
;     Anchor([Btn1, Btn2], "xy")
; }