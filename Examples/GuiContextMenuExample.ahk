#Requires AutoHotkey v2.0

#SingleInstance Force

#Requires AutoHotkey 2
g := Gui(, 'Right click')
g.OnEvent 'ContextMenu', gui_ContextMenu
g.Show 'w300 h300'

gui_ContextMenu(guiObj, guiCtrlObj, item, isRightClick, x, y) {

    ;MsgBox 'Right click: ' isRightClick '`nx = ' x '`ny = ' y

     MyMenu := Menu()

    ; Add menu items. The second parameter specifies the
    ; function to call when the item is clicked.
    MyMenu.Add("Custom", MenuHandler)
    MyMenu.Add("Copy", MenuHandler)
    MyMenu.Add("Cut", MenuHandler)
    MyMenu.Add("Paste", MenuHandler)
    MyMenu.Add()  ; Creates a separator line.
    MyMenu.AddStandard()
 
    ; Show the menu at the current mouse cursor position.
    MyMenu.Show()
}

MenuHandler(ItemName, ItemPos, MyMenu) {

    MsgBox 'click: ' ItemName ' pos: ' ItemPos

        if (ItemName = "Copy") {
        Send("^c")
    } else if (ItemName = "Cut") {
        Send("^x")
    } else if (ItemName = "Paste") {
        Send("^v")
    }
}
