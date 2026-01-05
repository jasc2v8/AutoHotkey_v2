;ABOUT: Retrieves all file properties from an executable
;SOURCE: V2 source: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3806&start=20
;SOURCE: Gemini

#Requires AutoHotkey v2.0
#SingleInstance Force
;#NoTrayIcon

#Include <String>


;Str := "P.O. Box"
;StrCleaned := RegExReplace(Str, "[^a-zA-Z0-9]", "")
;OutputDebug("Str: " StrCleaned)
;Exit

;FileSelectFile, FilePath					; Select a file to use for this example.
;FilePath := FileSelect(,"D:\Software\DEV\Work\AHK2\Projects\AhkLauncher\AhkLauncher.exe")

FilePath := "D:\Software\DEV\Work\AHK2\Projects\AhkLauncher\AhkLauncher.exe"

; Change this to a path for a music file on your system.
; FilePath := A_Desktop '\music.mp3'

; Retrieve a collection of extended file properties.
; ok PropertiesObject := GetExtendedFileProperties( FilePath)

PropertiesObject := GetExtendedFilePropertiesALL(FilePath)
; list := DisplayObj(PropertiesObject)
; OutputDebug list
; Exit

if PropertiesObject = ''
    OutputDebug 'error'

;   OutputDebug(PropertiesObject.Count)

;list := DisplayObj(PropertiesObject)

list := ''
for k, v in PropertiesObject {
    list .= k ", " v "`n"
}

logFile := A_ScriptDir "\logfile.txt"
if FileExist(logFile)
    FileDelete(logFile)
FileAppend(list, logFile)

OutputDebug("Values Found: " PropertiesObject.Count)
OutputDebug("See log File: " logFile)

; CleanString(Str) {
;     return StrReplace(propName, "[^a-zA-Z0-9]", "", &R)
; }
;
; --- Extended file properties helper function ---
; This function requires a working COM library and is based on scripts by SKAN
; and other AutoHotkey community members. It uses the Windows Shell to get file properties.

GetExtendedFileProperties(filePath) {
    if !FileExist(filePath)
        return

    try {
        ; Create a Shell.Application COM object.
        shell := ComObject('Shell.Application')

        ; Get the directory and file name.
        folderPath := SubStr(filePath, 1, InStr(filePath, '\',,, -1))
        fileName := SubStr(filePath, InStr(filePath, '\',,, -1) + 1)
        
        ; Get the folder object and its items.
        folder := shell.NameSpace(folderPath)
        fileItem := folder.ParseName(fileName)

        ; Loop through all possible property indices and store valid properties.
        properties := Map()
        itemCount := 0
        While itemCount < 33 { ; Typically 33 items, but check for more if it changes
            propName := folder.GetDetailsOf(folder.Items, A_Index - 1)
            propValue := folder.GetDetailsOf(fileItem, A_Index - 1)

            if (propName != '') {
                ; Set Title Case for the property name.
                propName := StrTitle(propName)
                ; Normalize the property name to be a valid object key.
                propName := StrReplace(propName, ' ', '')
                propName := StrReplace(propName, '.', '')
                propName := StrReplace(propName, '#', '')
                if (propValue != '') {
                    properties[propName] := propValue
                    itemCount++
                }
            }
        }
    } catch as e {
        return {Error: 'COM error: ' e.Message}
    }

    return properties
}


GetExtendedFilePropertiesALL(filePath) {
    if !FileExist(filePath)
        return

                    tickStart := A_TickCount
                OutputDebug("START : " tickStart)

    try {
        ; Create a Shell.Application COM object.
        shell := ComObject('Shell.Application')

        ; Get the directory and file name.
        folderPath := SubStr(filePath, 1, InStr(filePath, '\',,, -1))
        fileName := SubStr(filePath, InStr(filePath, '\',,, -1) + 1)
        
        ; Get the folder object and its items.
        folder := shell.NameSpace(folderPath)
        fileItem := folder.ParseName(fileName)

;OutputDebug( "folderPath: " folderPath ", fileName: " fileName)
;list := DisplayObj(folder.Items)
;list := folder.Items.count
;OutputDebug("folder.Items.count: " folder.Items.count)
;OutputDebug("fileItem.count: " fileItem.length)

            ;OutputDebug( "folder.Items: " folder.Items ", fileItem: " fileItem)

        ; Loop through all possible property indices and store valid properties.
        properties := Map()
        loopCount := 0
        itemCount := 0
        ;endCount := 0
        ; gapCount := 0
        ; gapMax := 0
        ; gapMin := 0

        Loop 400 { ; Typically 322 items, but check for more if it changes
        ;While endCount <= 11 {
        ;While itemCount < 33 {
            propName := folder.GetDetailsOf(folder.Items, A_Index - 1)
            propValue := folder.GetDetailsOf(fileItem, A_Index - 1)

            if (propName != '') {


                ;titleCase := StrTitle(propName)
                ; ; Normalize the property name to be a valid object key.
                ; propName := StrReplace(propName, ' ', '')
                ; propName := StrReplace(propName, '.', '')
                ; propName := StrReplace(propName, '#', '')

                propName := RegExReplace(StrTitle(propName), "[^a-zA-Z0-9]", "")



                ; if (propValue != '') {
                    properties[propName] := propValue
                    ;endCount := 0
                    itemCount++
                ; }
            } else {
                ;endCount++
                ;gapCount++
                ; if (gapCount > gapMax) {
                ;     gapMax := gapCount
                ; }
                ; if (gapCount < gapMin) {
                ;     gapMin := gapCount
                ; }
                ; gapCount := 0
            }
            loopCount++

            ; if (loopCount > 400) 
            ;      Throw "loopCount > 300"            
        }
    } catch as e {
        return {Error: 'COM error: ' e.Message}
    }
    OutputDebug("loopCount: " loopCount)
    OutputDebug("itemCount: " itemCount)
    ; OutputDebug("gapMax: " gapMax)
    ; OutputDebug("gapMin: " gapMin)

                    tickFinish := A_TickCount
                OutputDebug("FINISH : " tickFinish)
                trickElapsed := tickFinish - tickStart
                OutputDebug("ELAPSED: " trickElapsed)

    return properties
}


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