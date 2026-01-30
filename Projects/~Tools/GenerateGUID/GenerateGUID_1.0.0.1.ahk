; TITLE  :  GenerateGUID v1.0.0.1
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
	TODO
*/

#Requires AutoHotkey v2.0+
#SingleInstance force
#NoTrayIcon

; Generate and display a GUID formatted for Inno Setup .iss

Loop {
    guidISS := GenerateGuid()
    if MsgBox(guidISS, "Generate GUID", "OKCancel") = "Cancel"
        break
}

ExitApp

GenerateGuid()
{
    ; Create a COM object for Scriptlet.TypeLib
    try {
        ; Use COM to create an instance of the GUIDGen object
        guidString := ComObject("Scriptlet.TypeLib").GUID

        ; Replace the single curly braces with double curly braces
        ; StringReplace is used to replace the starting "{" with "{{"
        ; and the ending "}" with "}}".
        guidString := StrReplace(guidString, "{", "{{", 1)
        guidString := StrReplace(guidString, "}", "}}", 1)

        ; Return the final formatted GUID string
        return guidString
    }
    catch as e
    {
        ; Handle errors gracefully in case the COM object cannot be created
        MsgBox("An error occurred: " e.Message)
        return ""
    }
}