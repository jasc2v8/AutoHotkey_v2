; ABOUT: Lib_Function_Example
/*
    test #Include Lib_Function

    TODO: 
*/
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; This will inclue Test.ahk
; Everything after the underscrore is just for documentation.
; Or, 

#Include <Test_NotExist>
#Include <Test_IsEmpty>

MsgBox "IsEmpty: " IsEmpty('')

MsgBox StrEnclose("Hello World", '{}')
