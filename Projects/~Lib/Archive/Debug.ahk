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
; ListVar()       ; List Array, Map, Object, CSV, or List String in MsgBox
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

    /*
        MyArray := ["item1", "item2", "item3"]
        MyLine := "The quick brown fox.`r`n"
        MyCSV := "apple, banana, cherry"
        MyMap := Map("Key1", "Value1", "Key2", "Value2")
        MyObj := {KeyA: "ValueA", KeyB: "ValueB", KeyC: "ValueC"}
    */

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

    ; Purpose: Displays the script's variables: their names and current contents.
    static ListVariables() {
        ListVars
    }
}

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included

; Text := "The rain in Spain..."
; ;Text := "['a',b,'c',d]"
; Debug.ListVar(Text)
