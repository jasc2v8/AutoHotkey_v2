; TITLE  :  AhkLauncher v1.0.0.2
; SOURCE :  jasc2v8 and https://www.autohotkey.com/boards/viewtopic.php?t=102798
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

/*
    TODO:
*/

#Requires Autohotkey v2+
#SingleInstance Force
TraySetIcon('imageres.dll', 250) ; light blue windows start button

#Include <Debug>
#Include <CredMgr>
; ok #Include <Anchor_3>
#Include Anchor.ahk

; ^ =Ctrl - # =Win - ! =Alt - + =Shift

;   #region Globals

global INI := ''

UserProfilePath := EnvGet("USERPROFILE")
DesktopPath := UserProfilePath "\Desktop\AutoHotkey\*.ahk"
DocumentsPath := UserProfilePath "\Documents\AutoHotkey\Lib\*.ahk"

global AhkAppsPath := UserProfilePath "\Documents\AutoHotkey\AhkLauncher\AhkApps"
global PCPath      := UserProfilePath "\Documents\AutoHotkey\AhkLauncher\PC\"
global ServerPath  := UserProfilePath "\Documents\AutoHotkey\AhkLauncher\SERVER\"
global WebPath     := UserProfilePath "\Documents\AutoHotkey\AhkLauncher\Web\"

global AHKMap := Map()
global PCMap := ENV_SETTINGS.GetAll()
global SERVERMap := Map()
global WEBMap := Map()

global LVArray := Array()
global MapsArray := [AHKMap, PCMap, ServerMap, WebMap]
global PathArray := [AhkAppsPath, PCPath, ServerPath, WebPath]

global Refreshing := false

global TiteModeStartsWith  :=1
global TiteModeContains    :=2 ; default
global TiteModeExact       :=3

; #region Create Gui

Gui1 := Gui("+Resize")
Gui1.Title:="AhkLauncher  v1.0.0.2"
;Gui1.BackColor := "232b2b" ; Charleston Green
;Gui1.BackColor := "AEDEFF" ; Very Light Blue
Gui1.BackColor := "7DA7CA" ; Steel Blue +2.5 Glaucous

;Gui1.BackColor := "08A1F7" ; Bright Blue
;Gui1.BackColor := "03C1F4" ; Cyan Blue
;Gui1.BackColor := "09E0FE" ; Light Cyan

Gui1.SetFont('s10', 'Cascadia Code')
Gui1.OnEvent('Close', OnGui_Close)
Gui1.OnEvent('Size', OnGui_Size)

;Gui1.Add("Text",, "Pick a file to launch from the list below.")
MyEdit := Gui1.Add("Edit", "W730")
MyEdit.OnEvent("Change", OnEdit_Change)

EM_SETCUEBANNER := 0x1501
CueText := 'Enter your search query here...'
SendMessage EM_SETCUEBANNER, true, StrPtr(CueText), MyEdit


Tabs  := Gui1.AddTab3(, ["AHK", "PC", "SERVER","WEB"])
Tabs.OnEvent("Change", OnTabs_Change)

; White Smoke #F5F5F5       ; Neutral, slightly grayish
; Seashell #FFF5EE          ; Warm, with a hint of peach
; Gainsboro #DCDCDC         ; Pale, soft gray—subtle, clean, and versatile. It’s lighter than “Silver” but darker than “White Smoke.”
; Ghost White #F8F8FF       ; Cool, bluish off‑whit
; Floral White #FFFAF0      ; white with a faint warm undertone, a very pale orange or cream
; Old Lace #FDF5E6
; Lace White #FFFFFF
; Mint Cream #F5FFFA
; Honeydew #F0FFF0
; Ivory #FFFFF0             ; Classic warm off‑white
; Light Gray #D3D3D3
; Light Slate Gray #778899
; Snow #FFFAFA              ; Very close to pure white, faint pink tone
; Slate Gray #708090

; AHK
Tabs.UseTab(1)
LV1 := Gui1.AddListView("r20 w700 BackgroundF5F5F5 Grid Sort", ["Name","Title", "Path"])

; PC
Tabs.UseTab(2)
LV2 := Gui1.AddListView("r20 w700 BackgroundF5F5F5 Grid Sort", ["Name","Value", "Path"])

; SERVER
Tabs.UseTab(3)
LV3 := Gui1.AddListView("r20 w700 BackgroundF5F5F5 Grid Sort", ["Name","Value", "Path"])

; WEB
Tabs.UseTab(4)
LV4 := Gui1.AddListView("r20 w700 BackgroundF5F5F5 Grid Sort", ["Name","Value", "Path"])

LVArray         := [LV1, LV2, LV3, LV4]

Tabs.UseTab()
Filler          := Gui1.AddText("xm w0 Hidden")
ButtonExplore   := Gui1.AddButton("yp w75","Explore").OnEvent("Click", OnButtonExplore_Click)
ButtonRefresh   := Gui1.AddButton("yp w75","Refresh").OnEvent("Click", OnButtonRefresh_Click)
MyCheckBox      := Gui1.AddCheckBox("yp x+40 h24 Checked -Wrap vCheckBox", "Hide Gui")
MyButtonHide    := Gui1.AddButton("yp w75 vHide", "Hide").OnEvent("Click", ToggleGui)

; #region Hotkeys

^!B::Run(AhkAppsPath '\BackupTool.ahk')  
^!C::Run(AhkAppsPath '\CloseAllWindows.ahk')  
^!D::Run(AhkAppsPath '\DownloadTool.ahk')  
^!H::ShowHelp()
^!L::ToggleGui()
^!P::SendPassword()
^!R::Run(AhkAppsPath '\ResetShell.ahk')  
^!S::Run(AhkAppsPath '\PowerTool.ahk')
^!U::SendUsername()
^!V::Run(AhkAppsPath '\BitwardenTool.ahk')
^!LButton::ToggleGui()

