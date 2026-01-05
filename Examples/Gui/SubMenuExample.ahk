
#SingleInstance
MyGui := Gui(,'My GUI') ; use title for determining visibility
MyGui.OnEvent('Close', (*)=>ExitApp())
MyGui.Add("Text","w100 h50", "test")
buttonOK :=MyGui.Add("Button","xm", "OK")
MyGui.Show()

buttonOK.OnEvent('Click', (*)=>MyMenu.Show())

; Create a new menu object
MyMenu := Menu()
MySubMenu := Menu()

; Add items to the menu
MyMenu.Add("Item 1", MyMenuHandler)
MyMenu.Add("Item 2", MyMenuHandler)
MyMenu.Add("E&xit", MyMenuHandler) ; The & makes 'x' a hotkey

; submenu
MySubMenu.Add("Submenu Item 1", MyMenuHandler)
MySubMenu.Add("Submenu Item 2", MyMenuHandler)
MyMenu.Add("My Submenu", MySubMenu)
; show
MyMenu.Show()

; Set the custom menu as the default tray menu.
; This line is key; it links the menu object to the tray icon.
; INOP A_TrayMenu := MyMenu

; A handler function for the menu items
MyMenuHandler(ItemName, ItemPos, MyMenu) {
    ;  MsgBox "You selected " ItemName " (position " ItemPos ")"
    if (ItemName = "E&xit") {
        ExitApp
    } else {
        MsgBox("You clicked " . ItemName)
    }
}

;ok
; #Requires AutoHotkey v2.0
; #SingleInstance Force
; Persistent(True)
; MenuTray := A_TrayMenu
; #F10::MenuTray.Show()


; A_TrayMenu.ClickCount:=1
; A_TrayMenu.Add("Gui", guishow)
; A_TrayMenu.Default:="Gui"

; MonitorGetWorkArea(1,,, &WARight, &WABottom)
; A_TrayMenu.Show(WARight, WABottom)

;return 


guishow(*){
    static toggle := true ; start as true because the window is already shown

    if !WinExist('My GUI')
    toggle:=!toggle
    if toggle
	MyGui.Show()
    else
	MyGui.Hide()
}