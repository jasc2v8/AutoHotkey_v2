#Requires AutoHotkey v2+
#SingleInstance
ESC::ExitApp()

/*
    See the AHK v2 Help, Gui Object, Window Appearance

    In Summary:
        TraySetIcon = Tray icon only.
        SendMessage WM_SETICON = Title, TaskBar, and Alt-Tab icons.
*/

g:= Gui() 
g.Show("w400 h200")

; all OK:
;TraySetIcon("shell32.dll", 24) ; MsgBox Question
;TraySetIcon("C:\Windows\System32\OneDrive.ico")
;TraySetIcon("c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe", 2) ;1=User, 2=Admin Shield

TraySetIcon
MsgBox "Default Icon for Title, TaskBar, Alt-Tab, and Tray", "Icons"

TraySetIcon("shell32.dll", 315) ; Cog Wheel
MsgBox  "Title, TaskBar, and Alt-Tab: AHK Default`n`nTray: Cog Wheel", "Icons"

SetIcons(g) ; Gold Star
MsgBox "Title, TaskBar, and Alt-Tab: Gold Star`n`nTray: Cog Wheel", "Icons"

TraySetIcon("shell32.dll", 44) ; Gold Star
MsgBox "Title, TaskBar, and Alt-Tab: Gold Star`n`nTray: Gold Star", "Icons"

ExitApp()

SetIcons(GuiCtrl, IconFile:="", IconNumber:=0) {

    IconFile:= (IconFile = "") ? "shell32.dll" : IconFile
    IconNumber:= (IconNumber = 0) ? 44 : IconNumber ; 44=Gold Star

    WM_SETICON := 0x80
    ICON_BIG   := 1     ; Alt-Tab
    ICON_SMALL := 0     ; Title and Taskbar

    hIcon := LoadPicture(IconFile, "Icon"  IconNumber, &OutImageType)

    SendMessage(WM_SETICON, ICON_BIG,   hIcon, GuiCtrl) ; Alt-Tab
    SendMessage(WM_SETICON, ICON_SMALL, hIcon, GuiCtrl) ; Title
    ; When both are set                                 ; Title, TaskBar, and Alt-Tab
}
