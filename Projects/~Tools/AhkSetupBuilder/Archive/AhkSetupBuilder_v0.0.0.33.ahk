; #region Version Info Block

; ProductVersion = Major.Minor.Patch.Build
;@AHK2EXE_PATH-Set ProductName, AhkSetupBuilder
;@AHK2EXE_PATH-Set ProductVersion, 0.0.0.9
;@AHK2EXE_PATH-Set LegalCopyright, © 2025 jasc2v8
;@AHK2EXE_PATH-Set CompanyName, jasc2v8
;@AHK2EXE_PATH-Set FileDescription, AutoHotkey Setup Builder
;@AHK2EXE_PATH-Set OriginalFilename, AhkSetupBuilder.exe
;@AHK2EXE_PATH-SetMainIcon AhkSetupBuilder.ico

/*
    TODO:
    make a backup cop to .\Backup?

*/
/**
 * AhkSetupBuilder -- Autohotkey and Inno Setup script compiler.
 * 
 * Features
 *  - One GUI to compile ahk script and create Inno Setup exe.
 *  - One Inno Setup Tempate for ALL your ahk scripts.
 *  - Automatic versioning of Ahk script file.
 *  - Result is a more organized and faster build process.
 *  - Benefit is less manual work and faster development.
 * 
 * Overview
 *  - AhkSetupBuilder will:
 *  -   Compile your .ahk script to an exe file.
 *  -   Compile the exe file to an Inno Setup exe file.
 *  - Automatic Versioning:
 *  -   Explain here...
 * 
 * Inputs/Outputs
 *  - Inputs  (3): .ahk script, .ico icon, .iss script template
 *  - Outputs (3): ahk exe, Inno Setup script, Inno Setup exe file
 * 
 * User Process:
 *  - Run AhkSetupBuiler
 *  - Select the .ahk script for the application to be compiled.
 *  - Select the .iss template script used to compile the setup file.
 *  - Press the Build button to compile both into a _setup.exe file
 *  - Run the _setup.exe file to install the application.
 * 
 * AhkSetupBuiler Process:
 *  - Run AHK2EXE_PATH to compile the selected .ahk script into an exe file.
 *  - Note the version info block from the .ahk script is compiled into the exe file.
 *  - Read the version info vaules from the compiled exe file.
 *  - Read the user selected ISS Script Template.
 *  - Creates a new .iss script from the template.
 *  - Replace the %Placeholder% values in the ISS template script with the
 *  -   values read from the selected .ahk script
 *  - Run Inno Setup to compile the new .iss script into a _setup.exe file.
 * 
 * AhkSetupBuiler Directories
 *  - "C:\Program Files\AutoHotkey Setup Builder\AhkSetupBuiler.exe
 *  - "C:\Program Files\AutoHotkey\Compiler\AHK2EXE_PATH.exe"
 *  - "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
 *  - A_MyDocuments "\AutoHotkey\AhkSetupBuilder\Templates\"
 *  - A_MyDocuments "\AutoHotkey\AhkSetupBuilder\Configs"
 *  - A_Temp "\AhkApps\AhkSetupBuilder\AhkSetupBuilder.ini"
 */

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#Include "..\..\Lib\IniLite.ahk"

MyProductVersionIntheGuiTitle := "v1.0"


/**
 *  Setting a GUID in Inno Setup is crucial for ensuring a 
 * consistent and unique identity for your application across
 * different versions. The GUID (Globally Unique Identifier)
 * is used by the Windows operating system to track your
 * application for uninstallation and updates.
 * 
 *   In Inno Setup, the GUID is defined using the AppId directive
 * in the [Setup] section of your script. You should always set a 
 * unique GUID for your application and keep it consistent for all
 * future installer versions. This prevents the installer from 
 * creating multiple uninstall entries and ensures updates work
 * correctly.
 * 
 *  ;@Inno-AppId is a custom directive that is ignored by
 * the AHK2EXE_PATH compiler. This application reads this value and
 * writes it to the ISS Template you select.
 * 
 *  Search online for "Free Online GUID Generator" or use the one
 * in theInno Setup Compiler (Menu: Tools, Generate GUID).
 */

; This AppId is unique to this AhkSetupBuilder.exe
;@Inno-Set AppId, {{B7D1FB29-B701-4010-8DEA-A5477C60C76D}}

