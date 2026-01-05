;ABOUT Added Join()

#Requires AutoHotkey v2.0

/*
    SplitPath implemented

    TODO:
        Path.Join(firstPart, secondPart) ; add dir separator


        C# Path Class Methods: https://learn.microsoft.com/en-us/dotnet/api/system.io.path
        ChangeExtension
        Combine ; array
        EndsInDirectorySeparator
        Exists
        GetDirectoryName
        GetExtension
        GetFileName
        GetFileNameWithoutExtension
        GetFullPath
        GetInvalidFileNameChars
        GetInvalidPathChars
        GetPathRoot
        GetRandomFileName
        GetRelativePath
        GetTempFileName
        GetTempPath
        HasExtension
        IsPathFullyQualified
        IsPathRooted
        Join ; strings
        TrimEndingDirectorySeparator
        TryJoin
        TrySplitPath
*/
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; A class with properties and an instance method to split afileInfo string.
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

class Path
{
    FullPath := ''
    ParentDir := ''
    FileName := ''
    Dir := ''
    Ext := ''
    NameNoExt := ''
    Drive := ''
   
    __New(PathString)
    {
        SplitPath(PathString, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
        SplitPath(Dir, &ParentDir)
        this.FullPath := PathString
        this.ParentDir := ParentDir
        this.FileName := FileName
        this.Dir := Dir
        this.Ext := Ext
        this.NameNoExt := NameNoExt
        this.Drive := Drive
    }

    Join(Parts*) {
        JoinedPath := ""
        for index, Part in Parts
        {
            ; Skip empty parts
            if (Part = "")
                continue

            ; Start by just appending the first part
            if (JoinedPath = "")
            {
                JoinedPath := Part
                continue
            }

            ; Check if the last character of the current path is a backslash
            if (SubStr(JoinedPath, 0) != "\")
            {
                JoinedPath .= "\"
            }

            ; Append the new part
            JoinedPath .= Part
        }
        return JoinedPath
    }
}

; when run directly, not included
If (A_LineFile == A_ScriptFullPath) {
    MyPathObj := Path(A_ScriptFullPath)    
    DoTest(MyPathObj)
}

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
DoTest(Path) {

    ; --- Directory parts ---
    Dir_Part := Path.Dir ; "C:\MyFolder"
    File_Part := Path.NameNoExt ;"Document"
    Ext_Part := Path.Ext ; ".txt"

    Full_Path := Path.Join(Dir_Part, File_Part, Ext_Part)
    MsgBox Full_Path ; Output: C:\MyFolder\Document.txt

    Dir_With_Slash := "C:\OtherFolder\" ; Directory with a trailing slash
    Full_Path_2 := Path.Join(Dir_With_Slash, File_Part, Ext_Part)
    MsgBox Full_Path_2 ; Output: C:\OtherFolder\Document.txt
    
    ExitApp
}