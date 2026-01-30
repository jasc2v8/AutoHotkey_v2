; Version 1.0.4
#Include Anchor.ahk
#SingleInstance Force

MyGui := Gui("+Resize", "Anchor v2 Example")
MyGui.Opt("+MinSize305x120 +MaxSize1240x680")
MyGui.SetFont("s10", "Segoe UI")

; Add a text box that stays anchored to the top/left
MyEdit := MyGui.Add("Edit", "w300 h150", "This box grows with the window.")

; Add a button that stays in the bottom right corner
MyBtn := MyGui.Add("Button", "x235 w80", "Close")
MyBtn.OnEvent("Click", (*) => MyGui.Destroy())


; Register the Size event
MyGui.OnEvent("Size", Gui_Size)
MyGui.Show()

Gui_Size(GuiObj, minMax, width, height) {
    ; Keep if/return on separate lines as per your preference
    if (minMax = -1)
        return

    ; Disable redraw to prevent flicker during batch move
    ;Anchor_SetRedraw(GuiObj, false)
    

    ; "wh" makes the edit grow in both directions
    Anchor(MyEdit, "wh")
    
    ; "xy" moves the button so it stays in the bottom-right
    Anchor(MyBtn, "xy")

    ; Re-enable redraw and force update
    ;Anchor_SetRedraw(GuiObj, true)
}