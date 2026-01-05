#Requires AutoHotkey v2.0

; Directives, keywords
#SingleInstance Force
#NoTrayIcon

#Include "..\..\Lib\IniFile_Static.ahk"

; #region Version Info Block
;@Ahk2Exe-Set ProductName, Gui Example
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-Set LegalCopyright, © 2025 jasc2v8
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Gui Example
;@Ahk2Exe-Set OriginalFilename, GuiExample.exe
; --- End of Version Info Block ---

; #region Global Variables
global iniPath := A_Temp "\SetupMaker\SetupMaker.ini"

; #region Hotkeys
^h::ShowHelp()

; #region Create Gui
MyGui := Gui(, "Setup Maker") ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w480", "Segouie UI")

buttonSelectAhk := MyGui.Add("Button", "w104 h24 xm ym", "AHK Script")
editBoxAhk := MyGui.Add("Edit", "yp w640 h24")
buttonCompileAhk := MyGui.Add("Button", "yp w76 h24", "Compile")
buttonExplore := MyGui.Add("Button", "yp w76 h24", "Explore")

buttonSelectExe := MyGui.Add("Button", "w104 h24 xm", "AHK Exe")
editBoxExe := MyGui.Add("Edit", "yp w640 h24")
buttonCompileIss := MyGui.Add("Button", "yp w76 h24", "Build")
buttonExplore_new := MyGui.Add("Button", "yp w76 h24", "Run")

buttonSelectIss := MyGui.Add("Button", "w104 h24 xm", "ISS Template")
editBoxIss := MyGui.Add("Edit", "yp w640 h24")
buttonEdit := MyGui.Add("Button", "yp w76 h24", "Edit")
buttonCancel := MyGui.Add("Button", "yp w76 h24 Default", "Cancel")

MyGui.GetPos(,, &w, &h)

;MyGui.Add("Text", "xm y+m h1 w812" " +0x9") ; Etched horizontal line that autosizes with the GUI

myStatusBar := myGui.Add("StatusBar")

; #region Bind OnEvent Handlers
buttonSelectAhk.OnEvent("Click", buttonSelectAhkClicked)
buttonSelectExe.OnEvent("Click", buttonSelectExeClicked)
buttonSelectIss.OnEvent("Click", buttonSelectIssClicked)
buttonCompileAhk.OnEvent("Click", buttonCompileAhkClicked)
buttonCompileIss.OnEvent("Click", buttonBuildIssClicked)
buttonExplore.OnEvent("Click", buttonExploreClicked)
buttonEdit.OnEvent("Click", buttonEditClicked)
buttonCancel.OnEvent("Click", buttonCancelClicked)

myGui.OnEvent("Close", OnCloseHandler)

; #region Show GUI
MyGui.Show()

; Uncomment to determine the width of the Text control
;MyGui.GetPos(,, &w, &h)
;MsgBox("GUI Dimensions:`n`nWidth: " w "`n`nHeight: " h, "GUI Size")

WriteStatus("Press Ctrl-h for HELP")
; Read saved settings from ini file
resultCode := IniFile.Initialize(iniPath)
if (!resultCode) {
	MsgBox("ERROR Initializing IniFile")
	ExitApp()
}

ReadIni()

; #region Click Handlers

buttonSelectAhkClicked(Ctrl, Info) {

    WriteStatus()

    SelectedFile := FileSelect(1+2, , "Open AHK file", "Ahk Files (*.ahk)")

    if (SelectedFile = '') {
        return
    } else {
        IniFile.Write("Settings", "SelectedAHK", SelectedFile)
        editBoxAhk.Text := SelectedFile
    }
}

buttonSelectExeClicked(Ctrl, Info) {

    WriteStatus()

    SelectedFile := FileSelect(1+2, , "Open EXE file", "EXE Files (*.exe)")

    if (SelectedFile = '') {
        return
    } else {
        IniFile.Write("Settings", "SelectedEXE", SelectedFile)
        editBoxExe.Text := SelectedFile
    }
}

buttonSelectIssClicked(Ctrl, Info) {

    WriteStatus()

    SelectedFile := FileSelect(1+2, , "Open ISS file", "ISS Files (*.iss)")

    if (SelectedFile = '') {
        return
    } else {
        IniFile.Write("Settings", "SelectedISS", SelectedFile)
        editBoxIss.Text := SelectedFile
    }
}

