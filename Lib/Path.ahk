;ABOUT: Path related functions
;   TODO
;       return definition for (VarName)

#Requires AutoHotkey v2.0

;-------------------------------------------------------------------------------
; FUNCTION: JoinPath(Separator, PathParts*)
; Purpose: Joins the path parts with the separator.
; Returns: Joined path without duplicate separators.
JoinPath(Separator := '\', PathParts*) {
    joinedPath := ""
    for index, value in PathParts {
        joinedPath .= value . Separator
    }
    while (InStr(joinedPath, Separator Separator) > 0)
        joinedPath := StrReplace(joinedPath, Separator . Separator, Separator)
    return SubStr(joinedPath, 1, -StrLen(Separator))
}

;-------------------------------------------------------------------------------
; FUNCTION: SplitPathObj(path)
; Purpose: Splits the path into its components.
; Returns: Each component as a Map object.
SplitPathObj(path) {
    path := StrReplace(path, "\\", "\")
    SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    SplitPath(Dir,,&ParentDir)
    return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}


If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    _Test_PathFunctions()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
_Test_PathFunctions() {

    #Warn Unreachable, Off

    Run_Tests := false

    if !Run_Tests
        SoundBeep(), ExitApp()


    ; comment out test to skip:
    ;Test_ListObj()
    Test_JoinPath()
    ;Test_GetFileProperty()
    ;Test_SplitPathObj()

    
    Test_JoinPath() {

        myRootDir := "C:\Windows"
        myDir := "\Shell32"
        MyFilename := "\ping.exe\"
        myParts := myRootDir ", " myDir ", " MyFilename
        myPath := JoinPath(, myRootDir, myDir, MyFilename)
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

