#Requires AutoHotkey v2.0

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
}

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    DoTest()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
DoTest() {

    ; Create an instance of the class
    fileInfo := Path("C:\Users\John Doe\Documents\My Project\MyFile.txt")

    ; Access the static properties of the returned object
    message :=
        "FullPath:    " fileInfo.FullPath "`n" .
        "ParentName:  " fileInfo.ParentDir "`n" .
        "File Name:   " fileInfo.FileName "`n" .
        "Directory:   " fileInfo.Dir "`n" .
        "Extension:   " fileInfo.Ext "`n" .
        "NameNoExt:   " fileInfo.NameNoExt "`n" .
        "Drive    :   " fileInfo.Drive "`n"

    MsgBox(message, "Path Properties")

}