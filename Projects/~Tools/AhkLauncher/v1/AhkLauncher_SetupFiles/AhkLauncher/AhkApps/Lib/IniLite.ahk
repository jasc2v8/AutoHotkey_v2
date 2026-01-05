; TITLE IniLite

#Requires AutoHotkey v2.0

#Include <String>

;------------------------------------------------------
; INI := IniLite(Path)
; Path property
; Read(section, key)
; ReadSettings(key)
; ReadSection(section)
; ReadSectionNames()
; Write(section, key, value)
; WriteSettings(key, value)
;------------------------------------------------------
class IniLite
{
    Path := ''

    __New(IniFilePath:="")
    {
        if IniFilePath = "" {
            IniFilePath := A_ScriptFullPath.SplitPath().NameNoExt ".ini"
        } else {
            SplitPath(IniFilePath,, &IniDir)
            if !DirExist(IniDir)
            DirCreate(IniDir)
        }

        if !FileExist(IniFilePath)
            FileAppend("[Settings]`r`n", IniFilePath)
            ;FileAppend("INI_PATH=" IniFilePath "`r`n", IniFilePath)
            
        this.Path := IniFilePath

        ;MsgBox this.Path, "IniLite"
	}

    GetPath() => this.Path

    Read(section, key) {

        try {
            if FileExist(this.Path) {
                return IniRead(this.Path, section, key)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    ReadSection(section) {
        try {
            if FileExist(this.Path) {
                return IniRead(this.Path, section)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    ReadSectionNames() {
        try {
            if FileExist(this.Path) {
                return IniRead(this.Path)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

	ReadSettings(key) {
        try {
            if FileExist(this.Path) {
        		return IniRead(this.Path, "Settings", key)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    Write(section, key, value) {
		try {
			if FileExist(this.Path) {
				IniWrite(value, this.Path, section, key)
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
            if FileExist(this.Path) {
                return IniWrite(value, this.Path, "Settings", key )
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

        Path := A_Temp "\default.ini"

        if !FileExist(Path) {
            FileAppend("[Settings]`r`n", Path)
            FileAppend("INI_PATH=" Path "`r`n", Path)
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

        ;Run("notepad " INI.Path)

        ;Run("explore " A_ScriptDir)
    }

    Test3() {
    
        AhkAppsDir := '' ;A_ScriptDir
        Path := ''

        defaultAhkAppsDir := A_ScriptDir
        defaultPath := defaultAhkAppsDir "]default.ini"

        OutputDebug("defaultPath: " defaultPath)

        ;optional
        if FileExist(defaultPath)
            FileDelete(defaultPath)

        INI := IniLite(defaultPath)

        if FileExist(defaultPath) {

            path := INI.ReadSettings("Path")

            if (path = '') {
                Path := defaultPath
                INI.WriteSettings("Path", Path)
            }

            value := INI.ReadSettings("AhkAppsDir")

            if (value = '') {
                AhkAppsDir := defaultAhkAppsDir
                INI.WriteSettings("AhkAppsDir", AhkAppsDir)
            }

        } else {     
            AhkAppsDir := defaultAhkAppsDir
            Path := defaultPath
            FileAppend("[Settings]`r`n", Path)
            FileAppend("AhkAppsDir=" AhkAppsDir "`r`n", Path)
            FileAppend("Path=" Path "`r`n", Path)
        }

        OutputDebug("Initialize: AhkAppsDir:" AhkAppsDir)
        OutputDebug("Initialize: Path   :" Path)

        ;INI.WriteSettings("AhkAppsDir", "c:\windows\test")

        OutputDebug(INI.ReadSettings("AhkAppsDir"))
        OutputDebug(INI.ReadSettings("Path"))

    }

    #Warn Unreachable, Off
}
