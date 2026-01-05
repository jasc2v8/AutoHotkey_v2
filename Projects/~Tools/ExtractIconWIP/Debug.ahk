; MainScript.ahk
;#Include MyIncludedFunctions.ahk ; Include the file containing the function
#Include <MyIncludedFunctions> ; Include the file containing the function

myMap := Map("Key1", "Value1", "Key2", "Value2")

MyFunction(myMap) ; Pass the Map variable as an argument

MsgBox "Value for NewKey after function call: " myMap["NewKey"]

ListObj(myMap)
