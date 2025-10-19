;ABOUT: Update version info and ISS templates
/*
    From: AhkSetupBuilder-v0.0.0.26-usethisone.ahk

    TODO: 
    DoReadProductVersion [Inno Template] _setup_v1.0.0.0.exe
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

#Include "..\..\Lib\IniLite.ahk"


; #region Version Info Block

;@Ahk2Exe-Set ProductName, AhkSetupBuilder
;@Ahk2Exe-Set FileVersion, 0.0.0.2
;@Ahk2Exe-Set ProductVersion, 0.0.0.1
;@Ahk2Exe-Set LegalCopyright, © 2025 jasc2v8
;@Ahk2Exe-Set CompanyName, AhkApps
;@Ahk2Exe-Set FileDescription, AutoHotkey Setup Builder
;@Ahk2Exe-Set OriginalFilename, AhkSetupBuilder.exe
;@Ahk2Exe-SetMainIcon AhkSetupBuilder.ico

/**
 *  Setting a GUID in Inno Setup is crucial for ensuring a 
 * consistent and unique identity for your application across
 * different versions. The GUID (Globally Unique Identifier)
 * is used by the Windows operating system to track your application for
 * uninstallation and updates.
 * 
 *   In Inno Setup, the GUID is defined using the AppId directive
 * in the [Setup] section of your script. You should always set a 
 * unique GUID for your application and keep it consistent for all
 * future installer versions. This prevents the installer from 
 * creating multiple uninstall entries and ensures updates work correctly.
 * 
 *  ;@Inno-AppId is a custom directive that is ignored by
 * the Ahk2exe compiler. This application reads this value and writes it to
 * the ISS Template you select.
 */
;@Inno-Set AppId, {{B7D1FB29-B701-4010-8DEA-A5477C60C76D}}
;@Inno-Set AppPublisher, AhkApps

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

;TODO REPLACE THIS WITH CONFIG INIT
DoIniRead()


;DoConfigInitialize()
;DEBUG
;DoFindInFile(editBoxAhk.Text, ";@Ahk2Exe-Set ProductVersion,")
;DoFindInFile(editBoxAhk.Text, ";@Inno-Set AppId,")

; path := "AhkSetupBuilder.ahk"
; ;path := "AhkSetupBuilder-v0.0.0.26.ahk"
; ;path := "AhkSetupBuilder-v0.0.0.26-usethisone.ahk"
; ver := DoReadSetting(path, ";@Ahk2Exe-Set ProductVersion,")
; ;ver := DoReadSetting(editBoxAhk.Text, ";@Ahk2Exe-Set ProductVersion,")
; MsgBox("ver: [" ver "]", "DEBUG")

; ;guid := DoReadSetting(editBoxAhk.Text, ";@Inno-Set AppId,")
; ;guid := DoReadSetting(path, ";@Inno-Set AppId,")
; ;MsgBox("guid: [" guid "]", "DEBUG")

