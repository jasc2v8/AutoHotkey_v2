;ABOUT: Added cue text for Edit

/**
 * TODO:
 *  Checkbox save state to INI?
 *  Context menu in Gui to access Tray Menu items?
 *
 */
#Requires AutoHotkey v2.0
#SingleInstance Force
;#NoTrayIcon
TraySetIcon('imageres.dll', 250)

Persistent

; #region Version Invo

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, AutoHotkey Launcher
;@Ahk2Exe-Set FileVersion, 0.0.0.1746
;@Ahk2Exe-Set InternalName, AhkLauncher
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, AhkLauncher.exe
;@Ahk2Exe-Set ProductName, AhkLauncher
;@Ahk2Exe-Set ProductVersion, 0.0.0.1
;;;@Ahk2Exe-SetMainIcon AhkLauncher.ico

;@Inno-Set AppId, {{D28D9A2A-ED03-443E-B8C1-EDB4F54B293E}}
;@Inno-Set AppPublisher, jasc2v8

; #region Includes

#Include <Class_IniLite>
#Include <String>

; #region Globals

global AhkAppsDir := EnvGet("USERPROFILE") "\Documents\AutoHotkey\AhkLauncher\AhkApps"
global IniPath    := EnvGet("USERPROFILE") "\Documents\AutoHotkey\AhkLauncher\AhkLauncher.ini"
global AutoHotKey64 := "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"

global INI := ''
global FilesMap := Map()
global EnvVarsMap := Map()
global refreshing := false

; #region Hotkeys

^!C::Run(AhkAppsDir '\CloseAllWindows.ahk')  
^!B::Run(AhkAppsDir '\BackupControlTool.ahk')
^!L::ToggleGui()
^!P::SendPassword()
^!S::Run(AhkAppsDir '\PowerControlTool.ahk')
^!U::SendUsername()
^!LButton::ToggleGui()

; #region Main

Initialize()

CreateGui()

;DEBUG
;EditCredentials()

;_Debug()

; #region Handlers

OnButtonClearEdit_Click(GuiCtrl,*) {
    MyEdit.Text := ''
    ListViewFilter()
}

OnButtonExplore_Click(GuiCtrl,*) {
    RunSelectedFile(true)
}

OnButtonMode_Click(GuiCtrl,*) {

    OutputDebug("OnButtonMode_Click")

    ; get DDL count
    ; Get the items from the DropDownList into an array
    DDLItems := ControlGetItems(DDL)

    ; Get the count of items using the .Length property of the array
    ItemCount := DDLItems.Length

    ; Display the count
    ; OK OutputDebug("Number of items in the DropDownList: " ItemCount)    ; get DDL selected index

    selectedIndex := DDL.Value

    ; ok OutputDebug("selectedIndex: " selectedIndex)    ; get DDL selected index

    ; index += 1
    selectedIndex += 1

    OutputDebug("OnButtonMode_Click selectedIndex: " selectedIndex ", ItemCount: " ItemCount)

    ; if index < cont then index := 1
    if selectedIndex > ItemCount
        selectedIndex := 1

    ; make the new index in the DDL
    DDL.Choose(selectedIndex)

    OnDDL_Change(DDL,'')

    DDL.Focus()

}

OnButtonRun_Click(GuiCtrl,*) {

    OutputDebug('RunClick: ' GuiCtrl.Text)

    switch GuiCtrl.Text {

        case "Run":
            RunSelectedFile()

        case "Open":
            OpenEnvVar()

        default:

    }
}
TrayDefaultAction(*) {
    MyGui.Show()
}

OnTrayMenu_Click(ItemName, ItemPos, MyMenu) {
    switch ItemName {
        case "Open":
            MyGui.Show()  ; Display the window.
        case "Help":
            ShowHelp()
        case "Credentials":
            EditCredentials()
        case "Exit":
            OnGui_Exit(MyGui)
        default:
            MyGui.Show()  ; Display the window.
    }
    ;MsgBox "You selected " ItemName " (position " ItemPos ")"
}
OnLV_Click(*) {
    OnButtonRun_Click(buttonRun)
}

