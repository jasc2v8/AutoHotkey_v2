; TITLE  :  AhkSetupBuilder v1.0.0.34
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :
;ABOUT: AhkSetupBuilder.ahk
/*
    TODO:
        after compile Ahk, load _setup_vX.X.X.X in ISS Exe
*/
/**
 * AhkBuilder -- Autohotkey and Inno Setup script    compiler.
 *  - AhkBuilder will:
 *  -   Compile your .ahk script to an exe file.
 *  -   Compile the exe file into an Inno Setup exe file.
 * 
 * Overview
 *  - Inputs  (3): .ahk script, .ico icon, .iss script template
 *  - Outputs (2): ahk exe file, Inno Setup exe file
 * 
 * User Process:
 *  - Run AhkBuilder
 *  - Select the .ahk script for the application to be compiled.
 *  - Select the .iss template script used to compile the setup file.
 *  - Press the Build button to compile both into a _setup.exe file
 *  - Run the _setup.exe file to install the application.
 * 
 * AhkBuiler Process:
 *  - Run Ahk2Exe to compile the selected .ahk script into an exe file.
 *  -   (the version info block in the .ahk script is compiled into the exe file).
 *  - Read the version info vaules from the compiled exe file.
 *  - Read the ISS Script Template you select.
 *  - Creates a new .iss script from the template.
 *  - Replace the %Placeholder% values in the ISS template script with the
 *  -   values read from the selected .ahk script
 *  - Run Inno Setup to compile the new .iss script into a _setup.exe file.
 *  
 */
#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
TraySetIcon('shell32.dll', 81)

#Include <Anchor>
#Include <File>
#Include <IniFile>
#Include <String_Functions>

; #region Version Info Block
; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, AutoHotkey Setup Builder
;@Ahk2Exe-Set FileVersion, 0.0.0.378
;@Ahk2Exe-Set InternalName, AhkSetupBuilder
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, AhkSetupBuilder.exe
;@Ahk2Exe-Set ProductName, AhkSetupBuilder
;@Ahk2Exe-Set ProductVersion, 0.0.0.2
;@Ahk2Exe-SetMainIcon AhkSetupBuilder.ico

;@Inno-Set AppId, {{B7D1FB29-B701-4010-8DEA-A5477C60C76D}}
;@Inno-Set AppPublisher, jasc2v8

; #region Globals
global issTemplatePath := A_MyDocuments "\AutoHotkey\AhkSetupBuilder\Templates\"
global configPath := A_MyDocuments "\AutoHotkey\AhkSetupBuilder\Configs\"
global iniPath := A_Temp "\AhkApps\AhkSetupBuilder\AhkSetupBuilder.ini"
global ahk2exe := "C:\Program Files\AutoHotkey\Compiler\ahk2exe.exe"
global innoExe := "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
global AHK_EXE_PID := 0
global ISS_EXE_PID := 0
global pidMap := Map("", 0)

; #region GUI Create
MyGuiTitle := "AutoHotkey Setup Builder v1.0"
MyGui := Gui("+Resize", MyGuiTitle ) ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w532", "Segouie UI")

buttonSelectAhk := MyGui.Add("Button", "xm ym w104 h24", "AHK &Script")
editBoxAhk := MyGui.Add("Edit", "yp w640 h24")
buttonCompileAhk := MyGui.Add("Button", "yp w104 h24", "Compile")
buttonExploreAhk := MyGui.Add("Button", "yp h24", "Explore")

buttonSelectAhkExe := MyGui.Add("Button", "xm w104 h24", "&AHK Exe")
editBoxAhkExe := MyGui.Add("Edit", "yp w640 h24")
buttonRunAhkExe := MyGui.Add("Button", "yp w48 h24", "Run")
buttonStopAhkExe := MyGui.Add("Button", "yp w48 h24", "Stop")
buttonExploreAhkExe := MyGui.Add("Button", "yp h24", "Explore")