; #region Globals
global ISS_TEMPLATE_PATH := A_MyDocuments "\AutoHotkey\AhkSetupBuilder\Templates\"
global CONFIG_PATH := A_MyDocuments "\AutoHotkey\AhkSetupBuilder\Configs\"
global INI_PATH := A_Temp "\AhkApps\AhkSetupBuilder\AhkSetupBuilder.ini"
global AHK2EXE_PATH := "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
global INNOEXE_PATH := "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
global AHK_EXE_PID := 0
global ISS_EXE_PID := 0

; #region GUI Create
prodVer := DoGetProductVersion()
MyGuiTitle := "AutoHotkey Setup Builder v" . prodVer
MyGui := Gui(, MyGuiTitle )
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w530", "Segouie UI") ; w400=Normal (default)

buttonSelectAhk := MyGui.Add("Button", "xm ym w104 h24", "AHK &Script")
    .OnEvent("Click", (*) => DoSelectFile("AHK"))
editBoxAhk := MyGui.Add("Edit", "yp w640 h24")
buttonCompileAhk := MyGui.Add("Button", "yp w104 h24", "Compile")
    .OnEvent("Click", (*) => DoCompileAhk())
buttonExploreAhk := MyGui.Add("Button", "yp h24", "Explore")
    .OnEvent("Click", (*) => DoExplore("AHK"))

buttonSelectAhkExe := MyGui.Add("Button", "xm w104 h24", "&AHK Exe")
    .OnEvent("Click", (*) => DoSelectFolder("AHK_EXE"))
editBoxAhkExe := MyGui.Add("Edit", "yp w640 h24")
buttonRunAhkExe := MyGui.Add("Button", "yp w48 h24", "Run")
    .OnEvent("Click", (*) => DoExeRun("AHK_EXE"))
buttonStopAhkExe := MyGui.Add("Button", "yp w48 h24", "Stop")
    .OnEvent("Click", (*) => DoExeStop("AHK_EXE"))
buttonExploreAhkExe := MyGui.Add("Button", "yp h24", "Explore")
    .OnEvent("Click", (*) => DoExplore("AHK_EXE"))

buttonSelectIss := MyGui.Add("Button", "xm w104 h24", "Inno &Template")
    .OnEvent("Click", (*) => DoSelectFile("ISS"))
editBoxIss := MyGui.Add("Edit", "yp w640 h24")
buttonCompileIss := MyGui.Add("Button", "yp w104 h24", "Compile")
    .OnEvent("Click", (*) => DoCompileIss())
buttonExploreIss := MyGui.Add("Button", "yp h24", "Explore")
    .OnEvent("Click", (*) => DoExplore("ISS"))

buttonSelectInnoExe := MyGui.Add("Button", "xm w104 h24", "&Inno Exe")
    .OnEvent("Click", (*) => DoSelectFolder("ISS_EXE"))
editBoxIssExe := MyGui.Add("Edit", "yp w640 h24")
buttonRunInnoExe := MyGui.Add("Button", "yp w48 h24", "Run")
    .OnEvent("Click", (*) => DoExeRun("ISS_EXE"))
buttonStopInnoExe := MyGui.Add("Button", "yp w48 h24", "Stop")
    .OnEvent("Click", (*) => DoExeStop("ISS_EXE"))
buttonExploreInnoExe := MyGui.Add("Button", "yp h24", "Explore")
    .OnEvent("Click", (*) => DoExplore("ISS_EXE"))

textWidth := 981-42
MyGui.Add("Text", "xm y+m h1 w" textWidth " +0x9") ; Etched horizontal line that autosizes with the GUI

buttonBuild := MyGui.Add("Button", "xm w104 h24", "&Build")
buttonConfig := MyGui.Add("Button", "yp w104 h24", "&Config")
buttonHelp := MyGui.Add("Button", "yp w104 h24", "&Help")
buttonCancel := MyGui.Add("Button", "yp w104 h24 Default", "Cancel")

myStatusBar := myGui.Add("StatusBar")

; #region OnEvent Bindings

buttonBuild.OnEvent("Click", buttonBuild_Click)
buttonConfig.OnEvent("Click", buttonConfig_Click)
buttonHelp.OnEvent("Click", buttonHelp_Click)
buttonCancel.OnEvent("Click", buttonCancel_Click)

myGui.OnEvent("Close", OnGui_Close)

; #region GUI Show

MyGui.Show()

; Uncomment to determine the width of the Text control:
;MyGui.GetPos(,, &w, &h)
;MsgBox("GUI Dimensions:`n`nWidth: " w "`n`nHeight: " h, "GUI Size")

