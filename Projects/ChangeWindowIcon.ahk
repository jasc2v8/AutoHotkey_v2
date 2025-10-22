#Requires AutoHotkey v2.0
#SingleInstance Force

;=============================================================================================================
; Change the icon on an existing window. Source: https://tinyurl.com/2py768e4
; Params:
;   IconFile    Icon icoFilename (.dll, .exe, .ico)
;   IconNumber  Icon number in icoFile e.g. "Icon1" or "Icon-101"
;   WinTitle    Title of Window to change icon.
; Returns:      Succes returns '', Error returns "Error Description String"
; License: The Unlicense: https://unlicense.org/
;-------------------------------------------------------------------------------------------------------------
ChangeWindowIcon(IconFile, IconNumber:="Icon1", WinTitle := "A") {

    if !FileExist(IconFile)
        return "Icon File missing: " IconFile

    SplitPath(IconFile,,,&OutExt)

    if !InStr("ico,dll,exe", OutExt)
        return "Not a valid Icon File (dll, exe, ico)."
        
    hWnd  := WinExist(WinTitle)
    if (!hWnd)
        return "Window Not Found"

    hIcon := LoadPicture(IconFile, IconNumber, &IconType)
    if (!hIcon)
        Throw("Error loading icon: " IconFile)

    SendMessage(WM_SETICON:=0x80, ICON_SMALL:=0, hIcon,, WinTitle)
    SendMessage(WM_SETICON:=0x80, ICON_BIG:=1  , hIcon,, WinTitle)

    return
}

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    ChangeWindowIcon_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
ChangeWindowIcon_Test() {

    #Warn Unreachable

    ; set true to run tests, else false
    Run_Tests := true

    if !Run_Tests
        SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    ;Test2()
    ;Test3()
}

Test1() {

    global iconArray, Gui2, count

    Gui1 := Gui(, "Main Gui Example")
    Gu1Text :=Gui1.AddText(,"Press Enter to change the icon...")

    Gui2 := Gui(, "🡄 Change Icon")
    Gu2Text := Gui2.AddText(,"Defaul Icon")
 
    buttonChange := Gui1.Add("Button", "w64 Default", "Change").OnEvent("Click", ButtonChange_Click)

    Gui1.OnEvent("Close", OnGui_Close)
    Gui2.OnEvent("Close", OnGui_Close)

    Gui1.Show("w300 h100 x100 y100")
    Gui2.Show("w300 h100 x500 y100")

    ControlFocus("Change", Gui1)

    iconArray := ["Icon132", "Icon211", "Icon220", "Icon222", "Icon238"]

    ;demonstrate using icons from dll, exe, and ico files
    icoFile1 := "C:\Windows\SystemApps\MicrosoftWindows.Client.Core_cw5n1h2txyewy\StartMenu\Assets\UnplatedFolder\UnplatedFolder.ico"
    icoFile2 := "C:\Windows\System32\Notepad.exe"
    icoFile3:= "C:\Windows\System32\user32.dll"
    icoFile4 := "C:\Windows\System32\cleanmgr.exe"
    icoFile5 := "C:\Windows\System32\OneDrive.ico"
    iconFileArray := [icoFile1, icoFile2, icoFile3, icoFile4, icoFile5]

    count := 1

    ButtonChange_Click(Ctrl, Info) {

        SplitPath(iconFileArray[count],&OutName)

        Gu1Text.Text := OutName
        Gu2Text.Text := iconArray[count]

        r := ChangeWindowIcon("C:\Windows\System32\shell32.dll", iconArray[count], "ahk_id" Gui2.Hwnd)
        if (r != '')
            MsgBox("Error: " r)

        r := ChangeWindowIcon(iconFileArray[count], "Icon1", "ahk_id" Gui1.Hwnd)
        if (r != '')
            MsgBox("Error: " r)

        count++
        if (count > iconArray.Length)
            count := 1
    }

    OnGui_Close(*) {
        ExitApp()
    }
}
