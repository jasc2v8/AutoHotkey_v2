
#Requires AutoHotkey 2+
#SingleInstance Force
#Warn Unreachable, Off

/*

*/

#Include RunShell.ahk

;Esc::ExitApp()

; ok
;cmd := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST WITH SPACES"
;cmd := ["C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe", "TEST WITH SPACES"]
;output := RunShell(cmd)

;ok
;output := RunShell(["D:\TEST\StdOutArgs.exe",  "-switch", "D:\List Vars.ahk", "D:\ShowArgs.exe"])
;
output := RunShell(["D:\TEST\StdOut Args.exe", "-switch", "D:\List Vars.ahk", "D:\ShowArgs.exe"])

;ok
;cmd := RunShell.ToArray("D:\TEST\StdOut Args.exe", "-switch", "D:\List Vars.ahk", "D:\ShowArgs.exe")
;output := RunShell(cmd)

;ok
; exe := "D:\TEST\StdOut Args.exe"
; p1  := "-switch"
; p2  := "D:\List Vars.ahk"
; p3  := "D:\ShowArgs.exe"
; cmd := RunShell.ToCSV(exe, p1, p2, p3)
; output := RunShell(cmd)

; ok output := RunShell(["ipconfig", "/all"])
; ok output := RunShell(["ipconfig /all"])

; ok output := RunShell(["dir", "D:\"])
; ok output := RunShell(["dir", "x:\"]) ; force StdErr

; ok output := RunShell("dir D:\")
; ok output := RunShell("ipconfig /all")

; no - won't handle spaces in params
;exe := "D:\TEST\StdOut Args.exe"
;params :=  "-switch D:\List Vars.ahk D:\ShowArgs.exe"
;cmd := Format('"{}" {}', exe, params)
;output := RunShell(cmd)

; ok output := RunShell(3.1415927)

MsgBox output
ExitApp()