; #region _Main

DoIniRead()

;DEBUG

ver := DoGetProductVersion()
MsgBox("ver: " ver)

;MsgBox("A_AhkPath: " A_ScriptFullPath . "`n`nA_ScriptFullPath: " A_ScriptFullPath)

;DoAutoVersion()
; fname := "D:\Software\DEV\Work\AHK2\Projects\AhkSetupBuilder\AhkSetupBuilder.ahk"
; r := DoGetFilePathAndVersion(fname)
; MsgBox("r1: [" r[1] "]" "`n`nr2: [" r[2] "]")
; fname := "D:\Software\DEV\Work\AHK2\Projects\AhkSetupBuilder\AhkSetupBuilder_v0.0.0.29.ahk"
; r := DoGetFilePathAndVersion(fname)
; MsgBox("r1: [" r[1] "]" "`n`nr2: [" r[2] "]")

;MsgBox("A_AhkPath: " A_ScriptFullPath . "`n`nA_ScriptFullPath: " A_ScriptFullPath)
; fnameFull := SplitPathObj(fname).Dir .
;     SplitPathObj(fname).NameNoExt

; MsgBox("fnameFull: " fnameFull)

; #region OnEvent Handlers

buttonBuild_Click(*) {

    WriteStatus()

    r :=MsgBox("Compile AHK to EXE?", "Build", "YesNoCancel Default2 Icon?")
    if (r == "Yes")
        DoCompileAhk()
    else if (r == "Cancel")
        return

    r :=MsgBox("Compile Inno to EXE?", "Build", "YesNoCancel Default2 Icon?")
    if (r == "Yes")
        DoCompileIss()
    else if (r == "Cancel")
        return
}

buttonConfig_Click(*) {

    WriteStatus()
     
    r :=MsgBox("Load Config?", "Config", "YesNoCancel Default2 Icon?")
    if (r == "Yes") {
        DoConfigLoad()
        return
    } else if (r == "Cancel")
        return
    
    r :=MsgBox("Save Config?", "Build", "YesNoCancel Default2 Icon?")
    if (r == "Yes")
        DoConfigSave()
}

buttonCancel_Click(*) {
	WinClose()
}

buttonHelp_Click(*) {
	DoShowHelp()
}

OnGui_Close(*) {
    DoExeStop("AHK_EXE")
    DoExeStop("ISS_EXE")
    DoIniWriteAll()
    ExitApp()
}

; #region Functions

DoCompileAhk() {

    DoExeStop("AHK_EXE") ; terminate process if running

    WriteStatus("Running AHK2EXE_PATH to compile EXE...")
 
    ; make sure files exist
    ahkPath := editBoxAhk.Text
    if !FileExist(ahkPath) {
        MsgBox("Error: File not found:`n`n" ahkPath, "Error", "OK Icon!")
        return
    }

    ; check if EXE Dir is valid
    ahkExePath := editBoxAhkExe.Text
    if !DirExist(SplitPathObj(ahkExePath).Dir) {
       MsgBox("Error: EXE Dir not found.", "Error","OK Icon!")
       return
    }

    outDir := SplitPathObj(ahkExePath).Dir
    if !DirExist(outDir) {
        MsgBox("Error: The output directory does not exist:`n`n" . outDir, "Error", "OK Icon!")
        return
    }

    ; run AHK2EXE_PATH
    if !FileExist(AHK2EXE_PATH)  {
        MsgBox("Error: AHK2EXE_PATH Compiler not found at:`n`n" AHK2EXE_PATH  "Error", "OK Icon!")
        return
    }

    ;DEBUG
    r := DoGetFilePathAndVersion(ahkPath)
    iconPath := r[1] ".ico"
    if !FileExist(iconPath) {
        WriteStatus("Icon not found, using default: " iconPath)
    }

    ; The /Q switch makes the compilation quiet. 
    ; The command and path are quoted to handle spaces.
    command :=    '"' AHK2EXE_PATH '"' .
        ;" /base " '"' basePath '"' .  ; use default set by AHK2EXE_PATH GUI 
        " /in " '"' ahkPath '"' .
        " /out " '"' ahkExePath '"' .
        " /silent "

    if FileExist(iconPath) {
        command := command " /icon " '"' iconPath '"'
        iconMsg := '' 
     } else {
        iconMsg := " *** WITH DEFAULT ICON ***"
     }
    
    ; Update Inno Setup exe in case version is changed
    version := DoReadSetting(editBoxAhk.Text,
            ";@AHK2EXE_PATH-Set ProductVersion,")
    editBoxIssExe.Text := DoGetIssExeFileName(editBoxAhk.Text)
    ;'' StrReplace(editBoxAhk.Text,            ".ahk", "_setup_v" version ".exe")

    ;DEBUG 
    ;MsgBox("command:`n`n" command, "command", "OK Icon!")

    try {
        exitCode := RunWait(command, , "Hide")
        if (exitCode == 0) {
            WriteStatus("AhkExe created successfully: " ahkExePath iconMsg)
            DoAutoVersion()
        } else {
            WriteStatus("AhkExe compile failed with exit code: " exitCode)
        }
    } catch Error as e {
        MsgBox("Failed to run AHK2EXE_PATH Compiler.`n`n" e.Message, "Error", "OK Icon!")
    }
}

