; TITLE  :  ObjTree v2.0.0.1
; SOURCE :  jasc2v8, Gemini, and https://github.com/HotKeyIt/ObjTree/tree/v2
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  A utility to visualize object structures in a TreeView
; USAGE  :  ObjTree(Obj, Title := "Object TreeView")
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

#Include ObjTree.ahk

Esc::ExitApp()


;MsgBox , "Modal Examples", "IconI"

MyString     := "item1"
MyStringCSV  := "item1, item2, item3"
MyStringList := "item1`nitem2`nitem3"

ObjTree(MyString, "MyString")
ObjTree(MyStringCSV, "MyStringCSV")
ObjTree(MyStringList, "MyStringList")
