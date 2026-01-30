; Version: 2.1.5
; Based on Titan's original Anchor, updated for AHK v2
Anchor(ctrl, anchorString, redraw := false) {
    
    static controls := Map()
    
    ; Get control position
    try {
        ctrl.Gui.GetPos(&gX, &gY, &gW, &gH)
        ctrl.GetPos(&cX, &cY, &cW, &cH)
    } catch {
        return
    }

    if !controls.Has(ctrl.Hwnd) {
        controls[ctrl.Hwnd] := {x: cX, y: cY, w: cW, h: cH, gw: gW, gh: gH}
    }

    data := controls[ctrl.Hwnd]
    newX := data.x, newY := data.y, newW := data.w, newH := data.h
    
    ; Parse anchor string (e.g., "xyw0.5h")
    for , char in ["x", "y", "w", "h"] {
        if RegExMatch(anchorString, "i)" char "(?<factor>[\d\.]+)?", &match) {
            factor := match.factor = "" ? 1 : Float(match.factor)
            delta := (char ~= "i)x|w") ? (gW - data.gw) : (gH - data.gh)
            
            if (char = "x")
                newX := data.x + (delta * factor)
            else if (char = "y")
                newY := data.y + (delta * factor)
            else if (char = "w")
                newW := data.w + (delta * factor)
            else if (char = "h")
                newH := data.h + (delta * factor)
        }
    }

    if (redraw) {
        DllCall("SendMessage", "ptr", ctrl.Hwnd, "uint", 0x0B, "ptr", 0, "ptr", 0)
    }

    ctrl.Move(newX, newY, newW, newH)

    if (redraw) {
        DllCall("SendMessage", "ptr", ctrl.Hwnd, "uint", 0x0B, "ptr", 1, "ptr", 0)
        ctrl.Redraw()
    }
}