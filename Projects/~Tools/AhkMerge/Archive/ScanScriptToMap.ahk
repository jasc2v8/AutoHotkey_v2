; Version 1.0.0.17

/**
 * Scans a script string to identify top-level classes, functions, and #Include directives.
 * Returns an array of CSV strings: "Type, Name, Line, Length, Path"
 * @param {String} ScriptText - The raw code to analyze.
 * @param {String} ScriptFullPath - The full path of the file being scanned.
 * @returns {Map} - A map of key, CSV string [Type_Name, "Line,Length,Path"])
 */
ScanScriptToMap(ScriptText, ScriptFullPath) {

    ResultMap := Map()
    BraceDepth := 0
    CurrentItem := unset

    SplitPath(ScriptFullPath, , &BaseDir)

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
            else if RegExMatch(Line, "(?i)(?:if\s+)?(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match) {
                FoundType := "Function"
                ItemName := Match["Name"]
            }

            ; Initialize tracker for Class or Function blocks
            if (FoundType != "") {
                CurrentItem := {
                    Type: FoundType, 
                    Name: ItemName, 
                    StartLine: Index, 
                    LineCount: 1,
                    Path: ScriptFullPath
                }
                
                ; Fat arrow functions end on the same line
                if (FoundType = "Function" && InStr(Line, "=>")) {
                    ResultMap.Set(CurrentItem.Type "_" CurrentItem.Name, CurrentItem.StartLine "," CurrentItem.LineCount "," CurrentItem.Path)
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
                ResultMap.Set(CurrentItem.Type "_" CurrentItem.Name, CurrentItem.StartLine "," CurrentItem.LineCount "," CurrentItem.Path)
                CurrentItem := unset
            }
        }
    }
    return ResultMap
}
