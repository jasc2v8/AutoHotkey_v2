; Gemini

#Requires AutoHotkey v2.0

; Global variables separated as requested
global IL_Large := 0
global IL_Small := 0

grui := Gui("+AlwaysOnTop", "Unicode Reference")
grui.SetFont("s10", "Segoe UI")

; --- Section 1: Standard Symbols ---
grui.Add("GroupBox", "w220 h60", "Standard UI")
grui.Add("Button", "xp+10 yp+25 w95", "Back " Chr(0x25C0))
grui.Add("Button", "x+10 w95", "Next " Chr(0x25B6))

; --- Section 2: MDL2 Icons ---
grui.Add("GroupBox", "xm w220 h60", "Modern MDL2 Icons")
grui.SetFont("s14", "Segoe MDL2 Assets") ; Switch font for icons
grui.Add("Button", "xp+10 yp+25 w40 h30", Chr(0xE80F)) ; Home
grui.Add("Button", "x+5 w40 h30", Chr(0xE71E))        ; Search
grui.Add("Button", "x+5 w40 h30", Chr(0xE74E))        ; Save
grui.Add("Button", "x+5 w40 h30 cRed", Chr(0xE74D))    ; Trash

grui.Add("GroupBox", "xm w220 h60", "Other")
grui.Add("Button", "xp+10 yp+25 w40", Chr(0xE8B7))      ; MDL2 Folder
grui.Add("Button", "yp w40", Chr(0xE8F4))               ; MDL2 NewFolder
grui.Add("Button", "yp w40", Chr(0xE7B8))               ; MDL2 Shared Folder

grui.Add("GroupBox", "xm w220 h60", "Media")
grui.Add("Button", "xp+10 yp+25 w40", Chr(0xE892))      ; Skip Back
grui.Add("Button", "yp w40", Chr(0xE71A))               ; Stop
grui.Add("Button", "yp w40", Chr(0xE769))               ; Pause
grui.Add("Button", "yp w40", Chr(0xE768))               ; Play
grui.Add("Button", "yp w40", Chr(0xE893))               ; Skip Forward
grui.Add("Button", "yp w40", Chr(0xE8EE))               ; Repeat
grui.Add("Button", "yp w40", Chr(0xE995))               ; Volume (High)
grui.Add("Button", "yp w40", Chr(0xE74F))               ; Mute
grui.Add("Button", "yp w40", Chr(0xE8B1))               ; Shuffle

; Reset font for any further text
grui.SetFont("s9", "Segoe UI")
grui.Show()