buttonSelectIss := MyGui.Add("Button", "xm w104 h24", "Inno &Template")
editBoxIss := MyGui.Add("Edit", "yp w640 h24")
buttonCompileIss := MyGui.Add("Button", "yp w104 h24", "Compile")
buttonExploreIss := MyGui.Add("Button", "yp h24", "Explore")

buttonSelectInnoExe := MyGui.Add("Button", "xm w104 h24", "&Inno Exe")
editBoxIssExe := MyGui.Add("Edit", "yp w640 h24")
buttonRunInnoExe := MyGui.Add("Button", "yp w48 h24", "Run")
buttonStopInnoExe := MyGui.Add("Button", "yp w48 h24", "Stop")
buttonExploreInnoExe := MyGui.Add("Button", "yp h24", "Explore")

textWidth := 981-42
hLine:= MyGui.Add("Text", "xm y+m h1 w" textWidth " +0x9") ; Etched horizontal line that autosizes with the GUI

buttonBuild := MyGui.Add("Button", "xm w104 h24", "&Build")
buttonConfig := MyGui.Add("Button", "yp w104 h24", "&Config")
buttonHelp := MyGui.Add("Button", "yp w104 h24", "&Help")
buttonCancel := MyGui.Add("Button", "yp w104 h24 Default", "Cancel")

myStatusBar := myGui.Add("StatusBar")

; #region OnEvent Bindings
buttonSelectAhk.OnEvent("Click", (*) => DoSelectFile("AHK"))
buttonCompileAhk.OnEvent("Click", (*) => DoCompileAhk())
buttonExploreAhk.OnEvent("Click", (*) => DoExplore("AHK"))

buttonSelectAhkExe.OnEvent("Click", (*) => DoSelectFolder("AHK_EXE"))
buttonRunAhkExe.OnEvent("Click", (*) => DoExeRun("AHK_EXE"))
buttonStopAhkExe.OnEvent("Click", (*) => DoExeStop("AHK_EXE"))
buttonExploreAhkExe.OnEvent("Click", (*) => DoExplore("AHK_EXE"))

buttonSelectIss.OnEvent("Click", (*) => DoSelectFile("ISS"))
buttonCompileIss.OnEvent("Click", (*) => DoCompileIss())
buttonExploreIss.OnEvent("Click", (*) => DoExplore("ISS"))

buttonSelectInnoExe.OnEvent("Click", (*) => DoSelectFolder("ISS_EXE"))
buttonRunInnoExe.OnEvent("Click", (*) => DoExeRun("ISS_EXE"))
buttonStopInnoExe.OnEvent("Click", (*) => DoExeStop("ISS_EXE"))
buttonExploreInnoExe.OnEvent("Click", (*) => DoExplore("ISS_EXE"))

buttonBuild.OnEvent("Click", buttonBuild_Click)
buttonConfig.OnEvent("Click", buttonConfig_Click)
buttonHelp.OnEvent("Click", buttonHelp_Click)
buttonCancel.OnEvent("Click", buttonCancel_Click)

myGui.OnEvent("Close", OnGui_Close)
myGui.OnEvent("Size", OnGui_Size)

MyGui.Opt("MinSize470x210 MaxSize1280x210")

; #region GUI Show
MyGui.Show()

; Uncomment to determine the width of the Text control:
;MyGui.GetPos(,, &w, &h)
;MsgBox("GUI Dimensions:`n`nWidth: " w "`n`nHeight: " h, "GUI Size")

; #region _Main

;TODO REPLACE THIS WITH CONFIG INIT
DoIniRead()


;DoConfigInitialize()
;DEBUG
;DoFindInFile(editBoxAhk.Text, ";@Ahk2Exe-Set ProductVersion,")
;DoFindInFile(editBoxAhk.Text, ";@Inno-Set AppId,")

