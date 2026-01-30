/**
 * Scans a script string to identify top-level classes, functions, and #Include directives.
 * @param {String} ScriptText - The raw code to analyze.
 * @returns {Array} - An array of objects {Type, Name, StartLine, LineCount}
 */
ScanScriptDefinitions(ScriptText) {
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

            if RegExMatch(Line, "i)^class\s+(?P<Name>[a-zA-Z0-9_]+)", &Match) {
                FoundType := "Class"
                ItemName := Match["Name"]
            } else if RegExMatch(Line, "i)^(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match) {
                FoundType := "Function"
                ItemName := Match["Name"]
            } else if RegExMatch(Line, "i)^#Include(?:Again)?\s+(?P<Path>.+)", &Match) {
                ; #Include is a single-line directive
                Definitions.Push({
                    Type: "Include", 
                    Name: Match["Path"], 
                    StartLine: Index, 
                    LineCount: 1
                })
                continue
            }

            if (FoundType != "") {
                CurrentItem := {
                    Type: FoundType, 
                    Name: ItemName, 
                    StartLine: Index, 
                    LineCount: 1
                }
                Definitions.Push(CurrentItem)
                
                ; Fat arrow functions close immediately
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

; --- Example Usage ---
Code := "
(
#Include "Lib\MyLib.ahk"

#Include Lib\MyLib2.ahk

class MyClass {
    MethodInside() {
        MsgBox("Test")
    }
}

TopLevelFunc(a, b) {
    Result := a + b
    return Result
}

#Include <UsefulFunctions>
)"

FoundItems := ScanScriptDefinitions(Code)
Output := "Results:`n"
for Item in FoundItems {
    Output .= Item.Type ": " Item.Name " | Line: " Item.StartLine " | Count: " Item.LineCount "`n"
}
MsgBox(Output)
