#Requires AutoHotkey v2.0

; Directives, keywords
#SingleInstance Force
#NoTrayIcon

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; A class with static properties and a static method to split a Path string. Returns a Map.
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

class PathMap
{
    static Split(PathString)
    {
        SplitPath(PathString, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
        SplitPath(Dir, &ParentName)

        this.FullPath := PathString
        this.FileName := FileName
        this.Dir:= Dir
        this.Ext := Ext
        this.NameNoExt := NameNoExt
        this.Drive := Drive
		this.ParentName := ParentName
		
        return Map("FullPath", this.FullPath, "FileName", this.FileName, 
			"Dir", this.Dir, "Ext", this.Ext, "NameNoExt", this.NameNoExt, 
			"Drive", this.Drive, "ParentName", this.ParentName)
    }
}

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
;fileInfo := Object()
fileInfo := PathMap.Split("C:\Users\JohnDoe\Documents\MyProject\MyFile.txt")

;for key, value in fileInfo
    ;MsgBox key ": " value

; Access the static properties of the returned Map
message := 
	"Full Path:   " PathMap.FullPath "`n" . 
	"File Name:   " PathMap.FileName "`n" .
	"Directory:   " PathMap.Dir "`n" .
	"Extension:   " PathMap.Ext "`n" .
	"NameNoExt:   " PathMap.NameNoExt "`n" .
	"Drive    :   " PathMap.Drive  "`n" .
	"ParentName:  " PathMap.ParentName

MsgBox(message, "PathMap Properties")

; access by key
MsgBox("fileInfo.Get: " fileInfo.Get("FullPath"), "PathMap Acccess by fileInfo Key")

; access by key alternative syntax
MsgBox("Directory: " fileInfo["Dir"], "PathMap Acccess by alternative syntax")

; not needed, handled by the garbage collector: fileInfo.Delete()

;ExitApp

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; A class with static properties and a static method to split a Path string. Returns a Map.
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

class PathObj
{
    static FileName := ""
    static ParentName := ""

    static Split(PathString)
    {
        obj := {}

        SplitPath(PathString, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
        SplitPath(Dir, &ParentName)

		this.FileName := FileName
		;etc...

        obj.FullPath := PathString
        obj.FileName := FileName
		obj.Dir := Dir
		obj.Ext := Ext
		obj.NameNoExt := NameNoExt
		obj.Drive := Drive
		obj.ParentName := ParentName
		return obj

    }
}

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

; Call the static method directly from the class name
;obj := Object()
obj := PathObj.Split("C:\Users\JohnDoe\Documents\MyProject\MyFile.txt")

; Access the properties of the returned object
message := 
	"Full Path:   " obj.FullPath "`n" . 
	"File Name:   " obj.FileName "`n" .
	"Directory:   " obj.Dir "`n" .
	"Extension:   " obj.Ext "`n" .
	"NameNoExt:   " obj.NameNoExt "`n" .
	"Drive    :   " obj.Drive  "`n" .
	"ParentName:  " obj.ParentName

MsgBox(message, "PathObj Properties")

MsgBox("File Name: " PathObj.FileName, "PathObj Property Access")