DoCompileIss() {

    DoExeStop("ISS_EXE") ; terminate process if running

    WriteStatus("Running ISS to compile setup EXE...")

    ; make sure files exist
    ahkPath := editBoxAhk.Text
    ahkExePath := editBoxAhkExe.Text
    issPath := editBoxIss.Text
    issExePath := editBoxIssExe.Text

    r := DoGetFilePathAndVersion(ahkPath)
    iconPath := r[1] ".ico"

    if !FileExist(ahkPath) {
        MsgBox("Error: File not found:`n`n" ahkPath, "Error", "OK Icon!")
        return
    }

    if !FileExist(ahkExePath) {
        MsgBox("Error: File not found:`n`n" ahkExePath, "Error", "OK Icon!")
        return
    }

    if !FileExist(issPath) {
        MsgBox("Error: File not found:`n`n" issPath, "Error", "OK Icon!")
        return
    }

    if !FileExist(iconPath) {
        MsgBox("Error: File not found:`n`n" iconPath, "Error", "OK Icon!")
        return
    }

    outDir := SplitPathObj(issExePath).Dir

    if !DirExist(outDir) {
        DirCreate(outDir)
    }
    
    ; read settings from .ahk script
    issGUID := DoReadSetting(editBoxAhk.Text, ";@Inno-Set AppId,")

    ; read iss template
	issText := FileRead(issPath)

    ; do string replacements
    issText := StrReplace(issText, "%MyAppFilePath%", ahkExePath)
    issText := StrReplace(issText, "%MyAppIconPath%", iconPath)
    issText := StrReplace(issText, "%MyAppId%", issGUID)
    issText := StrReplace(issText, "%MyOutputDir%", outDir)
    issText := StrReplace(issText, "%MyIconPath%", iconPath)

    ; save iss template as exeName.iss
    exeNameNoExt := SplitPathObj(ahkPath).NameNoExt
    newIssPath := SplitPathObj(ahkPath).Dir "\" exeNameNoExt ".iss"

     ; Deletes the file if it exists
    if FileExist(newIssPath)
        FileDelete(newIssPath)

    ; Write the changed variables to the new .iss file
    FileAppend(issText, newIssPath, "UTF-8")
    Sleep(250) ; wait for file to be written

    ; Run Inno to create setup exe
    if !FileExist(INNOEXE_PATH) {
        MsgBox("Error: Inno Setup Compiler not found:`n`n" INNOEXE_PATH, "Error", "OK Icon!")
        return
    }

    ; The /Q switch makes the compilation quiet.
    ; The command and path are quoted to handle spaces.
    command := '"' INNOEXE_PATH '" /Q "' newIssPath '"'

    try {
        exitCode := RunWait(command, , "Hide")
        if (exitCode == 0) {
            WriteStatus("Inno Setup created successfully: " editBoxIssExe.Text)
        } else {
            MsgBox("Inno Setup compilation failed with exit code: " exitCode, "Error", "OK Icon!")
        }
    } catch Error as e {
        MsgBox("Failed to run Inno Setup Compiler.`n`n" e.Message, "Error", "OK Icon!")
    }
}

