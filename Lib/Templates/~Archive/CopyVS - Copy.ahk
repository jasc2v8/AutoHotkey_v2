/************************************************************************
 * @description 
 * @author 
 * @date 2025/09/16
 * @version 0.0.1
 ***********************************************************************/

#Requires AutoHotkey v2.0

/*
	TODO
	move ini to TEMP folder
	change make_iss to use make.iss
	change make.iss to read exe for version info
*/

#SingleInstance force
;#NoTrayIcon
;#include ..\..\Lib\String_v2.ahk ; String functions TBD
Persistent()

; --- Start of Version Info Block ---
;@Ahk2Exe-Set ProductName, Copy Virtual Studio
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-Set LegalCopyright, © 2025 jasc2v8
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Copy Virtual Studio
;@Ahk2Exe-Set OriginalFilename, CopyVS.exe
; --- End of Version Info Block ---

;@Ahk2Exe-SetMainIcon CopyVS.ico


#HotIf WinActive("ahk_class AutoHotkeyGUI")
^!t:: {
	MsgBox("You pressed Ctrl+Alt+T while the GUI was active!")
}
#HotIf

global NEWLINE := "`n"
global iniPath := "CopyVS.ini"

; Create a new Gui object
CreateGui()



ShowGui(*) {
	try myGui.Show()
}
HideGui() {
	try myGui.Hide()
}
if (FileExist(iniPath) = "") {
	SoundBeep()
	MsgBox("Ini file not found: " . iniPath, "WARNING", "OK")
} else {
	Edit1.Value := IniRead(iniPath, "CONFIG", "SelectedFolder")
}

ButtonCopyClick(Ctrl, Info)
{
	sourceFolder := Trim(Edit1.Value)

	if !IsDirExist(sourceFolder) {
		MsgBox("Please select a valid project folder.", "Copy Project", "OK Icon!")
		return false
	}
	; check if project folder has been cleaned
	; if !IsProjectClean(sourceFolder) {
	; 	result := MsgBox("Project folder not clean!`n`n"  .
	; 		"Do you want to clean it now?", "Copy Project",  "YesNo Icon?")
	; 		if (result = "Yes")
	; 			ButtonCleanClick(Ctrl, Info)
	; 	}

	targetFolder := FileSelect("D", sourceFolder, "Select Target Directory")

	if (targetFolder = "")
		return

	if (targetFolder = Edit1.Value)
	{
		MsgBox("Can't copy a Project to itsself.", "Copy Project",  "OK Icon!")
		return
	}

	; check if target dir is empty
	if !IsDirEmpty(targetFolder)
	{
		result := MsgBox("Target Directory not empty:`n`n" . targetFolder . "`n`n" .
			"Do you still want to Copy the Project?", "Copy Project",  "YesNo Icon?")
			if (result != "Yes")
		return
	}

	; user verify to proceed
	result := MsgBox("PLEASE VERIFY THE TARGET IS THE NEW PROJECT NAME!" . "`n`n" .
		"Source:`n" sourceFolder . "`n`n" .
		"Target:`n" targetFolder, "Copy Project",  "YesNo Icon!")
	if (result != "Yes")
		return
	
	fileCount := DoCopyProject(sourceFolder, targetFolder)

	result := MsgBox("Copied: " . fileCount, "Copy Project")

}

ButtonCleanClick(Ctrl, Info)
{
	sourceFolder := Trim(Edit1.Value)

	if !IsDirExist(sourceFolder) {
		MsgBox("Please select a valid project folder.", "Clean Project", "OK Icon!")
		return false
	}

	result := MsgBox("Are you sure you want to clean this Directory and Subdirectories?", "DEBUG", "YesNo")

	if (result != "Yes")
		return

	ExcludeExtensions := "bin, obj, .vs"

	loopFile := Trim(Edit1.Value) . "\\*.*"

	count := 0

	Loop Files loopFile, "FDR"
	{
		fileExt := SubStr(A_LoopFileFullPath, -3)

		FoundPos := InStr(ExcludeExtensions, fileExt)

		if (FoundPos > 0)
		{
			;MsgBox("DELETE: " . A_LoopFileFullPath, "DEBUG", "OK")
			DirDelete(A_LoopFileFullPath, true) ; Recurse
			count += 1
		}
	}

	MsgBox("Cleaned: " . count, "Clean Project", "OK")
}

