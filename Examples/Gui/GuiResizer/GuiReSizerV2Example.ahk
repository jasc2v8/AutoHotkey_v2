;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=113921

#Include GuiReSizerv2.ahk

guiList := Gui(, "Test - List"), guiList.Opt("+Resize +MinSize250x150")
guiList.OnEvent("Size", GuiReSizer) ; assign GuiReSizer to handle all size changes for this Gui
guiList.Button := {} ; required because you are going to have Button sub definititions, ie. more than one Button
guiList.Button.One := guiList.Add("Button", "Default", "One")
guiList.Button.One.X := 10 ; 10 from Left Margin
guiList.Button.Two := guiList.Add("Button", "yp", "Two")
guiList.Button.Two.X := 20 ; 20 from Left Margin
guiList.Button.Two.XP := 0.2 ; 20% from Left Margin
guiList.Button.Three := guiList.Add("Button", "yp", "Three")
guiList.Button.Three.XP := -0.4 ; 40% from Right Margin
guiList.Button.Four := guiList.Add("Button", "yp", "Four")
guiList.Button.Four.X := -10 ; -10 from Right Margin
guiList.Button.Four.OriginXP := 1 ; OriginX is 100% of Width of control ie. Right Side

guiList.ListView := guiList.Add("ListView", "+Grid -Multi xm r20 w750", ["This", "That", "Other"])
guiList.ListView.Function := ListView_Columns ; Call Custom Function to Adjust Column Width
guiList.ListView.Width := -10 ; 10 from Left Margin
guiList.ListView.HeightP := -0.60 ; 60% from Bottom Margin
guiList.GroupBox := guiList.Add("GroupBox", , "Boxxie")
guiList.GroupBox.XP := 0.20 ; 20% from Left Margin
guiList.GroupBox.YP := 0.45 ; 45% from Top Margin
guiList.GroupBox.WidthP := -0.50 ; Right Edge maintain 50% from Right Margin
guiList.GroupBox.HeightP := -0.30 ; Bottom Edge maintain 30% from Bottom Margin
SimpleNameForEdit := guiList.Add("Edit", , "In the Box") ; do not need to use an Object structure for naming, 'guiList.Edit' would just be my preferred convention
; SimpleNameForEdit.OriginXP := 0.5 ; Origin to Center
; SimpleNameForEdit.OriginYP := 0.5 ; Origin to Middle
; SimpleNameForEdit.XP := 0.35 ; Boxxie center of .20 to .50
; SimpleNameForEdit.YP := 0.575 ; Boxxie middle of .45 to .70
; SimpleNameForEdit.Y := 3 ; Boxxie actual box is slightly off center due to Title text
GuiReSizer.Opt(SimpleNameForEdit, "oCM xp.35 yp.575 y3") ; use Options method to set position same as above

guiList.Button.TopLeft := guiList.Add("Button", "Default", "TopLeft")
guiList.Button.TopLeft.XP := 0.20 ; 20% from Left Margin
guiList.Button.TopLeft.YP := 0.70 ; 70% from Top Margin
guiList.Button.TopLeft.WidthP := 0.20 ; 20% Width of Gui Width
guiList.Button.TopLeft.Height := 20 ; 20 Height of Gui Height
guiList.Button.BottomLeft := guiList.Add("Button", "Default", "BottomLeft")
guiList.Button.BottomLeft.XP := 0.20 ; 20% Left Margin, Margin to OriginX of .5 (Middle)
guiList.Button.BottomLeft.YP := -0.02 ; 2% from Bottom Margin, OriginY which is set to 100% of height or bottom
guiList.Button.BottomLeft.OriginXP := 0.5 ; X Origin Adjust to 50% (Middle of Button)
guiList.Button.BottomLeft.OriginYP := 1 ; Origin of Button is Bottom Left
guiList.Button.BottomLeft.WidthP := 0.25 ; 25% Width of Gui Width
guiList.Button.BottomLeft.HeightP := 0.05 ; 5% Height of Gui Height
guiList.Button.BottomLeft.MinHeight := 20 ; Minimum Height of 15
guiList.Button.TopRight := guiList.Add("Button", "Default", "TopRight")
guiList.Button.TopRight.X := -80 ; 80 from Right Margin (Width of Control Below)
guiList.Button.TopRight.XP := -0.15 ; 15% from Right Margin (this plus above effectively positions 15% edge to Right Margin)
guiList.Button.TopRight.YP := -0.58 ; 58% from Bottom Margin
guiList.Button.TopRight.MaxX := 1200 ; Max X Position of 1200
guiList.Button.TopRight.Width := 80 ; 80 Width
guiList.Button.TopRight.Height := 20 ; 20 Height of Gui Height
guiList.Button.BottomRight := guiList.Add("Button", "Default", "BottomRight") ; Centered below TopRight Right Edge
guiList.Button.BottomRight.OriginXP := 0.5 ; X Origin Adjusted to 50% (Middle of Button)
guiList.Button.BottomRight.XP := -0.15 ; 15% from Right Margin (Same as TopRight Button but with center OriginX)
guiList.Button.BottomRight.MaxX := 1130 ; Max X Position of 1130 (1200 + 80 - 150 = TopRight Right Edge to Center of Button)
guiList.Button.BottomRight.YP := -0.20 ; 20% from Bottom Margin
guiList.Button.BottomRight.WidthP := 0.25 ; 25% Width of Gui Width
guiList.Button.BottomRight.MaxWidth := 300 ; Max Width of 300
guiList.Button.BottomRight.MinWidth := 75 ; Minimum Width of 75
guiList.Button.BottomRight.Height := 20 ; 20 Height
ListView_Columns(CtrlObj, GuiObj) ; custom called function
{
    CtrlObj.ModifyCol(3, "AutoHdr")
}
guiTab := Gui(, "Tab 1"), guiTab.Opt("+Resize +MinSize250x150")
guiTab.OnEvent("Size", GuiReSizer)
guiTab.Text := guiTab.Add("Text", , "Tabs ->")
guiTab.Text.XP := 0.02 ; 2% from Left Margin
guiTab.Text.YP := 0.35 ; 35% from Left Margin
guiTab.Tab := guiTab.Add("Tab3", "x100 y100 w500 h500", ["General", "View", "Settings"])
guiTab.Tab.XP := 0.25 ; 25% from Left Margin
guiTab.Tab.YP := 0.35 ; 35% from Top Margin
guiTab.Tab.C := true ; Force Redraw everytime with this GUI (usually not needed)
guiTab.Tab.W := -10 ; Adjust Width to maintain 10 from Right Margin
guiTab.Tab.H := -10 ; Adjust Height to maintain 10 from Bottom Margin
guiTab.Tab.Button := {}

