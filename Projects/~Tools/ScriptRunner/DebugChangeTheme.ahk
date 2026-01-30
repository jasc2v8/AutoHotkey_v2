#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <RegSettings>

; --- Tray Icon ---
TraySetIcon("cmd.exe")

; --- GUI Creation ---
MyGui := Gui("+Resize +MinSize520x400 +0x02000000", A_ScriptName)

BtnTheme   := MyGui.Add("Button", "vBtnTheme xm w100", "Theme")
BtnCancel  := MyGui.Add("Button", "vBtnCancel w100", "Cancel")
SB := MyGui.Add("StatusBar")

; --- Event Handlers ---
BtnTheme.OnEvent("Click", ToggleTheme)
BtnCancel.OnEvent("Click", (*) => ExitApp())

MyGui.Show("w800 Center")

; Get theme from Registry
settings := RegistrySettings()

theme := settings.Read("Theme", "NOT_FOUND")

; if key not found then create default theme CMD
if (theme = "NOT_FOUND")
    theme := "ps1"
    settings.Write("Theme", theme)

UpdateTheme(theme)

; --- Functions ---

ToggleTheme(*) {
    SoundBeep

    theme := settings.Read("Theme", "NOT_FOUND")

    oldTheme := theme

    if (theme = "cmd")
        theme := "ps1"
    else
        theme := "cmd"
    settings.Write("Theme", theme)
    UpdateTheme(theme)

    ;MsgBox "Theme changed from " oldTheme " to " theme
}

UpdateTheme(theme) {
    if (theme = "cmd") {
        TraySetIcon("cmd.exe")
        SendMessage(0x80, 0, LoadPicture("cmd.exe", "Icon1 w16 h16", &imgType), MyGui.Hwnd)
        SendMessage(0x80, 1, LoadPicture("cmd.exe", "Icon1 w16 h16", &imgType), MyGui.Hwnd)
    } else {
        TraySetIcon("powershell_ise.exe")
        SendMessage(0x80, 0, LoadPicture("powershell_ise.exe", "Icon1 w16 h16", &imgType), MyGui.Hwnd)
        SendMessage(0x80, 1, LoadPicture("powershell_ise.exe", "Icon1 w16 h16", &imgType), MyGui.Hwnd)
    }

    SB.SetText("Theme: " theme)
}

