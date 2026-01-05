#Requires AutoHotkey v2.0

class GuiEx
{
    GuiObj := 0
    Hwnd   :=  0

    __New(GuiObj)
    {
        if !IsSet(GuiObj)
            Throw Error "Gui Object not specified."

        this.GuiObj := GuiObj
        this.Hwnd := GuiObj.Hwnd
    }

    __Delete() {
    }

    Center() {
        this.GuiObj.Show("Center")
    }

    ; SetIcons(IconFile:="C:\Windows\System32\shell32.dll", IconNumber:=16)  ; Load from DLL
    ; SetIcons(IconFile:="c:\windows\System32\OneDrive.ico", IconNumber:="") ; Load from File
    SetIcons(IconFile:="C:\Windows\System32\shell32.dll", IconNumber:=44)
    {
        WM_SETICON := 0x80
        ICON_SMALL := 0     ; Small Icon (Title bar)
        ICON_BIG   := 1     ; Big Icon (Alt-Tab / Taskbar)

        ; if no icon number then load from file
        if (IconNumber = "") {

            ; Load the icon from file
            hIcon := DllCall("LoadImage", 
                "Ptr",  0,
                "Str",  IconFile,
                "UInt", 1,              ; IMAGE_ICON
                "Int",  0, "Int", 0,    ; default size
                "UInt", 0x10,           ; LR_LOADFROMFILE
                "Ptr"
            )

            ; Apply the tray icon
            TraySetIcon(IconFile)

        ; else load from dll
        } else {

            TraySetIcon(IconFile, IconNumber)

            hIcon := LoadPicture(IconFile, "Icon"  IconNumber, &OutImageType)
        }

        ; Apply big and small icons
        SendMessage(WM_SETICON, ICON_BIG,   hIcon, this.Hwnd)
        SendMessage(WM_SETICON, ICON_SMALL, hIcon, this.Hwnd)

    }

    SetTitle(NewTitle) {
        WinSetTitle(NewTitle, "ahk_id " this.Hwnd)
    }
}

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    DoTest_GuiEx(1) ; 1=run, 0 or empty=exit

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

DoTest_GuiEx(flag:=false) {

    if !flag {
        SoundBeep(), ExitApp()
    }

    #Warn Unreachable

    ; add comment to skip:
    Test1()
    ;Test2()
    ;Test3()
}

Test1() {

    ;#NoTrayIcon

    TraySetIcon(IconFile:="shell32.dll", IconNumber:=44) ; gold star

    ; Create a new Gui object
    MyGui := Gui(, "GuiEx Demo")
    MyGui.BackColor := "4682B4" ; Steel Blue
    MyGui.SetFont("S11", "Segouie UI")

    ; Add Buttons
    buttonIconsDLL  := MyGui.AddButton("w100", "Set Icons DLL")
    buttonIconsFile := MyGui.AddButton("yp w100", "Set Icons File")
    buttonTitle     := MyGui.AddButton("yp w100", "Set Title")
    buttonCenter    := MyGui.AddButton("yp w100", "Center")
    buttonCancel    := MyGui.AddButton("yp w100 Default", "Cancel")

    ; Assign a function to be called when the button is clicked
    buttonIconsDLL.OnEvent("Click", ButtonIconsDLLClicked)
    buttonIconsFile.OnEvent("Click", ButtonIconsFileClicked)
    buttonTitle.OnEvent("Click", ButtonTitleClicked)
    buttonCenter.OnEvent("Click", ButtonCenterClicked)
    buttonCancel.OnEvent("Click", ButtonCancelClicked)

    ; Show the GUI
    MyGui.Show()
    MyGui.OnEvent("Close", OnGui_Close)

    grui := GuiEx(MyGui)

        ; SetIcons(IconFile:="C:\Windows\System32\shell32.dll", IconNumber:=16)
    ; SetIcons(IconFile:="c:\windows\System32\OneDrive.ico", IconNumber:="")

    ButtonIconsDLLClicked(Ctrl, Info) {

        ;grui.SetIcons(IconFile:="C:\Windows\System32\shell32.dll", IconNumber:=44) ; gold star
        grui.SetIcons(IconFile:="shell32.dll", 44) ; gold star

        ; WM_SETICON := 0x80
        ; ICON_SMALL := 0     ; Small Icon (Title bar)
        ; ICON_BIG   := 1     ; Big Icon (Alt-Tab / Taskbar)

        ; hIcon := LoadPicture("C:\Windows\System32\shell32.dll", "Icon44", &OutImageType)
        ; SendMessage(WM_SETICON, ICON_BIG,   hIcon, MyGui.Hwnd)
        ; SendMessage(WM_SETICON, ICON_SMALL, hIcon, MyGui.Hwnd)

    }

    ButtonIconsFileClicked(Ctrl, Info) {
        grui.SetIcons(IconFile:="c:\windows\System32\OneDrive.ico", IconNumber:="") ; blue clouds
    }

    ButtonTitleClicked(Ctrl, Info) {
        grui.SetTitle("New Title")
    }

    ButtonCenterClicked(Ctrl, Info) {
        grui.Center()
    }

    ButtonCancelClicked(Ctrl, Info) {
        MyGui.Destroy()
    }

    OnGui_Close(*) {
        ExitApp()
    }
}
