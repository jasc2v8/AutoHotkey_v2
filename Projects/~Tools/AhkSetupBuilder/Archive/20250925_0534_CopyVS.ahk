/************************************************************************
 * @description Copy Visual Studio Project and Refactor Project Name
 * @author 		jasc2v8
 * @date 		2025/09/17
 * @version 	1.0.0.0
 ***********************************************************************/

#Requires AutoHotkey v2.0

/*
	TODO
	change make_iss to use make.iss
	change make.iss to read exe for version info
*/

#SingleInstance force
;#NoTrayIcon

; #region Version Info Block

; Copy Visual Studio Project
;@Ahk2Exe-Set ProductName, CopyVS
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-Set LegalCopyright, © 2025 jasc2v8
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Copy Visual Studio Project
;@Ahk2Exe-Set OriginalFilename, CopyVS.exe
;@Ahk2Exe-SetMainIcon CopyVS.ico

; #region Global Variables

global myStatusBar
global iniPath := A_Temp "\CopyVS\CopyVS.ini"

; #region Main Execution

CreateGui()

ShowGui(*) {
	try myGui.Show()
}
HideGui(*) {
	try myGui.Hide()
}

; Ensure the directory for the INI file exists before trying to read or write to it.
try {
	DirCreate(A_Temp "\CopyVS")
} catch Error as e {
	MsgBox("Critical Error: Could not create configuration directory.`n`n" e.Message "`n`nThe application will now exit.", "Error", "OK Icon!")
	ExitApp()
}

if FileExist(iniPath) {
	Edit1.Value := IniRead(iniPath, "Settings", "SelectedFolder")
} else {
	IniWrite(Edit1.Value, iniPath, "Settings", "SelectedFolder")
	WriteStatus("New configuration file created.")
}

; #endregion

; MARK: -

; #region Click Handlers

ButtonCopyClick(Ctrl, Info)
{
	WriteStatus("Ready")
	sourceFolder := Trim(Edit1.Value)

	if !IsDirExist(sourceFolder) {
		MsgBox("Please select a valid project folder.", "Copy Project", "OK Icon!")
		return false
	}

	if !IsProjectClean(sourceFolder) {
		result := MsgBox("Project folder not clean.`n`n"  .
			"Do you want to clean it now?", "Copy Project",  "YesNo Icon?")
		if (result = "Yes")
			ButtonCleanClick(Ctrl, Info)
	}

	targetFolder := FileSelect("D", sourceFolder, "Select Target Directory")

	if (targetFolder = "")
		return

	if (targetFolder = Edit1.Value)
	{
		MsgBox("Can't copy a Project to itsself.", "Copy Project",  "OK Icon!")
		return
	}

	if !IsDirEmpty(targetFolder)
	{
		result := MsgBox("Target Directory not empty:`n`n" . targetFolder . "`n`n" .
			"Do you still want to Copy the Project?", "Copy Project",  "YesNo Icon?")
			if (result != "Yes")
		return
	}

	result := MsgBox("PLEASE VERIFY THE TARGET IS THE NEW PROJECT NAME!" . "`n`n" .
		"Source:`n" sourceFolder . "`n`n" .
		"Target:`n" targetFolder, "Copy Project",  "YesNo Icon!")
		
	if (result != "Yes")
		return
	
	WriteStatus("Copying project...")

	fileCount := DoCopyProject(sourceFolder, targetFolder)

	WriteStatus("Copy complete. " . fileCount . " items processed.")
}

ButtonCleanClick(Ctrl, Info)
{
	WriteStatus("Ready")

	sourceFolder := Trim(Edit1.Value)

	if !IsDirExist(sourceFolder) {
		MsgBox("Please select a valid project folder.", "Clean Project", "OK Icon!")
		return false
	}

	result := MsgBox("Are you sure you want to clean this Directory and Subdirectories?", "DEBUG", "YesNo")

	if (result != "Yes")
		return

	WriteStatus("Cleaning project...")

	ExcludeExtensions := "bin, obj, .vs"

	loopFile := Trim(Edit1.Value) . "\\*.*"

	count := 0

	Loop Files loopFile, "FDR"
	{
		fileExt := SubStr(A_LoopFileFullPath, -3)

		FoundPos := InStr(ExcludeExtensions, fileExt)

		if (FoundPos > 0)
		{
			try {
				DirDelete(A_LoopFileFullPath, true) ; Recurse
				count += 1
			} catch Error as e {
				WriteStatus("Error cleaning " . A_LoopFileFullPath . ": " . e.Message)
				;Sleep(1500) ; Give user time to read the status
			}
		}
	}

	WriteStatus("Clean complete. " . count . " items removed.")
}

