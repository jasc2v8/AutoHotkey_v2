#Requires AutoHotkey 2.0+

class GetType {
    static Call(val) {
        if Type(val) = "String" && InStr(val, ",")
            return "CSV"
        else
            return Type(val)
    }
}

Class IsType {
    static Call(val, guess:="") {      
        if (guess="") {
            if Type(val) = "String" && InStr(val, ",")
                return "CSV"
            else
                return Type(val)        
        }
        valType  := Type(val)
        valGuess := Type(guess)
        if (valType = guess)
            return true
        else if (valType = "String" && InStr(val, ",") && guess = "CSV")
            return true
        else
            return false
    }
}

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    IsType__Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

;Esc::ExitApp()

IsType__Tests() {

    ; comment out to run tests
    SoundBeep(), ExitApp()

    v1:="one", v2:="two", v3:="three"

    aFunc() {

    }

    ; Demo
    arr     := [1,2,3]
    csv     := '"' v1 ','  v2 ',' v3 '"'
    csvStr  := "a,b,c"
    amap    := Map("Key1", "Value1", "Key2", "Value2")
    astring := "Hello World"

    ;MsgBox Type(arr)        , "Array"

    ; All IsType() returns true
    MsgBox r := IsType(arr, "Array")        ? "True" : "False", "IsArray(arr)"
    MsgBox r := IsType(IsType, "Class")       ? "True" : "False", "IsClass(Demo)"
    MsgBox r := IsType(csv, "CSV")          ? "True" : "False", "IsCSV(csv)"
    MsgBox r := IsType(csvStr, "CSV")       ? "True" : "False", "IsCSV(csvStr)"
    MsgBox r := IsType(1.1, "Float")        ? "True" : "False", "IsFloat(1.1)"
    MsgBox r := IsType(aFunc, "Func")       ? "True" : "False", "IsFunc(IsType)"
    MsgBox r := IsType(1, "Integer")        ? "True" : "False", "IsInteger(1)"
    MsgBox r := IsType(amap, "Map")         ? "True" : "False", "IsMap(amap)"
    MsgBox r := IsType(astring, "String")   ? "True" : "False", "IsString(astring)"
    SoundBeep
    MsgBox , "Continue?"
    MsgBox IsType(arr)     , "Array"
    MsgBox IsType(IsType)    , "Class"
    MsgBox IsType(csv)     , "CSV"
    MsgBox IsType(csvStr)  , "CSVStr"
    MsgBox IsType(1.1)     , "Float"
    MsgBox IsType(aFunc)   , "Func"
    MsgBox IsType(1)       , "Integer"
    MsgBox IsType(amap)    , "Map"
    MsgBox IsType(astring) , "String"
    SoundBeep
    MsgBox , "Continue?"
    MsgBox GetType(arr)     , "Array"
    MsgBox GetType(IsType)    , "Class"
    MsgBox GetType(csv)     , "CSV"
    MsgBox GetType(csvStr)  , "CSV"
    MsgBox GetType(1.1)     , "Float"
    MsgBox GetType(aFunc)   , "Func"
    MsgBox GetType(1)       , "Integer"
    MsgBox GetType(amap)    , "Map"
    MsgBox GetType(astring) , "String"
    SoundBeep
    MsgBox , "Continue?"
    MsgBox Type(arr)        , "Array"
    MsgBox Type(IsType)       , "Class"
    MsgBox Type(csv)        , "String"
    MsgBox Type(csvStr)     , "String"
    MsgBox Type(1.1)        , "Float"
    MsgBox Type(aFunc)      , "Func"
    MsgBox Type(1)          , "Integer"
    MsgBox Type(amap)       , "Map"
    MsgBox Type(astring)    , "String"
    SoundBeep
    SoundBeep
}