DoConfigSave() {
    global CONFIG_PATH

    configFile := SplitPathObj(EditBoxAhk.Text).NameNoExt ".config"

    configFullPath := CONFIG_PATH . configFile

    if !DirExist(CONFIG_PATH)
        DirCreate(CONFIG_PATH)
    
    MyGui.Opt("+OwnDialogs")
    
    selectedFolder := FileSelect("S16", configFullPath, "Save Config As...", "Config Files (*.config)")

    if selectedFolder {

        ext := SplitPathObj(selectedFolder).Ext
        
        if (ext == "") {
            selectedFolder .= ".config"
        } else if (ext .= ".config") {
            StrReplace(selectedFolder, ext, ".config")
        }

        CONFIG := IniLite(selectedFolder)
        
        CONFIG.Write("Configuration", "AHK", editBoxAhk.Text)
        CONFIG.Write("Configuration", "AHK_EXE", editBoxAhkExe.Text)
        CONFIG.Write("Configuration", "ISS", editBoxIss.Text)
        CONFIG.Write("Configuration", "ISS_EXE", editBoxIssExe.Text)
        
        CONFIG := ""

        WriteStatus("Config Saved: " selectedFolder)
    }
}

DoConfigLoad() {

;    if !DirExist(CONFIG_PATH)
;        DirCreate(CONFIG_PATH)

    MyGui.Opt("+OwnDialogs")
    
    selectedFolder := FileSelect(1+2, CONFIG_PATH, "Select Config File...", "Config Files (*.config)")

    if (selectedFolder != "") {

        ext := SplitPathObj(selectedFolder).Ext
        
        ; #region TODO is this necessary?
        if (ext == "")
            selectedFolder .= ".config"

        CONFIG := IniLite(selectedFolder)
        
        editBoxAhk.Text := CONFIG.Read("Configuration", "AHK")
        editBoxAhkExe.Text := CONFIG.Read("Configuration", "AHK_EXE")
        editBoxIss.Text := CONFIG.Read("Configuration", "ISS")
        editBoxIssExe.Text := CONFIG.Read("Configuration", "ISS_EXE")

        CONFIG := ""

        WriteStatus("Config Loaded: " selectedFolder)
    }
}

DoExplore(Item) {
    WriteStatus()
    switch Item {
        case "AHK":
            Run(SplitPathObj(EditBoxAhk.Text).Dir)
        case "AHK_EXE":
            Run(SplitPathObj(EditBoxAhkExe.Text).Dir)
        case "ISS":
            Run(SplitPathObj(EditBoxIss.Text).Dir)
        case "ISS_EXE":
            Run(SplitPathObj(EditBoxIssExe.Text).Dir)
    }
}

DoExeRun(Item) {

    global AHK_EXE_PID, ISS_EXE_PID
    
    switch Item {
        case "AHK_EXE":
            exePath := editBoxAhkExe.Text
        case "ISS_EXE":
            exePath := editBoxIssExe.Text         
    }

    if !FileExist(exePath) {
        WriteStatus("File not found: " exePath)
        return
    }

    command := '"' exePath '"'
    
    try {
        Run(command, '', '', &exePID)
        if (exePID != 0) {
            WriteStatus("Running: " exePath)
        } else {
            WriteStatus("Run Failed: " exePath)
            return
        }
    } catch Error as e {
        MsgBox("Failed to run EXE`n`n" e.Message, "Error", "OK Icon!")
    }

    switch Item {
        case "AHK_EXE":
            AHK_EXE_PID := exePID
        case "ISS_EXE":
            ISS_EXE_PID := exePID         
    }
}

DoExeStop(Item) {

    global AHK_EXE_PID, ISS_EXE_PID

    switch Item {
        case "AHK_EXE":
            exePID := AHK_EXE_PID
            exePath := editBoxAhkExe.Text
        case "ISS_EXE":
            exePID := ISS_EXE_PID
            exePath := editBoxIssExe.Text
    }
    r := ProcessClose(exePID)

    if (r != 0) {
        WriteStatus("Stopped : " exePath)
        Sleep(2000) ; give time to close and user to read
    } else {
        WriteStatus("Exe not running")
    }  
}

DoFindInFile(textFilePath, findKey) {
    foundLine := ""
    try {
        fileObj := FileOpen(textFilePath, "r")
        while !fileObj.AtEOF {
            foundLine := fileObj.ReadLine()
            if InStr(foundLine, findKey, true) {
                break
            }
        }
        fileObj.Close()
    } catch Error {
        Throw "Error reading file: " . Error.Message
    }
    return foundLine
}

DoReadSetting(textFilePath, findKey) {
    foundLine := DoFindInFile(textFilePath, findKey)
    lineParts := StrSplit(foundLine, ",")
    if (lineParts.Length < 2)
        return ""
    else
    return Trim(lineParts[2])
}

