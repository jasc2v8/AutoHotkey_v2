
#Requires AutoHotkey v2+
#SingleInstance force

#Include Anchor.ahk

MyGui := Gui("+Resize", "Tab & ListView Anchor v2.2.6")
MyGui.SetFont("s10", "Segoe UI")

; 1. Add Search box
MyEdit := MyGui.Add("Edit", "w400", "Search...")

; 2. Add Tab3 Control
MyTabs := MyGui.Add("Tab3", "w400 h300", ["General", "Settings"])

; 3. Add ListView to Tab 1
MyTabs.UseTab(1)
LV1 := MyGui.Add("ListView", "r10 w380", ["Item Name", "Value"])
Loop 5
    LV1.Add("", "General Item " A_Index, Random(1, 100))

; 4. Add ListView to Tab 2
MyTabs.UseTab(2)
LV2 := MyGui.Add("ListView", "r10 w380", ["Setting", "Status"])
Loop 5
    LV2.Add("", "Setting " A_Index, "Enabled")

MyTabs.UseTab() ; Exit Tab context

; 5. Add Bottom Buttons
BtnClose := MyGui.Add("Button", "w80", "Close")

MyGui.OnEvent("Size", OnGui_Size)
MyGui.Show()

OnGui_Size(GuiObj, MinMax, Width, Height) {
    if (MinMax = -1)
        return

    ; Expand Edit across top
    Anchor(MyEdit, "w")

    ; Expand Tab control to fill window
    Anchor(MyTabs, "wh")

    ; Expand BOTH ListViews to fill the Tab area
    ; We use an Array here to trigger the flicker-free DeferWindowPos
    Anchor([LV1, LV2], "wh")

    ; Pin button to bottom-left
    Anchor(BtnClose, "y")
}