ExternalScriptPath:= EnvGet('USERPROFILE') "\Documents\AutoHotkey\AhkLauncher\AhkApps\IncrementVSCodeBuild.ahk"

^NumpadDel::
^NumpadDot::
{    
    if FileExist(ExternalScriptPath) {
        RunWait('"' A_AhkPath '" "' ExternalScriptPath '"')
    }
}


; ^!V:: 
; {
;     if WinExist("Visual Studio Code")
;         WinActivate()
;     else
;         Run("C:\Users\Jim\AppData\Local\Programs\Microsoft VS Code\Code.exe")
; }

#HotIf WinActive("ahk_id " Gui1.Hwnd)
    Esc::
    {
        ; Check if the Edit control specifically has focus
        if (Gui1.FocusedCtrl == myEdit) {
            MyEdit.Text := ''
            Refresh()
        } else {
            ; If you want Escape to still close the window or do something else:
            ;myGui.Hide()
        }
    }

#HotIf

; #region Main

;DEBUG
;ToggleGui()

; Keep script alive in the tray
Persistent

; #region Create Tray Menu

A_TrayMenu.Delete
A_TrayMenu.Add("Open", TrayDefaultAction)
A_TrayMenu.Add()  ; Creates a separator line.
A_TrayMenu.Add("Help", OnTrayMenu_Click)
A_TrayMenu.Add("Credentials", OnTrayMenu_Click)
A_TrayMenu.Add("Exit", OnTrayMenu_Click)

; single left click handler
A_TrayMenu.ClickCount := 1 ; 1 = single-click triggers the default item (instead of double-click)
A_TrayMenu.Default := "Open" ; Set the new item as the default action

; #region Event Handlers

for LV in LVArray
    LV.OnEvent('Click', RunFile)

OnButtonRefresh_Click(GuiCtrl,*) {
    SetFocus(MyEdit)
    Refresh()
}

OnButtonExplore_Click(GuiCtrl,*) {
    SetFocus(MyEdit)
    PathArray[Tabs.Value]
    Run(PathArray[Tabs.Value])
    if MyCheckBox.Value
        Gui1.Hide()
}

OnEdit_Change(*) {
    ListViewFilter()
}

OnGui_Size(GuiObj, MinMax, Width, Height) {

    if (MinMax = -1)
        return

    Gui1.Opt("+MinSize480x320 +MaxSize1880x980")

    Anchor.Add(MyEdit, "w")

    Anchor.Add(Tabs, "wh")

    ;Anchor.Add(LV1, "w h")
    ;Anchor.Add(LV2, "w h")
    ;Anchor.Add(LV3, "w h")
    ;Anchor.Add(LV4, "w h")

    ;static bottomRowArray := [Gui1["Refresh"], Gui1["Explore"], MyCheckBox, Gui1["Hide"]]
    ;Anchor(bottomRowArray, "y")
    ;anchor1.add(bottomRowArray, "y")
    Anchor.Add(Gui1["Refresh"], "y")
    Anchor.Add(Gui1["Explore"], "y")
    Anchor.Add(MyCheckBox, "y")
    Anchor.Add(Gui1["Hide"], "y")

    ; Move the Cancel Button to the bottom right side of the Gui
    ;WinGetPos &GuiX, &GuiY, &GuiWidth, &GuiHeight, Gui1

    ;MyButtonHide.GetPos(&X, &Y, &ButtonWidth, &ButtonHeight)
    ;Gui1["Hide"].GetPos(&X, &Y, &ButtonWidth, &ButtonHeight)

    ;MyButtonHide.Move(GuiWidth-ButtonWidth-Gui1.MarginX*2.5,,,)
    ;Gui1["Hide"].Move(GuiWidth-ButtonWidth-Gui1.MarginX*2.5,,,)

    ; Move the checkbox to the bottom center
    ;MyCheckBox.Move(GuiWidth/2-ButtonWidth/2-Gui1.MarginX*1,,,)
    ;Gui1["CheckBox"].Move(GuiWidth/2-ButtonWidth/2-Gui1.MarginX*1,,,)

}

OnTabs_Change(*) {
    SetFocus(MyEdit)
    MyEdit.Text := ''
    Refresh()
}

TrayDefaultAction(*) {
    Gui1.Show()
}

OnTrayMenu_Click(ItemName, ItemPos, MyMenu) {
    switch ItemName {
        case "Open":
            Gui1.Show()  ; Display the window.
        case "Help":
            ShowHelp()
        case "Credentials":
            EditCredentials()
        case "Exit":
            OnGui_Exit(Gui1)
        default:
            Gui1.Show()
    }

}

OnGui_Close(*)
{

    Gui1.Hide()

    ; Shift + Close or Cancel exits the script
    if GetKeyState('Shift')
        OnGui_Exit(Gui1)
}

OnGui_Exit(Gui1)
{
    Hotkey("^!LButton", "Off") ;^LButton::ToggleGui()
    Hotkey("^!L", "Off") ;^!L::ToggleGui()
    Hotkey("^!P", "Off") ;^!P::SendPassword()
    Hotkey("^!U", "Off") ;^!U::SendUsername()
    Hotkey("^!L", "Off") ;^LButton::ToggleGui()
    ExitApp()
}

; #region Functions

