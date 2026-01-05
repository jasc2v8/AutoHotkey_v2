;ABOUT: GetVarName.ahk
;SOURCE: Copilot, Gemini, AHK forums

#Requires AutoHotkey v2.0+
#SingleInstance Force

esc::ExitApp

#Warn Unreachable, off

test:="TEST"
MsgBox VarName(test) ": " test, "Debug"

junk:="THIS IS JUNK1"
MsgBox VarName(junk) ": " junk, "Debug"

junk:="THIS IS JUNK2"
MsgBox VarName(junk) ": " junk, "Debug"

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


return

;     if result {
;         varNameOpening := match[1] ; Captures "VarName("
;         numberTwo := match[2]      ; Captures "2"
;         wordAfterComma := match[3] ; Captures "junk"

;         MsgBox "id: " id "`n`nnumberTwo: " numberTwo, "VarName"
        
;         if numberTwo = id {

;             MsgBox("Captured Parts:"
;                 . "`nMatch 1 (Name & Open Paren): " . varNameOpening
;                 . "`nMatch 2 (First Number): " . numberTwo
;                 . "`nMatch 3 (Word After Comma): " . wordAfterComma)

;             return wordAfterComma

;         }
        
;     } else {
;         MsgBox("No match found.")
;     }
;     }

; return

; inputString := "leading text VarName(2, junk) trailing text"
; pattern := "(\QVarName(\E)(\d+)"
; result := RegexMatch(inputString, pattern, &match)

; if result {
;     varNameOpening := match[1] ; Captures "VarName("
;     numberTwo := match[2]      ; Captures "2"

;     MsgBox("Captured Parts:"
;         . "`nMatch 1: " . varNameOpening
;         . "`nMatch 2: " . numberTwo)

;     /*
;     Outputs:
;     Captured Parts:
;     Match 1: VarName(
;     Match 2: 2
;     */
; } else {
;     MsgBox("No match found.")
; }

; return

 ; search the UNCOMPILED Script for the first occurance

; test:="TEST"
; junk:="THIS IS JUNK"

; MsgBox VarName(2, junk) ": " junk, "junk"
; MsgBox VarName(1, test) ": " test, "test"

; ;MsgBox VarNameDISABLE(1, test) ": " test
; ;MsgBox VarNameDISABLE(2, junk) ": " junk

; VarName(id, variable) { 
    
;     if A_IsCompiled
;         return

;     test:=variable

;     ScriptText := FileRead(A_ScriptFullPath)
;     ;ScriptText := "leading text VarName(2, junk) trailing text"

;     pattern := "VarName\(([^)]+)\)"
;     ;pattern := "(\w+\s*\(.+\))"
;     pattern := "VarName\((.+)\)"

;     r := RegExMatch(ScriptText, pattern, &Match)

;     if r 
;         return match[1] 
;     else
;         return ""
    
    
; }