; ExitApp


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
DoCheckFileProperties(filePath) {

    static propertiesArray := [
            "Name",
            "Size",
            "ProductName", 
            "ProductVersion", 
            "FileDescription",
            "Company", 
            "Copyright", 
            "FileVersion", 
        ]

    try
    {
        ; Create a Shell.Application COM object
        shellApp := ComObject('Shell.Application')

        ; Get the parent folder and filename
        splitPath(filePath, &filename, &directory)
        folder := shellApp.Namespace(directory)
        fileItem := folder.ParseName(filename)

        ; Get the file version using the ExtendedProperty method
        fileVersion := fileItem.ExtendedProperty('System.Size')

        buff := ''
        buffMissing := ''
        ItemCount := 0

        missing := ''

        for key, value in propertiesArray {

            ItemCount++

            props := ''
            props := fileItem.ExtendedProperty(value)

            if (props = '') {
                buffMissing .= value . "`n"
            } else {
                buff .= props . "`n"
            }

            ;MsgBox('[' props ']')

            ;buff .= props . "`n`n"


            ; if IsSet(props) && props != '' {
            ;     buff .= props
            ;     ;MsgBox(filepath . " is missing required property: `n`n" value)
            ;     return ''
            ; }
        }

        ;MsgBox("buffMissing: " buffMissing ", len: " StrLen(buffMissing))

        return buffMissing

        ; if buffMissing != '' {
        ;     return buffMissing
        ; } else {
        ;     return buff
        ; }
    }
    catch as e
    {
        MsgBox 'Error: ' e.Message
    }
}

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
    if !DirExist(SplitPathObj(ahkExePath).Dir) {
       MsgBox("Dir not found:`n`n" ahkExePath, "DoCompileAhk ERROR","OK Icon!")
       return
    }

    outDir := SplitPathObj(ahkExePath).Dir
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
    outDir := SplitPathObj(ahkPath).Dir
    innoExePath := SplitPathObj(ahkPath).NameNoExt "_setup_vX.X.X.X.exe"

    if !FileExist(ahkExePath) {
        MsgBox("AHK EXE file not found:`n`n" ahkExePath, "DoCompileIss ERROR", "OK Icon!")
        return
    }

    props := DoCheckFileProperties(ahkExePath)
    if (props != '') {
        MsgBox("Missing required properties:`n`n" .
        "File:`n`n" ahkExePath "`n`n" .
        "Missing:`n`n" . props "`n" ,
        "DoCompileIss ERROR", "OK Icon!")
        return
    }

    if !FileExist(issPath) {
        MsgBox("ISS file not found:`n`n" issPath, "DoCompileIss ERROR", "OK Icon!")
        return
    }

    if !FileExist(iconPath) {
        MsgBox("Icon file not found:`n`n" iconPath, "DoCompileIss ERROR", "OK Icon!")
        return
    }

    ; get replacement values
    issGUID := DoReadSetting(editBoxAhk.Text, ";@Inno-Set AppId,")

    if !issGUID {
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
    issText := StrReplace(issText, "%MyAppFilePath%", ahkExePath)
    issText := StrReplace(issText, "%MyAppIconPath%", iconPath)
    issText := StrReplace(issText, "%MyAppId%", issGUID)
    issText := StrReplace(issText, "%MyOutputDir%", outDir)
    issText := StrReplace(issText, "%MyIconPath%", iconPath)
    issText := StrReplace(issText, "%MyAppPublisher%", issPublisher)

    ; save iss template as exeName.iss
    ;DELETE exeNameNoExt := SplitPathObj(ahkPath).NameNoExt
    newIssPath := SplitPathObj(ahkPath).Dir "\" SplitPathObj(ahkPath).NameNoExt ".iss"

    ; if !FileExist(newIssPath) {
    ;     MsgBox("New ISS path not found:`n`n" newIssPath, "DoCompileIss ERROR", "OK Icon!")
    ;     return
    ; }

    ; Write the new .iss file
    if FileExist(newIssPath)
        FileDelete(newIssPath)
    FileAppend(issText, newIssPath, "UTF-8")
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
    
    configFile := SplitPathObj(EditBoxAhk.Text).NameNoExt ".config"

    configFullPath := configPath . configFile

    if !DirExist(configPath)
        DirCreate(configPath)
    
    MyGui.Opt("+OwnDialogs")
    
    selectedFolder := FileSelect("S16", configFullPath, "Save Config As...", 
        "Config Files (*.config)")

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
DoConfigInitialize() {
    if FileExist(configPath)
        return

    DirCreate(configPath)

    FileDelete(configPath)

    FileAppend("[Configuration]", configPath)
    FileAppend("AHK=OPEN YOUR AHK SCRIPT", configPath)

    FileAppend("AHK_EXE=OPEN YOUR AHK EXE ", configPath)

    configText := "OPEN YOUR AHK SCRIPT"
    FileAppend(configText, configPath)

; (
; [Configuration]
; AHK=D:\Software\DEV\Work\AHK2\Projects\AhkSetupBuilder\AhkSetupBuilder_v0.0.0.26.ahk
; AHK_EXE=D:\Software\DEV\Work\AHK2\Projects\AhkSetupBuilder\AhkSetupBuilder_v0.0.0.26.exe
; ISS=C:\Users\Jim\Documents\AutoHotkey\AhkSetupBuilder\Templates\Template_OneFile.iss
; ISS_EXE=D:\Software\DEV\Work\AHK2\Projects\AhkSetupBuilder\AhkSetupBuilder_setup_vX.X.X.X.exe
; )"
;         FileDelete(iniPath)
; AhkSetupBuilder.config    
}
DoConfigLoad() {

    global configPath

    if !DirExist(configPath)
        DirCreate(configPath)

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

DoFindInFile_DELETE(textFilePath, findKey) {
    line_number := 0
    found_lines := ""
    try {
        file_obj := FileOpen(textFilePath, "r")
        while !file_obj.AtEOF {
            line_number += 1
            line_content := file_obj.ReadLine()

            ;if (SubStr(line_content, 1, StrLen(findKey)) != findKey)
                ;continue

            if InStr(line_content, findKey, true) {
                ;found_lines .= line_content . ","

                MsgBox "DEBUG line_content: [" . line_content . " ]"

                return line_content
            }
        }
        file_obj.Close()
    } catch {
        MsgBox "Error reading file: " . Error.Message
        return
    }

    lineParts := StrSplit(found_lines, ",")

    For index, item in lineParts {
        MsgBox "Item at index " . index . " is: [" . item . " ]"
    }
    

    ;MsgBox("found_lines: " found_lines "`n`n" .
    ;foundPart: [" foundPart "]", "DEBUG")

    ;DEBUG
    ;return lineParts[2]
    return


}

DoReadGuid_OLD(textFilePath) {
    findKey := ";@Inno-Set AppId,"
    foundLine := DoFindInFile(textFilePath, findKey)
    lineParts := StrSplit(foundLine, ",")
    return Trim(lineParts[2])
}

DoReadProductVersion(textFilePath) {
    findKey := ";@Ahk2Exe-Set ProductVersion,"
    foundLine := DoFindInFile(textFilePath, findKey)

    MsgBox "DEBUG foundLine: [" foundLine " ]"

    lineParts := StrSplit(foundLine, ",")
    return Trim(lineParts[2])
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
DoGetFileVersionInfo(FilePath, VersionKey) {
    ; Check if the file exists to prevent errors.
    if (!FileExist(FilePath)) {
        return ""
    }

    ; Step 1: Get the size of the version information buffer required.
    ; VerQueryValueA: A - ANSI version (no W for Wide/Unicode)
    ; This call returns the number of bytes required for the buffer.
    bufferSize := DllCall("Version\GetFileVersionInfoSizeA", "Str", FilePath, "UInt", 0)

    ; If the size is 0, no version info is available.
    if (bufferSize = 0) {
        return ""
    }

    ; Step 2: Allocate memory and retrieve the version information.
    ; VarSetCapacity: Allocates a buffer of the required size.
    ; This call fills the buffer with the version information data.
    ObjSetCapacity(versionBuffer, bufferSize)
    DllCall("Version\GetFileVersionInfoA", "Str", FilePath, "UInt", 0, "UInt", bufferSize, "Ptr", &versionBuffer)

    ; Step 3: Query the buffer for the specific string value.
    ; VerQueryValueA: Queries the version information buffer.
    ; The first parameter is the pointer to our versionBuffer.
    ; The second parameter is the sub-block to query. We're using the standard
    ; English (US) block "StringFileInfo\040904B0\".
    queryBlock := "\StringFileInfo\040904B0\" . VersionKey
    
    ; The 'InfoPtr' will receive a pointer to the start of the desired string.
    ; The 'InfoLen' will receive the length of the string in characters.
    InfoPtr := 0
    InfoLen := 0
    
    ; The DllCall returns a non-zero value on success.
    success := DllCall("Version\VerQueryValueA", "Ptr", &versionBuffer, "Str", queryBlock, "PtrP", InfoPtr, "UIntP", InfoLen)
    
    if (success && InfoPtr != 0) {
        ; Step 4: Extract the string from the pointer.
        ; StrGet() is used to read a string from memory given a pointer.
        ; The second parameter specifies the encoding (UTF-8 for AHK v2).
        return StrGet(InfoPtr, "UTF-8")
    }

    ; Return an empty string if the query was not successful.
    return ""
}

DoGetGuid_DEBUG() {

    findKey := ";@Inno-AppId"
    guidFormat := "{{B7D1FB29-B701-4010-8DEA-A5477C60C76D}}"

    ; read .ahk script
    try {
        scriptContent := FileRead(editBoxAhk.Text)
    } catch Error as e {
        Throw("Error reading .ahk script: " e.Message)        
    }

    ; find ";@Inno-AppId"
    startPos := InStr(scriptContent, ";@Inno-AppId")
    if (startPos == 0) {
        MsgBox("ERROR .ahk script does not contain @Inno-Appid {{GUID}}")
        return    
    }

    ; extract the GUID: "{{B7D1FB29-B701-4010-8DEA-A5477C60C76D}}"
    GUID := SubStr(scriptContent, 
        startPos, StrLen(guidFormat))

    MsgBox("DEBUG startPos: " startPos "`n`n" .
        "DEBUG findKey: " findKey "`n`n" .
        "DEBUG guidFormat: " guidFormat "`n`n" .
        "DEBUG GUID: " GUID)

    

    ; return the GUID
    ;MsgBox("DEBUG GUID: " GUID)
    return GUID
}

DoGetProductVersion() {

    ; arrayPathVer := DoGetFilePathAndVersion(A_ScriptFullPath)
 
    ; ;if version not in filename
    ; if (arrayPathVer[2] =="") {
        ;Read from script
        return DoReadSetting(A_ScriptFullPath,
            ";@AHK2EXE_PATH-Set ProductVersion,")
    ; } else {
    ;     return arrayPathVer[2]
    ; }
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

    DoIniWrite("Settings", Item, SelectedFolder) 
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
DoIniWrite(section, key, value) {
    INI := IniLite(iniPath)
    INI.Write(section, key, value)
    INI := ""
}

DoIniWriteAll() {
    
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

WriteStatus(Text := '') {
    myStatusBar.SetText("    " . Text )
}