; path := "AhkSetupBuilder.ahk"
; ;path := "AhkSetupBuilder-v0.0.0.27.ahk"
; ;path := "AhkSetupBuilder-v0.0.0.27-usethisone.ahk"
; ver := DoReadSetting(path, ";@Ahk2Exe-Set ProductVersion,")
; ;ver := DoReadSetting(editBoxAhk.Text, ";@Ahk2Exe-Set ProductVersion,")
; MsgBox("ver: [" ver "]", "DEBUG")

; ;guid := DoReadSetting(editBoxAhk.Text, ";@Inno-Set AppId,")
; ;guid := DoReadSetting(path, ";@Inno-Set AppId,")
; ;MsgBox("guid: [" guid "]", "DEBUG")

; ExitApp


; #region OnEvent Handlers
OnGui_Size(GuiObj, MinMax, Width, Height) {

    if (MinMax = -1)
        return

    Anchor([editBoxAhk, editBoxAhkExe, editBoxIss, editBoxIssExe, hLine], 'w')

    Anchor([buttonCompileAhk, buttonExploreAhk,
            buttonRunAhkExe, buttonStopAhkExe, buttonExploreAhkExe,
            buttonCompileIss, buttonExploreIss,
            buttonRunInnoExe, buttonStopInnoExe, buttonExploreInnoExe], "x")

}

buttonBuild_Click(*) {

    WriteStatus()

    ; r :=MsgBox("Compile AHK to EXE?", "Build", "YesNoCancel Default2 Icon?")
    ; if (r == "Yes")
        DoCompileAhk()
    ; else if (r == "Cancel")
    ;     return

    ; r :=MsgBox("Compile Inno to EXE?", "Build", "YesNoCancel Default2 Icon?")
    ; if (r == "Yes")
        DoCompileIss()
    ; else if (r == "Cancel")
    ;     return
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

    WriteStatus("Running Ahk2Exe to compile AHK...")
 
    ; make sure files exist
    ahkPath := editBoxAhk.Text
    if !FileExist(ahkPath) {
        MsgBox("File not found:`n`n" ahkPath, "DoCompileAhk ERROR", "OK Icon!")
        return
    }

    ; check if EXE Dir is valid
    ahkExePath := editBoxAhkExe.Text
    if !DirExist(StrSplitPath(ahkExePath).Dir) {
       MsgBox("Dir not found:`n`n" ahkExePath, "DoCompileAhk ERROR","OK Icon!")
       return
    }

    outDir := StrSplitPath(ahkExePath).Dir
    if !DirExist(outDir) {
        MsgBox("Dir not found:`n`n" outDir, "DoCompileAhk ERROR", "OK Icon!")
        return
    }

    ; run ahk2exe
    if !FileExist(ahk2exe)  {
        MsgBox("Compiler not found:`n`n" ahk2exe  "DoCompileAhk ERROR", "OK Icon!")
        return
    }

    ; The /Q switch makes the compilation quiet. 
    ; The command and path are quoted to handle spaces.
    command :=    '"' ahk2exe '"' .
        ;" /base " '"' basePath '"' .  ; use default set by ahk2exe GUI 
        " /in " '"' ahkPath '"' .
        " /out " '"' ahkExePath '"' .
        " /silent "

    iconPath := StrReplace(ahkPath, ".ahk", ".ico")
    if FileExist(iconPath) {
        command := command " /icon " '"' iconPath '"'
        iconMsg := '' 
     } else {
        iconMsg := " *** WITH DEFAULT ICON ***"
     }

    try {
        exitCode := RunWait(command, , "Hide")
        if (exitCode == 0) {
            WriteStatus("AhkExe created successfully: " ahkExePath iconMsg)
        } else {
            WriteStatus("AhkExe compile failed with exit code: " exitCode)
        }
    } catch Error as e {
        MsgBox("Failed to run Ahk2Exe Compiler.`n`n" e.Message, "Error", "OK Icon!")
    }
}

