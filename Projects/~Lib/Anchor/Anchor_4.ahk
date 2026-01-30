; Version: 2.0.7
#Requires AutoHotkey v2.0

/**
 * Anchor() - Positions and resizes controls with DeferWindowPos for zero flicker.
 * @param CtrlObj {Gui.Control|Array} A single control object or an Array of control objects.
 * @param a {String} Anchor string: "x", "y", "w", "h".
 * @param r {Boolean} Whether to redraw (usually unnecessary with DeferWindowPos).
 */
Anchor(CtrlObj, a := "", r := false) {
    static controls := []
    
    ; Handle Arrays with Batching
    if (CtrlObj is Array) {
        ; Begin batch update
        hDWP := DllCall("BeginDeferWindowPos", "Int", CtrlObj.Length, "Ptr")
        for ctrl in CtrlObj {
            hDWP := Anchor_Process(ctrl, a, r, hDWP, controls)
        }
        DllCall("EndDeferWindowPos", "Ptr", hDWP)
        return
    }

    ; Handle Single Control
    hDWP := DllCall("BeginDeferWindowPos", "Int", 1, "Ptr")
    hDWP := Anchor_Process(CtrlObj, a, r, hDWP, controls)
    DllCall("EndDeferWindowPos", "Ptr", hDWP)
}

; Internal processing function to allow batching or single calls
Anchor_Process(Ctrl, a, r, hDWP, controls) {
    try {
        Ctrl.Gui.GetClientPos(,, &gw, &gh)
    } catch {
        return hDWP
    }

    foundInfo := ""
    for index, info in controls {
        if (info.ptr = Ctrl.Hwnd) {
            foundInfo := info
            break
        }
    }

    if (foundInfo = "") {
        Ctrl.GetPos(&x, &y, &w, &h)
        controls.Push({ptr: Ctrl.Hwnd, x:x, y:y, w:w, h:h, gw:gw, gh:gh})
        return hDWP
    }

    dx := gw - foundInfo.gw, dy := gh - foundInfo.gh
    nx := foundInfo.x + (InStr(a, "x") ? dx : 0)
    ny := foundInfo.y + (InStr(a, "y") ? dy : 0)
    nw := foundInfo.w + (InStr(a, "w") ? dx : 0)
    nh := foundInfo.h + (InStr(a, "h") ? dy : 0)

    ; SWP_NOZORDER (0x0004) | SWP_NOACTIVATE (0x0010)
    flags := 0x0004 | 0x0010 | (r ? 0 : 0x4000) ; 0x4000 = SWP_NOSENDCHANGING
    
    return DllCall("DeferWindowPos", "Ptr", hDWP, "Ptr", Ctrl.Hwnd, "Ptr", 0 
        , "Int", nx, "Int", ny, "Int", nw, "Int", nh, "UInt", flags, "Ptr")
}

; --- Example Implementation ---

MyGui := Gui("+Resize", "Anchor v2.0.7 - Zero Flicker")
MyGui.SetFont("s10", "Segoe UI")

MainEdit := MyGui.Add("Edit", "w300 h200")
Btn1 := MyGui.Add("Button", "x160 y210 w60", "Save")
Btn2 := MyGui.Add("Button", "x230 y210 w60", "Cancel")

BtnGroup := [Btn1, Btn2]

MyGui.Show()
Anchor(MainEdit)
Anchor(BtnGroup)

MyGui.OnEvent("Size", MyGui_Size)

MyGui_Size(GuiObj, MinMax, Width, Height) {
    if (MinMax = -1)
    return
    
    Critical("On")
    ; Batching the group reduces flicker significantly
    Anchor(MainEdit, "wh")
    Anchor(BtnGroup, "xy")
}