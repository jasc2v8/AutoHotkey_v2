
#Requires AutoHotkey 2.0+
#SingleInstance Force
#Warn Unreachable, Off

/*

*/

#Include RunCMD.ahk

;Esc::ExitApp()

; ok
;cmd := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST WITH SPACES"
;cmd := ["C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe", "TEST WITH SPACES"]
;output := RunCMD(cmd)

;ok
;output := RunCMD(["D:\TEST\StdOutArgs.exe",  "-switch", "D:\List Vars.ahk", "D:\ShowArgs.exe"])
;
output := RunCMD(["D:\TEST\StdOut Args.exe", "-switch", "D:\List Vars.ahk", "D:\ShowArgs.exe"])

;ok
;cmd := RunCMD.ToArray("D:\TEST\StdOut Args.exe", "-switch", "D:\List Vars.ahk", "D:\ShowArgs.exe")
;output := RunCMD(cmd)

;ok
; exe := "D:\TEST\StdOut Args.exe"
; p1  := "-switch"
; p2  := "D:\List Vars.ahk"
; p3  := "D:\ShowArgs.exe"
; cmd := RunCMD.ToCSV(exe, p1, p2, p3)
; output := RunCMD(cmd)

; ok output := RunCMD(["ipconfig", "/all"])
; ok output := RunCMD(["ipconfig /all"])

; ok output := RunCMD(["dir", "D:\"])
; ok output := RunCMD(["dir", "x:\"]) ; force StdErr

; ok output := RunCMD("dir D:\")
; ok output := RunCMD("ipconfig /all")

; no - won't handle spaces in params
;exe := "D:\TEST\StdOut Args.exe"
;params :=  "-switch D:\List Vars.ahk D:\ShowArgs.exe"
;cmd := Format('"{}" {}', exe, params)
;output := RunCMD(cmd)

; ok output := RunCMD(3.1415927)

MsgBox output
ExitApp()
