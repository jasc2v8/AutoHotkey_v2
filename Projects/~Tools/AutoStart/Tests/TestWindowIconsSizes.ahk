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

size:=16
Loop 13 {
    SetIconsFromDLL(g,"C:\Users\Jim\Documents\AutoHotkey\Lib\Icons\cog.ico",1 ,size)
    MsgBox "Size: " size, "Icons"
    size += 8

}

; all OK:
;TraySetIcon("shell32.dll", 24) ; MsgBox Question
;TraySetIcon("C:\Windows\System32\OneDrive.ico")
TraySetIcon("E:\open_icon_library-win-0.11\open_icon_library-win\icons\22x22\actions\acrobat.ico")
;TraySetIcon("c:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe", 2) ;1=User, 2=Admin Shield

MsgBox "Default Icon for Title, TaskBar, Alt-Tab, and Tray", "Icons"

TraySetIcon("shell32.dll", 315) ; Cog
MsgBox  "Title, TaskBar, and Alt-Tab: AHK Default`n`nTray: Cog Wheel", "Icons"

SetIconsFromDLL(g) ; Gold Star
MsgBox "Title, TaskBar, and Alt-Tab: Gold Star`n`nTray: Cog Wheel", "Icons"

TraySetIcon("shell32.dll", 44) ; Gold Star
MsgBox "Title, TaskBar, and Alt-Tab: Gold Star`n`nTray: Gold Star", "Icons"

ExitApp()

SetIconsFromDLL(GuiCtrl, IconFile:="", IconNumber:=0, IconSize:=32) {

    IconFile:= (IconFile = "") ? "shell32.dll" : IconFile
    IconNumber:= (IconNumber = 0) ? 44 : IconNumber ; 44=Gold Star

    WM_SETICON := 0x80
    ICON_BIG   := 1     ; Alt-Tab
    ICON_SMALL := 0     ; Title and Taskbar

    ;hIcon := LoadPicture(IconFile, "Icon"  IconNumber, &OutImageType)
    hIcon := GetIconHandle(IconFile, IconNumber, IconSize)

    SendMessage(WM_SETICON, ICON_BIG,   hIcon, GuiCtrl) ; Alt-Tab
    SendMessage(WM_SETICON, ICON_SMALL, hIcon, GuiCtrl) ; Title
    ; When both are set                                 ; Title, TaskBar, and Alt-Tab

}

GetIconHandle(File, Index, Size:=32)
{
    hIcon := 0
    DllCall("PrivateExtractIcons", "str", File, "int", Index-1, "int", Size, "int", Size, "ptr*", &hIcon, "ptr*", 0, "uint", 1, "uint", 0, "uint")
    return hIcon
}
