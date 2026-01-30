;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2+
#SingleInstance Force
;#NoTrayIcon

Esc::ExitApp()

#Include ObjList.ahk

; Universal List GUI Class
; Version 1.0.10

; --- Input Examples ---
DataArray := ["Apple", "Banana", "Cherry"]
DataMap   := Map("Key1", "Value1", "Key2", "Value2")
DataCSV   := "Red,Green,Blue,Yellow"
DataLines := "Line One`nLine Two`nLine Three"
DataText  := "Single Item"

; Example usage:

ObjList(DataArray, "DataArray")
ObjList(DataMap, "DataMap")
ObjList(DataCSV, "DataCSV")
ObjList(DataLines, "DataLines", false)
MoveWindow("DataLines", 100, 100)
ObjList(DataText, "DataText")


MoveWindow(WinTitle, X, Y) {
    if WinExist(WinTitle)
        WinMove(X, Y,,, WinTitle)
}