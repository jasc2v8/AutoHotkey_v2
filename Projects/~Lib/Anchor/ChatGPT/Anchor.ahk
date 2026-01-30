class Anchor {

    __New(gui) {
        this.gui   := gui
        this.items := Map()
        this.lastW := 0
        this.lastH := 0

        ; Only handle resizing
        gui.OnEvent("Size", ObjBindMethod(this, "OnSize"))
    }

    ; ----------------------------
    ; Add one control or array of controls
    ; ----------------------------
    Add(ctrl, options := "w h") {
        if (Type(ctrl) = "Array")  ; array/list of controls
            for index, c in ctrl
                this._AddSingle(c, options)
        else
            this._AddSingle(ctrl, options)
    }

    _AddSingle(ctrl, options) {
        ctrl.GetPos(&x, &y, &w, &h)
        this.items[ctrl.Hwnd] := {
            hwnd: ctrl.Hwnd,
            ctrl: ctrl,
            opt: options,
            x: x, y: y, w: w, h: h
        }
    }

    ; ----------------------------
    ; Resize handler
    ; ----------------------------
    OnSize(gui, minMax, width, height) {
        if (this.lastW = 0) {
            this.lastW := width
            this.lastH := height
            return
        }

        dx := width  - this.lastW
        dy := height - this.lastH

        count := this.items.Count
        if !count
            return

        hDWP := DllCall("BeginDeferWindowPos", "Int", count, "Ptr")

        for _, item in this.items {

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

            item.x := x
            item.y := y
            item.w := w
            item.h := h
        }

        DllCall("EndDeferWindowPos", "Ptr", hDWP)

        this.lastW := width
        this.lastH := height
    }

    ; ----------------------------
    ; Optional manual cleanup
    ; ----------------------------
    Destroy() {
        this.items.Clear()
        this.gui := ""
    }
}
