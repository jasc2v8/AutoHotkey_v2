;#ABOUT: Debug.ahk add string, Debug.ListVar(string)

#Requires AutoHotkey v2.0+

; DEBUG #SingleInstance Force

#Include <String>

; Methods:
; ----------------
; MBox()          ; MsgBox
; WriteLine()     ; OutputDebug
; FileWrite       ; FileAppend
; FileWriteLine() ; FileAppend`n
; ListVar()       ; List Array, Map, Object, CSV, List String, or just a String in MsgBox.
; ListVariables   ; Same as built-in ListVars
class Debug
{
    static MBox(Text, Title:="", Options:="")
    {
        return MsgBox(Text, Title, Options)
    }
    
    static WriteLine(Text)
    {
        OutputDebug(Text)
    }

    static FileWrite(Text, Filename:="", Overwrite:=True)
    {
        Filename := (Filename) ? Filename : A_ScriptDir.JoinPath("Debug.txt")
        If (Overwrite AND FileExist(Filename))
            FileDelete(Filename)
        FileAppend(Text "`n", Filename)
    }

    static FileWriteLine(Text, Filename:="", Overwrite:=True)
    {
        Debug.FileWrite(Text "`n", Filename, Overwrite)
    }

    ;-------------------------------------------------------------------------------
    ; Purpose: Lists the values of an Array, Map, Object, or String in a MsgBox.
    ; Returns: The Button pressed in the MsgBox.
    ; Params : Enclose:="%", or Enclose:="[]", etc.
    static ListVar(MyObject, Title:="", Options:="", Enclose:="") {

    if InStr("Array, Map, Object, String", Type(MyObject)) = 0 {
        MsgBox "Value not enumerable.`n`nType: " Type(MyObject), "Error"
        return
    }

    Title := Title.IsEmpty() ? "Type: " Type(MyObject) : Title

    Text := ''

    objType := Type(MyObject)

    switch objType {
        case "Array":
            for index, value in MyObject {
                newvalue :=  (Enclose.Length >= 2) ? Enclose[1] . value . Enclose[2] : Enclose . value . Enclose
                Text .= index ": " newvalue "`n`n"
            }
        case "Map" :
            for key, value in MyObject {
                newvalue:=(Enclose.Length = 1) ?  value : Enclose[1] . value . Enclose[2]
                Text .= key ": " newvalue "`n`n"
            }
        case "Object" :
            for key, value in MyObject.OwnProps() {
                newvalue:=(Enclose.Length = 1) ?  value : Enclose[1] . value . Enclose[2]
                Text .= key ": " newvalue "`n`n"
            }
        case "String" :
            ; Line String
            if MyObject.EndsWith("`r`n") {
                ItemArray := StrSplit(MyObject, "`r`n")
                for index, value in ItemArray {
                    if (value) {
                        value := value.Trim()
                        newvalue:=(Enclose.Length = 1) ?  value : Enclose[1] . value . Enclose[2]
                        Text .= index ": " newvalue "`n"
                    }
                }
            } else if MyObject.Contains(",") {
                ; CSV String
                ItemArray := StrSplit(MyObject, ",")
                if ItemArray.Length >= 1 {
                    for index, value in ItemArray {
                        if (value) {
                            value := value.Trim()
                            newvalue :=  (Enclose.Length >= 2) ? Enclose[1] . value . Enclose[2] : Enclose . value . Enclose
                            Text .= index ": " newvalue "`n"
                        }
                    }  
                }
            } else {
                Text := MyObject
            }
        }
    return MsgBox(Text, Title, Options)
    }

    ;-------------------------------------------------------------------------------
    ; Purpose: Displays the script's variables: their names and current contents.
    ; Returns: ListVars is executed
    ; Params : None.
    static ListVariables() {
        ListVars
    }

    ;-------------------------------------------------------------------------------
    ; Purpose: Search the UNCOMPILED Script for the variable and return its name.
    ; Returns: The name of the variable
    ;          For Example: MsgBox VarName(myVar) ": " MyVar
    ; Params : A variable name.
    ;--------------------------------------------------------
    static VarName(variable) {

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
}

; If included, skip the following block of code.
; If run directly, execute the following block of code
If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    Debug__Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

Debug__Tests() {

    ; comment out to run tests
    SoundBeep(), ExitApp()

    ; comment out tests to skip:
    ;Test1()
    Test2()
    Test3()

    ; test methods
    Test1() {

        MyArray := ["item1", "item2", "item3"]
        MyLine := "The quick brown fox.`r`n"
        MyCSV := "apple, banana, cherry"
        MyMap := Map("Key1", "Value1", "Key2", "Value2")
        MyObj := {KeyA: "ValueA", KeyB: "ValueB", KeyC: "ValueC"}
        MyString := "The quick brown fox jumps over the dog."

        r := Debug.ListVar(MyArray, "Array", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true

        r := Debug.ListVar(MyLine, "Line of Text", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true

        r := Debug.ListVar(MyCSV, "CSV", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true

        r := Debug.ListVar(MyMap, "Map", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true

        r := Debug.ListVar(MyObj, "Object", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true

        r := Debug.ListVar(MyString, "String", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true
    }
    Test2() {

        test:="TEST"
        MsgBox Debug.VarName(test) ": " test, "Debug"

        junk:="THIS IS JUNK1"
        MsgBox Debug.VarName(junk) ": " junk, "Debug"

        junk:="THIS IS JUNK2"
        MsgBox Debug.VarName(junk) ": " junk, "Debug"
    }

    Test3() {
    }
}