DoSelectFile(Item) {
    switch Item {
        case "AHK":
            MyEditBox := editBoxAhk
            ext := StrLower(Item)

        case "AHK_EXE":
            MyEditBox := editBoxAhkExe
            ext := StrLower(Item)
            
        case "ISS":
            ext := StrLower(Item)
            MyEditBox := editBoxIss
            if !DirExist(MyEditBox.Text)
                MyEditBox.Text := ISS_TEMPLATE_PATH    

        case "ISS_EXE":
            MyEditBox := editBoxIssExe
            ext := StrLower(Item)

        default:
            SoundBeep
            return
    }

    WriteStatus()

    If IsShiftKeyPressed() {
        DoExplore(MyEditBox.Text)
        return
    }

    MyGui.Opt("+OwnDialogs")

    SelectedFile := FileSelect(1+2, MyEditBox.Text, 
        "Select " Item " file", Item "Files (*." ext ")")

    if (SelectedFile = '') {
        return
    } else {
        MyEditBox.Text := SelectedFile
        DoIniWrite("Settings", Item, SelectedFile)
    }

    if (Item == "AHK") {
        editBoxAhkExe.Text := StrReplace(SelectedFile,
            ".ahk", ".exe")
        ; version := DoReadSetting(editBoxAhk.Text,
        ;     ";@AHK2EXE_PATH-Set ProductVersion,")
        editBoxIssExe.Text := StrReplace(SelectedFile,
            ".ahk", "_setup.exe")
    }

    if (Item == "ISS") {
        ; editBoxAhkExe.Text := StrReplace(SelectedFile,
        ;     ".ahk", ".exe")
        ; version := DoReadSetting(editBoxAhk.Text,
        ;     ";@AHK2EXE_PATH-Set ProductVersion,")
        editBoxIss.Text := SelectedFile
        
    ;     editBoxIssExe.Text := StrReplace(SelectedFile,
    ;         ".ahk", "_setup.exe")
    }
}

DoSelectFolder(Item) {
    switch Item {
        case "AHK":
            MyEditBox := editBoxAhk
            ext := StrLower(Item)

        case "AHK_EXE":
            MyEditBox := editBoxAhkExe
            ext := StrLower(Item)
            
        case "ISS":
            MyEditBox := editBoxIss
            ext := StrLower(Item)

        case "ISS_EXE":
            MyEditBox := editBoxIssExe
            ext := StrLower(Item)

        default:
            SoundBeep
            return
    }

    WriteStatus()

    If IsShiftKeyPressed() {
        DoExplore(MyEditBox.Text)
        return
    }

    initialDir := SplitPathObj(MyEditBox.Text).Dir

    MyGui.Opt("+OwnDialogs")

    SelectedFolder := FileSelect("D", initialDir, "Select Folder")

    if (SelectedFolder = '')
        return

    switch Item {
        case "AHK_EXE":
            SelectedFolder := SelectedFolder . "\" .
                SplitPathObj(editBoxAhk.Text).NameNoExt . ".exe"
            MyEditBox.Text := SelectedFolder

        case "ISS_EXE":
            version := DoReadSetting(editBoxAhk.Text,
                ";@AHK2EXE_PATH-Set ProductVersion,")
            
            ;DEBUG
            issExeNameOld := 
                SplitPathObj(editBoxAhkExe.Text).NameNoExt

            issExeNameNew := SelectedFolder "\" . 
                issExeNameOld . "_setup.exe"

                ; StrReplace(issExeNameOld,".exe", 
                ;     "_setup_v" version ".exe")
            
            MsgBox("issExeNameOld: " issExeNameOld "`n`n" issExeNameNew)

            MyEditBox.Text := issExeNameNew

        default:
            MyEditBox.Text := SelectedFolder
    }

    DoIniWrite("Settings", Item, SelectedFolder) 
}
/**
 * Reads the product version from the script's AHK2EXE_PATH directives.
 * @returns {String} The product version (e.g., "1.0.0.0") or a placeholder if not found.
 */
GetProductVersion(ahkScriptFilePath) {
    try {
        scriptContent := FileRead(ahkScriptFilePath)
        if RegExMatch(scriptContent, "im)^\s*;@AHK2EXE_PATH-Set\s+ProductVersion,\s*([\d\.]+)", &match)
            return match[1]
    }
    return
}
IsFileExist(path) {
    if FileExist(path)
        return True
    else
        return False
    }

IsShiftKeyPressed() {

    if GetKeyState('Shift', 'P')
        return True
    else
        return False
    }

