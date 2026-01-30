#Requires AutoHotkey v2+

GuiSetIconsFromDLL(GuiCtrl, IconFile:="", IconNumber:=0) {

    IconFile:= (IconFile = "") ? "C:\Windows\System32\shell32.dll" : IconFile
    IconNumber:= (IconNumber = 0) ? 44 : IconNumber ; 44=Gold Star

    WM_SETICON := 0x80
    ICON_SMALL := 0     ; Small Icon (Title bar)
    ICON_BIG   := 1     ; Big Icon (Alt-Tab / Taskbar)

    TraySetIcon(IconFile, IconNumber)

    hIcon := LoadPicture(IconFile, "Icon"  IconNumber, &OutImageType)

    ; Apply big and small icons
    SendMessage(WM_SETICON, ICON_BIG,   hIcon, GuiCtrl.Hwnd)
    SendMessage(WM_SETICON, ICON_SMALL, hIcon, GuiCtrl.Hwnd)
}