guiTab.Tab.UseTab()
guiTab.Tab.Button.NoTabOne := guiTab.Add("Button", , "One No Tab (Click to Move)")
guiTab.Tab.Button.NoTabOne.XP := 0.25 ; 25% width of Gui Width
guiTab.Tab.Button.NoTabOne.Y := 5 ; 5 from Top Margin of Gui
guiTab.Tab.Button.NoTabOne.WidthP := 0.70 ; 70% Width of Gui Width
guiTab.Tab.Button.NoTabOne.OnEvent("Click", guiTab_Click_to_Move)
guiTab_Click_to_Move(GuiCtrlObj, Info)
{
    If guiTab.Tab.Button.NoTabOne.XP = 0.25
        guiTab.Tab.Button.NoTabOne.XP := 0.10
    Else
        guiTab.Tab.Button.NoTabOne.XP := 0.25
    GuiReSizer.Now(guiTab) ; forced resize call to adjust position

}
guiTab.Tab.Button.NoTabTwo := guiTab.Add("Button", "x100 y100", "Two Anchored")
guiTab.Tab.Button.NoTabTwo.Anchor := guiTab.Tab.Button.NoTabOne
guiTab.Tab.Button.NoTabTwo.AnchorIn := false
guiTab.Tab.Button.NoTabTwo.XP := 0.50 ; 50% from Anchor Top Left Corner
guiTab.Tab.Button.NoTabTwo.Y := 25 ; 25 Below Anchor Top Left Corner
guiTab.Tab.Button.NoTabTwo.WP := 0.5 ; 50% Width of Anchor Width
guiTab.Tab.Button.NoTabTwo.OriginXP := 0.5 ; Origin X at 50% or Center

guiTab.Tab.UseTab(1)
guiTab.Tab.Button.One := guiTab.Add("Button", "Default x150 y150", "One in General")
guiTab.Tab.Button.One.Anchor := guiTab.Tab ; need to set Anchor Tab for Controls in Tabs
guiTab.Tab.Button.One.XP := 0.50 ; 50% width of Anchor Tab
guiTab.Tab.Button.One.YP := -0.25 ; 25% width of Anchor Tab
guiTab.Tab.Button.One.OXP := 0.5 ; X Origin at 50% of Button Width, Center
guiTab.Tab.Button.One.OYP := 0.5 ; Y Origin at 50% of Button Height, Middle
guiTab.Tab.UseTab(2)
guiTab.Tab.Button.Two := guiTab.Add("Button", "Default x150 y150", "Two in View")
guiTab.Tab.Button.Two.Anchor := guiTab.Tab ; need to set Anchor Tab for Controls in Tabs
guiTab.Tab.Button.Two.X := -10 ; 10 from Right Margin of Anchor Tab
guiTab.Tab.Button.Two.Y := -10 ; 10 from Bottom Margin of Anchor Tab
guiTab.Tab.Button.Two.OXP := 1 ; X Origin to 100%, Right Edge
guiTab.Tab.Button.Two.OYP := 1 ; Y Origin to 100%, Bottom Edge (Origin is now Bottom Right corner)
guiTab.Tab.Button.Two.WP := 0.50 ; 50% width of Anchor Tab
guiTab.Tab.UseTab(3)
guiTab.Tab.Button.Three := guiTab.Add("Button", "Default x150 y150", "Three")
guiTab.Tab.Button.Three.Anchor := guiTab.Tab ; need to set Anchor Tab for Controls in Tabs
guiTab.Tab.Button.Three.XP := 0.7 ; 70% of Anchor Tab Width
guiTab.Tab.Button.Three.Y := -300 ; 300 from Bottom of Anchor Tab
guiTab.Tab.Button.Three.MinY := 20 ; 20 Min Y

guiList.Show("x10 y10 w500 h300")
guiTab.Show("x1000 y100")

Esc:: ExitApp
