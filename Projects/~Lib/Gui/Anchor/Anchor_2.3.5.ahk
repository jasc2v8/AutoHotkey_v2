; Version: 2.3.5
#Requires AutoHotkey v2+

Anchor(CtrlObj, a := "", r := false) {
    static controls := Map()
    Anchor.Storage := controls

    if (CtrlObj is Array) {
        if (CtrlObj.Length = 0)
            return
        
        hDWP := DllCall("user32\BeginDeferWindowPos", "Int", CtrlObj.Length, "Ptr")
        for ctrl in CtrlObj
            hDWP := Anchor_Process(ctrl, a, controls, hDWP)
        DllCall("user32\EndDeferWindowPos", "Ptr", hDWP)
        return
    }

    Anchor_Process(CtrlObj, a, controls)
    if (r)
        DllCall("user32\InvalidateRect", "Ptr", CtrlObj.Hwnd, "Ptr", 0, "Int", 1)
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

    ; Controls that should bypass DeferWindowPos:
    ; 1. ListView/TreeView: Complex internal scrolling/drawing logic often fights DWP.
    ; 2. Custom/ActiveX: External engines (like webview) prefer direct Move() calls.
    bypass := InStr(CtrlObj.Type, "ListView") || InStr(CtrlObj.Type, "TreeView") || InStr(CtrlObj.Type, "ActiveX")

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