DoCompileIss() {

    DoExeStop("ISS_EXE") ; terminate process if running

    WriteStatus("Running Inno to compile ISS into setup EXE...")

    ; make sure files exist
    ahkPath := editBoxAhk.Text
    ahkExePath := editBoxAhkExe.Text
    issPath := editBoxIss.Text
    iconPath := StrReplace(ahkPath, ".ahk", ".ico")
    outDir := StrSplitPath(ahkPath).Dir
    innoExePath := StrSplitPath(ahkPath).NameNoExt "_setup_vX.X.X.X"

    if !FileExist(ahkExePath) {
        MsgBox("AHK EXE file not found:`n`n" ahkExePath, "DoCompileIss ERROR", "OKCancel Icon!")
        return
    }

    propsMap := FileGetExtendedProperties(ahkExePath)

    ;debug
    ;ListObj(propsMap)

    if (propsMap = '') {
        MsgBox("Error getting Extended File Properties:`n`n" .
            "File:`n`n" ahkExePath, "CompileIss ERROR", "OK Icon!")
        return
    }

    if !FileExist(issPath) {
        MsgBox("ISS file not found:`n`n" issPath, "DoCompileIss ERROR", "OK Icon!")
        return
    }

    if !FileExist(iconPath) {
        r := MsgBox("Icon file not found:`n`n" iconPath, "DoCompileIss ERROR", "OKCancel Icon!")
        if (r == "Cancel")
            return
    }

    ; get replacement values
    issGUID := DoReadSetting(editBoxAhk.Text, ";@Inno-Set AppId,")

    if issGUID = '' {
        MsgBox("GUID not found in:`n`n" editBoxAhk.Text, "DoCompileIss ERROR", "OK Icon!")
        return
    }

    issPublisher := DoReadSetting(editBoxAhk.Text, ";@Inno-Set AppPublisher,")

    if !issPublisher {
        MsgBox("AppPublisher not found in:`n`n" editBoxAhk.Text, "DoCompileIss ERROR", "OK Icon!")
        return
    }

    ; create outDir if not exists
    if !DirExist(outDir) {
        DirCreate(outDir)
        editBoxIssExe.Text := innoExePath
    }
    
    ; read iss template
	issText := FileRead(issPath)

    ; do string replacements
    ; issText := StrReplace(issText, "%MyAppFilePath%", ahkExePath)
    ; issText := StrReplace(issText, "%MyAppIconPath%", iconPath)
    ; issText := StrReplace(issText, "%MyAppId%", issGUID)
    ; issText := StrReplace(issText, "%MyOutputDir%", outDir)
    ; issText := StrReplace(issText, "%MyIconPath%", iconPath)
    ; issText := StrReplace(issText, "%MyAppPublisher%", issPublisher)

    for k, v in propsMap {
        needle := '%' k '%'
        issText := StrReplace(issText, needle, v)

        if (k = "FileVersion")
            fileVersion := v
    }

    iconPath := StrReplace(ahkPath, ".ahk", ".ico")
    fileNameNoExt := StrSplitPath(ahkPath).NameNoExt
    outputDir := StrSplitPath(ahkPath).Dir
    outputFilename := fileNameNoExt "_setup_v" fileVersion

    issDefines := Map(
        "Icon_Path", iconPath, 
        "App_Publisher", issPublisher, 
        "FileName_NameNoExt", fileNameNoExt,
        "Inno_Id", issGUID,
        "Output_Dir", outputDir,
        "Output_Filename", outputFilename)

    for k, v in issDefines {
        needle := '%' k '%'
        issText := StrReplace(issText, needle, v)
    }

    ; show the full output path
    fullOutPath := outputDir . '\' . outputFilename . ".exe"
    editBoxIssExe.Text := fullOutPath

    ; strip #define comments for cleaniness and clarity
    issTextClean := ""
    Loop parse, issText, "`n", "`r" {
        if SubStr(A_LoopField, 1, 7) = '#define' {
            pos := InStr(A_LoopField, ';')
            issTextClean .= SubStr(A_LoopField, 1, pos-1) . "`r`n"
        } else {
            issTextClean .= A_LoopField . "`r`n"
        }
    }

    ; save iss template as exeName.iss
    ;DELETE exeNameNoExt := StrSplitPath(ahkPath).NameNoExt
    newIssPath := StrSplitPath(ahkPath).Dir "\" StrSplitPath(ahkPath).NameNoExt ".iss"

    ; if !FileExist(newIssPath) {
    ;     MsgBox("New ISS path not found:`n`n" newIssPath, "DoCompileIss ERROR", "OK Icon!")
    ;     return
    ; }

    ; Write the new .iss file
    if FileExist(newIssPath)
        FileDelete(newIssPath)
    FileAppend(issTextClean, newIssPath, "UTF-8")
    Sleep(250) ; wait for file to be written

;DEBUG
;ListVars

    ; Run Inno to create setup exe
    if !FileExist(innoExe) {
        MsgBox("Compiler not found:`n`n" innoExe, "DoCompileIss ERROR", "OK Icon!")
        return
    }

    ; The /Q switch makes the compilation quiet
    ; The command and path are quoted to handle spaces.
    command := '"' innoExe '" /Q "' newIssPath '"'

    try {
        exitCode := RunWait(command, , "Hide")
        if (exitCode == 0) {
            WriteStatus("Inno Setup created successfully: " editBoxIssExe.Text)
        } else {
            MsgBox("Compilation failed with exit code: " exitCode, 
                "DoCompileIss ERROR", "OK Icon!")
        }
    } catch Error as e {
        MsgBox("Failed to run Inno Setup Compiler.`n`n" e.Message, 
            "DoCompileIss ERROR", "OK Icon!")
    }
}

