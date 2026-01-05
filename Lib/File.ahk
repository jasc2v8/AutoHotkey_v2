;ABOUT: File.ahk

#Requires AutoHotkey v2.0+
;#SingleInstance Force
;#NoTrayIcon

; #region Functions
;-------------------------------------------------------------------------------
; Summary:  Returns Extended File Properties
; Param:    File Path.
; Returns:  Map(PropertyName, PropertyValue).
; Library:  None.
; Source:   Gemini and https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3806
FileGetExtendedProperties(filePath) {
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
        loopCount := 0
        While itemCount < 33 { ; Typically 33 items, but check for more if it changes
            try {
                
                propName := folder.GetDetailsOf(folder.Items, A_Index - 1)
                propValue := folder.GetDetailsOf(fileItem, A_Index - 1)

            } catch Error as e {
                MsgBox("Error GetDetailsOf:`n`n" fileName ":`n`n"
                    "Property:`n`n" propName ":`n`n" e.Message)
            }

            if (propName != '') {

                ; Set Title Case and strip non-alphanumeric characters.               
                propName := RegExReplace(StrTitle(propName), "[^a-zA-Z0-9]", "")

                ; Save the property if it has a value.
                if (propValue != '') {
                    properties[propName] := propValue
                    itemCount++
                }
            }

            loopCount++

            if (loopCount > 300) {
                OutputDebug('loopCount: ' loopCount)
                return properties
            }


        }
    } catch as e {

        OutputDebug('COM error: ' e.Message)

        return {Error: 'COM error: ' e.Message}
    }

OutputDebug('properties.Count: ' properties.Count)

    return properties
}

;-------------------------------------------------------------------------------
; Purpose:  Returns the selected property of the file (Version, etc)
; Library:  File.ahk
FileGetProperty(filePath, property) {
    try
    {
        ; Create a Shell.Application COM object
        shellApp := ComObject('Shell.Application')

        ; Get the parent folder and filename
        SplitPath(filePath, &filename, &directory)
        folder := shellApp.Namespace(directory)
        fileItem := folder.ParseName(filename)

        ; Get the file version using the ExtendedProperty method
        try {
            prop := fileItem.ExtendedProperty(property)        
        } catch Error as e {
             MsgBox("Error FileGetProperty:`n`n" filePath ":`n`n"
            "Property:`n`n" property ":`n`n" e.Message)
        }

        return prop
    }
    catch as e
    {
        ;MsgBox 'Error: ' e.Message
        MsgBox("Error FileGetProperty:`n`n" filePath ":`n`n"
            "Property:`n`n" property ":`n`n" e.Message)
    }
}

;FileGetShortcut LinkFile [, &OutTarget, &OutDir, &OutArgs, &OutDescription, &OutIcon, &OutIconNum, &OutRunState]

; FileGetShortcutObj(filePath) {
;     ;path := StrReplace(path, "\\", "\")
;     FileGetShortcut(filePath , &OutTarget, &OutDir, &OutArgs, &OutDescription, &OutIcon, &OutIconNum, &OutRunState)
;     ; prop :=  OutTarget
;     ; msgbox("File:`n`n" filePath "`n`nprop:`n`n" prop )
 
;     return {FullPath: filePath, 
;         Target: OutTarget, Dir: OutDir, Args: OutArgs, Description: OutDescription, 
;         Icon: OutIcon, IconNum: OutIconNum, RunState: OutRunState}
; }

