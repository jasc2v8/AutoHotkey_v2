/*
    Version: 1.0.1.0
    Description: Finds the first '{' at or after LineNumber and counts lines until the last '}'.
*/

CountLinesFromLine(Script, LineNumber) {
    if (Script = "")
        return 0

    ; Split script into lines to find the starting point
    AllLines := StrSplit(Script, "`n", "`r")

    if (LineNumber > AllLines.Length)
        return 0

    ; Reconstruct script starting from the target LineNumber
    TargetContent := ""
    Loop AllLines.Length - LineNumber + 1 {
        Index := A_Index + LineNumber - 1
        TargetContent .= AllLines[Index] . "`n"
    }

    ; 1. Find the first '{' in the target range
    FirstBracePos := InStr(TargetContent, "{")

    if (FirstBracePos = 0)
        return 0

    ; 2. Find the last '}' in the target range
    LastBracePos := InStr(TargetContent, "}", , -1)

    if (LastBracePos = 0)
        return 0

    if (LastBracePos < FirstBracePos)
        return 0

    ; Extract the block content
    Block := SubStr(TargetContent, FirstBracePos, LastBracePos - FirstBracePos + 1)

    ; Normalize and count lines
    Block := StrReplace(Block, "`r`n", "`n")
    LinesArray := StrSplit(Block, "`n")

    return LinesArray.Length
}

; EXAMPLE

MyScript := "
(
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
)"

; Start searching from Line 3
MsgBox(CountLinesFromLine(MyScript, 3)) ; Returns 11 (from '{' of MyClass to the last '}')