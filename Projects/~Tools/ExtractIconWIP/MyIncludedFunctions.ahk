#Requires AutoHotkey v2.0

; MyIncludedFunctions.ahk
MyFunction(myMap) {
    ; Access elements of the map within the function
    ;MsgBox "Value for Key1: " myMap["Key1"]
    myMap["NewKey"] := "NewValue" ; You can modify the map if desired

    Output := ''
    for index, value in myMap {
        Output .= "[" index "]:`n [" value "]`n`n"
    }
    ;MsgBox(Output, "Output:`n`n" Output)

    ;ListObjTEST(myMap)
}

ListObj(MyObject)
{
    objName := Type(MyObject)

    if (objName != "Array") AND (objName != "Map")
        return

    Output := ''
    for index, value in MyObject {
        Output .= "[" index "]:`n [" value "]`n`n"
    }
    MsgBox(Output, "List Object: [" objName ']')
}
