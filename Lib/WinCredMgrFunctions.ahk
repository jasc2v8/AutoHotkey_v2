;ABOUT: Store passwords in scripts securely through Windows Credential Manager API
;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116285
; Search "Manage Windows Credentials" to see the entry


#Requires AutoHotkey v2.0

class CredMgr {
	
	CredWrite(name, username, password) {
		cred := Buffer(24 + A_PtrSize * 7, 0)
		cbPassword := StrLen(password) * 2
		NumPut("UInt", 1               , cred,  4+A_PtrSize*0) ; Type = CRED_TYPE_GENERIC
		NumPut("Ptr",  StrPtr(name)    , cred,  8+A_PtrSize*0) ; TargetName
		NumPut("UInt", cbPassword      , cred, 16+A_PtrSize*2) ; CredentialBlobSize
		NumPut("Ptr",  StrPtr(password), cred, 16+A_PtrSize*3) ; CredentialBlob
		;NumPut("UInt", 3               , cred, 16+A_PtrSize*4) ; Persist = CRED_PERSIST_ENTERPRISE (roam across domain)
		NumPut("UInt", 2               , cred, 16+A_PtrSize*4) ; Persist = CRED_PERSIST_LOCAL_MACHINE (Computer-specificn)
		NumPut("Ptr",  StrPtr(username), cred, 24+A_PtrSize*6) ; UserName
		return DllCall("Advapi32.dll\CredWriteW",
			"Ptr", cred, ; [in] PCREDENTIALW Credential
			"UInt", 0,   ; [in] DWORD        Flags
			"UInt" ; BOOL
		)
	}

	CredDelete(name) {
		return DllCall("Advapi32.dll\CredDeleteW",
			"WStr", name, ; [in] LPCWSTR TargetName
			"UInt", 1,    ; [in] DWORD   Type
			"UInt", 0,    ; [in] DWORD   Flags
			"UInt" ; BOOL
		)
	}

	CredRead(name) {
		pCred := 0
		DllCall("Advapi32.dll\CredReadW",
			"Str",  name,   ; [in]  LPCWSTR      TargetName
			"UInt", 1,      ; [in]  DWORD        Type = CRED_TYPE_GENERIC (https://learn.microsoft.com/en-us/windows/win32/api/wincred/ns-wincred-credentiala)
			"UInt", 0,      ; [in]  DWORD        Flags
			"Ptr*", &pCred, ; [out] PCREDENTIALW *Credential
			"UInt" ; BOOL
		)
		if !pCred
			return
		name := StrGet(NumGet(pCred, 8 + A_PtrSize * 0, "UPtr"), 256, "UTF-16")
		username := StrGet(NumGet(pCred, 24 + A_PtrSize * 6, "UPtr"), 256, "UTF-16")
		len := NumGet(pCred, 16 + A_PtrSize * 2, "UInt")
		password := StrGet(NumGet(pCred, 16 + A_PtrSize * 3, "UPtr"), len/2, "UTF-16")
		DllCall("Advapi32.dll\CredFree", "Ptr", pCred)
		return {name: name, username: username, password: password}
	}
}

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    _Test_WinCredMgrFunctions()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
_Test_WinCredMgrFunctions() {

    #Warn Unreachable, Off

    ; comment out to run tests:
    SoundBeep()
    ;return

	if !CredMgr.CredWrite("AHK_CredForScript1", "SomeUsername", "SomePassword")
		MsgBox "failed to write cred", "CredWrite"

	; pause to see in "Manage Windows Credentials"
	;return

	if (cred := CredMgr.CredRead("AHK_CredForScript1"))
		MsgBox cred.name "," cred.username "," cred.password, "CredRead"
	else
		MsgBox "Cred not found", "CredRead"

	if !CredMgr.CredDelete("AHK_CredForScript1")
		MsgBox "Failed to delete cred", "CredDelete"

	if (cred := CredMgr.CredRead("AHK_CredForScript1"))
		MsgBox cred.name "," cred.username "," cred.password
	else
		MsgBox "Cred not found", "Validate CredDelete Worked"

}
