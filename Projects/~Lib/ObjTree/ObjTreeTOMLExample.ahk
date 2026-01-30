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

;Esc::ExitApp()

; A simulated complex object for ObjTree
SystemData := Map(
    "[settings]", Map(
        "servers",  ["192.168.1.1", "192.168.1.2"],
        "retry_codes", [404, 500, 503]
    )

)

ObjTree(SystemData, "Large Object Example")
