;ABOUT:  Retrieves Extended File Properties from a file.
;SOURCE: 
;SOURCE: Gemini

#Requires AutoHotkey v2.0

;-------------------------------------------------------------------------------
; Summary:  Returns Extended File Properties
; Param:    File Path.
; Returns:  Map(PropertyName, PropertyValue).
; Library:  None.
; Source:   Gemini and https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3806
FileGetExtFileProps(filePath) {
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

                ; Set Title Case and strip non-alphanumeric characters.               
                propName := RegExReplace(StrTitle(propName), "[^a-zA-Z0-9]", "")

                ; Save the property if it has a value.
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
