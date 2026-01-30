; ===============================
; Anchor.ahk — Per-GUI, no `new`, auto-cleanup
; Compatible with older AHK v2
; ===============================

class Anchor {

    __New(gui) {
        this.gui   := gui
        this.items := Map()
        this.lastW := 0
        this.lastH := 0

        gui.OnEvent("Size",    ObjBindMethod(this, "OnSize"))
        ;gui.OnEvent("Destroy", ObjBindMethod(this, "OnDestroy"))
    }

    ; ----------------------------
    ; Add a control to anchor
    ; options: "w", "h", "x", "y" combined
    ; ----------------------------
    Add(ctrl, options := "w h") {
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

            ; commit new geometry
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
    ; Auto cleanup on GUI destroy
    ; ----------------------------
    OnDestroy(*) {
        this.items.Clear()
        this.gui := ""
    }
}

; ----------------------------
; To instantiate (older v2 syntax)
; anchor := Anchor(grui)
; ----------------------------
