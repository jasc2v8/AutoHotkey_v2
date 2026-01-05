; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

nameof(&v) => StrGet(NumGet(ObjPtr(&v) + 8 + 6 * A_PtrSize, 'ptr'), 'utf-16')

MyVariable:="test"

MsgBox nameof(&MyVariable) " = " MyVariable
