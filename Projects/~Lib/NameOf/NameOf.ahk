; TITLE  :  NameOf v1.0
; SOURCE :  thqby https://github.com/thqby/ahk2_lib/blob/master/nameof.ahk
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Returns a string with the name of the variable
; USAGE  :  NameOf(&MyVariable) = 'MyVariable'

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

NameOf(&v) => StrGet(NumGet(ObjPtr(&v) + 8 + 6 * A_PtrSize, 'ptr'), 'utf-16')

; NameOf(&var) {
;     return StrGet(NumGet(ObjPtr(&v) + 8 + 6 * A_PtrSize, 'ptr'), 'utf-16')
; }

; MyVariable:="test"
; MsgBox nameof(&MyVariable) " = " MyVariable
