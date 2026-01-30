; Version: 2.2.1
#Requires AutoHotkey v2+

/**
 * Anchor() - Positions and resizes controls based on GUI resizing.
 * @param CtrlObj {Gui.Control|Array} A single control object or an Array of control objects.
 * @param a {String} Anchor string: "x", "y", "w", "h".
 * @param r {Boolean} Whether to redraw via InvalidateRect (default false).
 */
Anchor(CtrlObj, a := "", r := false) {
    static controls := Map()
    
    ; Export map for Reset function
    Anchor.Storage := controls

    ; Handle Array input with DeferWindowPos for maximum flicker prevention
    if (CtrlObj is Array) {
        if (CtrlObj.Length = 0)
            return
            
        ; Initialize the defer structure for the number of controls in the array
        hDWP := DllCall("user32\BeginDeferWindowPos", "Int", CtrlObj.Length, "Ptr")
        
        for ctrl in CtrlObj {
            ; We call the logic for each, but we'll need to pass the hDWP handle
            hDWP := Anchor_Process(ctrl, a, controls, hDWP)
        }
        
        ; Commit all moves at once
        DllCall("user32\EndDeferWindowPos", "Ptr", hDWP)
        return
    }

    ; Handle single control (fallback to standard Move)
    Anchor_Process(CtrlObj, a, controls)
    
    if (r) {
        DllCall("user32\InvalidateRect", "Ptr", CtrlObj.Hwnd, "Ptr", 0, "Int", 1)
    }
}

/**
 * Internal processing function to calculate coordinates and handle DeferWindowPos logic.
 */
Anchor_Process(CtrlObj, a, controls, hDWP := 0) {
    try {
        CtrlObj.Gui.GetClientPos(,, &gw, &gh)
    } catch {
        return hDWP
    }

    if !controls.Has(CtrlObj) {
        if (gw = 0 || gh = 0)
            return hDWP
            
        CtrlObj.GetPos(&x, &y, &w, &h)
        controls[CtrlObj] := {x:x, y:y, w:w, h:h, gw:gw, gh:gh}
        return hDWP
    }

    info := controls[CtrlObj]
    dx := gw - info.gw
    dy := gh - info.gh
    
    nx := info.x + (InStr(a, "x") ? dx : 0)
    ny := info.y + (InStr(a, "y") ? dy : 0)
    nw := info.w + (InStr(a, "w") ? dx : 0)
    nh := info.h + (InStr(a, "h") ? dy : 0)

    if (hDWP) {
        ; SWP_NOZORDER (0x0004) | SWP_NOACTIVATE (0x0010)
        return DllCall("user32\DeferWindowPos", "Ptr", hDWP, "Ptr", CtrlObj.Hwnd, "Ptr", 0, "Int", nx, "Int", ny, "Int", nw, "Int", nh, "UInt", 0x0014, "Ptr")
    } else {
        CtrlObj.Move(nx, ny, nw, nh)
        return 0
    }
}

/**
 * Anchor_Reset() - Clears saved positions for specific controls or all controls.
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

; MyGui := Gui("+Resize", "Anchor v2.2.1")
; MainEdit := MyGui.Add("Edit", "w300 h200")
; Btn1 := MyGui.Add("Button", "x160 y210 w60", "Save")
; Btn2 := MyGui.Add("Button", "x230 y210 w60", "Exit")

; MyGui.OnEvent("Size", MyGui_Size)
; MyGui.Show()

; MyGui_Size(GuiObj, MinMax, Width, Height) {
;     if (MinMax = -1)
;     return
    
;     ; Passing all controls in one array maximizes the benefit of DeferWindowPos
;     Anchor([MainEdit], "wh")
;     Anchor([Btn1, Btn2], "xy")
; }