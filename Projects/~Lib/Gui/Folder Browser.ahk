; Gemini
#Requires AutoHotkey v2.0


; Global variables separated as requested
global IL_Large := 0
global IL_Small := 0

MyGui := Gui("+Resize", "AHK v2 Folder Tree")
MyGui.SetFont("s10", "Segoe UI")

; Create an ImageList for the icons
; 0x1 is the flag for small icons (16x16)
IL_Small := IL_Create(5) 
IL_Add(IL_Small, "shell32.dll", 4)  ; Folder icon
IL_Add(IL_Small, "shell32.dll", 1)  ; Document icon

; Add the TreeView and assign the ImageList
TV := MyGui.Add("TreeView", "r15 w300 ImageList" IL_Small)

; Add sample folder structure
Root := TV.Add("Project Root", 0, "Icon1 Expand")
Sub1 := TV.Add("Assets", Root, "Icon1")
        TV.Add("Logo.png", Sub1, "Icon2")
Sub2 := TV.Add("Scripts", Root, "Icon1")
        TV.Add("Main.ahk", Sub2, "Icon2")
        TV.Add("Lib.ahk", Sub2, "Icon2")

MyGui.Add("Button", "w100", Chr(0xE8F4) " New Folder").SetFont("s10", "Segoe MDL2 Assets")

MyGui.Show()