ButtonZipClick(Ctrl, Info) {

	WriteStatus("Ready")
	sourceFolder := Trim(Edit1.Value)

	if (sourceFolder = "" || !DirExist(sourceFolder)) {
		MsgBox("Please select a valid project folder.", "Zip Project", "OK Icon!")
		return
	}	

	if !IsProjectClean(sourceFolder) {
		result := MsgBox("Project folder not clean!`n`n"  .
			"Please clean the Project folder before zipping.`n`n" .
			"Do you want to clean it now?", "Zip Project",  "YesNo Icon!")
			if (result = "Yes")
				ButtonCleanClick(Ctrl, Info)
	}	

	WriteStatus("Zipping project...")
	DoZipProject(sourceFolder)
	WriteStatus("Zip operation finished.")
}

ButtonSelectClick(Ctrl, Info) {

	WriteStatus("Ready")
	sourceFolder := Edit1.Value

	SelectedFolder := FileSelect("D", sourceFolder, "Select Folder")

	if (SelectedFolder != "") {
		Edit1.Value := SelectedFolder
		IniWrite(SelectedFolder, iniPath, "Settings", "SelectedFolder")
		WriteStatus("Project folder selection saved.")
	}
 }

ButtonExploreClick(Ctrl, Info) {
	WriteStatus("Ready")
	Run("Explorer " . Edit1.Value)
}

ButtonHelpClick(Ctrl, Info) {
	WriteStatus("Ready")
    StringArray := []
    StringArray.Push("Select:`r`n")
    StringArray.Push("Click     : Opens the Folder Dialog to select the Project folder.`r`n")
    StringArray.Push("Ctrl-Click: Opens the default ProjectDir in the config file.`r`n`n")

    StringArray.Push("Explore:`r`n")
    StringArray.Push("Click     : Opens the Project folder in File Explorer.`r`n")
    StringArray.Push("Ctrl-Click: Opens the Application Folder (to edit the config file).`r`n`n")

    StringArray.Push("Help:`r`n")
    StringArray.Push("Shows this help text.`r`n`n")

    StringArray.Push("Copy:`r`n")
    StringArray.Push("Copies the Project Dir, except the [Excluded Dirs] to reduce the project size on disk.`r`n`n")

    StringArray.Push("Zip:`r`n")
    StringArray.Push("Copies the Project Dir to a Zip file.`r`n`n")

    StringArray.Push("Cancel:`r`n")
    StringArray.Push("Exits this program.")
    FinalString := ArrayJoin(StringArray)
	MsgBox(FinalString, "HELP", "OK")
}

ButtonCancelClick(Ctrl, Info) {
	WinClose()
}

StatusBarClickHandler(Ctrl, Info) {
	WriteStatus("Ready")
}

; #endregion

; MARK: -

; #region Core Logic

