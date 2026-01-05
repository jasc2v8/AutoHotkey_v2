#Requires AutoHotkey v2.0+

#Include <Debug>

; Purpose:  Find Functions to include in the MainScriptFile.
; Return:   CSV file of functionName, LibScriptFile, ScriptLineNumber, FunctionLineCount.
;----------------------------------------------------------------------------------------
ScanLibScript(LibScriptFile)
{

    FunctionCSV := ""

    ScriptText := FileRead(LibScriptFile)

    ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

    ClassBlockStart := false
    InClassBlock := false
    InCommentBlock := false
    ScriptLineNumber := 0
    IgnoreToEnd := False

    Loop {
   
        if IgnoreToEnd
            break

        ScriptLineNumber++

        if ScriptLineNumber > ScriptTextArray.Length
            break

        functionName := ""

        ;remove leading whitespace
        line := ScriptTextArray[ScriptLineNumber].LTrim()

        if line.StartsWith("/*")
            InCommentBlock := true
        else if line.StartsWith("*/")
            InCommentBlock := false

        if InCommentBlock
            continue

        if line.IsEmpty() OR line.StartsWith(";")
            continue

        ; Exclude test functions at bottom of script
        if line.StartsWith("If (A_LineFile == A_ScriptFullPath)") {
            IgnoreToEnd := True
            continue
        }

        if line.StartsWith("class") {

            ClassBlockStart := true

            ;match the second word
            ;functionName := line.Match("^\s*\S+\s+(\S+)")

            ; if class search for the name of the class e.g. class Debug {, Debug.ahk
            ;functionName := LibScriptFile.SplitPath().NameNoExt
            functionName := "#Include"

            ;Debug.MBox("LibScriptFile: " LibScriptFile "`n`nfunctionName: " functionName)


            ;OutputDebug("class: " line ", name: " r)

        }

        if functionName.IsEmpty() {
            ; This RegExMatch pattern will find and capture the function name: ".*?(\w+)\("
            ;   .*?     : This is a non-greedy match for any character (.) zero or more times (*?).
            ;               It will match as few chars as possible from the beginning of the string until the next part of the pattern can be satisfied.
            ;               This is useful for skipping over things like if or leading whitespace.
            ;   (\w+)   : This is the capturing group.
            ;               It matches one or more "word" characters (letters, numbers, and underscores).
            ;               This will capture the function name (e.g., DirExist).
            ;   \(      : This matches the literal opening parenthesis that immediately follows the function name, 
            ;               confirming it's a function call.
            RegExMatch(line, ".*?(\w+)\(", &match)

            if !IsObject(match)
                continue

            functionName := match[1]

            ;Debug.WriteLine("functionName: " functionName)
            ;Debug.MBox("functionName: " functionName)

        }

        ; if still empty we didn't detect a function name in this line, continue
        if functionName.IsEmpty()
            continue

        ;static excludedFunctionNames := "for, if, MsgBox, while"
        static excludedFunctionNames := "MsgBox"

        if excludedFunctionNames.Contains(functionName)
            continue

        ;If next line > end of Array then Break
        if (ScriptLineNumber + 1) > ScriptTextArray.Length
            break

        ;If next line starts with { then add { to this line and clear next line
        if ScriptTextArray[ScriptLineNumber + 1].StartsWith("{") {
            ScriptTextArray[ScriptLineNumber] .= "{"
            ScriptTextArray[ScriptLineNumber + 1] := ""        
        }

        ;if not in class block, save the function, script name, and line number
        if FunctionCSV.Contains(functionName)
            continue

        if NOT InClassBlock
            FunctionCSV .= functionName ", " LibScriptFile ", " ScriptLineNumber

        if ClassBlockStart
            InClassBlock := true

        ; Preset counters
        FunctionLineCount := 1
        BraceCount := 0

    ;MsgBox "Script: " OutName "`n`nFunctionName:`n`n" functionName "`n`nlineNumber: " ScriptLineNumber "`n`nInCommentBlock: " InCommentBlock, "Loop 1"


        ; If this line contains { then Count braces
        if ScriptTextArray[ScriptLineNumber].Contains("{") {

    ;MsgBox "Script: " OutName "`n`nCounting Braces.", "Loop 1"

            Loop {

                line := ScriptTextArray[ScriptLineNumber]

                if line.Contains("}") and line.Contains("{") {
                    BraceCount += 0
                } else if line.Contains("{") {
                    BraceCount += 1
                } else if line.Contains("}") {
                    BraceCount -= 1
                }

    ;MsgBox "Script: " OutName "`n`nScriptLineNumber: " ScriptLineNumber "`n`nBraceCount: " BraceCount , "Loop 1"

                if (BraceCount = 0) {
                    ;DEBUG THIS ISN'T USED, REMOVE
                    if InClassBlock
                        InClassBlock := false
                    break
                }
                
                FunctionLineCount++

                ScriptLineNumber++
                
                if ScriptLineNumber > ScriptTextArray.Length
                    break ; 2
            }

        }

        FunctionCSV .= ", " FunctionLineCount "`n"

    } ; end loop

    ;Debug.ListVar FunctionCSV

    return FunctionCSV
}

GetFunctionLineCount(Buffer, FunctionName, LineNumber) {

;TODO: Buffer[] needs to be an Array so we can step through it to count function lines

    ;MsgBox "FunctionName: " FunctionName ", LineNumber: " LineNumber, "GetFunctionLineCount"

    FunctionLineCount := BraceCount := 0

    Loop Parse Buffer, "`n" {

    ;     split := StrSplit(A_LoopField, ",")

    ; MsgBox "split[3]: " split[3], "Loop"

        ; if split.Length >= 4
        ;     lineNumber := split[3]
        ; else
        ;     continue


        if A_Index != lineNumber
            continue

        ; Found Function in Buffer, now count braces
        line := A_LoopField.Trim()

        Loop {

            FunctionLineCount := 0
        
        ;MsgBox "line: " line "`n`nlineNumber: " lineNumber, "Loop"

        ;MsgBox "lineNumber: " lineNumber, "Loop"

            if line.Contains("}") and line.Contains("{") {
                BraceCount += 0
            } else if line.Contains("{") {
                BraceCount += 1
            } else if line.Contains("}") {
                BraceCount -= 1
            }

            if (BraceCount = 0) {
                break
            }

            if (BraceCount > 0)
                FunctionLineCount++

        }
    }

    MsgBox "FunctionName: " FunctionName "`n`nBraceCount: " BraceCount "`n`nFunctionLineCount: " FunctionLineCount "`n`n", "Loop"

    return FunctionLineCount
}
