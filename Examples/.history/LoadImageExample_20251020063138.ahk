#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; Load the first icon from a DLL
hIcon1 := LoadPicture("C:\Windows\System32\shell32.dll", "Icon16")

; Load the second icon from an EXE
hIcon2 := LoadPicture("C:\Windows\System32\notepad.exe", "Icon1")

; Load an icon by its resource ID (e.g., resource ID 101)
MyResourceIcon := LoadPicture("C:\Path\To\Your.dll", "Icon-101")

; You can then use the loaded image, for example, in a GUI Picture control:
MyGui := Gui()
;MyGui.AddPicture("w32 h-1", "HICON:*" hIcon1)
MyGui.AddPicture("w32 h-1", "HBITMAP:*" hIcon1)
MyGui.AddPicture("w32 h-1", "HBITMAP:*" hIcon2)
MyGui.AddPicture("Icon315", "C:\Windows\System32\shell32.dll")
MyGui.Show()
MyGui.OnEvent("Close", OnGui_Close)

OnGui_Close(*) {
   if (hIcon1 != 0)
      DllCall("DestroyIcon", "ptr", hIcon1)
   if (hIcon2 != 0)
      DllCall("DestroyIcon", "ptr", hIcon2)

}