DoCopyProject(SourceDir, DestDir) {

	fileCount := 0

	oldName := SplitPathObj(SplitPathObj(SourceDir).FullPath).NameNoExt
	newName := SplitPathObj(SplitPathObj(DestDir).FullPath).NameNoExt

	static Exclusions := '\.vs,\bin,\obj'

	; Create the destination directory if it doesn't exist.
	try {
		DirCreate(DestDir)
	} catch Error as e {
		WriteStatus("Could not create destination directory: `n" e.Message)
		return 0
	}

	; This function checks if a path matches any exclusion.
	; It returns true if it should be excluded, false otherwise.
	ShouldExclude(fullPath, Exclusions) {

		Loop Parse, Exclusions, ','
		{
			;WriteConsole 'fullPath : ' fullPath
			;WriteConsole 'exclusion:' A_LoopField
	
			if InStr(fullPath, A_LoopField)
				return true

		}
		return false
	}

	; Loop recursively through all files and folders in the source directory.
	Loop Files, SourceDir '\*', 'DFR' ; directories, files, recurse
	{
		sourcePath := A_LoopFileFullPath
		destinationPath := StrReplace(sourcePath, oldName, newName, 1)

		if ShouldExclude(sourcePath, Exclusions) {
			continue
		}

		WriteConsole 'A_LoopFileAttrib: ' A_LoopFileAttrib

		; Check if the current item is a directory.
		if A_LoopFileAttrib ~= 'D' {

			WriteConsole 'DirCreate: ' destinationPath

			; Create the corresponding directory in the destination.
			try {
				DirCreate(destinationPath)
			} catch Error as e {
				WriteStatus("Error creating dir: " . e.Message)
			}

		} else {
			; It's a file, so copy it.
			; The '1' ensures files are overwritten if they already exist.

			;DEBUG
			WriteConsole 'FileCopy sourcePath        : ' sourcePath
			WriteConsole 'FileCopy destinationPath: ' destinationPath

			oldText := FileRead(sourcePath)

			newText := StrReplace(oldText, oldName, newName)

			if (newText != oldText) {
				try {
					if FileExist(destinationPath)
						FileDelete(destinationPath)
			
					FileAppend(newText, destinationPath)
				
				} catch Error as e {
					WriteStatus("FileDel or FileApp Error: " e.Message)
				}
			} else {
				try {
					FileCopy(sourcePath, destinationPath, 1)
				} catch Error as e {
					WriteStatus("FileCopy Error: " e.Message)
				}
			}

			fileCount++
		}
	}
	WriteConsole 'Copy complete.'
	return fileCount
}

DoZipProject(sourceFolder) {

	if (sourceFolder = "" || !DirExist(sourceFolder)) {
		MsgBox("Please select a valid project folder to zip.", "Zip Project", "OK Icon!")
		return
	}
	; Ask user for zip file destination
	zipFile := FileSelect("S16", sourceFolder, "Save Zip File", "Zip Files (*.zip)")
	if (zipFile = "")
		return
	; Ensure .zip extension
	if !InStr(zipFile, ".zip")
		zipFile .= ".zip"
	; PowerShell command to zip
	psCommand := "Compress-Archive -Path '" . sourceFolder . "\*' -DestinationPath '" . zipFile . "' -Force"
	try {
		exitCode := RunWait('powershell.exe -NoProfile -Command "' . psCommand . '"', , 'Hide')
		if (exitCode != 0) {
			WriteStatus("Zip operation failed with exit code: " . exitCode)
			MsgBox("The zip operation failed. Please check the source folder and try again.", "Zip Error", "OK Icon!")
		}
	} catch Error as e {
		WriteStatus("Error: Could not run PowerShell. " . e.Message)
		MsgBox("Error: Could not run PowerShell to create the zip file.`nIs PowerShell installed and in your system's PATH?", "Zip Error", "OK Icon!")
	}

	FileDelete(A_Temp . "\xml_file*.xml") ;cleanup
}

; #endregion

; MARK: -

; #region Helper Functions

ArrayJoin(ArrayObj){

	JoinedString := ""

	For Value in ArrayObj
		JoinedString := JoinedString . Value

	return JoinedString
}

IsBinaryFile(filePath, tolerance := 5) {

	WriteConsole("TEST: " filePath)

    if !FileExist(filePath)
        return false

	try {
	    file := FileOpen(filePath, "r")	
	} catch Error as e {
		WriteStatus("IsBinaryFile ERROR: " e.Message)
		return true
	}

    if !file
        return false

    buff := Buffer(1)

    loop tolerance {

        BytesRead := file.RawRead(buff, 1)

        if (BytesRead = 0)
            break

        byte := NumGet(buff, 0, "UChar")

        ; byte < 9: Catches control characters except TAB (ASCII 9).
        ; byte > 126: Catches non-printable characters above standard ASCII.
        ; (byte < 32) and (byte > 13): Catches control characters between carriage return (13) and space (32), excluding TAB, LF, and CR.
        ; This logic is correct for most ASCII/UTF-8 text files. If any byte in the sample matches these conditions, the file is likely binary.
        if (byte < 9) or (byte > 126) or ((byte < 32) and (byte > 13)) {
            file.Close()
            return true
        }
    }

    file.Close()
    return false
}

IsDirEmpty(dir) {
    Loop Files, dir "\*", "FD" {
        return false
    }
    ; If the loop never ran, the directory must be empty
    return true
}

