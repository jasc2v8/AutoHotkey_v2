; TITLE  :  ColorPickers v1.0.0.4
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2+
#SingleInstance Force
#NoTrayIcon

#Include <Colors>

; Version: 1.0.0.4

MainGui := Gui("+AlwaysOnTop", "Color Pickers v1.0.0.4")
MainGui.SetFont("s10", "Consolas")
MainGui.BackColor := Colors.AirSuperiorityBlue

MainGui.Add("Text",, "Select a ColorPicker tool to open:")

; Define the URLs
URLMap := Map(
    "Adobe Color", "https://color.adobe.com/",
    "Canva Color Wheel", "https://www.canva.com/colors/color-wheel/",
    "Color Meanings", "https://www.color-meanings.com/themed-color-palettes/",
    "Color Meanings 550 Color Names and Hex Codes", "https://www.color-meanings.com/list-of-colors-names-hex-codes/",
    "Coolors.co", "https://coolors.co/",
    "Flat UI Colors", "https://flatuicolors.com/",
    "Google Color Picker", "https://www.google.com/search?q=color+picker",
    "HTML Color Codes", "https://htmlcolorcodes.com/",
    "Material Design Color Chart", "https://htmlcolorcodes.com/color-chart/material-design-color-chart/",
    "Rapid Tables", "https://www.rapidtables.com/web/color/RGB_Color.html"
)

; Extract keys for the ListBox
URLNames := []
for Name in URLMap
    URLNames.Push(Name)

; Add ListBox
LB := MainGui.Add("ListBox", "r10 w350 Sort Background" Colors.LemonChiffon, URLNames)
LB.OnEvent("DoubleClick", LaunchURL)

; Add Buttons
BtnLaunch := MainGui.Add("Button", "Default w80", "Open")
BtnLaunch.OnEvent("Click", LaunchURL)

BtnCancel := MainGui.Add("Button", "x+10 w80", "Cancel")
BtnCancel.OnEvent("Click", (*) => MainGui.Hide())

MainGui.Show()

; --- Functions ---

LaunchURL(*) {
    SelectedName := LB.Text
    
    if (SelectedName = "")
        return
        
    TargetURL := URLMap[SelectedName]
    Run(TargetURL)
}

; Cleanup
GuiEscape(*) => MainGui.Hide()