EditCredentials() {
    global Saved

    MyGui := Gui("", "AhkLauncher Edit Credentials") ; Use WinDirStat to get file count
    MyGui.BackColor := "4682B4" ; Steel Blue
    MyGui.SetFont("s12", "Lucida Sans")

    MyTextU := MyGui.Add("Text", "", "Username")
    MyEditU := MyGui.Add("Edit", "vMyEditU ym w350")

    MyTextP := MyGui.Add("Text", "xm", "Password")
    MyEditP := MyGui.Add("Edit", "vMyEditP x+18 yp w350 +Password")

    MyHorzLine := MyGui.Add("Text", "xm w440 h1 0x10") ;SS_ETCHEDHORZ

    MyGui.SetFont("s10", "Segoe UI")

    buttonSubmit := MyGui.Add("Button", "xm+87 w65 Default", "Submit")
    buttonSubmit.OnEvent('Click', OnButtonSubmit_Click)

    buttonReveal := MyGui.Add("Button", "yp w65", "Reveal")
    buttonReveal.OnEvent('Click', TogglePassword)

    buttonHide := MyGui.Add("Button", "yp w65", "Cancel")
    buttonHide.OnEvent('Click', OnButtonHide_Click)

    if (!cred := CredMgr.CredRead("AhkLauncher")) {
        MsgBox "Credentials not found", "ERROR", "IconX"
        return
    }

    MyEditU.Text := cred.Username
    MyEditP.Text := cred.Password

    MyGui.Show()

    ; #Region Functions

    OnButtonSubmit_Click(GuiCtrl,*) {

        if (MyEditU.Text = '' || MyEditP.Text = '' ) {
            SoundBeep
            return
        }

        Saved := MyGui.Submit()

        if !CredMgr.CredWrite("AhkLauncher", Saved.MyEditU, Saved.MyEditP)
            MsgBox "Failed to write credentials", "CredWrite Error"
   }

    OnButtonHide_Click(GuiCtrl,*) {
        MyGui.Submit()
    }

    TogglePassword(*) {

        IsPasswordMasked() {
            return ControlGetStyle(MyEditP, "A") & 0x20 ? true : false
        }

        MyEditP.Opt(IsPasswordMasked() ? "-Password" : "+Password")

        buttonReveal.Text := (!IsPasswordMasked()) ? "Mask" : "Reveal"

    }
}

FileGetProperty(filePath, property) {
    try {
        shellApp := ComObject('Shell.Application')
        SplitPath(filePath, &filename, &directory)
        folder := shellApp.Namespace(directory)
        fileItem := folder.ParseName(filename)
        return fileItem.ExtendedProperty(property)
    }
    catch as e {
        MsgBox 'Error: ' e.Message
    }
}

; Search the first 10 lines of the script for ";TITLE:"
; If found return the text after the ":"
; Else return ""
; Example: "; TITLE: BackupControlTool v3.0" returns "BackupControlTool v3.0"
;----------------------------------------------------------------------------------
FileGetScriptTitle(ScriptPath) {

    if !FileExist(ScriptPath)
        return ""

    content := FileRead(ScriptPath)
    count := 10
    title:= ""

    Loop Parse content, "`r", "`n" {
        if (SubStr(StrReplace(A_LoopField, A_Space, ''), 1, 7) = ";TITLE:") {
            title := SubStr(A_LoopField, InStr(A_LoopField, ":") +1)
        }
        count--
        if (count < 0)
            break
    }
    return Trim(title)
}

ListViewFilter() {
    global Refreshing, MapsArray
    
    if Refreshing
        return

    if MyEdit.Text = "" {
        Refreshing := true
        Refresh()
        Refreshing := false
    }

    ; get the search key
    searchKey := MyEdit.Text

    if (searchKey = '')
        return

    activeTab := Tabs.Value
    activeMap := MapsArray[activeTab]
    activeLV := LVArray[activeTab]
    rowNum := activeLV.GetNext(0, "F")

    ; search the list view map for the text in the Edit
    filteredMap := Map()

    for k, v in activeMap {
        if InStr(k, searchKey)
            filteredMap.Set(k, v)
    }

    ; load the Items found into the ListView
    ListViewLoad(activeLV, filteredMap)
}

ListViewLoad(activeLV, LVMap) {

    activeLV.Delete

    activeLV.Opt("-Redraw")

    ;TODO: value is different for each tab
    ;AHK = description, PC=path, SERVER=path, WEB=url
    for k, v in LVMap {

        p:=v

        if (SubStr(k,-3,3) = "lnk") {
            ahkPath:= PathArray[Tabs.Value] "\" k

             ;MsgBox ahkPath, "ListViewLoad"
            ;p := StrSplitShortcut(AhkPath).Target

            FileGetShortcut AhkPath, &v
            p:=v

            if (Tabs.Value = 1)
               v:= ""
        }

        if (SubStr(k,-3,3) = "ahk") {
            p := AhkAppsPath "\" k
            v := FileGetScriptTitle(p)
        }

        if (SubStr(k,1,1) = "%") {
            p := EnvGet(StrReplace(k, "%", ""))
        }

        activeLV.Add('', k, v, p)
    }

    activeLV.Modify(1, "+Select +Focus")
    activeLV.ModifyCol(1, "AutoHdr") 
    activeLV.ModifyCol(2, "AutoHdr") 
    activeLV.ModifyCol(3, 0) 

    activeLV.Opt("+Redraw")
}

Refresh() {
    global MapsArray

    excludedExt := "ini"

    AHKMap := Map()
    ServerMap := Map()
    WEBMap := Map()

    Loop Files, AhkAppsPath "/*" {

        SplitPath(A_LoopFileFullPath, &OutName, &OutDir, &OutExt, &OutNameNoExt, &OutDrive)

        if (OutExt = 'lnk')
            FileGetShortcut A_LoopFileFullPath, &OutTarget
        else
            OutTarget := A_LoopFileFullPath

        if (OutExt!='ini')
            AHKMap.Set(OutName, "TBD")
    }

    Loop Files, SERVERPath "/*" {

        if (A_LoopFileExt = 'lnk')
            FileGetShortcut(A_LoopFileFullPath, &OutTarget)
        else
            OutTarget := A_LoopFileFullPath

        ServerMap.Set(A_LoopFileName, OutTarget)
    }

    Loop Files, WEBPath "/*" {
        targetUrl := IniRead(A_LoopFileFullPath, "InternetShortcut", "URL")
        WEBMap.Set(A_LoopFileName, targetUrl)
    }
 
    MapsArray    := [AHKMap, PCMap, ServerMap, WebMap]

    activeTab := Tabs.Value
    activeMap := MapsArray[activeTab]
    activeLV := LVArray[activeTab]

    ListViewLoad(activeLV, activeMap)
}

