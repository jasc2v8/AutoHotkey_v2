; TITLE Initial version

#Requires AutoHotkey v2.0

/*
	This is a lighweight Ini class that implements:
		_New(iniPath)
		Read(section, key)
		ReadSettings(key) ; section := "Settings"
		ReadSection(section)
		ReadSectionNames()

		Write(section, key, value)
		WriteSettings(key, value) ; section := "Settings"
*/
;------------------------------------------------------
; INI := IniLite(iniPath)
;------------------------------------------------------
class IniLite
{
    IniPath := ''

    __New(IniFilePath:="")
    {
        ; If no iniPath given, create a defaul one.
        if IniFilePath = "" {
            IniFilePath := A_Temp "\default.ini"
            if FileExist(IniFilePath)
                FileDelete(IniFilePath)
            FileAppend("[Settings]`r`n", IniFilePath)
            FileAppend("INI_PATH=" IniFilePath "`r`n", IniFilePath)
        } else {
            if !FileExist(IniFilePath)
                Throw "Error - Invalid IniFilePath."

            SplitPath(IniFilePath, &IniName, &IniDir)

            if !DirExist(IniDir)
                DirCreate(IniDir)
        }

        this.IniPath := IniFilePath

	}

    Read(section, key) {

        try {
            if FileExist(this.IniPath) {
                return IniRead(this.IniPath, section, key)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    ReadSection(section) {
        try {
            if FileExist(this.IniPath) {
                return IniRead(this.IniPath, section)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    ReadSectionNames() {
        try {
            if FileExist(this.IniPath) {
                return IniRead(this.IniPath)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

	ReadSettings(key) {
        try {
            if FileExist(this.IniPath) {
        		return IniRead(this.IniPath, "Settings", key)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    Write(section, key, value) {
		try {
			if FileExist(this.IniPath) {
				IniWrite(value, this.IniPath, section, key)
				return true
			} else {
				return false
			}
		} catch Error as e {
			return false
		}
	}
	
	WriteSettings(key, value) {
                try {
            if FileExist(this.IniPath) {
                return IniWrite(value, this.IniPath, "Settings", key )
            } else {
                return false
            }
        } catch Error as e {
            return false
        }
	}
}

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    DoTest_IniLite()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
DoTest_IniLite() {

    #Warn Unreachable

    SoundBeep(), ExitApp()

    ; comment out tests to skip:
    ;Test1()
    Test2()
    ;Test3()

    ; test methods

    Init_Tests() {

        iniPath := A_Temp "\default.ini"

        if !FileExist(iniPath) {
            FileAppend("[Settings]`r`n", iniPath)
            FileAppend("INI_PATH=" iniPath "`r`n", iniPath)
        }
    }

    Test1() { 
        ; Create default ini file
        INI := IniLite()
        MsgBox  "Sections: " INI.ReadSectionNames() "`n`n" . 
                "Key: " "INI_PATH" "`n`n" . "Value:`n`n" INI.ReadSettings("INI_PATH"), "Defaults"
    }

    Test2() {

        INI := IniLite()
 
        error := INI.Read("Settings", "Non-Existant-Key")

        ; not exist so return ''
        r := MsgBox("Attempt to read non-existant key:`n`nResult: [" error "]", "Non-Existant Key", "OKCancel")
        r = 'Cancel' ? ExitApp() : nop := true

        Loop 5
            INI.WriteSettings("Key" A_Index, "Value" A_Index)

        Loop 5
            INI.Write("RandomNumbers", "Random" A_Index, Random(10, 100))

        text := INI.ReadSectionNames()
        r := MsgBox("SectionNames:`n`n" text, "IniLiteExample", "OKCancel")
        r = 'Cancel' ? ExitApp() : nop := true

        ; message := ""
        ; Loop 5 {
        ;     message .= INI.Read("Settings", "Key" A_Index)
        ; }
        ;MsgBox( message, "IniLiteExample", "OK Icon!")

        text := INI.ReadSection("sEtTiNgS")
        r := MsgBox("[Settings]`n`n" text, "IniLiteExample", "OKCancel")
        r = 'Cancel' ? ExitApp() : nop := true

        message := ""
        Loop 5
            message .= "Key" A_Index "=" INI.Read("Settings", "Key" A_Index) "`n"
        r := MsgBox(message, "Settings", "OKCancel Icon!")
        r = 'Cancel' ? ExitApp() : nop := true

        text := INI.ReadSection("RANDOMNUMBERS")
        r := MsgBox("[RandomNumbers]`n`n" text, "IniLiteExample", "OKCancel")
        r = 'Cancel' ? ExitApp() : nop := true

        message := ""
        Loop 5
            message .= "Random" A_Index "=" INI.Read("RandomNumbers", "Random" A_Index) "`n"
        MsgBox( message, "RandomNumbers", "OK Icon!")

        ;Run("notepad " INI.IniPath)

        ;Run("explore " A_ScriptDir)
    }

    Test3() {
    
        AhkAppsDir := '' ;A_ScriptDir
        IniPath := ''

        defaultAhkAppsDir := A_ScriptDir
        defaultIniPath := defaultAhkAppsDir "]default.ini"

        OutputDebug("defaultIniPath: " defaultIniPath)

        ;optional
        if FileExist(defaultIniPath)
            FileDelete(defaultIniPath)

        INI := IniLite(defaultIniPath)

        if FileExist(defaultIniPath) {

            path := INI.ReadSettings("IniPath")

            if (path = '') {
                IniPath := defaultIniPath
                INI.WriteSettings("IniPath", IniPath)
            }

            value := INI.ReadSettings("AhkAppsDir")

            if (value = '') {
                AhkAppsDir := defaultAhkAppsDir
                INI.WriteSettings("AhkAppsDir", AhkAppsDir)
            }

        } else {     
            AhkAppsDir := defaultAhkAppsDir
            IniPath := defaultIniPath
            FileAppend("[Settings]`r`n", IniPath)
            FileAppend("AhkAppsDir=" AhkAppsDir "`r`n", IniPath)
            FileAppend("IniPath=" IniPath "`r`n", IniPath)
        }

        OutputDebug("Initialize: AhkAppsDir:" AhkAppsDir)
        OutputDebug("Initialize: IniPath   :" IniPath)

        ;INI.WriteSettings("AhkAppsDir", "c:\windows\test")

        OutputDebug(INI.ReadSettings("AhkAppsDir"))
        OutputDebug(INI.ReadSettings("IniPath"))

    }

    #Warn Unreachable, Off
}
