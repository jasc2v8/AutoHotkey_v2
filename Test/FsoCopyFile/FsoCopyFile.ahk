;ABOUT: FsoCopyFile

;WIN32: https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/filesystemobject-object

/**
 * 
 */

#Warn Unreachable, Off

Source := "D:\SOURCE\source.txt"
Target := "D:\TARGET\"

SplitPath(Source, &Outname, &SourceFolder)
SplitPath(Target, &Outname, &TargetFolder)

;MsgBox SourceFolder ", " TargetFolder

fso := ComObject("Scripting.FileSystemObject")

if (!fso.FolderExists(SourceFolder))
	MsgBox "Error: Folder doesn't exist: " SourceFolder

if (!fso.FolderExists(TargetFolder))
	MsgBox "Error: Folder doesn't exist: " TargetFolder

if (!fso.FileExists(Source))
	MsgBox "Error: File doesn't exist." Source

;fso.CopyFile(Source, Target, true)
fso.CopyFolder(SourceFolder, TargetFolder, true)

 ExitApp


; try {
;     fso := ComObject("Scripting.FileSystemObject")
; } catch {
;     MsgBox("Error: Could not create FileSystemObject. Check COM registration.", "Error", 0x10)
;     ExitApp
; }

; MsgBox("fso created successifly.", "Info", "")

; fso := ComObject("Scripting.FileSystemObject")
; f := fso.GetFile(Source)
; MsgBox("DateCreated: " f.DateCreated)

; return

; fso := ComObject("Scripting.FileSystemObject")
; r := fso.CopyFile(Source, Target)
; MsgBox("Result: " r)

