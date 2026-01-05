;ABOUT: General functions to include or copy
;   TODO
;       return definition for (VarName)

#Requires AutoHotkey v2.0

;-------------------------------------------------------------------------------
; FUNCTION  :GetEnvironmentVariables
; Purpose   : Retrieves all environment variables as an AHK Map object.
; Returns   : A Map object where keys are variable names and values are their strings.
; PathsOnly : Only returns the variables with a path versus just a string value.
;-------------------------------------------------------------------------------
GetEnvironmentVariables(PathsOnly := true)
{
    static ExcludedPaths := "Path, Comspec, PSModulePath"

    ; GetEnvironmentStrings returns a pointer to a block of memory containing
    ; null-terminated strings, followed by a double null-terminator.
    pEnv := DllCall("GetEnvironmentStrings", "ptr")
    
    ; Create a Map to store the environment variables
    EnvMap := Map()
    
    ; Loop through the block of memory until a double null-terminator is found
    CurrentPtr := pEnv
    while (DllCall("lstrlen", "ptr", CurrentPtr, "uint") != 0) {
        ; Read the null-terminated string at the current pointer location
        ; Max 32KB is safe for a single environment variable.
        EnvString := StrGet(CurrentPtr, 'CP0')
        
        ; Environment strings are in the format "Name=Value"
        ; Find the position of the first "="
        EqPos := InStr(EnvString, "=")
        
        if (EqPos > 0) {
            ; Extract the Name (Key) and the Value
            Key   := SubStr(EnvString, 1, EqPos - 1)
            Value := SubStr(EnvString, EqPos + 1)

            if (Key != '') {
                if (InStr(ExcludedPaths, Key) = 0) {
                    if (PathsOnly) {
                        if (InStr(Value, ':\') > 0) {
                            EnvMap.Set(Key, Value)
                        }
                    } else {
                        EnvMap.Set(Key, Value)
                    }
                }
            }

        }
        
        ; Advance the pointer to the next string (current string length + 1 for null terminator)
        StringLen := DllCall("lstrlen", "ptr", CurrentPtr, "uint")
        CurrentPtr := CurrentPtr + StringLen + 1
    }
    
    ; Free the memory allocated by GetEnvironmentStrings
    DllCall("FreeEnvironmentStrings", "ptr", pEnv)
    
    return EnvMap
}

;-----------------------------------------------------------------------------
; DEPRECIATED: Use StrSplitPat() instead
; FUNCTION: SplitPathObj(path)
; Purpose: Splits the path into its components.
; Returns: Each component as a Map object.
; SplitPathObj(path) {
;     path := StrReplace(path, "\\", "\")
;     SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
;     SplitPath(Dir,,&ParentDir)
;     return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
; }


If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    _Test_AhkFunctions()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
_Test_AhkFunctions() {

    #Warn Unreachable, Off

    ; comment out to run tests:
    ; SoundBeep()
    ; return

    ; comment out test to skip:
    ;Test_ListObj()
    Test_JoinPath()
    ;Test_GetFileProperty()
    ;Test_SplitPathObj()

    ; Test_GetFileProperty() {
    ;     path := "C:\Windows\notepad.exe"
    ;     prop := GetFileProperty(path, "FileVersion")
    ;     MsgBox("File Path:`n`n" path "`n`nFileVersion:`n`n" prop, "GetFileProperty Function")
    ; }

    Test_ListObj() {

        MyMap := Map("A", "A VALUE", "B", "B VALUE", "C", "C VALUE")
        ListObj(MyMap)
        ListObj(MyMap, true)

        MyArray := [1,2,3,4,5]
        ListObj(MyArray)
        ListObj(MyArray, true)
    }
    
    Test_JoinPath() {

        myRootDir := "C:\Windows"
        myDir := "\Shell32"
        MyFilename := "\ping.exe\"
        myParts := myRootDir ", " myDir ", " MyFilename
        myPath := strJoin(, myRootDir, myDir, MyFilename)
        MsgBox("Path parts:`n`n" myParts "`n`nJoined Path:`n`n" myPath, "JoinPath Example One")

        myRootDir := "C:\Windows\"
        myDir := "\Shell32\"
        MyFilename := "\ping.exe\"
        myParts := myRootDir ", " myDir ", " MyFilename
        myPath := JoinPath(, "C:\", "\Windows\", "\Shell32\", "\ping.exe\")
        MsgBox("Path parts:`n`n" myParts "`n`nJoined Path:`n`n" myPath, "JoinPath Example Two")
    }

    Test_SplitPathObj() {
        global MyPath

        ; SplitPathObj() will change double '\\' to single '\'
        ; This makes the SplitPath().FullPath useful
        MyPath := "C:\Users\John Doe\Documents\My Project\\MyFile.txt"

        pathObj := SplitPathObj(MyPath)
        ShowPathInfo(pathObj, "ShowPathInfo Function")

        myDir := SplitPathObj(MyPath).Dir
        myParentDir := SplitPathObj(MyPath).ParentDir
        MsgBox("*** Path: ***`n`n" MyPath "`n`n" 
            "*** Dir: ***`n`n" myDir "`n`n"
            "*** ParentDir: ***`n`n" myParentDir "`n`n"
            , "SplitPathObj Function")

    }

    ShowPathInfo(pathObj, title) {

        message :=
            "My Path   : " MyPath "`n`n" .
            "Full Path : " pathObj.FullPath "`n`n" .
            "Directory : " pathObj.Dir "`n`n" .
            "Parent Dir: " pathObj.ParentDir "`n`n" .
            "File Name : " pathObj.FileName "`n`n" .
            "Extension : " pathObj.Ext "`n`n" .
            "NameNoExt : " pathObj.NameNoExt "`n`n" .
            "Drive     : " pathObj.Drive "`n`n"

            MsgBox(message, title)

    }
}

