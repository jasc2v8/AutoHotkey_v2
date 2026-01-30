
#Requires AutoHotkey v2+
#SingleInstance force

#Include Anchor.ahk

Gui1 := Gui("+Resize")
Gui1.OnEvent("Size", OnGui_Size)

; Give the Tab control a very specific starting Y
MyEdit := Gui1.Add("Edit", "x10 y10 w400")
Tabs   := Gui1.Add("Tab3", "x10 y45 w400 h300", ["Main", "Second"])

; Inside Tab 1
Tabs.UseTab(1)
; USE ABSOLUTE Y (The Tab header is ~25-30px, so 45 + 30 = 75)
LV1 := Gui1.Add("ListView", "x20 y80 w380 h250", ["Column 1"]) 

; Inside Tab 2
Tabs.UseTab(2)
; MATCH LV1 EXACTLY
LV2 := Gui1.Add("ListView", "x20 y80 w380 h250", ["Column A"]) 

Tabs.UseTab()
Gui1.Show()

OnGui_Size(GuiObj, MinMax, Width, Height) {
    if (MinMax = -1)
        return

    ; 1. Anchor ListViews FIRST. Only "wh".
    ; This explicitly tells AHK: "Keep x=20 and y=80, only change size."
    Anchor([LV1, LV2], "wh")

    ; 2. Anchor the Tab and Edit
    Anchor(MyEdit, "w")
    Anchor(Tabs, "wh")
}