DoConfigSave() {

    global configPath

    if !DirExist(configPath)
        DirCreate(configPath)
    
    configFile := StrSplitPath(EditBoxAhk.Text).NameNoExt ".config"

    configFullPath := configPath . configFile

    if !DirExist(configPath)
        DirCreate(configPath)
    
    MyGui.Opt("+OwnDialogs")
    
    selectedFolder := FileSelect("S16", configFullPath, "Save Config As...", 
        "Config Files (*.config)")

    if selectedFolder {

        ext := StrSplitPath(selectedFolder).Ext
        
        if (ext == "") {
            selectedFolder .= ".config"
        } else if (ext .= ".config") {
            StrReplace(selectedFolder, ext, ".config")
        }

        CONFIG := IniFile(selectedFolder)
        
        CONFIG.Write("Configuration", "AHK", editBoxAhk.Text)
        CONFIG.Write("Configuration", "AHK_EXE", editBoxAhkExe.Text)
        CONFIG.Write("Configuration", "ISS", editBoxIss.Text)
        CONFIG.Write("Configuration", "ISS_EXE", editBoxIssExe.Text)
        
        CONFIG := ""

        WriteStatus("Config Saved: " selectedFolder)
    }
}

DoConfigLoad() {

    global configPath

    if !DirExist(configPath)
        DirCreate(configPath)

    MyGui.Opt("+OwnDialogs")
    
    selectedFolder := FileSelect(1+2, configPath, "Select Config File...", "Config Files (*.config)")

    if (selectedFolder != "") {

        ext := StrSplitPath(selectedFolder).Ext
        
        ; #region TODO is this necessary?
        if (ext == "")
            selectedFolder .= ".config"

        CONFIG := IniFile(selectedFolder)
        
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
            Run(StrSplitPath(EditBoxAhk.Text).Dir)
        case "AHK_EXE":
            Run(StrSplitPath(EditBoxAhkExe.Text).Dir)
        case "ISS":
            Run(StrSplitPath(EditBoxIss.Text).Dir)
        case "ISS_EXE":
            Run(StrSplitPath(EditBoxIssExe.Text).Dir)
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
        WriteStatus("AHK Exe not running")
    }  
}

