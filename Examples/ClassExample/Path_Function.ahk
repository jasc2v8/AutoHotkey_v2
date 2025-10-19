#Requires AutoHotkey v2.0

SplitPathObj(path) {
    SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    SplitPath(Dir,,,,&ParentDir)
    return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    DoTest()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
DoTest() {

    ; cant do ParentDir here, needs multiple statements
    SplitPathObjFatArrow := (path) => (
        SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive),
        {FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
    )

    ; cant do ParentDir here, needs multiple statements
    SplitPathMap := (path) => (
        SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive),
        Map("FileName", FileName, "Dir", Dir, "Ext", Ext, "NameNoExt", NameNoExt, "Drive", Drive)
    )

    ; BEST ONE
    infoObj := SplitPathObj("C:\Users\John Doe\Documents\My Project\MyFile.txt") ; "\\" not allowed in path
    ShowInfo(infoObj, "SplitPath Obj Function")

    ; cant show ParentDir here, needs multiple statements in fat arrow function
    infoObjFatArrow := SplitPathObj("C:\\Users\\JohnDoe\\Documents\\MyProject\\MyFile.txt")
    ShowInfo(infoObjFatArrow, "SplitPath Obj Fat Arrow Function")

    infoMap := SplitPathMap("C:\Users\JohnDoe\Documents\MyProject\MyFile.txt")

    ; alternate Map access
    MsgBox("File Name from Map: " infoMap.Get("FileName"), "SplitPath Map Function")

    ; optional: iterate Map
    ; count := 0

    ; for key, value in infoMap {
    ;     count++
    ;     MsgBox "Iteration: " count "`nKey: " key "`nValue: " value
    ; }

    ShowInfo(info, title) 
    {
    message :=
        "Full Path :   " info.FullPath "`n" .
        "Parent Dir:   " info.ParentDir "`n" .
        "File Name :   " info.FileName "`n" .
        "Directory :   " info.Dir "`n" .
        "Extension :   " info.Ext "`n" .
        "NameNoExt :   " info.NameNoExt "`n" .
        "Drive     :   " info.Drive "`n"

        MsgBox(message, title)

    }
}