GenerateGUID()
{
    try {
        guidString := ComObject("Scriptlet.TypeLib").GUID
        guidString := StrReplace(guidString, "{", "{{", 1)
        guidString := StrReplace(guidString, "}", "}}", 1)
        return guidString
    }
    catch as e
    {
        MsgBox("ERROR GenerateGUID: " e.Message)
        return
    }
}

SplitPathObj(path) {
    SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    SplitPath(Dir,,,,&ParentDir)
    return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}

DoShowHelp() {
    WriteStatus()   
    helpText := "
(
Setup Maker Help

This tool helps create an Inno Setup installer for your AutoHotkey script.

1.  [AHK Script]: Select your main AutoHotkey script (.ahk).
    - [Compile] : Compiles the selected .ahk script into an .exe file.
    - [Explore] : Opens the folder containing the .ahk script.

2.  [AHK Exe]  : Select the Directory for the compiled executable (.exe).
The .exe filname will be filled in, then you can manually edit it.
    - [Run]  : Executes the selected .exe file.
    - [Stop] : Stops the selected .exe file.
    - [Explore] : Opens the folder containing the .exe file.

3.  [Inno Template]: Select your Inno Setup script template (.iss).
    - [Compile]   : Compiles the selected .iss script into a *_setup.exe file.
    - [Explore] : Opens the folder containing the .ahk script.

4.  [Inno Exe]  : Select the Directory for the compiled executable (_setup.exe). A temporary filname will be filled in just to show the output path. NOTE: The final _setup.exe filename will be formed by the .iss script.
    - [Run]  : Executes the selected _setup.exe file.
    - [Stop] : Stops the selected _setup.exe file.
    - [Explore] : Opens the folder containing the _setup.exe file.

5.  [Build] : Prompts user to Compile AHK and Inno scripts.

6.  [Config]: Prompts user to Load or Save Configuration in the Edit boxes.

7. [Help] : Shows this help text.

9. [Cancel]: Closes the application.

Basic Workflow:
Select AHK ➤ Verify EXE ➤ Select ISS ➤ Verify _SEUP.EXE ➤ Build
)"
    MsgBox(helpText, "Help")
}

