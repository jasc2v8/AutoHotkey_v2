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

;# region Create a new Gui object
MyGui := Gui(, "Setup Maker") ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w480", "Segouie UI")

buttonSelectExe := MyGui.Add("Button", "w76 h24 xm ym", "Select EXE")  ; "x+5 y+5"
editBoxExe := MyGui.Add("Edit", "yp w640 h24")

buttonSelectIss := MyGui.Add("Button", "w76 h24 xm", "Select ISS")  ; "x+5 y+5"
editBoxIss := MyGui.Add("Edit", "yp w640 h24")

MyDividerLine := StrRepeat("_", 103)
MyGui.Add("Text", "xm y+0", MyDividerLine)
buttonMake := MyGui.Add("Button", "xm w76 h24", "Make")  ; "x+5 y+5"
buttonExplore := MyGui.Add("Button", "yp w76 h24", "Explore")
buttonCancel := MyGui.Add("Button", "yp w76 h24 Default", "Cancel")

; OnEvent Handlers
buttonSelectExe.OnEvent("Click", buttonSelectExeClicked)
buttonSelectIss.OnEvent("Click", buttonSelectIssClicked)
buttonMake.OnEvent("Click", buttonMakeClicked)
buttonExplore.OnEvent("Click", buttonExploreClicked)
buttonCancel.OnEvent("Click", buttonCancelClicked)

myGui.OnEvent("Close", OnCloseHandler)

; Show the GUI
MyGui.Show("w760 h132")

; Read saved settings from ini file
resultCode := IniFile.Initialize(iniPath)
if (!resultCode) {
	MsgBox("ERROR Initializing IniFile")
	ExitApp()
}

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

; #region Click Handlers

buttonSelectExeClicked(Ctrl, Info) {

    SelectedFile := FileSelect(1+2, , "Open EXE file", "EXE Files (*.exe)")

    if (SelectedFile = '') {
        return
    } else {
        IniFile.Write("Settings", "SelectedEXE", SelectedFile)
        editBoxExe.Text := SelectedFile
    }
}

buttonSelectIssClicked(Ctrl, Info) {

    SelectedFile := FileSelect(1+2, , "Open ISS file", "ISS Files (*.iss)")

    if (SelectedFile = '') {
        return
    } else {
        IniFile.Write("Settings", "SelectedISS", SelectedFile)
        editBoxIss.Text := SelectedFile
    }
}

buttonMakeClicked(Ctrl, Info) {

    ; make sure files exist
    exePath := editBoxExe.Text
    issPath := editBoxIss.Text

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

    ; make setup: Run "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    isccPath := "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

    if !FileExist(isccPath) {
        MsgBox("Error: Inno Setup Compiler not found at:`n`n" isccPath, "Error", "OK Icon!")
        return
    }

    ; The /Q switch makes the compilation quiet. The command and path are quoted to handle spaces.
    command := '"' isccPath '" /Q "' newIssPath '"'

    try {
        exitCode := RunWait(command, , "Hide")
        if (exitCode == 0) {
            MsgBox("Setup created successfully in:`n" outDir, "Success", "OK")
        } else {
            MsgBox("Inno Setup compilation failed with exit code: " exitCode, "Error", "OK Icon!")
        }
    } catch Error as e {
        MsgBox("Failed to run Inno Setup Compiler.`n`n" e.Message, "Error", "OK Icon!")
    }
}

buttonExploreClicked(Ctrl, Info) {
    Run(SplitPathObj(editBoxExe.Text).Dir)
}

buttonFolderClicked(Ctrl, Info) {

 editBoxExe.Value := ""

 SelectedFolder := FileSelect("D", , "Select a folder")

 if SelectedFolder = ""
  editBoxExe.Text := "The dialog was canceled."
 else
 editBoxExe.Text := "Folder selected: " . SelectedFolder
}

buttonCancelClicked(Ctrl, Info) {
	WinClose() ; will invoke OnCloseHandler to gracefully exit
}

; #region Functions

GenerateGuid()
{
    ; Create a COM object for Scriptlet.TypeLib
    try {
        ; Use COM to create an instance of the GUIDGen object
        guidString := ComObject("Scriptlet.TypeLib").GUID

        ; Get the GUID string. This will be in the format {xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}.
        ;guidString := GUIDGen.Value

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

    if (editBoxExe.Text != '') {
        IniFile.Write("Settings", "SelectedEXE", editBoxExe.Text)
    }
    
    if (editBoxIss.Text != '') {
        IniFile.Write("Settings", "SelectedISS", editBoxIss.Text)
    }
}

InitializeIniFile(iniPath) {
    resultCode := IniFile.Initialize(iniPath)

    if (!resultCode)
    	MsgBox("ERROR Initializing IniFile")
}


SplitPathObj(path) {
    SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    SplitPath(Dir,,,,&ParentDir)
    return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}

StrRepeat(text, times) {
 return StrReplace(Format("{:" times "}", ""), " ", text)
}
; This function is called when the window is closed
MyGui.OnEvent("Close", (*) => ExitApp())
