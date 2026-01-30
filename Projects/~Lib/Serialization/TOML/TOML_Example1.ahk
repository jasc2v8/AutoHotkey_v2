;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include TOML.ahk

Esc::ExitApp()

;
; Array
;

; Create a serialized structure
MyArray := ["item1", "item2", "item3"]

; Convert to TOML String
tomlOutput := TOML.Stringify(MyArray)
MsgBox(tomlOutput, "MyArray to TOML String")

; Parse it back
parsedArray := TOML.Parse(tomlOutput)
MsgBox(parsedArray["2"], "MyArray TOML String Parsed")

;
; Map
;

; Create a serialized structure
MyMap := Map("Key1", "Value1", "Key2", "Value2", "Key3", "Value3")

; Convert to TOML String
tomlOutput := TOML.Stringify(MyMap)
MsgBox(tomlOutput, "MyMap to TOML String")

; Parse it back
parsedMap := TOML.Parse(tomlOutput)
MsgBox(parsedMap["Key2"], "MyMap to TOML String")
