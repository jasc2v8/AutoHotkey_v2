; Version: 2.3.6
#Requires AutoHotkey v2+

/**
 * Anchor() - Positions and resizes controls. Now accepts bulk input.
 * @param Params - Accepts single controls, Arrays of controls, or multiple arguments.
 * Usage: Anchor([LV1, LV2], "wh", MyBtn, "xy", [Edit1, Edit2], "w")
 */
Anchor(Params*) {
    static controls := Map()
    Anchor.Storage := controls

    ; Loop through parameters in pairs (Control/Array, AnchorString)
    Loop Params.Length // 2 {
        Target := Params[A_Index * 2 - 1]
        a      := Params[A_Index * 2]
        
        if (Target is Array) {
            if (Target.Length = 0)
                continue
            
            hDWP := DllCall("user32\BeginDeferWindowPos", "Int", Target.Length, "Ptr")
            for ctrl in Target
                hDWP := Anchor_Process(ctrl, a, controls, hDWP)
            DllCall("user32\EndDeferWindowPos", "Ptr", hDWP)
        } else {
            Anchor_Process(Target, a, controls)
        }
    }
}

Anchor_Process(CtrlObj, a, controls, hDWP := 0) {
    try
        CtrlObj.Gui.GetClientPos(,, &gw, &gh)
    catch
        return hDWP

    if !controls.Has(CtrlObj) {
        if (gw = 0 || gh = 0)
            return hDWP
        CtrlObj.GetPos(&x, &y, &w, &h)
        controls[CtrlObj] := {x:x, y:y, w:w, h:h, gw:gw, gh:gh}
        return hDWP
    }

    info := controls[CtrlObj]
    dx := gw - info.gw, dy := gh - info.gh
    
    nx := info.x + (InStr(a, "x") ? dx : 0)
    ny := info.y + (InStr(a, "y") ? dy : 0)
    nw := info.w + (InStr(a, "w") ? dx : 0)
    nh := info.h + (InStr(a, "h") ? dy : 0)

    ; Direct Move() for types that fight DeferWindowPos (ListView, TreeView)
    bypass := InStr(CtrlObj.Type, "ListView") || InStr(CtrlObj.Type, "TreeView")

    if (hDWP && !bypass) {
        return DllCall("user32\DeferWindowPos", "Ptr", hDWP, "Ptr", CtrlObj.Hwnd, "Ptr", 0, "Int", nx, "Int", ny, "Int", nw, "Int", nh, "UInt", 0x0014, "Ptr")
    } else {
        CtrlObj.Move(nx, ny, nw, nh)
        return hDWP
    }
}

Anchor_Reset(CtrlObj := "All") {
    if !HasProp(Anchor, "Storage")
        return
    if (CtrlObj = "All")
        Anchor.Storage.Clear()
    else if (CtrlObj is Array) {
        for ctrl in CtrlObj
            if Anchor.Storage.Has(ctrl)
                Anchor.Storage.Delete(ctrl)
    } else if (IsObject(CtrlObj)) {
        if Anchor.Storage.Has(CtrlObj)
            Anchor.Storage.Delete(CtrlObj)
    }
}