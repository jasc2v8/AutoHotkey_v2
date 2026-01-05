;ABOUT: Debug-Beta_v1.1.0.0
/************************************************************************
 * @description Debug Helpers
 * @author jasc2v8
 * @date 2025/11/14
 * @version 1.0.2
 ***********************************************************************/

;#ABOUT: Debug.ahk add string, Debug.ListVar(string)

#Requires AutoHotkey v2.0+

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
    ; Purpose:  Displays the Labels and  variables in a MsgBox.
    ; Returns:  Label: Variable
    ; Params :  Labels is a CSV "Label1, Label2, Label3"
    ;           Vars are Variable1, Variable2, Variable3
    ; Options:  Enclose[], Spacing2, OKCancel, IconX
    static ListVars(Title:="", Options:="Spacing2", Labels:="", Vars*) {
        ;MsgBox Labels "`n`n" Vars.Length

        LineEnd := "`n"
        Enclose := ""
        
        ; Options: Enclose[], Spacing2, OKCancel, IconX
        if (Options !="") {
            newOptions:= Array()          
            opts := StrSplit(Options, ",")
            Loop opts.Length {
                item:= Trim(opts[A_Index])
                if (SubStr(item,1, 7)="Enclose"){
                    Enclose:= SubStr(item, 8, 2)
                } else if (SubStr(item,1, 7)="Spacing"){
                    Spacing:= SubStr(item, 8, 1)
                    LineEnd := ""
                    Loop Spacing{
                        LineEnd .= "`n"
                    }
                } else {
                    newOptions.Push(item)
                }
                Options:=""
                Loop newOptions.Length {
                    Options .= newOptions[A_Index] " "
                }
             }
        
        }

        Text := ""
        split := StrSplit(Labels, ",")
        if Vars.Length > split.Length {
            delta := Vars.Length - split.Length
            Loop delta {
                split.Push("?")
            }
        } else if Vars.Length < split.Length {
            ; dunno?
        }
        Loop Vars.Length {
            if (Enclose !="") {
                Text .= split[A_Index] ": " SubStr(Enclose,1,1) Vars[A_Index] SubStr(Enclose,2,1) LineEnd
            } else {
                Text .= split[A_Index] ": " Vars[A_Index] LineEnd
            }
        }

        MsgBox Text, Title, Options
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
                ;     . "`n`nMatch 1 : " . m1
                ;     . "`n`nMatch 2 : " . m2
                ;     . "`n`nLine Number: " . callingLineNumber)

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
    Test0()
    Test1()
    Test2()
    ;Test3()

    ; test methods

    Test0(){

        ; ListVars(Title:="", Options:="", Labels:="", Vars*)

        a:=Format("0x{:X}", 0xFCFCFC)
        b:=2.25
        c:=Format("{:.2f}", 3.1415927)
        d:=2
        e:=4
        f:=8

        ; equal number of vars
        Debug.ListVars("Test", "Enclose[], Spacing2", "a, b, c", a, b, c)

        ; vars > labels
        Debug.ListVars("Test", "Enclose(), Spacing3, OKCancel", "a, b, c", a, b, c, d, e, f)

        ; vars < labels
        Debug.ListVars("Test", "Enclose<>, Spacing4, YesNoCancel", "a, b, c", a, b)

    }
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