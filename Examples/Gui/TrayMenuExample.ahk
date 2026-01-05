#Requires AutoHotkey v2.0
#SingleInstance Force

A_IconHidden := false  ; Hides the tray icon.

A_TrayMenu.Delete  ; Clears any existing tray menu items.
A_TrayMenu.Add()  ; Creates a separator line.
A_TrayMenu.Add("Item1", MenuHandler)  ; Creates a new menu item.
Persistent

MenuHandler(ItemName, ItemPos, MyMenu) {
    MsgBox "You selected " ItemName " (position " ItemPos ")"
}

MsgBox "Right-click the tray icon to see the menu."

; Keep the script running
Persistent
