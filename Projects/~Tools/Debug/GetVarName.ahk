;ABOUT: GetVarName.ahk
;SOURCE: Copilot, Gemini, AHK forums

#Requires AutoHotkey v2.0+

;--------------------------------------------------------
; Search the UNCOMPILED Script for the variable and return its name.
; For Example: MsgBox VarName(myVar) ": " MyVar
VarName(variable) {

    callingLineNumber := GetCallerLineNumber()

    ;MsgBox "Called from line: " callingLineNumber

    ScriptText := FileRead(A_ScriptFullPath)

    ; Match the parameter in the parenthesis after "VarName("
    pattern := "(\QVarName(\E)(\w+)"

    returnValue := ""

    Loop Parse ScriptText, "`n" , "`r`n" {

        line := A_LoopField

        if A_Index != callingLineNumber
            continue

        result := RegexMatch(line, pattern, &match)

        if result {
            m1 := match[1]      ; Captures "VarName("
            m2 := match[2]      ; Captures parameter

            ; MsgBox("Captured Parts:"
            ;     . "`n`nMatch 1 : " . paramOne
            ;     . "`n`nMatch 2 : " . paramTwo
            ;     . "`n`nLine Number: " . A_Index)

            returnValue := m2
        } else {
            MsgBox("No match found.")
        }
        break
    }

    GetCallerLineNumber() {
        try {
            throw Error()
        } catch as e {
            ; Match the parameter in the first set of parenthesis
            pattern := "\s*\(([^()]+)\)\s*:\s*\[\]"
            if RegExMatch(e.Stack, pattern, &m)
                return m[1]  ; Line number of the caller
        }
            return -1  ; Fallback
    }
    return returnValue
}
