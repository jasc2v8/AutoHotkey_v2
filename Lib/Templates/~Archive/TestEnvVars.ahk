;ABOUT: Reset .history
/** 
 * TODO:
 *  LaunchList.EnvVars  "%TEMP%", "C:\<user-name>\AppData\Local\Temp"
 *                       ^              ^
 *                    WILL OPEN     WON'T OPEN
 * 
 * 
 *  MOVE CANCEL BUTTON ON GUI SIZE EVEN
 * 
 *  
 *
 *  var := EnvGet("PROGRAMFILES")
 *  
 */
#Requires AutoHotkey v2.0
#SingleInstance Force

; #region Version & Main Icon
;@Ahk2Exe-Set ProductName, AhkLauncher
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-Set LegalCopyright, © 2025 jasc2v8
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, AutoHotkey Launcher
;@Ahk2Exe-Set Originalvar, AhksLauncher.exe
;@Ahk2Exe-SetMainIcon AhkLauncher.ico

;@Inno-Set {{D28D9A2A-ED03-443E-B8C1-EDB4F54B293E}}
;@Inno-Set AppPublisher, AhkApps

; #region Includes
#Include <Class_IniLite>
#Include <AhkFunctions>
;#Include ..\..\Lib\AhkFunctions.ahk

; #region Globals
global MyGui, MyEdit, LV, DDL, buttonRun, buttonMode, buttonCancel
global IsGuiVisible := false
global AHK_APPS_PATH := "D:\Software\DEV\Work\AHK2\AhkApps\"
global INI := ''
global FilesMap := Map()
global EnvVarsMap := Map()
global buttonRun := ''

; #region Hotkeys
;#^!z::HK_z()
^!L::DoToggleGui()
^!P::DoSendPassword()
^!U::DoSendUsername()
;^!R::DoShowRunMenu()

; #region Main


DoCreateGui()
DoRefreshFiles()

;OutputDebug("running Do_Debug")

;Do_RunOne()

Do_Debug()



; #region Handlers


MenuHandler(ItemName, ItemPos, MyMenu) {
    switch ItemName {
        case "Help":
            DoShowHelp()
        case "Open":
            MyGui.Show()  ; Display the window.
        case "Exit":
            OnGui_Exit(MyGui)
    }
    ;MsgBox "You selected " ItemName " (position " ItemPos ")"
}



; #region Functions

#Include <AhkFunctions>

Do_RunOne() {

    param := "shell:AppDataDesktop" ;NO
    ;param := "shell:AppDataDocuments" ;NO
    ;param := "shell:AppData" ;OK

    OutputDebug("RunOne: " param)

        try {

            Run(param)

            ;OutputDebug("SUCCESS")
            ;FileAppend("SUCCESS: " k "`n", logFile)

            HWND:= WinWait('File Explorer',,2) ; timeout
            if (HWND = 0) {
                OutputDebug("RunOne TIMEOUT: " param "`n")
                WinClose()
            } else (
                OutputDebug("RunOne SUCCESS: " param "`n")
                ;Sleep(200)
                WinClose()
                WinWaitClose() 
            )
            
        } catch Error as e {
            ;OutputDebug("ERROR")
            OutputDebug("RunOne ERROR: " param ", " e.Message)  
        }
}

