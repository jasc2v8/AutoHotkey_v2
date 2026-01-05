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
global iniPath := A_Temp "\AhkBuilder\AhkBuilder.ini"
global ahk2exe := "C:\Program Files\AutoHotkey\Compiler\ahk2exe.exe"
global innoExe := "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

; #region Hotkeys
F1::ShowHelp()

; #region GUI Create
MyGui := Gui(, "AHK Buidler -- Ahk2Exe Compiler & Inno Setup Builder") ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w532", "Segouie UI")
;MyGui.SetFont("S11 CBlack w520")

buttonSelectAhk := MyGui.Add("Button", "w104 h24 xm ym", "AHK Script ▷")
;labelMenuOpenAhk := MyGui.Add("Text", "w104 h24 xm ym", "AHK Script:")
editBoxAhk := MyGui.Add("Edit", "yp w640 h24")
;buttonCompileAhk := MyGui.Add("Button", "yp w76 h24", "Compile")
;buttonExplore := MyGui.Add("Button", "yp w76 h24", "Explore")

buttonSelectIss := MyGui.Add("Button", "w104 h24 xm", "Inno Template ▷")
;buttonSelectIss := MyGui.Add("Button", "w104 h24 xm", "ISS Template ▷")
;labelSelectIss := MyGui.Add("Text", "w104 h24 xm", "ISS Template")
editBoxIss := MyGui.Add("Edit", "yp w640 h24")
;buttonEdit := MyGui.Add("Button", "yp w76 h24", "Edit")
;buttonCancel := MyGui.Add("Button", "yp w76 h24 Default", "Cancel")

buttonSelectExe := MyGui.Add("Button", "w104 h24 xm", "AHK Exe ▷")
;labelSelectExe := MyGui.Add("Text", "w104 h24 xm", "AHK Exe")
editBoxExe := MyGui.Add("Edit", "yp w640 h24")
;buttonBuildExe := MyGui.Add("Button", "yp w76 h24", "Build")
;buttonRunExe := MyGui.Add("Button", "yp w76 h24", "Run")

; #region Menu Bar Submenus
FileMenu := Menu()
FileMenu.Add("▽▽▽ Click=SELECT, Shift+Click=EXPLORE:", MenuHandler)
;FileMenu.Add() ; Separator line.
FileMenu.Add("Select AHK", MenuHandler)
FileMenu.Add("Select EXE", MenuHandler)
FileMenu.Add("Select ISS", MenuHandler)
FileMenu.Add() ; Separator line.
FileMenu.Add("Open Config file", MenuHandler)
FileMenu.Add("Save Config file", MenuHandler)
FileMenu.Add("Save As Config file", MenuHandler)
FileMenu.Add() ; Separator line.
FileMenu.Add("E&xit", MenuHandler)

ToolsMenu := Menu()
ToolsMenu.Add("Build", MenuHandler)
ToolsMenu.Add("Run EXE", MenuHandler)
ToolsMenu.Add("Stop EXE", MenuHandler)

HelpMenu := Menu()
HelpMenu.Add("&Documentation", MenuHandler)
HelpMenu.Add("")
HelpMenu.Add("&About", MenuHandler)

; #region Menu Bar
MyMenuBar := MenuBar()
MyMenuBar.Add("File", FileMenu)
MyMenuBar.Add("Tools", ToolsMenu)
MyMenuBar.Add("Help", HelpMenu)

; Attach the menu bar to the window:
MyGui.MenuBar := MyMenuBar

;MyGui.GetPos(,, &w, &h)
;MyGui.Add("Text", "xm y+m h1 w812" " +0x9") ; Etched horizontal line that autosizes with the GUI

myStatusBar := myGui.Add("StatusBar")

; #region Bind OnEvent Handlers
buttonSelectAhk.OnEvent("Click", buttonSelectAhkClicked)
;buttonMenuOpenAhk.OnEvent("Click", buttonMenuOpenAhkClicked)
;buttonCompileAhk.OnEvent("Click", buttonCompileAhkClicked)
;buttonExplore.OnEvent("Click", buttonExploreClicked)

buttonSelectExe.OnEvent("Click", buttonSelectExeClicked)
;buttonRunExe.OnEvent("Click", buttonRunExeClicked)

buttonSelectIss.OnEvent("Click", buttonSelectIssClicked)
;buttonBuildExe.OnEvent("Click", buttonBuildIssClicked)
;buttonEdit.OnEvent("Click", buttonEditClicked)
;buttonCancel.OnEvent("Click", buttonCancelClicked)

myGui.OnEvent("Close", OnCloseHandler)

; #region GUI Show
MyGui.Show()

; Uncomment to determine the width of the Text control
;MyGui.GetPos(,, &w, &h)
;MsgBox("GUI Dimensions:`n`nWidth: " w "`n`nHeight: " h, "GUI Size")

; Read saved settings from ini file
iniPath := A_Temp "\AhkBuilder\AhkBuilder.ini"
resultCode := INI := IniFile(iniPath)
if (!resultCode) {
	MsgBox("ERROR Initializing IniFile")
	ExitApp()
}