OnDDL_Change(Ctrl, Info) {

    OutputDebug('OnDDL_Change: ' DDL.Text ", Info: " Info)

    if (Ctrl.Text = "Files") {
        buttonRun.Text := "Run"
        buttonExplore.Enabled := true
    }
    else {
        buttonRun.Text := "Open"
        buttonExplore.Enabled := false
    }

    OutputDebug('OnDDL_Change: Refresh ' Ctrl.Text)

    Refresh(Ctrl.Text)

    ListViewFilter()

    DDL.Focus()

}

OnEdit_Change(*) {

    ListViewFilter()
}

OnGui_Close(*)
{

    MyGui.Hide()

    ; Shift + Close or Cancl exits the script
    if GetKeyState('Shift')
        OnGui_Exit(MyGui)
}

OnGui_Exit(MyGui)
{
    Hotkey("^!LButton", "Off") ;^LButton::ToggleGui()
    Hotkey("^!L", "Off") ;^!L::ToggleGui()
    Hotkey("^!P", "Off") ;^!P::SendPassword()
    Hotkey("^!U", "Off") ;^!U::SendUsername()
    Hotkey("^!L", "Off") ;^LButton::ToggleGui()

    ExitApp()
}

;OnGui_Size(MyGui, MyCtrl, xGuiRight:=0, xGuiTop:=0) {
OnGui_Size(*) {

    ; Gui position
    WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui

    xGui := OutX
    yGui := OutY

    wGui := OutWidth
    hGui := OutHeight

    X_Margin := MyGui.MarginX
    Y_Margin := MyGui.MarginY

    xmGui := MyGui.MarginX
    ymGui := MyGui.MarginY

    ; Control position
    buttonCancel.GetPos(&X, &Y, &bWidth, &bHeight)

    ; Move control to the right side of the Gui
    buttonCancel.Move(wGui-bWidth-xmGui*2.5,,,)

    ;DEBUG-----------------------------------------------------
    ;MsgBoxList(,"wGui", wGui, "bWidth", bWidth, "xmGui", xmGui)
    ; OutputDebug("wGui: " wGui ", bWidth: " bWidth ", xmGui: " xmGui ", MATH: " wGui-bWidth-xmGui)
    ; OutputDebug("OutWidth: " OutWidth ", bWidth: " bWidth ", xmGui: " xmGui ", MATH: " wGui-bWidth-xmGui)

    ; if buttons different width, need to compensate
    ;MyButtonCancel.GetPos(&X, &Y, &bWidth, &bHeight)
    ;MyButtonMove.Move(wGui-(bWidth*2)-xmGui,,,)

}
; #region Functions

_Debug() {


}

FindFiles() {
    global FilesMap

    static validExt := 'ahk,bat,cmd,iss,exe,lnk'

    FilesMap := ''
    FilesMap := Map()

    FilePattern := AhkAppsDir "\*"

    Loop Files, FilePattern
    {
        ; split path
        SplitPath(A_LoopFilePath, &OutName, &OutDir, &OutExt, &OutNameNoExt, &OutDrive)

        ; skip if no extension
        if (OutExt = '')
            continue

        ; skip if not a valid extension
        if (InStr(validExt, OutExt) = 0)
            continue

        ; skip if this app (AhkLauncher) is in the directory
        if (OutNameNoExt = StrSplitPath(A_ScriptFullPath).NameNoExt)
            continue

        ; if Shortcut
        if (OutExt = "lnk") {

            targetPath := StrSplitShortcut(A_LoopFilePath).Target

            if !FileExist(targetPath)
                continue

            try {
                fileDescription := FileGetProperty(targetPath, "FileDescription")
                fileVersion := FileGetProperty(targetPath, "FileVersion")
            } catch Error as e {
                MsgBox("Error FileGetProperty: " targetPath ": " e.Message)
            }

            if IsEmpty(fileDescription)
                fileDescription := targetPath

        ; if ahk script
        } else if (OutExt = "ahk") {
            fileDescription := ReadSetting(A_LoopFilePath, ';@Ahk2Exe-Set FileDescription,')
            fileVersion := ReadSetting(A_LoopFilePath, ';@Ahk2Exe-Set FileVersion,')

        ; if exe
        } else {
            try {
                fileDescription := FileGetProperty(A_LoopFilePath, "FileDescription")
                fileVersion := FileGetProperty(A_LoopFilePath, "FileVersion")
            } catch Error as e {
                MsgBox("Error FileGetProperty: " A_LoopFilePath ": " e.Message)
            }
        }

        ; build the version string
        if fileVersion != ''
            fileVersion := " (v" fileVersion ")"

        ; combine strings
        fileNameAndVersion := fileDescription fileVersion

        ; add to map
        try {
            FilesMap.Set(OutName, fileNameAndVersion)

        } catch Error as e {
            MsgBox("Error FilesMap.Set:`n`n" OutName ":`n`n"
                    "Property:`n`n" fileNameAndVersion ":`n`n" e.Message)
        }

        ;ListLines
    }

    OutputDebug("FindFiles FilePattern: " FilePattern)
    OutputDebug("FindFiles count: " FilesMap.Count)

    if FilesMap.Count = 0
        return

    return FilesMap
}

ListViewFilter() {
    global refreshing

    if refreshing
        return

    OutputDebug('ListViewFilter ENTER: ' DDL.Text)

    if MyEdit.Text = "" {
        refreshing := true
        mode := DDL.Text
        Refresh(mode)
        refreshing := false
        OutputDebug('mode: ' mode)
    }

    ; get the search key
    searchKey := MyEdit.Text
    if (searchKey = '')
        return

    ; search the array for the text in the Edit
    try {
        ; clear the previous map

        ;DEBUG MAKE THIS newMap
        FilesMap := Map()

        ; get count of items in the LV
        itemCount := LV.GetCount()

        ; search line by line
        Loop LV.GetCount() {
            rowNumber := A_Index
            Col1Text := LV.GetText(rowNumber, 1)
            Col2Text := LV.GetText(rowNumber, 2)

            OutputDebug("searchKey: " searchKey "`n, Col1Text: [" Col1Text "]" "`n, Col12ext: [" Col2Text "]")

            if InStr(Col1Text, searchKey)
                ;Items.Set(Col1Text, Col2Text)
                FilesMap.Set(Col1Text, Col2Text)
        }

        OutputDebug('ListViewFilter DURING: ' DDL.Text)

        ; load the Items found into the LV
        ListViewLoad(FilesMap)

        OutputDebug('ListViewFilter END: ' DDL.Text)

    } catch TargetError as e {
        MsgBox("Error: Target window or control not found. " e.Message)
    }
}
Initialize() {

    global INI, IniPath, AhkAppsDir

    ;defaultAhkAppsDir := "%USERPROFILE%\.AhkApps\"
    ;defaultAhkAppsDir := "D:\Software\DEV\Work\AHK2\.AhkApps\"
    ;defaultIniPath := StrJoin('\', defaultAhkAppsDir, "AhkLauncher.ini")

    OutputDebug("Initialize: AhkAppsDir:" AhkAppsDir)
    OutputDebug("Initialize: IniPath   :" IniPath)

    if FileExist(IniPath) {

        INI := IniLite(IniPath)

        path := INI.ReadSettings("IniPath")

        if (path != IniPath) {
            IniPath := path
            INI.WriteSettings("IniPath", IniPath)
        }

        dir := INI.ReadSettings("AhkAppsDir")

        if (dir != AhkAppsDir) {
            AhkAppsDir := dir
            INI.WriteSettings("AhkAppsDir", AhkAppsDir)
        }

    } else {
        FileAppend("[Settings]`r`n", IniPath)
        FileAppend("AhkAppsDir=" AhkAppsDir "`r`n", IniPath)
        FileAppend("IniPath=" IniPath "`r`n", IniPath)
    }

    OutputDebug("Initialize END: AhkAppsDir:" AhkAppsDir)
    OutputDebug("Initialize END: IniPath   :" IniPath)

    ;Refresh("Files")
}

ListViewLoad(FilesMap) {

    if (FilesMap = '') {
        OutputDebug("FilesMap Empty")
        return
    }

    LV.Delete

    for k, v in FilesMap {
        LV.Add('', k, v)
    }

    LV.Modify(1, "+Select +Focus")

    ; LV.ModifyCol(1, "AutoHdr")
    ; LV.ModifyCol(2, "AutoHdr")

    Loop LV.GetCount("Column")
        LV.ModifyCol(A_Index, "AutoHdr")
}
OpenEnvVar() {
    global DDL, LV

    rowNum := LV.GetNext(0, "F")

    var := LV.GetText(rowNum, 1)

    mode := DDL.Text

    switch mode {
        case "EnvVars":
            filePath := EnvGet(StrReplace(var, "%", ""))
        case "shell":
            filePath := LaunchList.ShellVars[var]
        case "CLSID":
            filePath := LaunchList.CLSIDVars[var]
        default:

    }

    Run(filePath)

    if MyCheckBox.Value
        MyGui.Hide()
}

FindInFile(textFilePath, findKey) {
    if !FileExist(textFilePath) {
        return
    }
    foundLine := ""
    try {
        fileObj := FileOpen(textFilePath, "r")
        while !fileObj.AtEOF {
            foundLine := fileObj.ReadLine()
            if InStr(foundLine, findKey, true) {
                return foundLine
            }
        }
        fileObj.Close()
    } catch Error {
        Throw "Error reading file: DoFindInFile"
    }
    return
}

ReadSetting(textFilePath, findKey) {
    foundLine := FindInFile(textFilePath, findKey)
    if (!foundLine) {
        return
    }
    lineParts := StrSplit(foundLine, ",")
    return Trim(lineParts[2])
}

Refresh(Mode) {

    ;OutputDebug('Refresh: ' Mode)

    switch Mode {
        case "EnvVars":
            ListViewLoad(LaunchList.EnvVars)

        case "Files":
            ListViewLoad(FindFiles())

        case "shell":
            ListViewLoad(LaunchList.ShellVars)

        case "CLSID":
            ListViewLoad(LaunchList.CLSIDVars)

        default:
    }

    ;MyEdit.Text := 'Filter...'
}

RunSelectedFile(Explore := false) {
    global FilesMap, AutoHotKey64

    rowNum := LV.GetNext(0, "F")

    key := LV.GetText(rowNum, 1)

    if (DDL.Text = "Files") {
        key := LV.GetText(rowNum, 1)
        filePath := JoinPath(, AhkAppsDir, key)
    } else {
        key := LV.GetText(rowNum, 1)
        filePath := EnvGet(StrReplace(key, "%", ""))
    }

    if (Explore)
        Run(AhkAppsDir)
    else
        if (StrSplitPath(filepath).Ext = 'ahk') {
            Run( A_ComSpec ' /c ' '"' AutoHotKey64 '"' ' ' filePath,,'Hide')
        } else
            Run(filePath)

    if MyCheckBox.Value
        MyGui.Hide()

}

CapsLockOff()
{
    SetCapsLockState(false)

    ; if GetKeyState("CapsLock", "T")
    ; {
    ;     MsgBox("CapsLock is ON (Toggled).")
    ; }
    ; else
    ; {
    ;     MsgBox("CapsLock is OFF (Untoggled).")
    ; }


    ; if (Control.IsKeyLocked(Keys.CapsLock))
    ; {
    ;     Win.Send(Keys.CapsLock);
    ; }
}
SelectAhkAppsDir() {
    global AhkAppsDir, INI

    path := FileSelect("D", AhkAppsDir)

    if (path = '')
        return


OutputDebug("AhkAppsDir OLD`t`t`t: " AhkAppsDir)
    AhkAppsDir := path
OutputDebug("AhkAppsDir NEW`t`t`t: " AhkAppsDir)

path := INI.ReadSettings("AhkAppsDir")
OutputDebug("AhkAppsDir INI: " path)

    INI.WriteSettings("AhkAppsDir", AhkAppsDir)

    Refresh("Files")

    OutputDebug("IniPath:`t`t`t" IniPath)
    OutputDebug("SelectAhkAppsDir:`t`t`t" AhkAppsDir)
    OutputDebug("INI AhkAppsDir:`t`t`t" INI.ReadSettings("AhkAppsDir"))

}
SendPassword() {

    if (!cred := CredMgr.CredRead("AhkLauncher")) {
        MsgBox "`Cred not found", "ERROR Credential not found", "Icon!"
    }
    Sleep(250)
    SetKeyDelay(25)
    SendEvent(cred.password)
    SendEvent("{Enter}")
}

SendUsername() {

    if (!cred := CredMgr.CredRead("AhkLauncher")) {
        MsgBox "`Cred not found", "ERROR Credential not found", "Icon!"
    }

    Sleep(250)
    SetKeyDelay(25)
    SendEvent(cred.username)
    SendEvent("{Enter}")

}


ShowGui() {

    OutputDebug("ShowGui BEFORE: " DDL.Text)

    FilesMap := FindFiles()
    ListViewLoad(FilesMap)

    OutputDebug("ShowGui: AFTER " DDL.Text)

}

ShowHelp() {
    ;WriteStatus()
    helpText := "
(
AutoHotkey Launcher Help

SUMMARY:
1. Ctrl+LButton or Ctrl+Alt+L opens the Launcher window.
2. Choose Files, EnvVars, shell, or CLSID variables.
3. Click on the Item to Run Exe or to Explore a Var path.
4. Edit box at Top will filter the list as you type.
5. Right Click Tray Icon to Edit Credentials.

c:\programFiles\AhkApps\AhkLauncher
    AhkLauncher.exe
    AhkSetupBuilder.exe
    GetFileProerties.exe
    DownloadControl.exe

1. Features:
    - Starts at User Login and remains in the system tray.
    - Hotkeys for Launching AutoHotkey scripts and general use.
    - Hotkey to send username and password to active window.
    - List of files in the AhkApp Directory. Click to open

?. Tray Menu
    - Help: Shows this help text.
    - Cred: entials: Opens a window to edit Username and Password.
    - Open: Opens the GUI window.
    - Path: Select the Path for AhkApps folder.
    - Exit: Closes the script
)"
    MsgBox(helpText, "Help")
}

ToggleGui() {

    if WinActive(MyGui)
    {
        MyGui.Hide()
        MyEdit.Text := ''
    }
    else
    {
        Refresh(DDL.Text)
        ;MyGui.Show("NoActivate")
        MyGui.Show()
    }

}

 ; #region Create Gui

CreateGui() {

    global

    MyGui := Gui(, "AhkLauncher v0.0.0.1746") ; Use WinDirStat to get file count
    MyGui.BackColor := "4682B4" ; Steel Blue
    MyGui.SetFont("S10", "Segouie UI") ;w532
    ;MyGui.SetFont('s12', 'Consolas')

    MyEdit := MyGui.Add("Edit", "W350")
    MyEdit.OnEvent("Change", OnEdit_Change)

    buttonClearEdit := MyGui.Add("Button", "ym w72 h24", "🡸Clear") ;W56
    buttonClearEdit.OnEvent('Click', OnButtonClearEdit_Click)

    DDL := MyGui.Add("DropDownList", "ym w88 vMyDDL Choose1",
        ["Files", "EnvVars", "shell", "CLSID"])
    DDL.OnEvent("Change", OnDDL_Change)

    buttonMode := MyGui.Add("Button", "ym w72 h24", "🡸Change")
    buttonMode.OnEvent('Click', OnButtonMode_Click)

    MyGui.OnEvent('Close', OnGui_Close)
    MyGui.OnEvent('Size', OnGui_Size)

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

    ; Define the Windows Message ID (constant) for setting the cue banner
    EM_SETCUEBANNER := 0x1501
    CueText := 'Enter your search query here...'
    SendMessage EM_SETCUEBANNER, true, StrPtr(CueText), MyEdit

    Persistent

    ; Add the ListView control
    LV := MyGui.Add('ListView',
        ;'w650 h400 +Grid vMyListView cff0000 LV0x1 LV0x20',
        'xm w620 h400 +Grid -Multi +Sort vMyListView +Report', ;cff0000
        ['Item','Description'])

    LV.OnEvent("Click", OnLV_Click)

    buttonExplore := MyGui.Add("Button", "xp w64", "Explore")
    buttonExplore.OnEvent("Click", OnButtonExplore_Click)

    buttonRun := MyGui.Add("Button", "yp w64 Default", "Run")
    buttonRun.OnEvent("Click", OnButtonRun_Click)

    MyCheckBox := MyGui.Add("CheckBox", "yp h24 Checked -Wrap", "Hide Gui")

    buttonCancel := MyGui.Add("Button", "yp w64", "Cancel") ;x600
    buttonCancel.OnEvent("Click", (*) => OnGui_Close(MyGui,))

    ; Open from Tray Menu - MyGui.Show()

}

EditCredentials() {
    global Saved

    MyGui := Gui("", "AhkLauncher Edit Credentials") ; Use WinDirStat to get file count
    MyGui.BackColor := "4682B4" ; Steel Blue
    MyGui.SetFont("S12", "Segouie UI") ;w532
    ;MyGui.SetFont('s12', 'Consolas')

    MyTextU := MyGui.Add("Text", "", "Username")
    MyEditU := MyGui.Add("Edit", "vMyEditU ym w350")

    MyTextP := MyGui.Add("Text", "xm", "Password")
    MyEditP := MyGui.Add("Edit", "vMyEditP x+20 yp w350 +Password")

    ;MyEdit.OnEvent("Change", OnEdit_Change)

    MyHorzLine := MyGui.Add("Text", "xm w440 h1 0x10") ;SS_ETCHEDHORZ
    buttonSubmit := MyGui.Add("Button", "xm Default", "Submit")
    buttonSubmit.OnEvent('Click', OnButtonSubmit_Click)

    buttonClear := MyGui.Add("Button", "yp", "Clear")
    buttonClear .OnEvent('Click', OnButtonClear_Click)

    buttonReveal := MyGui.Add("Button", "yp", "Reveal")
    buttonReveal.OnEvent('Click', TogglePassword)

    buttonCancel := MyGui.Add("Button", "yp", "Cancel")
    buttonCancel.OnEvent('Click', OnButtonCancel_Click)

    ; MyEditU.Text := "DEBUG Username"
    ; MyEditP.Text := "DEBUG Password"

    if (!cred := CredMgr.CredRead("AhkLauncher")) {
        MsgBox "`Cred not found", "ERROR Credential not found", "Icon!"
    }

    MyEditU.Text := cred.Username
    MyEditP.Text := cred.Password

    MyGui.Show()

    MyGui.Flash(true)

    OnButtonSubmit_Click(GuiCtrl,*) {

        if (MyEditU.Text = '' || MyEditP.Text = '' ) {
            SoundBeep
            return
        }

        Saved := MyGui.Submit()

        if !CredMgr.CredWrite("AhkLauncher", Saved.MyEditU, Saved.MyEditP)
            MsgBox "failed to write `cred", "CredWrite"

        ; if (cred := CredMgr.CredRead("AhkLauncher"))
        ;     MsgBox cred.name "," cred.username "," cred.password
        ; else
        ;     MsgBox "`Cred not found", "Validate CredDelete Worked"

        ;MsgBox("TEST:" "`cred")
    }

    OnButtonClear_Click(GuiCtrl,*) {
        MyEditU.Text := ""
        MyEditU.Focus()
        MyEditP.Text := ""
    }

    OnButtonCancel_Click(GuiCtrl,*) {
        MyGui.Submit()
        ;MyGui.Destroy()
    }

    TogglePassword(*)
        {
            IsPasswordMasked(){
                return ControlGetStyle(MyEditP, "A") & 0x20 ? true : false
            }

            ; static pset := 1
        	; MyEditP.opt((pset := !pset) ? "+Password" : "-Password")
            ; buttonReveal.Text := (!pset) ? "Mask": "Reveal"

            MyEditP.Opt(IsPasswordMasked() ? "-Password" : "+Password")

            buttonReveal.Text := (!IsPasswordMasked()) ? "Mask" : "Reveal"

        }
}

; #region Classes

Class LaunchList {

    static EnvVars := Map(
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
       static ShellVars := Map(
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
        "Temporary Burn Folder","shell:CD Burning",
        "ChangeRemoveProgramsFolder","shell:ChangeRemoveProgramsFolder",
        "Windows Tools","shell:Common Administrative Tools",
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
        "Pictures","shell:Local Pictures",
        "Videos","shell:Local Videos",
        "LocalAppDataLow","shell:LocalAppDataLow",
        "LocalizedResourcesDir","shell:LocalizedResourcesDir",
        "Music","shell:MusicLibrary",
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
        "Documents","shell:Personal",
        "Slide Shows","shell:PhotoAlbums",
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
  )

    static CLSIDVars := Map(
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
#Include <CredMgr>
FileGetProperty(filePath, property) {
    try
    {
;OutputDebug("create shellApp")
        ; Create a Shell.Application COM object
        shellApp := ComObject('Shell.Application')

        ; Get the parent folder and filename
        SplitPath(filePath, &filename, &directory)
        folder := shellApp.Namespace(directory)
        fileItem := folder.ParseName(filename)

;OutputDebug("get ext prop: " filename)
        ; Get the file version using the ExtendedProperty method
        prop := fileItem.ExtendedProperty(property)

;OutputDebug("return prop: " filename)

        return prop
    }
    catch as e
    {
        MsgBox 'Error: ' e.Message
    }
}