Do_Test(Name, List, LogFile) {

    varsMap := Map()
    varsMap := List

    FileAppend("TEST: " Name ": START: " A_Now "`n", LogFile)

 
    for k, v in varsMap
    {
            FileAppend("k: " k ", v: " v "`n", LogFile)


        if (InStr(k, "AppData") > 0) {

            param := "explorer " v

            OutputDebug('param: [' param ']')

            SetTitleMatchMode 2 ; CONTAINS
            DetectHiddenWindows true
            DetectHiddenText true

            try {
                Run(param)

            MsgBox("Running: " param "`n`n Confirm success/fail and record.")

                ;OutputDebug("SUCCESS")
                ;FileAppend("SUCCESS: " k "`n", logFile)

                HWND:= WinWait('File Explorer',,2) ; timeout
                if (HWND = 0) {
                    FileAppend(Name ": TIMEOUT: " k "`n", LogFile)
                    WinClose()
                } else (
                    FileAppend(Name ": SUCCESS: " k "`n", LogFile)
                    ;Sleep(200)
                    WinClose()
                    WinWaitClose() 
                )
                
            } catch Error as e {
                OutputDebug(Name ": " param ", " e.Message)  
                FileAppend(Name ": ERROR  : " k "`n", LogFile)
                
            }
        }

    }

    FileAppend("TEST: " Name ": END: " A_Now "`n`n", LogFile)

}
Do_Debug() {

    logFile := A_ScriptDir "\TestEnvVars.txt"

    if FileExist(logFile)
        FileDelete(logFile)

    ;Do_Test("EnvVars", LaunchList.EnvVars, logFile)
    Do_Test("ShellVars", LaunchList.ShellVars, logFile)
    ;Do_Test("CLSIDVars", LaunchList.CLSIDVars, logFile)

    Run(logFile)

    MsgBox("Done`n`nSee LogFile opened in default editor.","TestEnvVars Complete","Icon!")

}
Do_Debug_OLD() {

    var := "shell:::{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"

    param := '"' "explorer " var '"'

    param := "explorer " var

    OutputDebug('param: [' param ']')

    try {
        Run(param)
        OutputDebug("SUCCESS")
        
    } catch Error as e {
        OutputDebug("ERROR")
        
    }

    ; OutputDebug("TEST shell:::{0DB7E03F-FC29-4DC6-9020-FF41B59E513A} exists")

    ; if FileExist("shell:::{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}")
    ;     OutputDebug("shell:::{0DB7E03F-FC29-4DC6-9020-FF41B59E513A} exists")
    ; else
    ;     OutputDebug("shell:::{0DB7E03F-FC29-4DC6-9020-FF41B59E513A} does not exist")


    
    return

    MyMap := Map()
    MyMap := LaunchList.EnvVars

    ; MyMap := Map()
    ; MyMap := GetEnvironmentVariables()

    MyType :=Type(MyMap)

    OutputDebug('Type MyMap: ' MyType )

    MsgBox('Type MyMap: ' MyType)

    r := ListObj(MyMap)
    if (r = '')
        MsgBox('Not a Map')
    else
        MsgBox(r)

    var1 := EnvGet("TEMP")
    var2 := EnvGet("%TEMP%")
    ;MsgBox("var1: ", var1 ", var2: " var2)
    ListObj(var1)
    ListObj(var2)

}

DoToggleGui() {
    global

    ;f IsGuiVisible
    if IsGuiVisible
    {
        MyGui.Hide()
        IsGuiVisible := false
        MyEdit.Text := ''
    }
    else
    {
        ;MyGui.Show("NoActivate")
    DoRefreshFiles()
        MyGui.Show()

        IsGuiVisible := true
    }
}

DoListViewLoad(filesMap) {
    ;global LV

    LV.Delete

    for k, v in filesMap
    {
        ;output .= k . ": " . v . "`n"
        output .= filesMap[k] "`n"

        LV.Add('', k, v)
    }

    LV.Modify(1, "+Select +Focus")

      ;Loop LV.GetCount("Column")        LV.ModifyCol(A_Index, "AutoHdr")

    LV.ModifyCol  ; Auto-size each column to fit its contents.
}


DoShowGui() {

    filesMap := DoFindFiles()

    DoListViewLoad(filesMap)


}
DoShowHelp() {
    ;WriteStatus()
    helpText := "
(
AutoHotkey Launcher Help

c:\programFiles\AhkApps\AhkLauncher
    AhkLauncher.exe
    AhkSetupBuilder.exe
    GetFileProerties.exe
    DownloadControl.exe


1. Features:
    - Starts at User Login and remains in the system tray.
    - Hotkeys for Launching AutoHotkey scripts and general use.
    - Hotkey to send username and password to active window.

?. Tray Menu
    - Help: Shows this help text.
    - Open: Opens the GUI window.
    - Exit: Closes the script
)"
    MsgBox(helpText, "Help")
}

OnButtonMode_Click(GuiCtrl,*) {
    global buttonRun

    OutputDebug('buttonRun: ' buttonRun.Text)

    ;MyEdit.Text := 'Mode: ' GuiCtrl.Text

    ;Sleep(250)

    modeText := buttonRun.Text

    switch modeText {
        case "Run":
            DoRefreshEnvVars()
            newText := "Open"
            
        case "Open":
            DoRefreshFiles()
            newText := "Run"
            
        default:
            
    }

    buttonRun.Text := newText

    buttonRun.Focus()
}
OnButton_Click(GuiCtrl,*) {

    OutputDebug('OnButton_Click: ' GuiCtrl.Text)
    OutputDebug('b1: ' buttonRun.Text)
    OutputDebug('b2: ' buttonMode.Text)
    OutputDebug('b3: ' buttonCancel.Text)

    switch GuiCtrl.Text {
        case "Run":
            OnButtonRun_Click(GuiCtrl)
            
        case "Cancel":
            OnGui_Exit(MyGui)
            
        case "EnvVars":
            OnButtonMode_Click(buttonMode)
            
        case "Files":
            OnButtonMode_Click(buttonMode) 

            
        default:
            
    }
   

}

