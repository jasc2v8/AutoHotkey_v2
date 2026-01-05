/*
    TODO: 
    done? MyGui.Opt("+OwnDialogs") for all dialogs?
*/
#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#Include "..\..\Lib\IniLite.ahk"

MyProductVersion := "1.0"

; #region Version Info Block
;@Ahk2Exe-Set ProductName, AhkBuilder
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-Set LegalCopyright, © 2025 jasc2v8
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Ahk2Exe and Inno Setup Builder
;@Ahk2Exe-Set OriginalFilename, AhkBuilder.exe
;@Ahk2Exe-SetMainIcon AhkBuilder.ico

; --- End of Version Info Block ---

; #region Globals
global issTemplatePath := A_MyDocuments "\AutoHotkey\AhkBuilder\Templates\"
global configPath := A_MyDocuments "\AutoHotkey\AhkBuilder\Config\"
global iniPath := A_Temp "\AhkApps\AhkBuilder\AhkBuilder.ini"
global ahk2exe := "C:\Program Files\AutoHotkey\Compiler\ahk2exe.exe"
global innoExe := "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
global AHK_EXE_PID := 0
global ISS_EXE_PID := 0
global pidMap := Map("", 0)

; #region GUI Create
MyGuiTitle := "AHK Buidler -- Ahk2Exe Compiler & Inno Setup Builder v" . 
    MyProductVersion
MyGui := Gui(, MyGuiTitle ) ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w532", "Segouie UI")

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

;DEBUG DoConfigSave()

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
    DoIniWrite()
    DoIniClose()
    ExitApp()
}

; #region Functions

DoCompileAhk() {

    DoExeStop("AHK_EXE") ; terminate process if running

    WriteStatus("Running Ahk2Exe to compile EXE...")
 
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

    DoIniWrite()

    ; run ahk2exe
    if !FileExist(ahk2exe)  {
        MsgBox("Error: Ahk2Exe Compiler not found at:`n`n" ahk2exe  "Error", "OK Icon!")
        return
    }

    iconPath := StrReplace(ahkPath, ".ahk", ".ico")
    ;  if !FileExist(iconPath) {
    ;     WriteStatus("Icon not found, using default: " iconPath)
    ; }

    ; The /Q switch makes the compilation quiet. The command and path are quoted to handle spaces.
    command :=    '"' ahk2exe '"' .
        ;" /base " '"' basePath '"' .  ; use default set by ahk2exe GUI 
        " /in " '"' ahkPath '"' .
        " /out " '"' ahkExePath '"' .
        " /silent "

    if FileExist(iconPath) {
        command := command " /icon " '"' iconPath '"'
        iconMsg := '' 
     } else {
        iconMsg := " *** WITH DEFAULT ICON ***"
     }
    
    ;  if FileExist(ahkPath) {
    ;     MsgBox("Command: " command, "DEBUG", "OK Icon!")
    ;     return
    ; }

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

    WriteStatus("Running ISS to compile setup EXE...")

    ; make sure files exist
    ;ahkPath := editBoxAhk.Text
    ahkPath := editBoxAhk.Text
    ahkExePath := editBoxAhkExe.Text
    issPath := editBoxIss.Text
    iconPath := StrReplace(ahkPath, ".ahk", ".ico")
    outDir := SplitPathObj(ahkPath).Dir
    innoExePath := SplitPathObj(ahkPath).NameNoExt "_setup_vX.X.X.X.exe"

    newGUID := GenerateGUID()

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

    ; get replacement values
    newGUID := GenerateGUID()

    ; make sure outDir exists
    if !DirExist(outDir) {
        DirCreate(outDir)
        editBoxIssExe.Text := innoExePath
    }
    
    ; read iss template
	issText := FileRead(issPath)

    ; do string replacements
    issText := StrReplace(issText, "%MyAppFilePath%", ahkExePath)
    issText := StrReplace(issText, "%MyAppIconPath%", iconPath)
    issText := StrReplace(issText, "%MyAppId%", newGUID)
    issText := StrReplace(issText, "%MyOutputDir%", outDir)
    issText := StrReplace(issText, "%MyIconPath%", iconPath)

    ; save iss template as exeName.iss
    exeNameNoExt := SplitPathObj(ahkPath).NameNoExt
    newIssPath := SplitPathObj(ahkPath).Dir "\" exeNameNoExt ".iss"

    if FileExist(newIssPath)
        FileDelete(newIssPath) ; Deletes the file if it exists

    FileAppend(issText, newIssPath, "UTF-8")
    Sleep(250) ; wait for file to be written Defender?

    ;DEBUG
    ;ListVars

    if !FileExist(newIssPath) {
        MsgBox("newIssPath: " newIssPath, "DEBUG", "OK Icon!")
        return
    }

    ; Run Inno to create setup exe
    if !FileExist(innoExe) {
        MsgBox("Error: Inno Setup Compiler not found at:`n`n" innoExe, "Error", "OK Icon!")
        return
    }

    DoIniWrite()

    ; The /Q switch makes the compilation quiet. The command and path are quoted to handle spaces.
    command := '"' innoExe '" /Q "' newIssPath '"'
    ;command := '"' innoExe '" /Q "' newIssPath '"' '" > D:\Software\DEV\Work\AHK2\AhkApps\iss.txt"'

    try {
        exitCode := RunWait(command, , "Hide")
        if (exitCode == 0) {
            ;MsgBox("Setup created successfully in:`n" outDir, "Success", "OK")
            WriteStatus("Setup created successfully in: " outDir)
        } else {
            MsgBox("Inno Setup compilation failed with exit code: " exitCode, "Error", "OK Icon!")
        }
    } catch Error as e {
        MsgBox("Failed to run Inno Setup Compiler.`n`n" e.Message, "Error", "OK Icon!")
    }
}

