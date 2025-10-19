#Requires AutoHotkey v2.0

; Directives, keywords
#SingleInstance Force
;#NoTrayIcon

class Path
{
    fileName := ''
    dir := ''
    ext := ''
    nameNoExt := ''
    drive := ''
    fullPath := ''
    parentDir := ''

    ; Constructor method
    __New(pathString)
    {
        SplitPath(pathString, &fileName, &dir, &ext, &nameNoExt, &drive)
        SplitPath(dir, &parentDir)

        this.fileName := fileName
        this.dir := dir
        this.ext := ext
        this.nameNoExt := nameNoExt
        this.drive := drive
        this.fullPath := pathString
        this.parentDir := parentDir
    }
}

; --- Usage Example ---

; Create an instance of the Path class
filePath := Path("C:\Users\John Doe\Documents\My Project\MyFile.txt")

; Access the properties directly
MsgBox "Full Path: " . filePath.FullPath
; MsgBox "File Name: " . filePath.FileName
; MsgBox "Directory: " . filePath.Dir
; MsgBox "Extension: " . filePath.Ext
; MsgBox "Name (no extension): " . filePath.NameNoExt
; MsgBox "Drive: " . filePath.Drive
MsgBox "Parent Directory: " . filePath.ParentDir

; You can use the properties in other operations
; For example, to create a new path with a different extension
;newPath := filePath.dir . filePath.nameNoExt . ".ini"
;MsgBox "New Path: " . newPath


; Class PathSplit {

;     static var2 := "static var2"
;     static _path := ""
    
;     static FileName := ""
;     static ParentName := ""

;     __Call(path) {
;         this._path := path
;         SplitPath path, &FileName, &Dir, &Ext, &NameNoExt, &Drive
;         SplitPath this.Dir, , , , &ParentName
;         this.FileName := FileName
;         this.ParentName := ParentName
;     }

; }

fullPath := "D:\Software\DEV\Work\csharp\Projects\TEST_NOT_CLEANED\myfile.txt"

;fn := PathSplit(fullPath).FileName

;MyStaticClass.MyStaticMethod() ; Calls the static method

	;PathSplit := new PathSplit(fullPath)

	;MsgBox "File Name: " PathSplit.FileName "`n"
	; . "Directory: " PathSplit.Dir "`n"
	; . "Extension: " PathSplit.Ext "`n"
	; . "Name without Ext: " PathSplit.NameNoExt "`n"
	; . "Drive: " PathSplit.Drive


;Obj1 := Example("test")

;CallObject := Example("")

;CallObject.funk()

;MsgBox("PathSplit.var2: " PathSplit.var2)

;MsgBox("PathSplit.var2: " . PathSplit(fullPath).FileName)

; MyPathSplit := new PathSplit()

; class PathSplit {

; 	static var2 := "static var2"
; 	static _path := ""
	
; 	static FileName := ""
; 	static ParentName := ""

; 	_new(path) {
; 		this._path := path
; 		SplitPath path, &FileName, &Dir, &Ext, &NameNoExt, &Drive
; 		SplitPath this.Dir, , , , &ParentName

; 		this.FileName := FileName
; 		this.ParentName := ParentName
; 	}	
; }

	;DEBUG
	; fullPath := "D:\Software\DEV\Work\csharp\Projects\TEST_NOT_CLEANED\myfile.txt"
	
	; PathInfo := SplitPathObj(fullPath).Get("ParentName")
	; ; ok MsgBox "parentName: " PathInfo

	; PathInfo := SplitPathObj(fullPath)["ParentName"]
	; ; ok MsgBox "parentName1: " PathInfo

	; name := "ParentName"
	; n := SplitPathObj(fullPath)[name]
	; ; ok MsgBox "parentName4: " n

	; t := SplitPathObj_TEST(fullPath).FileName
	; MsgBox "FileName: " t

