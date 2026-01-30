; Version 1.0.0.13

/**
 * Scans a script string to identify top-level classes, functions, and #Include directives.
 * Resolves #Include paths to absolute file locations.
 * @param {String} ScriptText - The raw code to analyze.
 * @param {String} BaseDir - The directory used to resolve relative paths (defaults to A_ScriptDir).
 * @returns {Array} - An array of objects {Type, Name, StartLine, LineCount, FullPath}
 */
ScanScriptDefinitions(ScriptText, BaseDir := A_ScriptDir) {
    if (ScriptText = "")
        return

    Definitions := []
    BraceDepth := 0
    CurrentItem := unset

    Lines := StrSplit(ScriptText, "`n", "`r")

    for Index, RawLine in Lines {
        Line := Trim(RawLine)
        
        ; Logic for tracking lines while inside a definition
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

        ; Only look for new definitions at the root level (Global scope)
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
            else if RegExMatch(Line, "i)^(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match) {
                FoundType := "Function"
                ItemName := Match["Name"]
            } 
            ; 3. Check for #Include
            else if RegExMatch(Line, "i)^#Include(?:Again)?\s+(?P<Path>.+)", &Match) {
                RawPath := Match["Path"]
                IsLib := (SubStr(Trim(RawPath), 1, 1) = "<")
                
                ; Fixed: Using double-quote wrapper to escape single quotes safely
                CleanPath := Trim(RawPath, " `"'<>")
                
                ResolvedPath := ""
                
                if (IsLib) {
                    ; Check standard AHK v2 library locations
                    PathsToTry := [
                        BaseDir "\Lib\" CleanPath ".ahk",
                        A_MyDocuments "\AutoHotkey\Lib\" CleanPath ".ahk"
                    ]
                    
                    ; Check the AHK installation directory Lib
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
                    ; Check absolute or relative to BaseDir
                    if (InStr(CleanPath, ":") || SubStr(CleanPath, 1, 2) = "\\") {
                        ResolvedPath := CleanPath
                    } else {
                        ResolvedPath := BaseDir "\" CleanPath
                    }
                }

                Definitions.Push({
                    Type: "Include", 
                    Name: CleanPath, 
                    FullPath: ResolvedPath || "Not Found",
                    StartLine: Index, 
                    LineCount: 1
                })
                
                continue
            }

            ; If a Class or Function was found, initialize the tracker
            if (FoundType != "") {
                CurrentItem := {
                    Type: FoundType, 
                    Name: ItemName, 
                    StartLine: Index, 
                    LineCount: 1
                }
                Definitions.Push(CurrentItem)
                
                ; Fat arrow functions are single-line definitions
                if (FoundType = "Function" && InStr(Line, "=>")) {
                    CurrentItem := unset
                }
                
                continue
            }
        }

        ; Increment count for active blocks (Class or Standard Function)
        if IsSet(CurrentItem) {
            CurrentItem.LineCount++
            
            ; Definition block ends when depth returns to zero
            if (BraceDepth = 0) {
                CurrentItem := unset
            }
        }
    }

    return Definitions
}

; --- Testing / Example Usage ---

ExampleCode := "
(
#Include "Lib\NetworkTools.ahk"
#Include <JSON>

class DatabaseManager {
    Connect() {
        MsgBox("Connecting...")
    }
}

ProcessData(input) {
    if (input = "")
        return
    
    return StrUpper(input)
}

QuickLog(msg) => FileAppend(msg "`n", "log.txt")
)"

; Run the scanner
Results := ScanScriptDefinitions(ExampleCode)

; Build the output string
Summary := "Script Analysis Result:`n" . "------------------------------------`n"
for Entry in Results {
    Summary .= Entry.Type ": " Entry.Name "`n"
    Summary .= "   Line: " Entry.StartLine " | Length: " Entry.LineCount " lines`n"
    
    if (Entry.HasProp("FullPath")) {
        Summary .= "   Path: " Entry.FullPath "`n"
    }
    Summary .= "------------------------------------`n"
}

; Display the summary
MsgBox(Summary)