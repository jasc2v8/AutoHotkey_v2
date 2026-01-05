#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#Include "..\..\Lib\IniFile.ahk"

; #region Version Info Block
;@Ahk2Exe-Set ProductName, AhkBuilder
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-Set LegalCopyright, © 2025 jasc2v8
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Ahk2Exe and Inno Setup Builder
;@Ahk2Exe-Set OriginalFilename, AhkBuilder.exe
; --- End of Version Info Block ---

productVersion := GetProductVersion()
productMinorVersion := SubStr(productVersion, 1, Instr(productVersion,'.',,3)-1)

; #region Globals
global iniPath := A_Temp "\AhkApps\AhkBuilder\AhkBuilder.ini"
global ahk2exe := "C:\Program Files\AutoHotkey\Compiler\ahk2exe.exe"
global innoExe := "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
global exePID := 0

; #region GUI Create
MyGuiTitle := "AHK Buidler -- Ahk2Exe Compiler & Inno Setup Builder v" . 
    productMinorVersion
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
buttonEditAhk := MyGui.Add("Button", "yp h24", "Edit")
    .OnEvent("Click", (*) => DoEdit("AHK"))

buttonSelectIss := MyGui.Add("Button", "w104 h24 xm", "Inno &Template")
    .OnEvent("Click", (*) => DoSelectFile("ISS"))
editBoxIss := MyGui.Add("Edit", "yp w640 h24")
buttonCompileIss := MyGui.Add("Button", "yp w104 h24", "Compile")
    .OnEvent("Click", (*) => DoCompileIss())
buttonExploreIss := MyGui.Add("Button", "yp h24", "Explore")
    .OnEvent("Click", (*) => DoExplore("ISS"))
buttonEditIss := MyGui.Add("Button", "yp h24", "Edit")
    .OnEvent("Click", (*) => DoEdit("ISS"))
buttonSelectExe := MyGui.Add("Button", "w104 h24 xm", "AHK &Exe")
    .OnEvent("Click", (*) => DoSelectFile("EXE"))
editBoxExe := MyGui.Add("Edit", "yp w640 h24")
buttonRunExe := MyGui.Add("Button", "yp w48 h24", "Run")
    .OnEvent("Click", (*) => DoRunExe())
buttonStopExe := MyGui.Add("Button", "yp w48 h24", "Stop")
    .OnEvent("Click", (*) => DoStopExe())
buttonExploreExe := MyGui.Add("Button", "yp h24", "Explore")
    .OnEvent("Click", (*) => DoExplore("EXE"))

textWidth := 1018-30
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

myGui.OnEvent("Close", Gui_Close)

; #region GUI Show
MyGui.Show()

; Uncomment to determine the width of the Text control:
;MyGui.GetPos(,, &w, &h)
;MsgBox("GUI Dimensions:`n`nWidth: " w "`n`nHeight: " h, "GUI Size")

; #region _Main

INI := IniFile(iniPath)

DoReadIni()

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
     
    r :=MsgBox("Open Config?", "Config", "YesNoCancel Default2 Icon?")
    if (r == "Yes")
        DoOpenConfig()
    else if (r == "Cancel")
        return
    
    r :=MsgBox("Save Config?", "Build", "YesNoCancel Default2 Icon?")
    if (r == "Yes")
        DoSaveConfig()
}

buttonCancel_Click(*) {
	WinClose()
    ExitApp()
}

buttonHelp_Click(*) {
	DoHelp()
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

Gui_Close(*) {
    DoStopExe()
    WriteIni()
}

; #region Functions

DoCompileAhk() {

    DoStopExe() ; terminate process if running

    WriteStatus("Running Ahk2Exe to compile EXE...")
 
    ; make sure files exist
    ahkPath := editBoxAhk.Text
    if !FileExist(ahkPath) {
        MsgBox("Error: File not found:`n`n" ahkPath, "Error", "OK Icon!")
        return
    }

    ; load EXE
    ;exePath := StrReplace(ahkPath, ".ahk", ".exe")
    exePath := editBoxExe.Text

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
        " /out " '"' exePath '"' .
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
            WriteStatus("AhkExe created successfully: " exePath iconMsg)
        } else {
            WriteStatus("AhkExe compile failed with exit code: " exitCode)
        }
    } catch Error as e {
        MsgBox("Failed to run Ahk2Exe Compiler.`n`n" e.Message, "Error", "OK Icon!")
    }
}

