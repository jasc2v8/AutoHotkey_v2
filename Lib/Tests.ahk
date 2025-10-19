;ABOUT: Scante <Lib>, classes > Include_classes.ahk, functions > Include_functions.ahk

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#Include <AhkFunctions>
#Include <String>

;Test_StrSplitShortcut()

; #region Functions

Test_StrSplitShortcut() {
	path := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\Remote Desktop Connection.lnk"
	MsgBox("Path:`n`n" path "`n`n" 
	"Target:`n`n" LPad(, 4,) StrSplitShortcut(path).Target "`n`n"
	"Dir:`n`n[" StrSplitShortcut(path).Dir "]`n`n"
	"Args:`n`n[" StrSplitShortcut(path).Args "]`n`n"
	"Description:`n`n" StrSplitShortcut(path).Description,
	"StrSplitShortcut")
}

;StrMsgBox('TITLE', 'icon', NL("Value1:"), NL(LPad(100)), NL("Value2:"), LPad(200))

; ok MsgBoxList('TITLE', 'icon', '`n`n' ,"Value1:", LPad(100), "Value2:", LPad(200))



;ListVars()
;sgBox([Text := '', Title := A_ScriptName, Options := 0]) => String





StrBrackets(str) {
	return "[" str "]"
}
StrQuotes(str) {
	return '""' str '""'
}
StrQuoteSingle(str) {
	return "'" str "'"
}

; #endregion


