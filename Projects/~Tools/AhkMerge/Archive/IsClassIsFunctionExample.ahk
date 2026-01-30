IsClass(ScriptLine) {
    ; Trim whitespace from both ends
    ScriptLine := Trim(ScriptLine)

    if (ScriptLine = "")
        return false

    ; Regex pattern explanation:
    ; ^i)          -> Case-insensitive (though PrivateExtractIcons is case sensitive, keywords aren't)
    ; ^class\s+    -> Starts with 'class' followed by at least one space
    ; [a-zA-Z0-9_] -> Followed by a valid class name character
    if (RegExMatch(ScriptLine, "^i)class\s+[a-zA-Z0-9_]+"))
        return true

    return false
}

IsFunction(ScriptLine) {
    ScriptLine := Trim(ScriptLine)

    if (ScriptLine = "")
        return false

    ; Exclude common keywords that look like functions
    ;if (RegExMatch(ScriptLine, "^i)(if|while|for|loop|switch|catch)\b"))        return false

    ; Regex pattern explanation:
    ; ^[a-zA-Z0-9_]+  -> Starts with a valid function name
    ; \s*\(           -> Followed by optional space and an opening parenthesis
    ; [^\)]* -> Followed by anything that is NOT a closing parenthesis (parameters)
    ; \)\s* -> Followed by closing parenthesis and optional space
    ; (\{|$)          -> Ends with an opening brace OR the end of the line
    if (RegExMatch(ScriptLine, "^[a-zA-Z0-9_]+\s*\([^\)]*\)\s*\{?$"))
        return true

    return false
}

; EXAMPLE

ESC::ExitApp()


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
Line 3
MyFunction(a, b) {
    return
}

MsgBox MyFunction(a, b)

)"

Loop Parse MySCript, "`n", "`r"{

    MsgBox A_LoopField

    ;if IsClass(A_LoopField)
    ;    MsgBox "Is Class at line: " A_Index

    if IsFunction(A_LoopField) {
        SoundBeep
        MsgBox "Is Function at line: " A_Index "`n`nLine: " A_LoopField
    }

}