DoCompileIss() {

    DoStopExe() ; terminate process if running

    WriteStatus("Running ISS to compile setup EXE...")

    ; make sure files exist
    ;ahkPath := editBoxAhk.Text
    exePath := editBoxExe.Text
    issPath := editBoxIss.Text
    iconPath := StrReplace(editBoxAhk.Text, ".ahk", ".ico")

    if !FileExist(exePath) {
        MsgBox("Error: File not found:`n`n" exePath, "Error", "OK Icon!")
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
    outDir := SplitPathObj(exePath).Dir

    ; make sure outDir exists
    if !DirExist(outDir) {
        DirCreate(outDir)
    }
    
    ; read iss template
	issText := FileRead(issPath)

    ; do string replacements
    issText := StrReplace(issText, "%MyAppFilePath%", exePath)
    issText := StrReplace(issText, "%MyAppIconPath%", iconPath)
    issText := StrReplace(issText, "%MyAppId%", newGUID)
    issText := StrReplace(issText, "%MyOutputDir%", outDir)
    issText := StrReplace(issText, "%MyIconPath%", iconPath)

    ; save iss template as exeName.iss
    exeNameNoExt := SplitPathObj(exePath).NameNoExt
    newIssPath := SplitPathObj(exePath).Dir "\" exeNameNoExt ".iss"

    if FileExist(newIssPath)
        FileDelete(newIssPath) ; Deletes the file if it exists

    FileAppend(issText, newIssPath, "UTF-8")

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

    ; The /Q switch makes the compilation quiet. The command and path are quoted to handle spaces.
    command := '"' innoExe '" /Q "' newIssPath '"'

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


DoEdit(Item) {
    WriteStatus()
    switch Item {
        case "AHK":
            Run(EditBoxAhk.Text)
        case "ISS":
            Run(EditBoxIss.Text)
    }
}

DoExplore(Item) {
    WriteStatus()
    switch Item {
        case "AHK":
            Run(SplitPathObj(EditBoxAhk.Text).Dir)
        case "EXE":
            Run(SplitPathObj(EditBoxExe.Text).Dir)
        case "ISS":
            Run(SplitPathObj(EditBoxIss.Text).Dir)
    }
}

DoRunExe() {

    global exePID

    exePath := editBoxExe.Text

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
        }
    } catch Error as e {
        MsgBox("Failed to run EXE`n`n" e.Message, "Error", "OK Icon!")
    }
}

DoSelectFile(Item) {
    switch Item {
        case "AHK":
            editBox := editBoxAhk
            ext := StrLower(Item)

        case "EXE":
            editBox := editBoxExe
            ext := StrLower(Item)
            
        case "ISS":
            editBox := editBoxIss
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

    SelectedFile := FileSelect(1+2, editBox.Text, 
        "Open " Item " Files (*." ext ")")

    if (SelectedFile = '') {
        return
    } else {
        editBox := SelectedFile
        INI.Write("Settings", "Selected" Item, SelectedFile)
    }

    if (Item == "AHK") {
        editBoxExe.Text := StrReplace(SelectedFile, ".ahk", ".exe")
    }
}

DoStopExe() {
    global exePID

    r := ProcessClose(exePID)

    if (r != 0) {
        WriteStatus("Stopped : " editBoxExe.Text)
        Sleep(2000) ; give time to close and user to read
    } else {
        WriteStatus("AHK Exe not running")
    }  
}

DoSaveConfig(){
    INI.Write("Settings", "SelectedAHK", editBoxAhk.Text)
    INI.Write("Settings", "SelectedEXE", editBoxExe.Text)
    INI.Write("Settings", "SelectedISS", editBoxIss.Text)
    WriteStatus("Config Saved")
}

DoOpenConfig(){
    editBoxAhk.Text := INI.Read("Settings", "SelectedAHK")
    editBoxExe.Text := INI.Read("Settings", "SelectedEXE")
    editBoxIss.Text := INI.Read("Settings", "SelectedISS")
    WriteStatus("Config Opened")
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

DoHelp() {
    WriteStatus()   
    helpText := "
(
Setup Maker Help

This tool helps create an Inno Setup installer for your AutoHotkey script.

1.  [AHK Script]: Select your main AutoHotkey script (.ahk).
    - [Compile] : Compiles the selected .ahk script into an .exe file.
    - [Open] : Opens the folder containing the .ahk script.
    - [Edit] : Opens the selected .ahk script for editing.

2.  [Inno Template]: Select your Inno Setup script template (.iss).
    - [Compile]   : Compiles the selected .iss script into a *_setup.exe file.
    - [Open] : Opens the folder containing the .ahk script.
    - [Edit] : Opens the selected .iss template for editing.

3.  [AHK Exe]  : Select the compiled executable (.exe).
    - [Run]  : Executes the selected .exe file.
    - [Stop] : Stops the selected .exe file.
    - [Open] : Opens the folder containing the .exe file.

Basic Workflow: Select AHK ➤ Select ISS ➤ Select EXE ➤ Build
)"
    MsgBox(helpText, "Help")
}

StrRepeat(text, times) {
    return StrReplace(Format("{:" times "}", ""), " ", text)
}

DoReadIni() {

    value := INI.Read("Settings", "SelectedAHK")
    if (value == '')
        editBoxAhk.Text := ''
    else
        editBoxAhk.Text := value

    value := INI.Read("Settings", "SelectedEXE")
    if (value == '')
        editBoxExe.Text := ''
    else
        editBoxExe.Text := value

    value := INI.Read("Settings", "SelectedISS")
    if (value == '')
        editBoxIss.Text := ''
    else
        editBoxIss.Text := value
}

WriteIni() {
    
    if (editBoxAhk.Text != '')
        INI.Write("Settings", "SelectedAHK", editBoxAhk.Text)
    
    if (editBoxExe.Text != '')
        INI.Write("Settings", "SelectedEXE", editBoxExe.Text)
    
    if (editBoxIss.Text != '')
        INI.Write("Settings", "SelectedISS", editBoxIss.Text)
}
WriteStatus(Text := '', Pad := 4) {
    myStatusBar.SetText(StrRepeat(" ", Pad) . Text )
}