#Requires AutoHotkey v2.0

/*
	TODO

	Change From: IniFile.Write("settings", "tickcount", A_TickCount)

	Change To:
				IniWrite Value, Filename, Section, Key
				IniFile.Write(A_TickCount,"settings", "tickcount", )

				Value := IniRead(Filename, Section, Key [, Default])
				IniFile.Read("settings", "tickcount",  A_TickCount)
*/

#SingleInstance force
;#NoTrayIcon

#Include "..\Lib\IniFile_Static.ahk"

; define ini file path
iniPath := A_Temp "\~IniFileExample\IniFileExample.ini"

; create ini file
resultCode := IniFile.Initialize(iniPath)

if (!resultCode) {
	MsgBox("DEBUG ERROR FROM IniFile.Initialize(iniPath)")
	ExitApp()
}

; write [SECTION] and [KEY=VALUE]
IniFile.Write("settings", "tickcount", A_TickCount)

; read [SECTION] and [KEY=VALUE]
tickCount := IniFile.Write("settings", "tickcount", A_TickCount)

value := IniFile.Read("settings", "tickcount")

; show result
MsgBox("tickCount: " value, "IniFileExample", "OK Icon!")

; ; get new values from user
; section := InputBox("Enter New Section name ", "New Section",,"ID")
; if (section.Result == 'Cancel')
; 	ExitApp()

; keyObj := InputBox("Enter New Key", "New Key",,"NAME")
; if (keyObj.Result == 'Cancel')
; 	ExitApp()

; valueObj := InputBox("Enter New Value", "New Value",,"Jane Doe")
; if (valueObj.Result == 'Cancel')
; 	ExitApp()

; message := "Entered:" .
; 		"`n`nSection: " section.Value .
; 		"`n`nKey: " keyObj.Value . 
; 		"`n`nValue: " valueObj.Value

; MsgBox(message, "IniFileExample", "OK Icon!")

; IniFile.Write(section.Value, keyObj.Value, valueObj.Value)

IniFile.Write("Settings", "NAME1", "Jane Doe")

IniFile.Append("Settings", "NAMEAPPEND", "Jane Doe")

IniFile.WriteSettings("NAME2", "John Doe")

IniFile.WritePairs("Settings", "NAME3=Jane Smith")

Run("notepad " IniFile.MyIniPath)

run("explore " A_Temp)
