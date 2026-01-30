
#Requires AutoHotkey v2+
#SingleInstance force

#Include Anchor.ahk

Gui1 := Gui("+Resize")
Gui1.OnEvent("Size", OnGui_Size)

MyEdit := Gui1.Add("Edit", "w400")
; Tab3 is essential here
Tabs := Gui1.Add("Tab3", "w400 h300", ["Main", "Second"])

Tabs.UseTab(1)
; The 'y' of this ListView is determined by its position inside the Tab
LV1 := Gui1.Add("ListView", "w380 h250", ["Column 1", "Column 2"]) 

Tabs.UseTab(2)
; The 'y' of this ListView is determined by its position inside the Tab
LV2 := Gui1.Add("ListView", "w380 h250", ["Column A", "Column B"]) 

;Tabs.UseTab()

Gui1.Show()

OnGui_Size(GuiObj, MinMax, Width, Height) {
    if (MinMax = -1)
        return

    ; 1. Edit stays at top, only gets wider
    Anchor(MyEdit, "w")

    ; 2. Tab grows in both directions. 
    ; Its 'y' is fixed, so it stays below the Edit.
    Anchor(Tabs, "wh")

    ; 3. ListView grows in both directions.
    ; CRITICAL: No "y" in this string. 
    ; This keeps it at the exact top-left interior of the Tab.
    Anchor([LV1, LV2], "wh")
}