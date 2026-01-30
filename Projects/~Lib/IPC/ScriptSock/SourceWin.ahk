;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

; ----------------------------------------------------------------------------------------------------------------------------------
; SourceWin.ahk (Example Usage)
; ----------------------------------------------------------------------------------------------------------------------------------

#Requires AutoHotkey v2
#SingleInstance Force

#Warn All, StdOut
#Warn Unreachable, Off
#Warn LocalSameAsGlobal, Off
#Warn VarUnset, StdOut

DetectHiddenWindows(false)
DetectHiddenText(false)
SetTitleMatchMode(2)

#Include "ScriptSock.ahk"

; ----------------------------------------------------------------------------------------------------------------------------------
; Example 01
; ----------------------------------------------------------------------------------------------------------------------------------
if (0)
{
	; Make sure "TargetWin.ahk" is running.

	MsgBox("Get a variable from target script...")
	MsgBox("Result: " ScriptSock("TargetWin.ahk").GetVar("iGlobalTestVar")) ; 1111
}

; ----------------------------------------------------------------------------------------------------------------------------------
; Example 02
; ----------------------------------------------------------------------------------------------------------------------------------
else if (0)
{
	; Make sure "TargetWin.ahk" is running.

	oScriptSock := ScriptSock("")

	; Add "#" identifier to a variable's name for debugging
	MsgBox("Begin debugging...")
	MsgBox("Result: " oScriptSock("TargetWin.ahk").GetVar("iGlobalTestVar#")) ; 1111
}

; ----------------------------------------------------------------------------------------------------------------------------------
; Example 03
; ----------------------------------------------------------------------------------------------------------------------------------
else if (0)
{
	; Make sure "TargetWin.ahk" is running.

	MsgBox("Set a variable in target script...")
	ScriptSock("TargetWin.ahk").SetVar("iGlobalTestVar", 2222)
	MsgBox("Result: " ScriptSock("TargetWin.ahk").GetVar("iGlobalTestVar")) ; 2222
}


; ----------------------------------------------------------------------------------------------------------------------------------
; Example 04
; ----------------------------------------------------------------------------------------------------------------------------------
else if (0)
{
	; Make sure 'TargetWin.ahk' is running

	MsgBox("Set a variable in target script...")
	ScriptSock("TargetWin.ahk").SetVar("iGloblalTestVar", 3333)
	MsgBox("Result: " ScriptSock("TargetWin.ahk").GetVar("iGloblalTestVar")) ; 3333

	MsgBox("Post a variable and start fetching in target script...")
	ScriptSock("TargetWin.ahk").PostVar("bStartFirst", true)
	Sleep(300)
	MsgBox("Result: " ScriptSock("TargetWin.ahk").GetVar("iGloblalTestVar")) ; 9999
}

; ----------------------------------------------------------------------------------------------------------------------------------
; Example 05
; ----------------------------------------------------------------------------------------------------------------------------------
else if (1)
{
	; Make sure 'TargetWin.ahk' is running

	MsgBox("Post multiple variables to target script...")

	ScriptSock("TargetWin.ahk").PostVar("bBooleanVar", true)
	ScriptSock("TargetWin.ahk").PostVar("iIntegerVar", 5555)
	ScriptSock("TargetWin.ahk").PostVar("sStringVar", "Hello, world!")

	MsgBox("Start fetching in target script...")

	ScriptSock("TargetWin.ahk").PostVar("bStartSecond", true, 0)
}

return


