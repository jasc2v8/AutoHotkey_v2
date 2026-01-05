#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

Escape::ExitApp()

MyDllFile := "C:\Users\Jim\Documents\AutoHotkey\Lib\MyIcons_v1.dll"

/**
 * "HICON:"  hIcon   No Asterisk means AutoHotkey will call DestroyIcon()
 * "HICON:*" hIcon   Asterisk means the user will call DestroyIcon()
 */

; Load icon from a ICO
;hIcon0 := LoadPicture("C:\Windows\System32\OneDrive.ico", "Icon1", &IconType)

;OutputDebug(hIcon0)

; Load the first icon from a DLL
;hIcon0 := LoadPicture("C:\Windows\System32\OneDrive.ico", "Icon1", &IconType)
hIcon1 := LoadPicture(MyDllFile, "Icon1", &IconType)
hIcon2 := LoadPicture(MyDllFile, "Icon2", &IconType)
hIcon3 := LoadPicture(MyDllFile, "Icon3", &IconType)
hIcon4 := LoadPicture(MyDllFile, "Icon4", &IconType)

;MsgBox("hIcon1: " hIcon1 ",`nhIcon2: " hIcon2 "`nhIcon3: " hIcon3 "`nhIcon4: " hIcon4)

; 
; Load the second icon from an EXE
;hIcon2 := LoadPicture("C:\Windows\System32\notepad.exe", "Icon1")

; Load an icon by its resource ID (e.g., resource ID 101)
;MyResourceIcon := LoadPicture("C:\Path\To\Your.dll", "Icon-101")

; You can then use the loaded image, for example, in a GUI Picture control:
MyGui := Gui()
r := (hIcon1) ? MyGui.AddPicture("w40 h-1", "HICON:" hIcon1) : ''
r := (hIcon2) ? MyGui.AddPicture("yp w40 h-1", "HICON:" hIcon2) : ''
r := (hIcon3) ? MyGui.AddPicture("yp w40 h-1", "HICON:" hIcon3) : ''
r := (hIcon4) ? MyGui.AddPicture("yp w40 h-1", "HICON:" hIcon4) : ''

r := (hIcon1) ? MyGui.AddText("xm w40", "Icon1") : ''
r := (hIcon2) ? MyGui.AddText("yp w40", "Icon2") : ''
r := (hIcon3) ? MyGui.AddText("yp w40", "Icon3") : ''
r := (hIcon4) ? MyGui.AddText("yp w40", "Icon4") : ''

ButtonShow := MyGui.AddButton("xm", "hIcon").OnEvent('Click',(*) => 
    MsgBox("hIcon1: " hIcon1 ",`nhIcon2: " hIcon2 "`nhIcon3: " hIcon3 "`nhIcon4: " hIcon4))
ButtonHelp := MyGui.AddButton("yp", "Help").OnEvent("Click", ButtonHelp_Click)

;MyGui.AddPicture("w40 h-1", "HICON:" hIcon4)
;MyGui.AddPicture("w32 h-1", "HBITMAP:" hIcon1)
;MyGui.AddPicture("w32 h-1", "HBITMAP:" hIcon2)
;MyGui.AddPicture("Icon315", "C:\Windows\System32\shell32.dll")
MyGui.Show()
;MyGui.OnEvent("Close", OnGui_Close)

; OnGui_Close(*) {
;    if (hIcon0 != 0)
;       DllCall("DestroyIcon", "ptr", hIcon0)
;    if (hIcon1 != 0)
;       DllCall("DestroyIcon", "ptr", hIcon1)
;    if (hIcon2 != 0)
;       DllCall("DestroyIcon", "ptr", hIcon2)
; }

ButtonHelp_Click(*) { 

        helpText := "
(
1. Open ResourceHacker
2. Menu, Create new Blank Script
2. Menu, Add binary or image
3. Select one file at a time
4. Save as "myFile.dll"
)"

        MsgBox(helpText)
}



