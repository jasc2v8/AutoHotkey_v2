#Requires AutoHotkey 2.0+
#SingleInstance Force

Esc::ExitApp()

GetType(val) {
    if Type(val) = "String" && InStr(val, ",")
        return "CSV String"
    else
        return Type(val)
}

IsType(val, guess) {
    valType  := Type(val)
    valGuess := Type(guess)
    if (valType = guess)
        return true
    else if (valType = "String" && InStr(val, ",") && guess = "CSV String")
        return true
    else
        return false
}

;===================================
;   DEMO
;===================================

class aClass {
}

; Demo
arr := [1,2,3]
csv := "a,b,c"
amap := Map("Key1", "Value1", "Key2", "Value2")
astring := "Hello World"

; All IsType() returns true
MsgBox r := IsType(arr, "Array")        ? "True" : "False", "IsArray(arr)"
MsgBox r := IsType(aclass, "Class")     ? "True" : "False", "IsClass(aClass)"
MsgBox r := IsType(csv, "CSV String")   ? "True" : "False", "IsCSVString(csv)"
MsgBox r := IsType(1.1, "Float")        ? "True" : "False", "IsFloat(1.1)"
MsgBox r := IsType(IsType, "Func")      ? "True" : "False", "IsFunc(IsType)"
MsgBox r := IsType(1, "Integer")        ? "True" : "False", "IsInteger(1)"
MsgBox r := IsType(amap, "Map")         ? "True" : "False", "IsMap(amap)"
MsgBox r := IsType(astring, "String")   ? "True" : "False", "IsString(astring)"
SoundBeep
MsgBox , "Continue?"
MsgBox GetType(arr)     , "Array"
MsgBox GetType(aClass)  , "Class"
MsgBox GetType(csv)     , "CSV String"
MsgBox GetType(1.1)     , "Float"
MsgBox GetType(1)       , "Integer"
MsgBox GetType(amap)    , "Map"
MsgBox GetType(astring) , "String"
SoundBeep
MsgBox , "Continue?"
MsgBox GetType(arr)     , "Array"
MsgBox GetType(aClass)  , "Class"
MsgBox GetType(csv)     , "CSV String"
MsgBox GetType(1.1)     , "Float"
MsgBox GetType(1)       , "Integer"
MsgBox GetType(amap)    , "Map"
MsgBox GetType(astring) , "String"
SoundBeep
MsgBox , "Continue?"
MsgBox Type(arr)        , "Array"
MsgBox Type(aClass)     , "Class"
MsgBox Type(csv)        , "String" ; Doesn't recognize CSV String (makes sense actually)
MsgBox Type(1.1)        , "Float"
MsgBox Type(1)          , "Integer"
MsgBox Type(amap)       , "Map"
MsgBox Type(astring)    , "String"