RunFile(LV, RowNumber)
{
    FileName := LV.GetText(RowNumber, 1)
    FileDir  := LV.GetText(RowNumber, 2)
    FilePath := LV.GetText(RowNumber, 3)
    
    try
        Run(FilePath)
    catch
        MsgBox("Could not Run:`n`n" FilePath)
    
    if MyCheckBox.Value
        Gui1.Hide()
}

SendPassword() {

    if (!cred := CredMgr.CredRead("AhkLauncher")) {
        MsgBox "Credentials not found", "ERROR", "IconX"
        return
    }
    Sleep(250)
    SetKeyDelay(25)
    SendEvent(cred.password)
    SendEvent("{Enter}")
    SetKeyDelay(10)
}

SendUsername() {

    if (!cred := CredMgr.CredRead("AhkLauncher")) {
        MsgBox "Credentials not found", "ERROR", "IconX"
        return
    }
    Sleep(250)
    SetKeyDelay(25)
    SendEvent(cred.username)
    SendEvent("{Enter}")
    SetKeyDelay(10)
}

SetFocus(Ctrl) {
    ControlFocus(Ctrl, Gui1)
}

; #region Help

ShowHelp() {
    ;WriteStatus()
    helpText := "
(
AutoHotkey Launcher HotKeys:

^!B     BackupTool

^!C     CloseAllWindows

^!D     DownloadTool

^!H     ShowHelp()

^!L     ToggleGui()

^!P     SendPassword()

^!R     ResetShell

^!S     PowerTool

^!U     SendUsername()

^!V     BitwardenTool

)"
    MsgBox(helpText, "AhkLauncherHelp")
}

ToggleGui(*) {
    if WinActive(Gui1) {
        Gui1.Hide()
        MyEdit.Text := ''
    } else {
        Refresh()

        ;Anchor_Reset("All")

        Gui1.Show()
    }
}


