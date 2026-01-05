#Requires AutoHotkey v2.0

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; A class with static properties and a static method to split a Path string. Returns a Map.
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

class Path {
    static Split(PathString) {
        SplitPath(PathString, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
        SplitPath(Dir, &ParentName)

        this.FullPath := PathString
        this.ParentDir := ParentName
        this.FileName := FileName
        this.Dir := Dir
        this.Ext := Ext
        this.NameNoExt := NameNoExt
        this.Drive := Drive

        return Map("FullPath", this.FullPath, "FileName", this.FileName,
            "Dir", this.Dir, "Ext", this.Ext, "NameNoExt", this.NameNoExt,
            "Drive", this.Drive, "ParentName", this.ParentDir)
    }
}

;MsgBox "A_LineFile: `n" A_LineFile "`n`n" "A_ScriptFullPath :`n" A_ScriptFullPath

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    DoTest()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
DoTest() {

    fileInfo := Path.Split("C:\Users\JohnDoe\Documents\MyProject\MyFile.txt")

    ;for key, value in fileInfo
    ;MsgBox key ": " value

    ; Access the static properties of the returned Map
    message :=
        "Full Path:   " Path.FullPath "`n" .
        "Parent Dir:  " Path.ParentDir "`n" .
        "File Name:   " Path.FileName "`n" .
        "Directory:   " Path.Dir "`n" .
        "Extension:   " Path.Ext "`n" .
        "NameNoExt:   " Path.NameNoExt "`n" .
        "Drive    :   " Path.Drive "`n" .
        ""

    MsgBox(message, "Path Properties")

    ; access by key
    MsgBox("fileInfo.Get: " fileInfo.Get("FullPath"), "Path Acccess by fileInfo Key")

    ; access by key alternative syntax
    MsgBox("fileInfo[Dir]: " fileInfo["Dir"], "Path Acccess by alternative syntax")

    ; fileInfo.Delete() ; not needed, handled by the garbage collector
}
