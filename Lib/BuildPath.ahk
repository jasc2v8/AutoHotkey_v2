;ABOUT: FsoCopyFile

;WIN32: https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/filesystemobject-object

/**
 * TODO:
 * 
 *
 */

;-------------------------------------------------------------------------------
; Purpose: Joins the path parts with separators.
; Returns: Joined path without duplicate separators.
; Example: BuildPath("C:", "Windows", "Sub1", "Sub2", "Sub3", name)
; Return : "C:Windows\Sub1\Sub2\Sub3\source.txt"
BuildPath(PathParts*) {
	try {
		fso := ComObject("Scripting.FileSystemObject")
		joinedPath := ""
		for value in PathParts {
			joinedPath := fso.BuildPath(joinedPath, value)
		}
	    returnValue := joinedPath

	} catch Error as e {
	    returnValue := ""
	}
	fso := ""
	return returnValue
}


If (A_LineFile != A_ScriptFullPath)  ; when included, not run directly
    return

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

; Comment out to skip:
SoundBeep(), ExitApp()

#Warn Unreachable, Off

filename := "source.txt"

; Return: C:Windows\Sub1\Sub2\Sub3\source.txt
MsgBox BuildPath("C:", "Windows", "Sub1", "Sub2", "Sub3", filename)

ExitApp

