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

; #region Globals
global iniPath := A_Temp "\AhkApps\AhkBuilder\AhkBuilder.ini"
global ahk2exe := "C:\Program Files\AutoHotkey\Compiler\ahk2exe.exe"
global innoExe := "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

; #region Hotkeys
F1::DoHelp()

; #region GUI Create
MyGui := Gui(, "AHK Buidler -- Ahk2Exe Compiler & Inno Setup Builder") ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w532", "Segouie UI")

buttonSelectAhk := MyGui.Add("Button", "xm ym w104 h24", "AHK &Script")
editBoxAhk := MyGui.Add("Edit", "yp w640 h24")
buttonCompileAhk := MyGui.Add("Button", "yp w104 h24", "Compile")
buttonExploreAhk := MyGui.Add("Button", "yp h24", "Open").OnEvent("Click", (*) => DoOpen("AHK"))
buttonEditAhk := MyGui.Add("Button", "yp h24", "Edit").OnEvent("Click", (*) => DoEdit("AHK"))

buttonSelectIss := MyGui.Add("Button", "w104 h24 xm", "Inno &Template")
editBoxIss := MyGui.Add("Edit", "yp w640 h24")
buttonCompileIss := MyGui.Add("Button", "yp w104 h24", "Compile")
buttonExploreIss := MyGui.Add("Button", "yp h24", "Open").OnEvent("Click", (*) => DoOpen("ISS"))
buttonEditIss := MyGui.Add("Button", "yp h24", "Edit").OnEvent("Click", (*) => DoEdit("ISS"))

buttonSelectExe := MyGui.Add("Button", "w104 h24 xm", "AHK &Exe")
editBoxExe := MyGui.Add("Edit", "yp w640 h24")
buttonRunExe := MyGui.Add("Button", "yp w48 h24", "Run")
buttonStopExe := MyGui.Add("Button", "yp w48 h24", "Stop")
buttonExploreExe := MyGui.Add("Button", "yp h24", "Open").OnEvent("Click", (*) => DoOpen("EXE"))

;buttonBuildExe := MyGui.Add("Button", "yp w76 h24", "Build")
;buttonRunExe := MyGui.Add("Button", "yp w76 h24", "Run")

textWidth := 1018-44
MyGui.Add("Text", "xm y+m h1 w" textWidth " +0x9") ; Etched horizontal line that autosizes with the GUI

buttonBuild := MyGui.Add("Button", "xm w104 h24", "&Build")
buttonConfig := MyGui.Add("Button", "yp w104 h24", "&Config")
buttonHelp := MyGui.Add("Button", "yp w104 h24", "&Help")
buttonCancel := MyGui.Add("Button", "yp w104 h24 Default", "Cancel")

myStatusBar := myGui.Add("StatusBar")

; #region OnEvent Bindings

buttonSelectAhk.OnEvent("Click", buttonSelectAhk_Click)
buttonCompileAhk.OnEvent("Click", buttonCompileAhk_Click)

buttonSelectExe.OnEvent("Click", buttonSelectExe_Click)
;buttonRunExe.OnEvent("Click", buttonRunExe_licke)
;buttonStopExe.OnEvent("Click", buttonStopExe_Click)

buttonSelectIss.OnEvent("Click", buttonSelectIss_Click)
buttonCompileIss.OnEvent("Click", buttonCompileIss_Click)

buttonBuild.OnEvent("Click", buttonBuild_Click)
buttonConfig.OnEvent("Click", buttonConfig_Click)
buttonHelp.OnEvent("Click", buttonHelp_Click)
buttonCancel.OnEvent("Click", buttonCancel_Click)

myGui.OnEvent("Close", Gui_Close)

; #region GUI Show
MyGui.Show()

; Uncomment to determine the width of the Text control
; MyGui.GetPos(,, &w, &h)
; MsgBox("GUI Dimensions:`n`nWidth: " w "`n`nHeight: " h, "GUI Size")

; Read saved settings from ini file
INI := IniFile(iniPath)

DoReadIni()

; #region OnEvent Handlers

buttonBuild_Click(*) {

    r :=MsgBox("Compile AHK to EXE?", "Build", "YesNoCancel Default2 Icon?")
    if (r == "Yes")
        buttonCompileAhk_Click(0, 0)
    else if (r == "Cancel")
        return

    r :=MsgBox("Compile Inno to EXE?", "Build", "YesNoCancel Default2 Icon?")
    if (r == "Yes")
        buttonCompileIss_Click(0, 0)
}