ButtonZipClick(Ctrl, Info) {

	sourceFolder := Trim(Edit1.Value)

	if (sourceFolder = "" || !DirExist(sourceFolder)) {
		MsgBox("Please select a valid project folder.", "Zip Project", "OK Icon!")
		return
	}	

	; check if project folder has been cleaned
	if !IsProjectClean(sourceFolder) {
		result := MsgBox("Project folder not clean!`n`n"  .
			"Please clean the Project folder before zipping.`n`n" .
			"Do you want to clean it now?", "Zip Project",  "YesNo Icon!")
			if (result = "Yes")
				ButtonCleanClick(Ctrl, Info)
	}	

	; perform zip
	ZipProject(sourceFolder)
}

ButtonSelectClick(Ctrl, Info) {

	sourceFolder := Edit1.Value

	SelectedFolder := FileSelect("D", sourceFolder, "Select Folder")
	;MsgBox("Folder selected: " . SelectedFolder, "DEBUG", "OK")
	if (SelectedFolder != "") {
		Edit1.Value := SelectedFolder
		IniWrite(SelectedFolder, iniPath, "CONFIG", "SelectedFolder")
	}
 }

ButtonExploreClick(Ctrl, Info) {
	;MsgBox("Explore pressed.", "DEBUG", "OK")
	Run("Explorer " . Edit1.Value)
}

ButtonHelpClick(Ctrl, Info) {
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

DoCopyProject(source, target) {

	fileCount := 0

	oldName := SplitPathObj(SplitPathObj(source).FullPath).NameNoExt
	newName := SplitPathObj(SplitPathObj(target).FullPath).NameNoExt

	;DEBUG
	WriteConsole("oldName: " oldName)
	WriteConsole("newName: " newName)

	Loop Files, source "\*", "FDR" {

		WriteConsole("TEST: " A_LoopFileFullPath) ; "`n")

		destPath := StrReplace(A_LoopFileFullPath, oldName, newName, 1)

		if !IsDirExcluded(A_LoopFileFullPath) {
			
			if DirExist(A_LoopFileFullPath) {
				;MsgBox(A_LoopFileFullPath " is a directory.")

				if !DirExist(destPath) {

					;DEBUG
					WriteConsole("DirCreate: " destPath)

					DirCreate(destPath)
				}

			} else if FileExist(A_LoopFileFullPath) {
				;MsgBox(A_LoopFileFullPath " is a file.")

				if IsBinaryFile(A_LoopFileFullPath) {

					;DEBUG
					WriteConsole("BINARY: " A_LoopFileFullPath)

					FileCopy(A_LoopFileFullPath, destPath, true) ; overwrite

				} else {

					;DEBUG
					WriteConsole("TEXT: " A_LoopFileFullPath)

					try {

						oldText := FileRead(A_LoopFileFullPath)

						newText := StrReplace(oldText, oldName, newName)

						if (newText != oldText)
							FileDelete(destPath), FileAppend(newText, destPath)


						;DEBUG - delete this and use above
						; f := FileOpen(destPath, 'w')
						; f.Write(newText)
						; f.Close()

			
					} catch as Err {
						MsgBox("Error: " Err.Message)
					}
				}
			} else {
				;MsgBox(A_LoopFileFullPath " does not exist.")

				;DEBUG
				WriteConsole("ERROR NOT EXIST: " A_LoopFileFullPath)
			}
		} else {
			;MsgBox(A_LoopFileFullPath " is excluded.")

			;DEBUG
			WriteConsole("EXCLUDED: " A_LoopFileFullPath)
		}
		fileCount++
	}

	return fileCount
}

; GetParentDirName(fullPath) {
; 	SplitPath fullPath, , &dir
;     SplitPath dir, , , , &parentName
;     return parentName
; }