IsDirExist(dir) {
	return dir = "" || !DirExist(dir) ? false : true
}

IsProjectClean(path) {

	isClean := true

	Loop Files, path "\*.*", "DR"
	{
		if (InStr(A_LoopFileFullPath, "\.vs") || InStr(A_LoopFileFullPath, "\bin") || InStr(A_LoopFileFullPath, "\obj"))
		{
			isClean := false
		}
	}

	return isClean
}

OnCloseHandler(MyGui) {
	IniWrite(Edit1.Value, iniPath, "Settings", "SelectedFolder")
}

OnExit(ExitReason, ExitCode) {
    ; This function is called when the script exits, ensuring settings are saved
    ; regardless of how the script is closed (e.g., from the tray menu).
    if (myGui.Hwnd) ; Check if GUI window exists to avoid errors
        IniWrite(Edit1.Value, iniPath, "Settings", "SelectedFolder")
}
PadText(Text, spaces := 5) {
    return StrRepeat(" ", spaces) . Text
}
SplitPathObj(path) {
    SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    SplitPath(Dir,,,,&ParentDir)
    return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}

StrRepeat(text, times) {
return StrReplace(Format("{:" times "}", ""), " ", text)
}

WriteConsole(Text := "") {
	stdout := FileOpen("*", "w")
	stdout.WriteLine(Text)
	stdout.Close()
}

WriteStatus(Text := "") {
	myStatusBar.SetText(PadText(Text, 4))
}
; #endregion

; MARK: -

; #region GUI Definition

CreateGui() {

	global myGui
	global Edit1
	global myStatusBar

	Try MyGui.Destroy()
	myGui := Gui()
	MyGui.BackColor := "4682B4" ; Steel Blue
	;MyGui.SetFont("S8 CBlack w480", "Segoe UI")

	; note: ogc stands for "Object Gui Control"
	ogcButtonCancel := myGui.Add("Button", "x432 y107 w60 h25", "Cancel")
	ogcButtonHelp := myGui.Add("Button", "x432 y78 w60 h25", "Help")
	ogcButtonExplore := myGui.Add("Button", "x433 y48 w60 h25", "Explore")
	ogcButtonSelect := myGui.Add("Button", "x433 y17 w60 h25 Default", "Select")	; Default
	ogcButtonDoZipProject := myGui.Add("Button", "x269 y86 w80 h40", "  Zip  Project")
	ogcButtonCopyProject := myGui.Add("Button", "x179 y86 w80 h40", "Copy Project")
	ogcButtonCleanProject := myGui.Add("Button", "x89 y86 w80 h40", "Clean Project")
	myGui.Add("GroupBox", "x10 y12 w412 h61", "Project Dir")
	Edit1 := myGui.Add("Edit", "x18 y38 w396 h23", "D:\Software\DEV\Work\csharp\Projects\")
	myStatusBar := myGui.Add("StatusBar")
	WriteStatus("Ready")
	myStatusBar.OnEvent("Click", StatusBarClickHandler)
	ogcButtonCancel.OnEvent("Click", ButtonCancelClick)
	ogcButtonHelp.OnEvent("Click", ButtonHelpClick)
	ogcButtonExplore.OnEvent("Click", ButtonExploreClick)
	ogcButtonSelect.OnEvent("Click", ButtonSelectClick)
	ogcButtonDoZipProject.OnEvent("Click", ButtonZipClick)
	ogcButtonCopyProject.OnEvent("Click", ButtonCopyClick)
	ogcButtonCleanProject.OnEvent("Click", ButtonCleanClick)
	myGui.OnEvent("Close", OnCloseHandler)
	myGui.Title := "Copy Visual Studio Projects"
	myGui.Show("w505 h169")
	
	; --- Tray Icon Menu Setup ---
	A_TrayMenu.Delete() ; Clear any previous menu items
	A_TrayMenu.Add("Show Window", ShowGui)
	A_TrayMenu.Add("Hide Window", HideGui)
	A_TrayMenu.Add() ; Add a separator line
	A_TrayMenu.AddStandard() ; Add standard items like Reload, Suspend, Pause, Exit
	A_TrayMenu.Default := "Show Window"
	A_TrayMenu.ClickCount := 1 ; Single-click to activate default item
	A_TrayMenu.SetIcon("1&", "CopyVS.ico")
}

; #endregion