buttonConfig_Click(*) {

    r :=MsgBox("Open Config?", "Config", "YesNoCancel Default2 Icon?")
    if (r == "Yes")
        DoOpenConfig()
    else if (r == "Cancel")
        return
    
    r :=MsgBox("Save Config?", "Build", "YesNoCancel Default2 Icon?")
    if (r == "Yes")
        DoSaveConfig()
}

buttonCompileAhk_Click(*) {

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

buttonCompileIss_Click(Ctrl, Info) {

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

buttonCancel_Click(*) {
	WinClose()
    ExitApp()
}

buttonHelp_Click(*) {
	DoHelp()
}

buttonSelectAhk_Click(Item, *) {

    ;MsgBox("buttonSelectAhk_Click: You selected " Item.Text)

    If IsShiftKeyPressed() {
        DoOpen(editBoxAhk.Text)
        return
    }

    SelectedFile := FileSelect(1+2, editBoxAhk.Text, "Open AHK file", "Ahk Files (*.ahk)")

    if (SelectedFile = '') {
        return
    } else {
        editBoxAhk.Text := SelectedFile
        INI.Write("Settings", "SelectedAHK", SelectedFile)

        editBoxExe.Text := StrReplace(SelectedFile, ".ahk", ".exe")
    }
}

buttonSelectExe_Click(Ctrl, Info) {

    If IsShiftKeyPressed() {
        DoOpen(editBoxExe.Text)
        return
    }

    WriteStatus()

    SelectedFile := FileSelect(1+2, editBoxExe.Text, "Open EXE file", "EXE Files (*.exe)")

    if (SelectedFile = '') {
        return
    } else {
        INI.Write("Settings", "SelectedEXE", SelectedFile)
        editBoxExe.Text := SelectedFile
    }
}

buttonSelectIss_Click(Ctrl, Info) {

    If IsShiftKeyPressed() {
        DoOpen(editBoxIss.Text)
        return
    }


    SelectedFile := FileSelect(1+2, editBoxIss.Text, "Open ISS file", "ISS Files (*.iss)")

    if (SelectedFile = '') {
        return
    } else {
        INI.Write("Settings", "SelectedISS", SelectedFile)
        editBoxIss.Text := SelectedFile
    }
}

Gui_Close(*) {
    DoStopExe()
    Hotkey("F1", "Off")
    WriteIni()
}

; #region Functions

DoEdit(Item) {
    WriteStatus()
    switch Item {
        case "AHK":
            Run(EditBoxAhk.Text)
        case "EXE":
            Run(EditBoxExe.Text)
        case "ISS":
            Run(EditBoxIss.Text)
    }
}

DoOpen(Item) {
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
DoStopExe(){

    processName := SplitPathObj(editBoxExe.Text).FileName

    r := ProcessClose(processName)

    if (r != 0) {
        WriteStatus("Exe Stopped : " processName)
        Sleep(2000) ; give time to close and user to read
    }    
}

;buttonRunExeClicked(Ctrl, Info) {
DoRunExe() {

    exePath := editBoxExe.Text

    if !FileExist(exePath) {
        WriteStatus("File not found: " exePath)
        return
    }

    WriteStatus("Running : " exePath "...")
    
    command :=    '"' exePath '"'
    
    try {
        exitCode := RunWait(command, , "Hide")
        if (exitCode == 0) {
            WriteStatus("Ran successfully: " exePath)
        } else {
            WriteStatus("Failed with exit code: " exitCode)
        }
    } catch Error as e {
        MsgBox("Failed to run EXE`n`n" e.Message, "Error", "OK Icon!")
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
    ; Create a COM object for Scriptlet.TypeLib
    try {
        ; Use COM to create an instance of the GUIDGen object
        guidString := ComObject("Scriptlet.TypeLib").GUID

        ; Replace the single curly braces with double curly braces
        ; StringReplace is used to replace the starting "{" with "{{"
        ; and the ending "}" with "}}".
        guidString := StrReplace(guidString, "{", "{{", 1)
        guidString := StrReplace(guidString, "}", "}}", 1)

        ; Return the final formatted GUID string
        return guidString
    }
    catch as e
    {
        ; Handle errors gracefully in case the COM object cannot be created
        MsgBox("An error occurred: " e.Message)
        return ""
    }
}

SplitPathObj(path) {
    SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    SplitPath(Dir,,,,&ParentDir)
    return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}

DoHelp() {
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