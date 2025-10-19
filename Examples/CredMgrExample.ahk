
#Requires AutoHotkey 2

#Include <CredMgr>

	if !CredMgr.CredWrite("AHK_CredForScript1", "SomeUsername", "SomePassword")
		MsgBox "failed to write `cred", "CredWrite"

	; pause to see in "Manage Windows Credentials"
	;return

	if (cred := CredMgr.CredRead("AHK_CredForScript1"))
		MsgBox cred.name "," cred.username "," cred.password, "CredRead"
	else
		MsgBox "`Cred not found", "CredRead"

	if !CredMgr.CredDelete("AHK_CredForScript1")
		MsgBox "Failed to delete `cred", "CredDelete"

	if (cred := CredMgr.CredRead("AHK_CredForScript1"))
		MsgBox cred.name "," cred.username "," cred.password
	else
		MsgBox "`Cred not found", "Validate CredDelete Worked"

