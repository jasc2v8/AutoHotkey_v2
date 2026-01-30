; Version: 2.0.1
#Requires AutoHotkey v2.0

/**
 * Anchor() - Positions and resizes controls based on GUI size changes.
 * @param Ctrl {Gui.Control} The control object to anchor.
 * @param a {String} Anchor string: "x", "y", "w", "h" (can be combined like "xywh").
 * @param r {Boolean} Whether to redraw the control (default false).
 */
Anchor(Ctrl, a := "", r := false) {
    static controls := Map()
    
    ; Get GUI's client area
    try {
        Ctrl.Gui.GetClientPos(,, &gw, &gh)
    } catch {
        return
    }

    if !controls.Has(Ctrl) {
        Ctrl.GetPos(&x, &y, &w, &h)
        controls[Ctrl] := {x:x, y:y, w:w, h:h, gw:gw, gh:gh}
        return
    }

    info := controls[Ctrl]
    dx := gw - info.gw
    dy := gh - info.gh
    
    nx := info.x + (InStr(a, "x") ? dx : 0)
    ny := info.y + (InStr(a, "y") ? dy : 0)
    nw := info.w + (InStr(a, "w") ? dx : 0)
    nh := info.h + (InStr(a, "h") ? dy : 0)

    ; Move the control using the control object method
    Ctrl.Move(nx, ny, nw, nh)
    
    if (r) {
        ; Use DllCall for flicker-free redrawing since Gui.Redraw() does not exist
        DllCall("InvalidateRect", "Ptr", Ctrl.Hwnd, "Ptr", 0, "Int", 1)
    }
}

; --- Example Implementation ---

; MyGui := Gui("+Resize", "Anchor v2 Example")
; MyGui.SetFont("s10", "Segoe UI")

; EditBox := MyGui.Add("Edit", "w300 h200", "Resize the window to see me move and grow.")
; BtnClose := MyGui.Add("Button", "x240 y220 w70", "Close")

; ; Initial setup of coordinates
; Anchor(EditBox)
; Anchor(BtnClose)

; MyGui.OnEvent("Size", MyGui_Size)
; MyGui.Show()

; MyGui_Size(GuiObj, MinMax, Width, Height) {
;     if (MinMax = -1)
;     return
    
;     Anchor(EditBox, "wh", true)
;     Anchor(BtnClose, "xy")
; }