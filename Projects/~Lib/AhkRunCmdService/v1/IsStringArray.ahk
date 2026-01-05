#Requires AutoHotkey 2.0+

/* --- Test Variables --- */
stringArray := "v1, v2, v3" ; A plain string, not an array
array90 := StrSplit(stringArray, ",") ; This is now an Array

MsgBox IsStringArray(stringArray)  , "Output: 0 (False - not a String array)" 

; Convert the string to an actual array for testing
array90 := StrSplit(stringArray, ",")
for index, element in array90
    array90[index] := Trim(element)

MsgBox IsStringArray(array90)           , "Output: 1 (True)- Is a String array"
MsgBox IsStringArray([1, "v2", "v3"])   , "Output: 0 (False - contains a number)"
MsgBox IsStringArray("Hello")           , "Output: 0 (False - not an array)" 

IsStringArray(Var) {
    ; Check 1: Is the variable an AHK Array object?
    if Type(Var) != "Array"
        return false
        
    ; Check 2: Check every element in the array
    for index, element in Var
    {
        ; If any element's type is NOT "String", return false immediately.
        if Type(element) != "String"
            return false
    }
    
    ; If all checks pass, it is a String Array
    return true
}