DoConfigSave() {
    global configPath

    configFile := SplitPathObj(EditBoxAhk.Text).NameNoExt ".config"

    configFullPath := configPath . configFile

    if !DirExist(configPath)
        DirCreate(configPath)
    
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

;    if !DirExist(configPath)
;        DirCreate(configPath)

    MyGui.Opt("+OwnDialogs")
    
    selectedFolder := FileSelect(1+2, configPath, "Select Config File...", "Config Files (*.config)")

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
        WriteStatus("AHK Exe not running")
    }  
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
        INI.Write("Settings", "Selected" Item, SelectedFolder)
    }

    if (Item == "AHK") {
        editBoxAhkExe.Text := StrReplace(SelectedFolder, ".ahk", ".exe")
        editBoxIssExe.Text := StrReplace(SelectedFolder, ".ahk", "_setup_vX.X.X.X.exe")
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

    initialDir := SplitPathObj(editBox.Text).Dir

    MyGui.Opt("+OwnDialogs")

    SelectedFolder := FileSelect("D", initialDir, "Select Folder")

    if (SelectedFolder = '')
        return

    switch Item {
        case "AHK_EXE":
            SelectedFolder := SelectedFolder . "\" .
                SplitPathObj(editBoxAhk.Text).NameNoExt . ".exe"
            editBox.Text := SelectedFolder

        case "ISS_EXE":
            SelectedFolder := SelectedFolder . "\" .
                SplitPathObj(editBoxAhk.Text).NameNoExt . 
                "_setup_vX.X.X.X.exe"
            editBox.Text := SelectedFolder

        default:
            editBox.Text := SelectedFolder
    }

        INI.Write("Settings", "Selected" Item, SelectedFolder)

        INI := ""
    
    
}
/**
 * Reads the product version from the script's Ahk2Exe directives.
 * @returns {String} The product version (e.g., "1.0.0.0") or a placeholder if not found.
 */
GetProductVersion() {
    try {
        scriptContent := FileRead(A_ScriptFullPath)
        if RegExMatch(scriptContent, "im)^\s*;@Ahk2Exe-Set\s+ProductVersion,\s*([\d\.]+)", &match)
            return match[1]
    }
    return "?.?.?.?"
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

StrRepeat(text, times) {
    return StrReplace(Format("{:" times "}", ""), " ", text)
}

DoIniClose() {
    global INI := ""
}

DoIniOpen() {
    ; Keep open while app is running
    global INI := IniLite(iniPath)
}

DoIniRead() {

    INI := IniLite(iniPath)

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

DoIniWrite() {
    
    INI := IniLite(iniPath)

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