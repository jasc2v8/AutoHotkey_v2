;ABOUT: Retrieves all file properties from an executable

#Requires AutoHotkey v2.0
#SingleInstance Force
;#NoTrayIcon

#Include <String>

;FilePath := FileSelect(,"D:\Software\DEV\Work\AHK2\Projects\AhkLauncher\AhkLauncher.exe")

FilePath := "C:\Program Files\AutoHotkey\V2\AutoHotkey.exe"

; Get the folder containing the file.
folder := ComObject("Shell.Application").NameSpace(StrSplitPath(FilePath).Dir)

; Get the file object from the folder.
;filePath := folder.ParseName(FileGetName(FilePath))
filePath := folder.ParseName(StrSplitPath(FilePath).FileName)

list := ''

Loop 400 {
	value := folder.GetDetailsOf(filePath, A_Index -1)
	if (value != "")
		list .= A_Index "`t" value "`n"

}


OutputDebug("list: " list "`n")

;tValue: " value "")

; Use a loop to get properties by name.
; v1 PropertyNames := {0:"Name", 1:"Size", 2:"Type", 9:"Date created", 10:"Date modified", 11:"Date accessed", 38:"File description", 40:"Product name", 41:"Product version", 42:"Company"}

PropObj := Map(0, "Name", 1, "Size", 2, "Type", 9, "Date created", 10, "Date modified", 11, "Date accessed", 38, "File description", 40, "Product name", 41, "Product version", 42, "Company")
;PropObj := Map(0, "Name", 1, "Size", 25, "Copyright", 33, "Company", 34, "File description", 165, "Filename",
;	194, "Path", 166, "File version", 299, "Product name", 300, "Product version")

;PropObj := Map('0', "Name", '1', "Size", '2', "Type")

; for k, v in PropObj {

;     value := folder.GetDetailsOf(filePath, k)
;     if (value != "")
;         OutputDebug("Property: " v "`tValue: " value "`n")
; }

; mytype := Type(PropObj)
; OutputDebug("mytype: " mytype)

; OutputDebug("mytype: `n")


;ok 
; list := DisplayObj(PropObj)
; OutputDebug("list: " list "`n")

; For Key in PropObj {
;     value := PropObj[Key][A_Index]

; 	    if (value != "")
;         OutputDebug("Property: " Key "`nValue: " value "`n")
; }

DisplayObj(Obj, Depth:=5, IndentLevel:="")
{
	if Type(Obj) = "Object"
		Obj := Obj.OwnProps()
	for k,v in Obj
	{
		List.= IndentLevel "[" k "]"
		if (IsObject(v) && Depth>1)
			List.="`n" DisplayObj(v, Depth-1, IndentLevel . "    ")
		Else
			List.=" => " v
		List.="`n"
	}
	return RTrim(List)
}