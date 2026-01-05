; TITLE  :  Listen v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

; ok #Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <Peep>

#Include jsongo.v2.ahk

json := '{"Array":["a","b","c"]}'

obj := jsongo.Parse(json)

Peep("MyObject", obj)

objJSON := jsongo.Stringify(obj)

Peep("MyJSON", objJSON)

