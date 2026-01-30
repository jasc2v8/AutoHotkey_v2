; TITLE  :  RegistrySettings v1.0.0.1
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    Hive (Root)     HKEY_CURRENT_USER
    Keys\SubKeys    Software\MyApplication
    Values          Theme
    Data            Dark

    Type            Description         Best For
    REG_SZ          Standard            StringNames, paths, simple text.
    REG_DWORD       32-bit Integer      Booleans (0/1), counts, or small numbers.
    REG_MULTI_SZ    Array of Strings    Lists (separate items with `n).
    REG_BINARY      Hexadecimal         dataRaw data or complex objects.

    [SETTINGS]
    FILE_SELECTED
    CHECKBOX_STATE
    RESIZE
    
*/
#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <ListObj>
#Include <JSON>
#Include RegSettings.ahk

Esc::ExitApp()

AppSet := RegistrySettings()

AppSet.Write("Binary", "0x01A2B3C4") 
AppSet.Write("Bool", true) 
AppSet.Write("Float", 25.25)
AppSet.Write("Integer", 25)
AppSet.Write("List", "Apple, Banana, Cherry")
AppSet.Write("String", "Apple")

MyArray := ["item1", "item2", "item3"]
ListObj('MyArray',MyArray)
MyArrayJSON := JSON.ToString(MyArray)
AppSet.Write("Array", MyArrayJSON)

MyMap := Map("Key1", "Value1", "Key2", "Value2", "Key3", "Value3")
ListObj('MyMap',MyMap)
MyMapJSON := JSON.ToString(MyMap)
AppSet.Write("Map", MyMapJSON)

MsgBox "Binary: " AppSet.Read("Binary", "NOT_FOUND")
MsgBox "Bool: " AppSet.Read("Bool", "NOT_FOUND")
MsgBox "Float: " AppSet.Read("Float", "NOT_FOUND")
MsgBox "Integer: " AppSet.Read("Integer", "NOT_FOUND")
MsgBox "List: " AppSet.Read("List", "NOT_FOUND")
MsgBox "String: " AppSet.Read("String", "NOT_FOUND")
MsgBox "Array: " AppSet.Read("Array", "NOT_FOUND")
MsgBox "Map: " AppSet.Read("Map", "NOT_FOUND")

myNewArray := JSON.ToObject(AppSet.Read("Array", "NOT_FOUND"))
ListObj('myNewArray', myNewArray)

myNewMap := JSON.ToObject(AppSet.Read("Map", "NOT_FOUND"))
ListObj('myNewMap', myNewMap)

ExitApp()
