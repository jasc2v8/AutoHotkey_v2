class Anchor {
    static items := Map()
    static gui := unset
    static init := false

    static Add(ctrl, options := "w h") {
        if !Anchor.init {
            Anchor.gui := ctrl.Gui
            Anchor.gui.OnEvent("Size", ObjBindMethod(Anchor, "OnSize"))
            Anchor.init := true
        }

        ctrl.GetPos(&x, &y, &w, &h)
        Anchor.items[ctrl.Hwnd] := {
            hwnd: ctrl.Hwnd,
            opt: options,
            x: x, y: y, w: w, h: h
        }
    }

    static OnSize(gui, minMax, width, height) {
        static lastW := 0, lastH := 0

        if (lastW = 0) {
            lastW := width
            lastH := height
            return
        }

        dx := width  - lastW
        dy := height - lastH

        count := Anchor.items.Count
        if !count
            return

        hDWP := DllCall("BeginDeferWindowPos", "Int", count, "Ptr")

        for _, item in Anchor.items {
            x := item.x
            y := item.y
            w := item.w
            h := item.h

            if InStr(item.opt, "x")
                x += dx
            if InStr(item.opt, "y")
                y += dy
            if InStr(item.opt, "w")
                w += dx
            if InStr(item.opt, "h")
                h += dy

            hDWP := DllCall(
                "DeferWindowPos",
                "Ptr", hDWP,
                "Ptr", item.hwnd,
                "Ptr", 0,
                "Int", x,
                "Int", y,
                "Int", w,
                "Int", h,
                "UInt", 0x0010, ; SWP_NOZORDER
                "Ptr"
            )

            ; ✅ COMMIT new geometry
            item.x := x
            item.y := y
            item.w := w
            item.h := h
        }

        DllCall("EndDeferWindowPos", "Ptr", hDWP)

        lastW := width
        lastH := height
    }
}
