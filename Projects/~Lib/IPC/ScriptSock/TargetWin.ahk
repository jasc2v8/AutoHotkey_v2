;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

; ----------------------------------------------------------------------------------------------------------------------------------
; TargetWin.ahk (Example Usage)
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

oScriptSock := ScriptSock("")

iGlobalTestVar := 1111

SetTimer(fMainFunc, 100)

fMainFunc()
{
	if (oScriptSock.FetchVar("bStartFirst", 0))
	{
		global iGloblalTestVar := 9999

		oScriptSock.PushVar("bStartFirst", false, 0)
	}

	if (oScriptSock.FetchVar("bStartSecond", 0))
	{
		MsgBox("Result: " oScriptSock.FetchVar("bBooleanVar", false), , "T2")
		MsgBox("Result: " oScriptSock.FetchVar("iIntegerVar", 0), , "T2")
		MsgBox("Result: " oScriptSock.FetchVar("sStringVar", ""), , "T2")

		oScriptSock.PushVar("bStartSecond", false, 0)
	}
}

return

