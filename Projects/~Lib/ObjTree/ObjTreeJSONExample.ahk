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


; Correct AHK v2 Multi-line String format
jsonTest := "
(
{
    `"Project`": `"ObjTree Debugger`",
    `"Version`": `"2.0.55`",
    `"Features`": [
        `"Search Filtering`",
        `"Dark Mode`"
    ],
    `"Settings`": {
        `"Theme`": `"Light`",
        `"ShowIcons`": true
    }
}
)"

; Call the function
ObjTree(jsonTest, "AHK v2 String Test")


;
;
;

MsgBox , "Modless Examples", "IconI"

MyArray := ["item1", "item2", "item3"]
ObjTree(MyArray, "MyArray", false)

MyMap := Map("Key1", "Value1", "Key2", "Value2", "Key3", "Value3")
ObjTree(MyMap, "MyMap", false)

myData := {Name: "John", Roles: ["Admin", "User"], Meta: {ID: 123, Active: true}}
ObjTree(myData, "MyData", false)

MoveWindow("MyArray", 100, 100) 
MoveWindow("MyMap", 200, 140) 
MoveWindow("MyData", 300, 160) 

MsgBox "End of Examples`n`nNote the other modless windows...", "ObjTree Examples", "IconI"

; Test Case for Circular Reference:
;  a := {name: "A"}
;  b := {name: "B"}
;  a.child := b
;  b.parent := a
;  ObjTree(a)

ExitApp()

MoveWindow(WinTitle, X, Y) {
    if WinExist(WinTitle)
        WinMove(X, Y,,, WinTitle)
}