ReadIni()

; #region Handlers Button

MenuSelectAhkClicked(item) {

    MsgBox("DEBUG: MenuSelectAhkClicked You selected " item)
    buttonSelectAhkClicked(0, 0)
}

MenuSelectExeClicked(*) {
    buttonSelectExeClicked(MyGui, 0)
}

MenuSelectIssClicked(*) {
    buttonSelectIssClicked(MyGui, 0)
}

buttonSelectAhkClicked(Item, *) {

    ;MsgBox("buttonSelectAhkClicked: You selected " Item.Text)

    If IsShiftKeyPressed() {
        DoExplore(editBoxAhk.Text)
        return
    }

    SelectedFile := FileSelect(1+2, editBoxAhk.Text, "Open AHK file", "Ahk Files (*.ahk)")

    if (SelectedFile = '') {
        return
    } else {
        editBoxAhk.Text := SelectedFile
        IniFile.Write("Settings", "SelectedAHK", SelectedFile)

        editBoxExe.Text := StrReplace(SelectedFile, ".ahk", ".exe")
    }
}

buttonSelectExeClicked(Ctrl, Info) {

    If IsShiftKeyPressed() {
        DoExplore(editBoxExe.Text)
        return
    }

    WriteStatus()

    SelectedFile := FileSelect(1+2, editBoxExe.Text, "Open EXE file", "EXE Files (*.exe)")

    if (SelectedFile = '') {
        return
    } else {
        IniFile.Write("Settings", "SelectedEXE", SelectedFile)
        editBoxExe.Text := SelectedFile
    }
}

buttonSelectIssClicked(Ctrl, Info) {

    If IsShiftKeyPressed() {
        DoExplore(editBoxIss.Text)
        return
    }


    SelectedFile := FileSelect(1+2, editBoxIss.Text, "Open ISS file", "ISS Files (*.iss)")

    if (SelectedFile = '') {
        return
    } else {
        IniFile.Write("Settings", "SelectedISS", SelectedFile)
        editBoxIss.Text := SelectedFile
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

;buttonCompileAhkClicked(Ctrl, Info) {
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

;buttonBuildIssClicked(Ctrl, Info) {
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

buttonEditClicked(Ctrl, Info) {
    WriteStatus()
    Run(editBoxIss.Text)
}

buttonExploreClicked(Ctrl, Info) {
    WriteStatus()
    Run(SplitPathObj(editBoxExe.Text).Dir)
}

buttonCancelClicked(Ctrl, Info) {
	WinClose()
    ExitApp()
}

; #region Handler Menu

MenuHandler(Item, *) {

    ; File Menu

    switch Item {
        case "Select AHK":
            buttonSelectAhkClicked(0, 0)
            return
            
        case "Select EXE":
            buttonSelectExeClicked(0, 0)
            
        case "Select ISS":
            buttonSelectIssClicked(0, 0)
            
        case "Open Config file":
            
        case "Save Config file":
            
        case "Save As Config file":
            
        case "E&xit":
            WinClose()
        
        ; default:
        ;     SoundBeep
            ;MsgBox("MenuHandler: You selected [" Item "]")
    }

    ; Tools Menu

    switch Item {
        case "Build":
            DoBuild()
            return           
        case "Run EXE":
            DoRunExe()
            return
        case "Stop EXE":
            DoStopExe()
            return
        default:
            SoundBeep
    }

}

; #region Functions

DoSaveConfig(){

}

DoSaveAsConfig(){

}

DoOpenConfig(){


}
DoBuild() {

    r :=MsgBox("Compile AHK to EXE?", "Build", "YesNo icon?")
    if (r == "Yes")
        DoCompileAhk()

    r :=MsgBox("Compile ISS to EXE?", "Build", "YesNo icon?")
    if (r == "Yes")
        DoCompileIss()
}


DoExplore(path) {
    Run(SplitPathObj(path).Dir)
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

OnCloseHandler(MyGui) {
    DoStopExe()
    Hotkey("F1", "Off")
    WriteIni()
}

SplitPathObj(path) {
    SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    SplitPath(Dir,,,,&ParentDir)
    return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}

ShowHelp() {
    helpText := "
    (
Setup Maker Help

This tool helps create an Inno Setup installer for your AutoHotkey script.

1.  [AHK Script]: Select your main AutoHotkey script (.ahk).
    - [Compile] : Compiles the selected .ahk script into an .exe file.
    - [Explore] : Opens the folder containing the .ahk script.

2.  [AHK Exe]: Select the compiled executable (.exe). This is the main application for your installer.
    - [Build]: Creates the setup installer using Inno Setup.
    - [Run]  : Executes the selected .exe file.

3.  [ISS Template]: Select your Inno Setup script template (.iss).
    - [Edit]: Opens the selected .iss template for editing.

Basic Workflow:
Select AHK -> Compile -> Select EXE -> Select ISS -> Build
)"
    MsgBox(helpText, "Help")
}

StrRepeat(text, times) {
    return StrReplace(Format("{:" times "}", ""), " ", text)
}

ReadIni() {

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