DoFindInFile(textFilePath, findKey) {
    if !FileExist(textFilePath) {
        MsgBox "DoFindInFile not found:`n`n" .
        "textFilePath:`n`n[" textFilePath " ]" "`n`n" .
        "findKey:`n`n[" findKey " ]"
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
    return ""
}

DoReadSetting(textFilePath, findKey) {
    foundLine := DoFindInFile(textFilePath, findKey)
    if (!foundLine) {
        MsgBox "DoReadSetting not found:`n`n" .
            "textFilePath:`n`n[" textFilePath " ]" "`n`n" .
            "findKey: [" findKey " ]"
        return
    }
    lineParts := StrSplit(foundLine, ",")
    return Trim(lineParts[2])
}

DoSelectFile(Item) {
    switch Item {
        case "AHK":
            editBox := editBoxAhk
            ext := StrLower(Item)

        case "AHK_EXE":
            editBox := editBoxAhkExe
            ext := StrLower(Item)
            
        case "ISS":
            ext := StrLower(Item)
            editBox := editBoxIss

            ;MsgBox("DEBUG editBox: " editBox.Text) 

            if (editBox.Text == "")
                editBox.Text := issTemplatePath    

        case "ISS_EXE":
            editBox := editBoxIssExe
            ext := StrLower(Item)

        default:
            SoundBeep
            return
    }

    WriteStatus()

    If IsShiftKeyPressed() {
        DoExplore(editBox.Text)
        return
    }

    MyGui.Opt("+OwnDialogs")

    SelectedFolder := FileSelect(1+2, editBox.Text, 
        "Select " Item " file", Item "Files (*." ext ")")

    if (SelectedFolder = '') {
        return
    } else {
        editBox.Text := SelectedFolder
        DoIniWrite("Settings", Item, SelectedFolder)
    }

    if (Item == "AHK") {
        editBoxAhkExe.Text := StrReplace(SelectedFolder, ".ahk", ".exe")
        fileVersion := DoReadSetting(SelectedFolder, ";@Ahk2Exe-Set ProductVersion,")
        editBoxIssExe.Text := StrReplace(SelectedFolder, ".ahk", "_setup_v" fileVersion)
    }
}

DoSelectFolder(Item) {
    switch Item {
        case "AHK":
            editBox := editBoxAhk
            ext := StrLower(Item)

        case "AHK_EXE":
            editBox := editBoxAhkExe
            ext := StrLower(Item)
            
        case "ISS":
            editBox := editBoxIss
            ext := StrLower(Item)

        case "ISS_EXE":
            editBox := editBoxIssExe
            ext := StrLower(Item)

        default:
            SoundBeep
            return
    }

    WriteStatus()

    If IsShiftKeyPressed() {
        DoExplore(editBox)
        return
    }

    initialDir := StrSplitPath(editBox.Text).Dir

    MyGui.Opt("+OwnDialogs")

    SelectedFolder := FileSelect("D", initialDir, "Select Folder")

    if (SelectedFolder = '')
        return

    switch Item {
        case "AHK_EXE":
            SelectedFolder := SelectedFolder . "\" .
                StrSplitPath(editBoxAhk.Text).NameNoExt . ".exe"
            editBox.Text := SelectedFolder

        case "ISS_EXE":
            SelectedFolder := SelectedFolder . "\" .
                StrSplitPath(editBoxAhk.Text).NameNoExt . 
                "_setup_vX.X.X.X.exe"
            editBox.Text := SelectedFolder

        default:
            editBox.Text := SelectedFolder
    }

    DoIniWrite("Settings", Item, SelectedFolder) 
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

DoIniRead() {

    INI := IniFile(iniPath)

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
    INI := IniFile(iniPath)
    INI.Write(section, key, value)
    INI := ""
}

DoIniWriteAll() {
    
    INI := IniFile(iniPath)

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

WriteStatus(Text := '') {
    myStatusBar.SetText("    " . Text )
}