OnButtonRun_Click(GuiCtrl,*) {

    OutputDebug('RunClick: ' GuiCtrl.Text)

    switch GuiCtrl.Text {

        case "Run":
            DoRunSelectedFile()
            
        case "Open":
            DoOpenEnvVar()

        default:
            
    }
}

OnLV_Click(*) {
    OnButtonRun_Click(buttonRun)
}

OnDDL_Change(Ctrl, Info) {

    OutputDebug('OnDDL_Change: ' Ctrl.Text)

    if (Ctrl.Text = "Files")
        buttonRun.Text := "Run"
    else
        buttonRun.Text := "Open"


    DoRefresh(Ctrl.Text)
}

OnGui_Close(*)
{
    ;TODO IF SHIFT KEY DOWN, CLOSE INSTEAD OF HIDE

    ; Hide the GUI window instead of letting the script exit.
    MyGui.Hide()

    ; Optionally, show a tooltip to inform the user it is in the tray
    ;TrayTip("Script Running", "AhkLauncher has been minimized to the system tray.", 1)
    ;Sleep(2500)
    TrayTip

    if GetKeyState('Shift')
        OnGui_Exit(MyGui)
}

OnGui_Exit(MyGui)
{
    ;Hotkey("#^!z", "Off")
    Hotkey("^!L", "Off")

    ExitApp()
}

DoFindFiles() {
    global LV, FilesMap

    static validExt := 'ahk,bat,cmd,exe,lnk'

    FilePattern := AHK_APPS_PATH "\*"

    Loop Files, FilePattern
    {
        SplitPath(A_LoopFilePath, &OutName, &OutDir, &OutExt, &OutNameNoExt, &OutDrive)

        if !InStr(validExt, OutExt)
            continue

        if (OutName = 'AhkAppsLauncher.exe')
            continue

        ;OutputDebug('OutNameNoExt: ' OutNameNoExt)
        ;OutputDebug('A_LoopFilePath: ' A_LoopFilePath)

        ;filesMap[OutNameNoExt] := OutNameNoExt ',' A_LoopFilePath

        FilesMap.Set(OutName, A_LoopFilePath)

        ;OutputDebug('found: ' A_LoopFilePath)
    }

    if filesMap.Count = 0
    {
        return
    }

    return filesMap
}

DoFindEnvVars() {
    global LV, EnvVarsMap
    EnvVarsMap := GetEnvironmentVariables()

    ;ListObj(EnvVarsMap)

    DoListViewLoad(EnvVarsMap)

    return EnvVarsMap
}

DoOpenEnvVar() {
    global DDL, LV

;    ListObj(LaunchList.EnvVars)

    RowNum := LV.GetNext(0, "F")

    var := LV.GetText(RowNum, 1)

    mode := DDL.Text

    switch mode {
        case "EnvVars":
            ;filePath := LaunchList.EnvVars[var]
            filePath := EnvGet(StrReplace(var, "%", ""))
        case "shell::":
              filePath := LaunchList.ShellVars[var]
        case "CLSID":
              filePath := LaunchList.CLSIDVars[var]
        default:
            
    }

    ; OutputDebug('mode: ' mode)
    ; OutputDebug('var: ' var)
    ; OutputDebug('filePath: [' filePath ']')
    

    ;filePath := '%' EnvVarsMap[var] '%'
    ;filePath := EnvVarsMap[var]

    MyEdit.Text := var ', ' filePath

    ; OutputDebug('filePath: [' filePath ']')

    ;Run('"' filePath '"')

    ; ok param := '"' "explorer " var '"'
    param := "explorer " var

    OutputDebug('mode: ' mode)
    OutputDebug('var: ' var)
    OutputDebug('filePath: [' filePath ']')
    OutputDebug('param: [' param ']')

    ; filePath := EnvGet("TEMP")

    ;Run A_ComSpec ' /c ""explorer" "%TEMP%"'

    ;Run 'explorer %TEMP%'

    ;Run(param)
    ;Run(var)

    Run(filePath)
}
DoRefresh(Mode) {

    switch Mode {
        case "EnvVars":
            DoRefreshEnvVars()
            
        case "Files":
            DoRefreshFiles()

        case "shell::":
            DoRefreshShellVars()

        case "CLSID":
            DoRefreshCLSIDVars()
            
        default:
    }
}
DoRefreshEnvVars() {
    varsMap := Map()
    varsMap := LaunchList.EnvVars
    DoListViewLoad(varsMap)
}
DoRefreshShellVars() {
    varsMap := Map()
    varsMap := LaunchList.ShellVars
    DoListViewLoad(varsMap)
}