DoStrJoin(array, delimiter := "") {
    if (array.Length = 0)
        return ""
    local result := array[1]
    Loop array.Length - 1
        result .= delimiter . array[A_Index + 1]
    return result
}
StrRepeat(text, times) {
    return StrReplace(Format("{:" times "}", ""), " ", text)
}
DoAutoVersion() {

    ;\PATH\AhkSetupBuilder_v0.0.0.9.ahk
    ahkFile := editBoxAhk.Text

    ;\PATH\AhkSetupBuilder_v0.0.0.9
    ahkAppName := SplitPathObj(ahkFile).NameNoExt

    ;get the version tag to search for
    ;parts := StrSplit(ahkAppName, "_")
    ;part[1] := \PATH\AhkSetupBuilder
    ;part[2] := 0.0.0.9
    parts := StrSplit(ahkAppName, "_")
    
    ; Skip if ahk file doesn't use versioning: MyApp_v0.0.0.0.ahh
    if parts.Length < 2
        return

    ;_v0.0.0.9
    verTag := "_" parts[2]

    oldVersion := DoReadSetting(ahkFile, "ProductVersion,")
    newVersion := DoIncrementVersion(oldVersion, "Build")

    oldVersionLine := "ProductVersion, " oldVersion
    newVersionLine := "ProductVersion, " newVersion

    oldAhkText := FileRead(ahkFile)
    newAhkText := StrReplace(oldAhkText, oldVersion, newVersion)

    ;part[1] := \PATH\AhkSetupBuilder
    ;newVersion: 0.0.0.1
    newVerTag := "_v" newVersion
    
    ;AhkSetupBuilder_v0.0.0.9.ahk
    newAhkFile := StrReplace(ahkFile, verTag, newVerTag)

    if FileExist(newAhkFile)
        FileDelete(newAhkFile)

    FileAppend(newAhkText, newAhkFile, "UTF-8")

    editBoxIssExe := StrReplace(newAhkFile, ".ahk", ".exe")
    ;open in default editor
    Run(newAhkFile)
    Sleep(250)

    ;DEBUG
    ;  MsgBox(
    ;     "oldVersionLine: " oldVersion "`n`n" . 
    ;     "oldVersion: " oldVersion "`n`n" . 
    ;     "newVersion: " newVersion "`n`n" . 
    ;     "verTag: " verTag "`n`n" . 
    ;     "newVerTag: " newVerTag "`n`n" . 
    ;     "ahkFile: " ahkFile "`n`n" . 
    ;     "newAhkFile: " newAhkFile "`n`n" .
    ;     "")

}
DoGetProductVersion() {

    arrayPathVer := DoGetFilePathAndVersion(A_ScriptFullPath)
 
    ;if version not in filename
    if (arrayPathVer[2] =="") {
        ;Read from script
        return DoReadSetting(A_ScriptFullPath,
            ";@AHK2EXE_PATH-Set ProductVersion,")
    } else {
        return arrayPathVer[2]
    }
}
DoGetFilePathAndVersion(fileName, delimiter := "_v") {
    ; EXAMPLE                       EXAMPLE WITH VERSION
    ; filename  : D:\Dir\app.ext    D:\Dir\app_v0.0.0.0.ext
    ; path      : D:\Dir\app        D:\Dir\app
    ; version   : ""                0.0.0.0

    SplitPath(filename, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    pos1 := InStr(filename, delimiter)
    if !pos1
        return [Dir "\" NameNoExt, ""]
    fnameOnly := SplitPathObj(filename).NameNoExt
    pos2 := InStr(fnameOnly, delimiter)
    fname := SubStr(filename, 1, pos1-1)
    ver := SubStr(fnameOnly, pos2 + StrLen(delimiter))
    return [Dir "\" fname, ver]
}
DoGetIssExeFileName(editBoxControl) {
    ahkFile := editBoxAhk.Text
    ;ahkAppName := SplitPathObj(ahkFile).NameNoExt

    ;parts := StrSplit(ahkAppName, "_")
    ;part[1] := \PATH\AhkSetupBuilder
    ;part[2] := 0.0.0.9
    parts := StrSplit(ahkFile, "_")

    ;AutoVersioning not used
    if parts.Length < 2
        return StrReplace(ahkFile, ".ahk", ".exe")

    ;AutoVersioning is used
    version := "X.X.X.X"
    return parts[1] "_setup_v" version ".exe"
}

DoIncrementVersion(versionString, partToIncrement) {
    ; Major, Minor, Patch, Build
    parts := StrSplit(versionString, ".")

    ; Reset the other parts to 0 if incrementing a major or minor version.
    ; This is a common practice in semantic versioning.
    switch partToIncrement {
        case "Major":
            parts[1] += 1
            parts[2] := 0
            parts[3] := 0
            parts[4] := 0
        case "Minor":
            parts[2] += 1
            parts[3] := 0
            parts[4] := 0
        case "Patch":
            parts[3] += 1
            parts[4] := 0
        case "Build":
            parts[4] += 1
        default:
            Throw ("Error incrementing version: Invalid partToIncrement: " partToIncrement)            
    }
    ; Join the parts back into a single string.
    return DoStrJoin(parts, ".")
}

DoIniRead() {

    INI := IniLite(INI_PATH)

    value := INI.Read("Settings", "AHK")
    if (value == '')
        editBoxAhk.Text := ''
    else
        editBoxAhk.Text := value

    value := INI.Read("Settings", "AHK_EXE")
    if (value == '')
        editBoxAhkExe.Text := ''
    else
        editBoxAhkExe.Text := value

    value := INI.Read("Settings", "ISS")
    if (value == '')
        editBoxIss.Text := ''
    else
        editBoxIss.Text := value

    value := INI.Read("Settings", "ISS_EXE")
    if (value == '')
        editBoxIssExe.Text := ''
    else
        editBoxIssExe.Text := value
    INI := ""
}
DoIniWrite(section, key, value) {
    INI := IniLite(INI_PATH)
    INI.Write(section, key, value)
    INI := ""
}

DoIniWriteAll() {
    
    INI := IniLite(INI_PATH)

    if (editBoxAhk.Text != '')
        INI.Write("Settings", "AHK", editBoxAhk.Text)
    
    if (editBoxAhkExe.Text != '')
        INI.Write("Settings", "AHK_EXE", editBoxAhkExe.Text)
    
    if (editBoxIss.Text != '')
        INI.Write("Settings", "ISS", editBoxIss.Text)

    if (editBoxIssExe.Text != '')
        INI.Write("Settings", "ISS_EXE", editBoxIssExe.Text)
    
    INI := ""
}

WriteStatus(Text := '', Pad := 4) {
    myStatusBar.SetText(StrRepeat(" ", Pad) . Text )
}