Class ENV_SETTINGS {

    static ALL := unset

    static GetAll() {
        this.ALL := this.CombineMaps(this.ENV_VARS, this.SHELL_VARS, this.MS_SETTINGS, this.CSLID_VARS)
        return this.ALL
    }

    static CombineMaps(Maps*) {
        NewMap := Map()
        for SourceMap in Maps {
            for key, value in SourceMap {
                NewMap[key] := value
            }
        }
        return NewMap
    }

    static ENV_VARS := Map(
        "%ALLUSERSPROFILE%","C:\ProgramData",
        "%APPDATA%","C:\Users\(user-name)\AppData\Roaming",
        "%CommonProgramFiles(x86)%","C:\Program Files (x86)\Common Files",
        "%CommonProgramFiles%","C:\Program Files\Common Files",
        "%CommonProgramW6432%","C:\Program Files\Common Files",
        "%DriverData%","C:\Windows\System32\Drivers\DriverData",
        "%LOCALAPPDATA%","C:\Users\(user-name)\AppData\Local",
        "%ProgramData%","C:\ProgramData",
        "%ProgramFiles(x86)%","C:\Program Files (x86)",
        "%ProgramFiles%","C:\Program Files",
        "%ProgramW6432%","C:\Program Files",
        "%PUBLIC%","C:\Users\Public",
        "%SystemRoot%","C:\Windows",
        "%TEMP%","C:\Users\(user-name)\AppData\Local\Temp",
        "%TMP%","C:\Users\(user-name)\AppData\Local\Temp",
        "%USERPROFILE%","C:\Users\(user-name)",
        "%WINDIR%","C:\Windows",
        )

    static MS_SETTINGS := Map(
        "3D Objects", "shell:3D Objects",
        "About", "ms-settings:about",
        "About (System Info)", "ms-settings:about",
        "Account Pictures", "shell:AccountPictures",
        "Activation", "ms-settings:activation",
        "Add New Programs Folder", "shell:AddNewProgramsFolder",
        "Advanced Options (Update)", "ms-settings:windowsupdate-options",
        "Airplane Mode", "ms-settings:network-airplanemode",
        "App", "URI Scheme",
        "App Data", "shell:AppData",
        "App Updates Folder", "shell:AppUpdatesFolder",
        "Application Mods", "shell:AppMods",
        "Apps Folder", "shell:AppsFolder",
        "Auto Play", "ms-settings:autoplay",
        "Background", "ms-settings:personalization-background",
        "Background ", "ms-settings:personalization-background ",
        "Bluetooth & Devices", "ms-settings:bluetooth",
        "Cache", "shell:Cache",
        "Calculator", "calculator:",
        "Calendar", "outlookcal:",
        "Camera", "ms-settings:privacy-webcam",
        "Camera Privacy", "ms-settings:privacy-webcam",
        "Camera Roll", "shell:Camera Roll",
        "Camera Roll Library", "shell:CameraRollLibrary",
        "Cameras", "ms-settings:camera",
        "Captions", "ms-settings:easeofaccess-closedcaptioning",
        "Captures", "shell:Captures",
        "Change Remove Programs Folder", "shell:ChangeRemoveProgramsFolder",
        "Clock", "ms-clock:",
        "Clock/Alarms", "ms-clock: ",
        "Colors", "ms-settings:colors",
        "Common AppData", "shell:Common AppData",
        "Common Templates", "shell:Common Templates",
        "Common Ringtones", "shell:CommonRingtones",
        "ConflictFolder", "shell:ConflictFolder",
        "ConnectionsFolder", "shell:ConnectionsFolder",
        "Contacts", "shell:Contacts",
        "ControlPanelFolder", "shell:ControlPanelFolder",
        "Cookies", "shell:Cookies",
        "CredentialManager", "shell:CredentialManager",
        "CryptoKeys", "shell:CryptoKeys",
        "Date & Time", "ms-settings:dateandtime",
        "Default Apps", "ms-settings:defaultapps",
        "Desktop", "shell:Desktop",
        "Desktop Foler", "shell:ThisPCDesktopFolder",
        "Development Files", "shell:Development Files",
        "Device Metadata Store", "shell:Device Metadata Store",
        "Diagnostics & Feedback", "ms-settings:privacy-feedback",
        "Display", "ms-settings:display",
        "Documents Library", "shell:DocumentsLibrary",
        "Documents Local", "shell:Local Documents",
        "Downloads", "shell:Downloads",
        "Downloads Local", "shell:Local Downloads",
        "Dpapi Keys", "shell:DpapiKeys",
        "Edge", "microsoft-edge:",
        "Ethernet", "ms-settings:network-ethernet",
        "Favorites", "shell:Favorites",
        "Find My Device", "ms-settings:findmydevice",
        "Find My Device:", "ms-settings:findmydevice",
        "Focus", "ms-settings:focus",
        "Fonts", "ms-settings:fonts",
        "Game Tasks", "shell:GameTasks",
        "God Mode", "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}",
        "History", "shell:History",
        "Implicit App Shortcuts", "shell:ImplicitAppShortcuts",
        "Installed Apps", "ms-settings:appsfeatures",
        "Language & Region", "ms-settings:regionlanguage",
        "Libraries", "shell:Libraries",
        "Links", "shell:Links",
        "Local AppData", "shell:Local AppData",
        "Local AppDataLow", "shell:LocalAppDataLow",
        "Localized Resources Dir", "shell:LocalizedResourcesDir",
        "Location", "ms-settings:privacy-location",
        "Location Privacy", "ms-settings:privacy-location",
        "Lock Screen", "ms-settings:lockscreen",
        "Microphone Privacy", "ms-settings:privacy-microphone",
        "Microphone", "ms-settings:privacy-microphone",
        "Microsoft Edge", "microsoft-edge:https://www.google.com ",
        "Microsoft Store", "ms-store:",
        "Mobile Hotspot", "ms-settings:network-mobilehotspot",
        "Mouse", "ms-settings:mousetouchpad",
        "Multitasking", "ms-settings:multitasking",
        "Music", "shell:My Music",
        "Music Library", "shell:MusicLibrary",
        "Music Local", "shell:Local Music",
        "MyComputer Folder", "shell:MyComputerFolder",
        "Narrator", "ms-settings:easeofaccess-narrator",
        "Nearby Sharing", "ms-settings:nearbysharing",
        "NetHood", "shell:NetHood",
        "Network Status", "ms-settings:network",
        "Network Places Folder", "shell:NetworkPlacesFolder",
        "Notifications", "ms-settings:notifications",
        "OEM Links", "shell:OEM Links",
        "Offline Maps", "ms-settings:maps",
        "OneDrive", "shell:OneDrive",
        "OneDriveCameraRoll", "shell:OneDriveCameraRoll",
        "OneDriveDocuments", "shell:OneDriveDocuments",
        "OneDriveMusic", "shell:OneDriveMusic",
        "OneDrivePictures", "shell:OneDrivePictures",
        "Original Images", "shell:Original Images",
        "Personal", "shell:Personal",
        "Photos", "ms-photos:",
        "Pictures", "shell:My Pictures",
        "Pictures Library", "shell:PicturesLibrary",
        "Pictures Local", "shell:Local Pictures",
        "Playlists", "shell:Playlists",
        "Power & Battery", "ms-settings:powersleep",
        "Printers & Scanners", "ms-settings:printers",
        "Printers Folder", "shell:PrintersFolder",
        "Print Hood", "shell:PrintHood",
        "Privacy", "ms-settings:privacy-location",
        "Profile", "shell:Profile",
        "Program Files", "shell:ProgramFiles",
        "Program Files (x86)", "shell:ProgramFilesX86",
        "ProgramFilesCommon", "shell:ProgramFilesCommon",
        "ProgramFilesCommonX64", "shell:ProgramFilesCommonX64",
        "ProgramFilesCommonX86", "shell:ProgramFilesCommonX86",
        "ProgramFilesX64", "shell:ProgramFilesX64",
        "Programs", "shell:Programs",
        "Programs Common", "shell:Common Programs",
        "Proxy", "ms-settings:network-proxy",
        "Public", "shell:Public",
        "Public Account Pictures", "shell:PublicAccountPictures",
        "Public Desktop", "shell:Common Desktop",
        "Public Documents", "shell:Common Documents",
        "Public Downloads", "shell:CommonDownloads",
        "Public Game Tasks", "shell:PublicGameTasks",
        "Public Libraries", "shell:PublicLibraries",
        "Public Music", "shell:CommonMusic",
        "Public Pictures", "shell:CommonPictures",
        "Public Videos", "shell:CommonVideo",
        "Quick Launch", "shell:Quick Launch",
        "Recent Items", "shell:Recent",
        "Recorded Calls", "shell:Recorded Calls",
        "Recorded TV", "shell:RecordedTVLibrary",
        "Recovery", "ms-settings:recovery",
        "Recycle Bin", "shell:RecycleBinFolder",
        "Resource Dir", "shell:ResourceDir",
        "Retail Demo", "shell:Retail Demo",
        "Ringtones", "shell:Ringtones",
        "Roamed Tile Images", "shell:Roamed Tile Images",
        "Roaming Tiles", "shell:Roaming Tiles",
        "Saved Games", "shell:SavedGames",
        "Saved Pictures", "shell:SavedPictures",
        "Saved Pictures Library", "shell:SavedPicturesLibrary",
        "Screenshots", "shell:Screenshots",
        "Search History Folder", "shell:SearchHistoryFolder",
        "Search Home Folder", "shell:SearchHomeFolder",
        "Search Templates Folder", "shell:SearchTemplatesFolder",
        "Searches", "shell:Searches",
        "Send To", "shell:SendTo",
        "Settings", "Ms-settings:",
        "Sign-in Options", "ms-settings:signinoptions ",
        "Slide Shows", "shell:PhotoAlbums",
        "Sound", "ms-settings:sound",
        "Start Menu", "shell:Start Menu",
        "Start Menu Common", "shell:Common Start Menu",
        "Start Menu Common Places", "shell:Common Start Menu Places",
        "Startup", "shell:Startup",
        "Startup Apps", "ms-settings:startupapps",
        "Startup Apps ", "ms-settings:startupapps ",
        "Startup Common", "shell:Common Startup",
        "Storage", "ms-settings:storagesense",
        "Sync Center Folder", "shell:SyncCenterFolder",
        "Sync Results Folder", "shell:SyncResultsFolder",
        "Sync Setup Folder", "shell:SyncSetupFolder",
        "System", "shell:System",
        "System Certificates", "shell:SystemCertificates",
        "System Home", "ms-settings:system",
        "SystemX86", "shell:SystemX86",
        "Taskbar", "ms-settings:taskbar",
        "Taskbar ", "ms-settings:taskbar ",
        "Templates", "shell:Templates",
        "Temporary Burn Folder", "shell:CD Burning",
        "Text Size", "ms-settings:easeofaccess-display",
        "Themes", "ms-settings:themes",
        "Themes ", "ms-settings:themes ",
        "This Device Folder", "shell:ThisDeviceFolder",
        "Touchpad", "ms-settings:devices-touchpad",
        "Troubleshoot", "ms-settings:troubleshoot",
        "Uninstall", "shell:ChangeRemoveProgramsFolder",
        "Update History", "ms-settings:windowsupdate-history",
        "USB", "ms-settings:usb",
        "User Pinned", "shell:User Pinned",
        "User Program Files", "shell:UserProgramFiles",
        "User Program Files Common", "shell:UserProgramFilesCommon",
        "Users", "shell:UserProfiles",
        "Users Files Folder", "shell:UsersFilesFolder",
        "Users Libraries Folder", "shell:UsersLibrariesFolder",
        "Videos", "shell:My Video",
        "Videos Library", "shell:VideosLibrary",
        "Videos Local", "shell:Local Videos",
        "Visual Effects", "ms-settings:easeofaccess-visualeffects",
        "VPN", "ms-settings:network-vpn",
        "Weather", "msnweather:",
        "Weather ", "msnweather: ",
        "Wi-Fi", "ms-settings:network-wifi",
        "Windows", "shell:Windows",
        "Windows Security", "ms-settings:windowsdefender",
        "Windows Security:", "ms-settings:windowsdefender",
        "Windows Tools", "shell:Administrative Tools",
        "Windows Tools Common", "shell:Common Administrative Tools",
        "Windows Update", "ms-settings:windowsupdate",
        "Windows Update ", "ms-settings:windowsupdate",
        "Your Info ", "ms-settings:yourinfo ",
    )

    static SHELL_VARS := Map(
        "3D Objects","shell:3D Objects",
        "Account Pictures","shell:AccountPictures",
        "AddNewProgramsFolder","shell:AddNewProgramsFolder",
        "Windows Tools","shell:Administrative Tools",
        "AppData","shell:AppData",
        "Application Mods","shell:AppMods",
        "AppsFolder","shell:AppsFolder",
        "AppUpdatesFolder","shell:AppUpdatesFolder",
        "Cache","shell:Cache",
        "Camera Roll","shell:Camera Roll",
        "Camera Roll","shell:CameraRollLibrary",
        "Captures","shell:Captures",
        "ChangeRemoveProgramsFolder","shell:ChangeRemoveProgramsFolder",
        "God Mode", "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}",
        "Common AppData","shell:Common AppData",
        "Public Desktop","shell:Common Desktop",
        "Public Documents","shell:Common Documents",
        "Programs","shell:Common Programs",
        "Start Menu","shell:Common Start Menu",
        "Start Menu","shell:Common Start Menu Places",
        "Startup","shell:Common Startup",
        "Common Templates","shell:Common Templates",
        "Public Downloads","shell:CommonDownloads",
        "Public Music","shell:CommonMusic",
        "Public Pictures","shell:CommonPictures",
        "CommonRingtones","shell:CommonRingtones",
        "Public Videos","shell:CommonVideo",
        "ConflictFolder","shell:ConflictFolder",
        "ConnectionsFolder","shell:ConnectionsFolder",
        "Contacts","shell:Contacts",
        "ControlPanelFolder","shell:ControlPanelFolder",
        "Cookies","shell:Cookies",
        "CredentialManager","shell:CredentialManager",
        "CryptoKeys","shell:CryptoKeys",
        "Desktop","shell:Desktop",
        "Development Files","shell:Development Files",
        "Device Metadata Store","shell:Device Metadata Store",
        "Documents","shell:DocumentsLibrary",
        "Downloads","shell:Downloads",
        "DpapiKeys","shell:DpapiKeys",
        "Favorites","shell:Favorites",
        "Fonts","shell:Fonts",
        "GameTasks","shell:GameTasks",
        "History","shell:History",
        "ImplicitAppShortcuts","shell:ImplicitAppShortcuts",
        "Libraries","shell:Libraries",
        "Links","shell:Links",
        "Local AppData","shell:Local AppData",
        "Documents","shell:Local Documents",
        "Downloads","shell:Local Downloads",
        "Music","shell:Local Music",
        "Personal","shell:Personal",
        "Pictures","shell:Local Pictures",
        "Videos","shell:Local Videos",
        "LocalAppDataLow","shell:LocalAppDataLow",
        "LocalizedResourcesDir","shell:LocalizedResourcesDir",
        "Music Library","shell:MusicLibrary",
        "Music","shell:My Music",
        "Pictures","shell:My Pictures",
        "Videos","shell:My Video",
        "MyComputerFolder","shell:MyComputerFolder",
        "NetHood","shell:NetHood",
        "NetworkPlacesFolder","shell:NetworkPlacesFolder",
        "OEM Links","shell:OEM Links",
        "OneDrive","shell:OneDrive",
        "OneDriveCameraRoll","shell:OneDriveCameraRoll",
        "OneDriveDocuments","shell:OneDriveDocuments",
        "OneDriveMusic","shell:OneDriveMusic",
        "OneDrivePictures","shell:OneDrivePictures",
        "Original Images","shell:Original Images",
        "Slide Shows","shell:PhotoAlbums",
        "Temporary Burn Folder","shell:CD Burning",
        "Pictures","shell:PicturesLibrary",
        "Playlists","shell:Playlists",
        "PrintersFolder","shell:PrintersFolder",
        "PrintHood","shell:PrintHood",
        "Profile","shell:Profile",
        "Program Files","shell:ProgramFiles",
        "ProgramFilesCommon","shell:ProgramFilesCommon",
        "ProgramFilesCommonX64","shell:ProgramFilesCommonX64",
        "ProgramFilesCommonX86","shell:ProgramFilesCommonX86",
        "ProgramFilesX64","shell:ProgramFilesX64",
        "Program Files (x86)","shell:ProgramFilesX86",
        "Programs","shell:Programs",
        "Public","shell:Public",
        "Public Account Pictures","shell:PublicAccountPictures",
        "PublicGameTasks","shell:PublicGameTasks",
        "PublicLibraries","shell:PublicLibraries",
        "Quick Launch","shell:Quick Launch",
        "Recent Items","shell:Recent",
        "Recorded Calls","shell:Recorded Calls",
        "Recorded TV","shell:RecordedTVLibrary",
        "RecycleBinFolder","shell:RecycleBinFolder",
        "ResourceDir","shell:ResourceDir",
        "Retail Demo","shell:Retail Demo",
        "Ringtones","shell:Ringtones",
        "Roamed Tile Images","shell:Roamed Tile Images",
        "Roaming Tiles","shell:Roaming Tiles",
        "Saved Games","shell:SavedGames",
        "Saved Pictures","shell:SavedPictures",
        "Saved Pictures","shell:SavedPicturesLibrary",
        "Screenshots","shell:Screenshots",
        "Searches","shell:Searches",
        "SearchHistoryFolder","shell:SearchHistoryFolder",
        "SearchHomeFolder","shell:SearchHomeFolder",
        "SearchTemplatesFolder","shell:SearchTemplatesFolder",
        "SendTo","shell:SendTo",
        "Start Menu","shell:Start Menu",
        "Startup","shell:Startup",
        "SyncCenterFolder","shell:SyncCenterFolder",
        "SyncResultsFolder","shell:SyncResultsFolder",
        "SyncSetupFolder","shell:SyncSetupFolder",
        "System","shell:System",
        "SystemCertificates","shell:SystemCertificates",
        "SystemX86","shell:SystemX86",
        "Templates","shell:Templates",
        "ThisDeviceFolder","shell:ThisDeviceFolder",
        "Desktop","shell:ThisPCDesktopFolder",
        "User Pinned","shell:User Pinned",
        "Users","shell:UserProfiles",
        "UserProgramFiles","shell:UserProgramFiles",
        "UserProgramFilesCommon","shell:UserProgramFilesCommon",
        "UsersFilesFolder","shell:UsersFilesFolder",
        "UsersLibrariesFolder","shell:UsersLibrariesFolder",
        "Videos","shell:VideosLibrary",
        "Windows","shell:Windows",
        "Windows Tools","shell:Common Administrative Tools",
    )

    static CSLID_VARS := Map(
        "3D Objects","shell:::{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}",
        "About System","shell:::{BB06C0E4-D293-4f75-8A90-CB05B6477EEE}",
        "All Control Panel Items","shell:::{21EC2020-3AEA-1069-A2DD-08002B30309D}",
        "All Tasks","shell:::{ED7BA470-8E54-465E-825C-99712043E01C}",
        "Applications","shell:::{4234d49b-0245-4df3-b780-3893943456e1}",
        "AppSuggestedLocations","shell:::{c57a6066-66a3-4d91-9eb9-41532179f0a5}",
        "AutoPlay","shell:::{9C60DE1E-E5FC-40f4-A487-460851A8D915}",
        "Launch_Backup and Restore (Windows 7)","shell:::{B98A2BEA-7D42-4558-8BD1-832F41BAC6FD}",
        "BitLocker Drive Encryption","shell:::{D9EF8727-CAC2-4e60-809E-86F80A666C91}",
        "Bluetooth Devices","shell:::{28803F59-3A75-4058-995F-4EE5503B023C}",
        "Classic Windows Search","shell:::{9343812e-1c37-4a49-a12e-4b2d810d956b}",
        "Command Folder","shell:::{437ff9c0-a07f-4fa0-af80-84b6c6440a16}",
        "Common Places FS Folder","shell:::{d34a6ca6-62c2-4c34-8a7c-14709c1ad938}",
        "Control Panel","shell:::{26EE0668-A00A-44D7-9371-BEB064C98683}",
        "Control Panel for Start menu and desktop","shell:::{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}",
        "Credential Manager","shell:::{1206F5F1-0569-412C-8FEC-3204630DFB70}",
        "Default Programs","shell:::{17cd9488-1228-4b2f-88ce-4298e93e0966}",
        "Delegate folder that appears in Computer","shell:::{b155bdf8-02f0-451e-9a26-ae317cfd7779}",
        "Desktop","shell:::{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}",
        "Devices and Printers","shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}",
        "Documents","shell:::{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}",
        "Documents","shell:::{d3162b92-9365-467a-956b-92703aca08af}",
        "Downloads","shell:::{088e3905-0323-4b02-9826-5d99428e115f}",
        "Downloads","shell:::{374DE290-123F-4565-9164-39C4925E467B}",
        "Ease of Access Center","shell:::{D555645E-D4F8-4c29-A827-D93C859C4F2A}",
        "Favorites","shell:::{323CA680-C24D-4099-B94D-446DD2D7249E}",
        "File Explorer Options","shell:::{6DFD7C5C-2451-11d3-A299-00C04F8EF6AF}",
        "File History","shell:::{F6B6E965-E9B2-444B-9286-10C9152EDBC5}",
        "Font settings","shell:::{93412589-74D4-4E4E-AD0E-E0CB621440FD}",
        "Frequent folders","shell:::{3936E9E4-D92C-4EEE-A85A-BC16D5EA0819}",
        "Fusion Cache","shell:::{1D2680C9-0E2A-469d-B787-065558BC7D43}",
        "Get Programs","shell:::{15eae92e-f17a-4431-9f28-805e482dafd4}",
        "HomeGroup","shell:::{67CA7650-96E6-4FDD-BB43-A8E774F73A57}",
        "Homegroup","shell:::{6785BFAC-9D2D-4be5-B7E2-59937E8FB80A}",
        "Installed Updates","shell:::{d450a8a1-9568-45c7-9c0e-b4f9fb4537bd}",
        "Libraries","shell:::{031E4825-7B94-4dc3-B131-E946B44C8DD5}",
        "Linux","shell:::{B2B4A4D1-2754-4140-A2EB-9A76D9D7CDC6}",
        "Media Servers","shell:::{289AF617-1CC3-42A6-926C-E6A863F0E3BA}",
        "Music","shell:::{1CF1260C-4DD0-4ebb-811F-33C572699FDE}",
        "Music","shell:::{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}",
        "My Documents","shell:::{450D8FBA-AD25-11D0-98A8-0800361B1103}",
        "Network","shell:::{208D2C60-3AEA-1069-A2D7-08002B30309D}",
        "Network and Sharing Center","shell:::{8E908FC9-BECC-40f6-915B-F4CA0E70D03D}",
        "Network Computers and Devices","shell:::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}",
        "Network Connections","shell:::{7007ACC7-3202-11D1-AAD2-00805FC1270E}",
        "Network Connections","shell:::{992CFFA0-F557-101A-88EC-00DD010CCC48}",
        "OneDrive","shell:::{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
        "Personalization","shell:::{ED834ED6-4B5A-4bfe-8F11-A626DCB6A921}",
        "Pictures","shell:::{24ad3ad4-a569-4530-98e1-ab02f9417aa8}",
        "Pictures","shell:::{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}",
        "Portable Devices","shell:::{35786D3C-B075-49b9-88DD-029876E11C01}",
        "Power Options","shell:::{025A5937-A6BE-4686-A844-36FE4BEC8B6D}",
        "Previous Versions Results Folder","shell:::{f8c2ab3b-17bc-41da-9758-339d7dbf2d88}",
        "Printers","shell:::{2227A280-3AEA-1069-A2DE-08002B30309D}",
        "Printhood delegate folder","shell:::{ed50fc29-b964-48a9-afb3-15ebb9b97f36}",
        "Programs and Features","shell:::{7b81be6a-ce2b-4676-a29e-eb907a5126c5}",
        "Public Folder","shell:::{4336a54d-038b-4685-ab02-99bb52d3fb8b}",
        "Quick Access","shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}",
        "Recent Files","shell:::{3134ef9c-6b18-4996-ad04-ed5912e00eb5}",
        "Recent Items Instance Folder","shell:::{4564b25e-30cd-4787-82ba-39e73a750b14}",
        "Recent Places Folder","shell:::{22877a6d-37a1-461a-91b0-dbda5aaebc99}",
        "Recycle Bin","shell:::{645FF040-5081-101B-9F08-00AA002F954E}",
        "Remote Printers","shell:::{863aa9fd-42df-457b-8e4d-0de1b8015c60}",
        "RemoteApp and Desktop Connections","shell:::{241D7C96-F8BF-4F85-B01F-E2B043341A4B}",
        "Removable Drives","shell:::{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}",
        "Removable Storage Devices","shell:::{a6482830-08eb-41e2-84c1-73920c2badb9}",
        "Results Folder","shell:::{2965e715-eb66-4719-b53f-1672673bbefa}",
        "Security and Maintenance","shell:::{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}",
        "Sync Center","shell:::{9C73F5E5-7AE7-4E32-A8E8-8D23B85255BF}",
        "Sync Setup Folder","shell:::{2E9E59C0-B437-4981-A647-9C34B9B90891}",
        "System Recovery","shell:::{9FE63AFD-59CF-4419-9775-ABCC3849F861}",
        "The Home folder in File Explorer","shell:::{F874310E-B6B7-47DC-BC84-B9E6B38F5903}",
        "This Device","shell:::{5b934b42-522b-4c34-bbfe-37a3ef7b9c90}",
        "This Device","shell:::{f8278c54-a712-415b-b593-b77a2be0dda9}",
        "This PC","shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}",
        "Troubleshooting","shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}",
        "User Pinned","shell:::{1f3427c8-5c10-4210-aa03-2ee45287d668}",
        "UsersFiles","shell:::{59031a47-3f72-44a7-89c5-5595fe6b30ee}",
        "Videos","shell:::{A0953C92-50DC-43bf-BE83-3742FED03C9C}",
        "Videos","shell:::{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}",
        "Windows Defender Firewall","shell:::{4026492F-2F69-46B8-B9BF-5654FC07E423}",
        "Windows Tools","shell:::{D20EA4E1-3957-11d2-A40B-0C5020524153}",
   )
}