DoRefreshCLSIDVars() {
    varsMap := Map()
    varsMap := LaunchList.CLSIDVars
    DoListViewLoad(varsMap)
}

DoRefreshFiles() {
    filesMap := DoFindFiles()
    DoListViewLoad(filesMap)
}

DoRunSelectedFile(*) {
    global LV, FilesMap

    RowNum := LV.GetNext(0, "F")

    var := LV.GetText(RowNum, 1)

    filePath := FilesMap[var]

    MyEdit.Text := var ', ' filePath

    OutputDebug('filePath: [' filePath ']')

    Run(filePath)

}
DoSendPassword() {
    ;MyEdit.Text := "^!P pressed"
    Send("PASSWORD")
}

DoSendUsername() {
    MyEdit.Text := "^!U pressed"
}

 ; #region Create Gui

DoCreateGui() {

    global

    MyGui := Gui(, "AhkLauncher") ; ("ToolWindow"
    MyGui.BackColor := "4682B4" ; Steel Blue
    MyGui.SetFont("S10", "Segouie UI") ;w532
    ;MyGui.SetFont('s12', 'Consolas')
    MyEdit := MyGui.Add("Edit", "W520")
    DDL := MyGui.Add("DropDownList", "ym w152 Choose1", 
        ["Files", "EnvVars", "shell::", "CLSID"])
    DDL.OnEvent("Change", OnDDL_Change)

    MyGui.OnEvent('Close', OnGui_Close)

    ; #region Create Tray Menu
    A_TrayMenu.Delete
    A_TrayMenu.Add("Help", MenuHandler)
    A_TrayMenu.Add()  ; Creates a separator line.
    A_TrayMenu.Add("Open", MenuHandler)
    A_TrayMenu.Add("Exit", MenuHandler)

    ; Add the ListView control
    LV := MyGui.Add('ListView', 
        ;'w650 h400 +Grid vMyListView cff0000 LV0x1 LV0x20',
        'xm w720 h400 +Grid vMyListView cff0000 +Report',
        ['Item','Description'])
    
    LV.OnEvent("Click", OnLV_Click)

    buttonExplore := MyGui.Add("Button", "xp w64 h24", "Explore")
    ;buttonMenu := MyGui.Add("Button", "xp w64 h24", "Menu")
        ;.OnEvent("Click", (*) => DoShowMenu())
    ;buttonAdd := MyGui.Add("Button", "yp w64 h24", "Add")
    ;buttonDelete := MyGui.Add("Button", "yp w64 h24", "Delete")

    buttonRun := MyGui.Add("Button", "yp w64 h24 Default", "Run")
    buttonRun.OnEvent("Click", OnButtonRun_Click)

    buttonMode := MyGui.Add("Button", "x500 yp w72 h24", "Mode")
    buttonMode.OnEvent('Click', OnButtonMode_Click)

    buttonCancel := MyGui.Add("Button", "x600 yp w64 h24", "Cancel")
    buttonCancel.OnEvent("Click", (*) => OnGui_Close(MyGui,))

    ;MyGui.Show()
    return
}

Class LaunchList {

    static EnvVars := Map(
        "%ALLUSERSPROFILE%","C:\ProgramData",
        "%APPDATA%","C:\Users\(user-name)\AppData\Roaming",
        "%CommonProgramFiles(x86)%","C:\Program Files (x86)\Common Files",
        "%CommonProgramFiles%","C:\Program Files\Common Files",
        "%CommonProgramW6432%","C:\Program Files\Common Files",
        "%ComSpec%","C:\Windows\System32\cmd.exe",
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
        "AppDataDesktop","shell:AppDataDesktop",
        "AppDataDocuments","shell:AppDataDocuments",
        "AppDataFavorites","shell:AppDataFavorites",
        "AppDataProgramData","shell:AppDataProgramData",
        "Application Shortcuts","shell:Application Shortcuts",
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
        "CSCFolder","shell:CSCFolder",
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
        "InternetFolder","shell:InternetFolder",
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
        "MAPIFolder","shell:MAPIFolder",
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
        "Add Network Place","shell:::{D4480A50-BA28-11d1-8E75-00C04FA31A86}",
        "All Control Panel Items","shell:::{21EC2020-3AEA-1069-A2DD-08002B30309D}",
        "All Tasks","shell:::{ED7BA470-8E54-465E-825C-99712043E01C}",
        "Applications","shell:::{4234d49b-0245-4df3-b780-3893943456e1}",
        "AppSuggestedLocations","shell:::{c57a6066-66a3-4d91-9eb9-41532179f0a5}",
        "AutoPlay","shell:::{9C60DE1E-E5FC-40f4-A487-460851A8D915}",
        "Backup and Restore (Windows 7)","shell:::{B98A2BEA-7D42-4558-8BD1-832F41BAC6FD}",
        "BitLocker Drive Encryption","shell:::{D9EF8727-CAC2-4e60-809E-86F80A666C91}",
        "Bluetooth Devices","shell:::{28803F59-3A75-4058-995F-4EE5503B023C}",
        "Classic Windows Search","shell:::{9343812e-1c37-4a49-a12e-4b2d810d956b}",
        "Command Folder","shell:::{437ff9c0-a07f-4fa0-af80-84b6c6440a16}",
        "Common Places FS Folder","shell:::{d34a6ca6-62c2-4c34-8a7c-14709c1ad938}",
        "Connect To","shell:::{38A98528-6CBF-4CA9-8DC0-B1E1D10F7B1B}",
        "Control Panel","shell:::{26EE0668-A00A-44D7-9371-BEB064C98683}",
        "Control Panel command object for Start menu and desktop","shell:::{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}",
        "Credential Manager","shell:::{1206F5F1-0569-412C-8FEC-3204630DFB70}",
        "Default Programs","shell:::{17cd9488-1228-4b2f-88ce-4298e93e0966}",
        "delegate folder that appears in Computer","shell:::{b155bdf8-02f0-451e-9a26-ae317cfd7779}",
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
        "Manage Wireless Networks","shell:::{1FA9085F-25A2-489B-85D4-86326EEDCD87}",
        "Media Servers","shell:::{289AF617-1CC3-42A6-926C-E6A863F0E3BA}",
        "Microsoft FTP Folder","shell:::{63da6ec0-2e98-11cf-8d82-444553540000}",
        "Microsoft Office Outlook","shell:::{89D83576-6BD1-4c86-9454-BEB04E94C819}",
        "Music","shell:::{1CF1260C-4DD0-4ebb-811F-33C572699FDE}",
        "Music","shell:::{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}",
        "My Documents","shell:::{450D8FBA-AD25-11D0-98A8-0800361B1103}",
        "Network","shell:::{208D2C60-3AEA-1069-A2D7-08002B30309D}",
        "Network and Sharing Center","shell:::{8E908FC9-BECC-40f6-915B-F4CA0E70D03D}",
        "Network Computers and Devices","shell:::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}",
        "Network Connections","shell:::{7007ACC7-3202-11D1-AAD2-00805FC1270E}",
        "Network Connections","shell:::{992CFFA0-F557-101A-88EC-00DD010CCC48}",
        "Offline Files","shell:::{BD7A2E7B-21CB-41b2-A086-B309680C6B7E}",
        "Offline Files Folder","shell:::{AFDB1F70-2A4C-11d2-9039-00C04F8EEB3E}",
        "OneDrive","shell:::{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
        "Personalization","shell:::{ED834ED6-4B5A-4bfe-8F11-A626DCB6A921}",
        "Pictures","shell:::{24ad3ad4-a569-4530-98e1-ab02f9417aa8}",
        "Pictures","shell:::{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}",
        "Portable Devices","shell:::{35786D3C-B075-49b9-88DD-029876E11C01}",
        "Power Options","shell:::{025A5937-A6BE-4686-A844-36FE4BEC8B6D}",
        "Previous Versions","shell:::{9DB7A13C-F208-4981-8353-73CC61AE2783}",
        "Previous Versions Results Delegate Folder","shell:::{a3c3d402-e56c-4033-95f7-4885e80b0111}",
        "Previous Versions Results Folder","shell:::{f8c2ab3b-17bc-41da-9758-339d7dbf2d88}",
        "Printers","shell:::{2227A280-3AEA-1069-A2DE-08002B30309D}",
        "printhood delegate folder","shell:::{ed50fc29-b964-48a9-afb3-15ebb9b97f36}",
        "Programs and Features","shell:::{7b81be6a-ce2b-4676-a29e-eb907a5126c5}",
        "Public Folder","shell:::{4336a54d-038b-4685-ab02-99bb52d3fb8b}",
        "Quick Access","shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}",
        "Recent Files","shell:::{3134ef9c-6b18-4996-ad04-ed5912e00eb5}",
        "Recent Items Instance Folder","shell:::{4564b25e-30cd-4787-82ba-39e73a750b14}",
        "Recent Places Folder","shell:::{22877a6d-37a1-461a-91b0-dbda5aaebc99}",
        "Recycle Bin","shell:::{645FF040-5081-101B-9F08-00AA002F954E}",
        "Remote File Browser","shell:::{0907616E-F5E6-48D8-9D61-A91C3D28106D}",
        "Remote Printers","shell:::{863aa9fd-42df-457b-8e4d-0de1b8015c60}",
        "RemoteApp and Desktop Connections","shell:::{241D7C96-F8BF-4F85-B01F-E2B043341A4B}",
        "Removable Drives","shell:::{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}",
        "Removable Storage Devices","shell:::{a6482830-08eb-41e2-84c1-73920c2badb9}",
        "Results Folder","shell:::{2965e715-eb66-4719-b53f-1672673bbefa}",
        "Run...","shell:::{2559a1f3-21d7-11d4-bdaf-00c04f60b9f0}",
        "Security and Maintenance","shell:::{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}",
        "Set Program Access and Computer Defaults","shell:::{2559a1f7-21d7-11d4-bdaf-00c04f60b9f0}",
        "Show desktop","shell:::{3080F90D-D7AD-11D9-BD98-0000947B0257}",
        "Speech Recognition","shell:::{58E3C745-D971-4081-9034-86E34B30836A}",
        "Start Menu","shell:::{48e7caab-b918-4e58-a94d-505519c795dc}",
        "Storage Spaces","shell:::{F942C606-0914-47AB-BE56-1321B8035096}",
        "Switch between windows","shell:::{3080F90E-D7AD-11D9-BD98-0000947B0257}",
        "Sync Center","shell:::{9C73F5E5-7AE7-4E32-A8E8-8D23B85255BF}",
        "Sync Setup Folder","shell:::{2E9E59C0-B437-4981-A647-9C34B9B90891}",
        "System Recovery","shell:::{9FE63AFD-59CF-4419-9775-ABCC3849F861}",
        "System Restore","shell:::{3f6bc534-dfa1-4ab4-ae54-ef25a74e0107}",
        "Taskbar","shell:::{05d7b0f4-2121-4eff-bf6b-ed3f69b894d9}",
        "Taskbar","shell:::{0DF44EAA-FF21-4412-828E-260A8728E7F1}",
        "The Home folder in File Explorer","shell:::{F874310E-B6B7-47DC-BC84-B9E6B38F5903}",
        "This Device","shell:::{5b934b42-522b-4c34-bbfe-37a3ef7b9c90}",
        "This Device","shell:::{f8278c54-a712-415b-b593-b77a2be0dda9}",
        "This PC","shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}",
        "Troubleshooting","shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}",
        "User Accounts","shell:::{60632754-c523-4b62-b45c-4172da012619}",
        "User Accounts","shell:::{7A9D77BD-5403-11d2-8785-2E0420524153}",
        "User Pinned","shell:::{1f3427c8-5c10-4210-aa03-2ee45287d668}",
        "UsersFiles","shell:::{59031a47-3f72-44a7-89c5-5595fe6b30ee}",
        "Videos","shell:::{A0953C92-50DC-43bf-BE83-3742FED03C9C}",
        "Videos","shell:::{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}",
        "Windows Defender Firewall","shell:::{4026492F-2F69-46B8-B9BF-5654FC07E423}",
        "Windows Features","shell:::{67718415-c450-4f3c-bf8a-b487642dc39b}",
        "Windows Mobility Center","shell:::{5ea4f148-308c-46d7-98a9-49041b1dd468}",
        "Windows Search","shell:::{2559a1f8-21d7-11d4-bdaf-00c04f60b9f0}",
        "Windows Security","shell:::{2559a1f2-21d7-11d4-bdaf-00c04f60b9f0}",
        "Windows Tools","shell:::{D20EA4E1-3957-11d2-A40B-0C5020524153}",
        "Work Folders","shell:::{ECDB0924-4208-451E-8EE0-373C0956DE16}",
   )
}
