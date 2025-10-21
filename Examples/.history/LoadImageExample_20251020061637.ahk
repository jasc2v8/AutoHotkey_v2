#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; Load the first icon from a DLL
MyIcon := LoadPicture("C:\Windows\System32\shell32.dll", "Icon1")

; Load the second icon from a DLL
MyOtherIcon := LoadPicture("C:\Path\To\Your.dll", "Icon2")

; Load an icon by its resource ID (e.g., resource ID 101)
MyResourceIcon := LoadPicture("C:\Path\To\Your.dll", "Icon-101")

; You can then use the loaded image, for example, in a GUI Picture control:
MyGui := Gui()
MyGui.AddPicture("w32 h-1", "HBITMAP:*" MyIcon)
MyGui.AddPicture("Icon16", "C:\Windows\System32\shell32.dll")
MyGui.Show()