; ReplaceInFile(filePath, search, replace) {
;     text := FileRead(filePath)
;     newText := StrReplace(text, search, replace)
;     if (newText != text)
;         FileDelete(filePath), FileAppend(newText, filePath)
; }

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

		;DEBUG change to MsgBox?
		WriteConsole("IsBinaryFile ERROR: " e.Message)

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

        ;MsgBox(byte) ; Debug line to show byte value

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

IsDirExcluded(path) {

	;static ExcludedParts := ["\.vs\", "\bin\", "\obj\"]
	static ExcludedParts := ["\.vs", "\bin", "\obj"]
 
	for _, part in ExcludedParts {
		if InStr(path, part) {
			return true
		}
	}
	return false
}

IsProjectClean(path) {

	isClean := true

	Loop Files, path "\*.*", "DR"
	{
		if (InStr(A_LoopFileFullPath, "\.vs\") || InStr(A_LoopFileFullPath, "\bin\") || InStr(A_LoopFileFullPath, "\obj\"))
		{
			isClean := false
		}
	}

	return isClean
}

SplitPathObj(path) {
    SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    SplitPath(Dir,,,,&ParentDir)
    return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}

StrRepeat(text, times) {
 return StrReplace(Format("{:" times "}", ""), " ", text)
}

RunGetOutput(command) {
 ; cmd window briefly shown
 shell := ComObject("WScript.Shell")
 exec := shell.Exec(A_ComSpec . " /C " . command)
 output := exec.StdOut.ReadAll()
 return output
}

RunSaveOutput(command) {
 ; no cmd window shown, tempFile must not have spaces (fix TBD)
 tempFile := A_Temp . "\MyOutput.txt"
 RunWait(A_ComSpec . " /C " . command . " > " . tempFile, , 'Hide')
 output := FileRead(tempFile)
 FileDelete(tempFile)
 FileDelete(A_Temp . "\xml_file*.xml") ; cleanup from RunWait function
 return output
}

ZipProject(sourceFolder) {
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
	psCommand := "Compress-Archive -Path '" sourceFolder "\*' -DestinationPath '" zipFile "' -Force"
	RunWait 'powershell.exe -NoProfile -Command "' psCommand '"', , 'Hide'
	if FileExist(zipFile)
		MsgBox("Project zipped successfully!`n`n" zipFile, "Zip Project", "OK Icon!")
	else
		MsgBox("Failed to create zip file.", "Zip Project", "OK Icon!")
}

OnCloseHandler(MyGui) {
	;MsgBox("OnClose", "DEBUG")

	; save any user changes
	IniWrite(Edit1.Value, iniPath, "CONFIG", "SelectedFolder")
}

WriteConsole(Text := "") {
	stdout := FileOpen("*", "w")
	stdout.WriteLine(Text)
	stdout.Close()
}

CreateGui() {

	global myGui
	global Edit1

	Try MyGui.Destroy()
	myGui := Gui()
	MyGui.BackColor := "4682B4" ; Steel Blue
	;MyGui.SetFont("S8 CBlack w480", "Segoe UI")
	; note: ogc stands for "Object Gui Control"
	ogcButtonCancel := myGui.Add("Button", "x432 y107 w60 h25", "Cancel")
	ogcButtonHelp := myGui.Add("Button", "x432 y78 w60 h25", "Help")
	ogcButtonExplore := myGui.Add("Button", "x433 y48 w60 h25", "Explore")
	ogcButtonSelect := myGui.Add("Button", "x433 y17 w60 h25 Default", "Select")	; Default
	ogcButtonZipProject := myGui.Add("Button", "x269 y86 w80 h40", "  Zip  Project")
	ogcButtonCopyProject := myGui.Add("Button", "x179 y86 w80 h40", "Copy Project")
	ogcButtonCleanProject := myGui.Add("Button", "x89 y86 w80 h40", "Clean Project")
	myGui.Add("GroupBox", "x10 y12 w412 h61", "Project Dir")
	Edit1 := myGui.Add("Edit", "x18 y38 w396 h23", "D:\Software\DEV\Work\csharp\Projects\")
	ogcButtonCancel.OnEvent("Click", ButtonCancelClick)
	ogcButtonHelp.OnEvent("Click", ButtonHelpClick)
	ogcButtonExplore.OnEvent("Click", ButtonExploreClick)
	ogcButtonSelect.OnEvent("Click", ButtonSelectClick)
	ogcButtonZipProject.OnEvent("Click", ButtonZipClick)
	ogcButtonCopyProject.OnEvent("Click", ButtonCopyClick)
	ogcButtonCleanProject.OnEvent("Click", ButtonCleanClick)
	Edit1.OnEvent("Change", OnEventHandler)
	;myGui.OnEvent('Close', (*) => ExitApp())
	myGui.OnEvent("Close", OnCloseHandler)
	myGui.Title := "Copy Virtual Studio Projects"
	myGui.Show("w505 h147")
	

; 	A_TrayMenu.ClickCount:=1
; A_TrayMenu.Add("Gui", ShowGui)
; A_TrayMenu.Default:="Gui"

	; --- Tray Icon Menu Setup ---
;TrayMenu := A_TrayMenu
;TrayMenu.Delete()
;TrayMenu.AddStandard()
; TrayMenu.Add("Show GUI", (*) => ShowGui())
; TrayMenu.Add("Hide GUI", (*) => HideGui())
; ;TrayMenu.Add("Zip Project", (*) => ButtonZipClick(Ctrl, Info))
; TrayMenu.Add("Clean Project", (*) => ButtonCleanClick(0, 0))
;TrayMenu.Add("Help", (*) => ButtonHelpClick(0, 0))
;TrayMenu.Add()
;TrayMenu.Add("Exit", (*) => ExitApp())
;TrayMenu.Default := "Exit"
;TrayMenu.ClickCount := 1

	; A_TrayMenu.SetIcon("&Open",            "HICON:" MenuIcon(0xEC61, "cGreen"))
;A_TrayMenu.SetIcon("&Help",           "CopyVS.ico")
; A_TrayMenu.SetIcon("&Window Spy",      "HICON:" MenuIcon(0xE754))
; A_TrayMenu.SetIcon("&Reload Script",   "HICON:" MenuIcon(0xE72C))
; A_TrayMenu.SetIcon("&Edit Script",     "HICON:" MenuIcon(0xE943))
; A_TrayMenu.SetIcon("&Suspend Hotkeys", "HICON:" MenuIcon(0xE92E))
; A_TrayMenu.SetIcon("&Pause Script",    "HICON:" MenuIcon(0xE769))
; A_TrayMenu.SetIcon("E&xit",            "HICON:" MenuIcon(0xEB90, "cRed"))

;MenuIcon(False) ; Destroy ImageList & Gui

;MyTrayMenu :=  A_TrayMenu
;MyTrayMenu.Delete()
;MyTrayMenu.AddStandard()
;MyTrayMenu.Show()
;MsgBox("Script running. Right-click tray icon for menu.")

FoundPos := InStr(A_ScriptFullPath, ".")

if (FoundPos = 0) {
	MsgBox("NO DOT: " . A_ScriptFullPath, "DEBUG", "OK")
}



	OnEventHandler(Ctrl, Info)
	{
		if (Ctrl.Text = "  Zip  Project") {
			ZipProject(Edit1.Value)
		} else {
			ToolTip("Click! This is a sample action.`n"
			. "Active GUI element values include:`n"
			. "ogcButtonCancel => " ogcButtonCancel.Text "`n"
			. "ogcButtonHelp => " ogcButtonHelp.Text "`n"
			. "ogcButtonExplore => " ogcButtonExplore.Text "`n"
			. "ogcButtonSelect => " ogcButtonSelect.Text "`n"
			. "ogcButtonZipProject => " ogcButtonZipProject.Text "`n"
			. "ogcButtonCopyProject => " ogcButtonCopyProject.Text "`n"
			. "ogcButtonCleanProject => " ogcButtonCleanProject.Text "`n"
			. "Edit1 => " Edit1.Value "`n", 77, 277)
			SetTimer () => ToolTip(), -3000 ; tooltip timer
		}
	}

}
