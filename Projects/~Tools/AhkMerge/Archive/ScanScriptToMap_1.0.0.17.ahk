; Version 1.0.0.17

/**
 * Scans a script string to identify top-level classes, functions, and #Include directives.
 * Returns an array of CSV strings: "Type, Name, Line, Length, Path"
 * @param {String} ScriptText - The raw code to analyze.
 * @param {String} BaseDir - The directory of the script being scanned (for path resolution).
 * @param {String} CurrentFilePath - The full path of the file being scanned.
 * @returns {Map} - A map of key, CSV string [Type_Name, "Line,Length,Path"])
 */
;ScanScriptToMap(ScriptText, BaseDir := A_ScriptDir, CurrentFilePath := A_ScriptFullPath) {
ScanScriptToMap(ScriptFilePath) {

    if !FileExist(ScriptFilePath)
        return

    CSVResults := []
    BraceDepth := 0
    CurrentItem := unset

    SplitPath(ScriptFilePath, , &BaseDir)

    ScriptText := FileRead(ScriptFilePath)

    Lines := StrSplit(ScriptText, "`n", "`r")

    for Index, RawLine in Lines {
        Line := Trim(RawLine)
        
        IsActive := IsSet(CurrentItem)

        ; Skip processing for empty lines/comments unless we are counting inside a block
        if (Line = "" || SubStr(Line, 1, 1) = ";") {
            if (IsActive)
                CurrentItem.LineCount++
            
            continue
        }

        PreBraceDepth := BraceDepth
        StrReplace(Line, "{", , , &OpenCount)
        StrReplace(Line, "}", , , &CloseCount)
        BraceDepth += OpenCount - CloseCount

        ; Only identify definitions at the root level (Depth 0)
        if (PreBraceDepth = 0) {
            Match := ""
            FoundType := ""
            ItemName := ""

            ; 1. Check for Class
            if RegExMatch(Line, "i)^class\s+(?P<Name>[a-zA-Z0-9_]+)", &Match) {
                FoundType := "Class"
                ItemName := Match["Name"]
            } 
            ; 2. Check for Function (standard or fat-arrow)
            ;else if RegExMatch(Line, "i)^(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match) {
            else if RegExMatch(Line, "(?i)(?:if\s+)?(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match) {
                FoundType := "Function"
                ItemName := Match["Name"]
            } 
            ; 3. Check for #Include
            ;   MsgBox(ExtractIncludePath("#Include <MyLib> ; comment"))      ; Result: <MyLib>
            ;   MsgBox(ExtractIncludePath("#Include MyLib.ahk ; comment"))    ; Result: MyLib.ahk
            ;   MsgBox(ExtractIncludePath("#IncludeAgain C:\Path.ahk  ; tabbed comment")) ; Result: C:\Path.ahk
            else if RegExMatch(Line, "i)^#Include(?:Again)?\s+(?P<Path>[^;]+)", &Match) {
                RawPath := Match["Path"]

                IsLib := (SubStr(Trim(RawPath), 1, 1) = "<")
                
                ; Character list for trim: space, double-quote, single-quote, <, >
                CleanPath := Trim(RawPath, " `"'<>")
                
                ResolvedPath := ""
                if (IsLib) {
                    ; Standard AHK library locations
                    PathsToTry := [
                        BaseDir "\Lib\" CleanPath ".ahk",
                        A_MyDocuments "\AutoHotkey\Lib\" CleanPath ".ahk"
                    ]
                    if SplitPath(A_AhkPath,, &AhkDir) {
                        PathsToTry.Push(AhkDir "\Lib\" CleanPath ".ahk")
                    }
                    for TryPath in PathsToTry {
                        if (TryPath != "" && FileExist(TryPath)) {
                            ResolvedPath := TryPath
                            break
                        }
                    }
                } else {
                    ; Relative or Absolute path
                    if (InStr(CleanPath, ":") || SubStr(CleanPath, 1, 2) = "\\") {
                        ResolvedPath := CleanPath
                    } else {
                        ResolvedPath := BaseDir "\" CleanPath
                    }
                }

                ; CSV: Type, Name, Line, Length, Path
                PathVal := ResolvedPath || CleanPath
                CSVResults.Push("Include," . CleanPath . "," . Index . ",1," . PathVal)
                continue
            }

            ; Initialize tracker for Class or Function blocks
            if (FoundType != "") {
                CurrentItem := {
                    Type: FoundType, 
                    Name: ItemName, 
                    StartLine: Index, 
                    LineCount: 1,
                    Path: ScriptFilePath
                }
                
                ; Fat arrow functions end on the same line
                if (FoundType = "Function" && InStr(Line, "=>")) {
                    CSVResults.Push(CurrentItem.Type . "," . CurrentItem.Name . "," . CurrentItem.StartLine . "," . CurrentItem.LineCount . "," . CurrentItem.Path)
                    CurrentItem := unset
                }
                
                continue
            }
        }

        ; Increment count if we are currently inside a block
        if IsSet(CurrentItem) {
            CurrentItem.LineCount++
            
            ; Block closed when depth returns to 0
            if (BraceDepth = 0) {
                CSVResults.Push(CurrentItem.Type . "," . CurrentItem.Name . "," . CurrentItem.StartLine . "," . CurrentItem.LineCount . "," . CurrentItem.Path)
                CurrentItem := unset
            }
        }
    }

    ResultMap := Map()

    for item in CSVResults {
        split := StrSplit(item, ",")
        ResultMap.Set(split[1] "_" split [2], split[3] "," split[4] "," split[5])
    }

    ;return CSVResults
    return ResultMap
}
