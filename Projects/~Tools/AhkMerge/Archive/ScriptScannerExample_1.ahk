/**
 * Scans a script string to identify top-level classes and functions and their lengths.
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

        ; If we are at root level, look for new definitions
        if (PreBraceDepth = 0) {
            Match := ""
            FoundType := ""

            if RegExMatch(Line, "i)^class\s+(?P<Name>[a-zA-Z0-9_]+)", &Match) {
                FoundType := "Class"
            } else if RegExMatch(Line, "i)^(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match) {
                FoundType := "Function"
            }

            if (FoundType != "") {
                CurrentItem := {
                    Type: FoundType, 
                    Name: Match["Name"], 
                    StartLine: Index, 
                    LineCount: 1
                }
                Definitions.Push(CurrentItem)
                
                ; Handle single-line fat arrow functions
                if (FoundType = "Function" && InStr(Line, "=>")) {
                    CurrentItem := unset
                }
                continue
            }
        }

        ; If we are inside a definition, increment the count
        if IsSet(CurrentItem) {
            CurrentItem.LineCount++
            
            ; If depth returns to 0, the class or function block has closed
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
class MyClass {
    MethodInside() {
        MsgBox("Test")
    }
}

TopLevelFunc(a, b) {
    Result := a + b
    return Result
}

AnotherFunc() => MsgBox('Hello')

Line 1
Line 2
class MyClass {
    Method1() {
        return 1
    }
    Method2() {
        return 1
    }
    Method3() {
        return 1
    }
}
Line 3
MyFunction(a, b) {
    return
}

MsgBox MyFunction(a, b)

)"

FoundItems := ScanScriptDefinitions(Code)
Output := "Results:`n"
for Item in FoundItems {
    Output .= Item.Type ": " Item.Name " | Start: " Item.StartLine " | Total Lines: " Item.LineCount "`n"
}
MsgBox(Output)