buttonCompileAhkClicked(Ctrl, Info) {

    WriteStatus("Running Ahk2Exe to compile EXE...")
 
    ; make sure files exist
    ahkPath := editBoxAhk.Text

    if !FileExist(ahkPath) {
        MsgBox("Error: File not found:`n`n" ahkPath, "Error", "OK Icon!")
        return
    }

    ; load EXE
    global exePath := StrReplace(ahkPath, ".ahk", ".exe")

    ; run ahk2exe

    ahk2exePath := "C:\Program Files\AutoHotkey\Compiler\ahk2exe.exe"
    if !FileExist(ahk2exePath) {
        MsgBox("Error: Ahk2Exe Compiler not found at:`n`n" ahk2exePath, "Error", "OK Icon!")
        return
    }

    iconPath := StrReplace(exePath, ".exe", ".ico")
     if !FileExist(iconPath) {
        return
    }

    ; The /Q switch makes the compilation quiet. The command and path are quoted to handle spaces.
    command :=    '"' ahk2exePath '"' .
        " /in " '"' ahkPath '"' .
        " /out " '"' exePath '"' .
        " /icon " '"' iconPath '"' .
        ;" /base " '"' basePath '"' .  ; use default set by ahk2exe GUI 
        " /silent "
    
     if FileExist(ahkPath) {
        ;MsgBox("Command: " command, "DEBUG", "OK Icon!")
        ;return
    }

    try {
        exitCode := RunWait(command, , "Hide")
        if (exitCode == 0) {
            WriteStatus("AhkExe created successfully: " exePath)
        } else {
            WriteStatus("AhkExe compile failed with exit code: " exitCode)
        }
    } catch Error as e {
        MsgBox("Failed to run Ahk2Exe Compiler.`n`n" e.Message, "Error", "OK Icon!")
    }
}
buttonBuildIssClicked(Ctrl, Info) {

    WriteStatus("Running ISS to compile setup EXE...")

    ; make sure files exist
    exePath := editBoxExe.Text
    global issPath := editBoxIss.Text

    if !FileExist(exePath) {
        MsgBox("Error: File not found:`n`n" exePath, "Error", "OK Icon!")
        return
    }

    if !FileExist(issPath) {
        MsgBox("Error: File not found:`n`n" issPath, "Error", "OK Icon!")
        return
    }

    ; get replacement values
    iconPath := StrReplace(exePath, ".exe", ".ico")
    newGUID := GenerateGuid()
    outDir := SplitPathObj(exePath).Dir . "\Setup"

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

    ; save iss template as exeName.iss
    exeNameNoExt := SplitPathObj(exePath).NameNoExt
    newIssPath := SplitPathObj(exePath).Dir "\Setup\" exeNameNoExt ".iss"

    if FileExist(newIssPath)
        FileDelete(newIssPath) ; Deletes the file if it exists

    FileAppend(issText, newIssPath, "UTF-8")

    ; Run Inno to create setup exe
    ahk2exePath := "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

    if !FileExist(ahk2exePath) {
        MsgBox("Error: Inno Setup Compiler not found at:`n`n" ahk2exePath, "Error", "OK Icon!")
        return
    }

    ; The /Q switch makes the compilation quiet. The command and path are quoted to handle spaces.
    command := '"' ahk2exePath '" /Q "' newIssPath '"'

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
    Hotkey("^h", , "Off")
	WinClose() ; will invoke OnCloseHandler to gracefully exit
}

; #region Functions

GenerateGuid()
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

1.  **AHK Script**: Select your main AutoHotkey script (.ahk).
    - **Compile**: Compiles the selected .ahk script into an .exe file.
    - **Explore**: Opens the folder containing the .ahk script.

2.  **AHK Exe**: Select the compiled executable (.exe). This is the main application for your installer.
    - **Build**: Creates the setup installer using Inno Setup.
    - **Run**: Executes the selected .exe file.

3.  **ISS Template**: Select your Inno Setup script template (.iss).
    - **Edit**: Opens the selected .iss template for editing.

**Basic Workflow:**
Select AHK -> Compile -> Select EXE -> Select ISS -> Build
)"
    MsgBox(helpText, "Help")
}

StrRepeat(text, times) {
    return StrReplace(Format("{:" times "}", ""), " ", text)
}

ReadIni() {

    value := IniFile.Read("Settings", "SelectedAHK")
    if (value == '')
        editBoxAhk.Text := ''
    else
        editBoxAhk.Text := value


    value := IniFile.Read("Settings", "SelectedEXE")
    if (value == '')
        editBoxExe.Text := ''
    else
        editBoxExe.Text := value

    value := IniFile.Read("Settings", "SelectedISS")
    if (value == '')
        editBoxIss.Text := ''
    else
        editBoxIss.Text := value

}

WriteIni() {
    
    if (editBoxAhk.Text != '')
        IniFile.Write("Settings", "SelectedAHK", editBoxAhk.Text)
    
    if (editBoxExe.Text != '')
        IniFile.Write("Settings", "SelectedEXE", editBoxExe.Text)
    
    if (editBoxIss.Text != '')
        IniFile.Write("Settings", "SelectedISS", editBoxIss.Text)
}
WriteStatus(Text := '', Pad := 4) {
    myStatusBar.SetText(StrRepeat(" ", Pad) . Text )
}