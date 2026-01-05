; ABOUT IniFile v1.0

/*
    TODO:
        Update tests below
*/

#Requires AutoHotkey v2.0+

;-----------------------------------------------------------------
; USAGE:    INI := IniFile(Path) ; defalult A_ScriptFullPath.ini
;           Read(section, key)
;           ReadSection(section)
;           ReadSectionNames()
;           ReadSettings(key)
;           Write(section, key, value)
;           WriteSettings(key, value)
; RETURNS:  Read:   Success=Value, Error=''
;           Write:  Success=true, Error=false 
;----------------------------------------------------------------
class IniFile
{
    Path := ''

    __New(IniFilePath:="")
    {
        if IniFilePath = "" {
            IniFilePath := this.StrSplitPath(A_ScriptFullPath).NameNoExt ".ini"
        } else {
            SplitPath(IniFilePath,, &IniDir)
            if !DirExist(IniDir)
            DirCreate(IniDir)
        }

        if !FileExist(IniFilePath)
            FileAppend("[Settings]`r`n", IniFilePath)
            
        this.Path := IniFilePath

        return this.GetPath()

	}

    GetPath() => this.Path

    Read(section, key) {

        try {
            if FileExist(this.Path) {
                return IniRead(this.Path, section, key)
            } else {
                return
            }
        } catch Error as e {
            return
        }
	}

    ReadSection(section) {
        try {
            if FileExist(this.Path) {
                return IniRead(this.Path, section)
            } else {
                return
            }
        } catch Error as e {
            return
        }
	}

    ReadSectionNames() {
        try {
            if FileExist(this.Path) {
                return IniRead(this.Path)
            } else {
                return
            }
        } catch Error as e {
            return
        }
	}

	ReadSettings(key) {
        try {
            if FileExist(this.Path) {
        		return IniRead(this.Path, "Settings", key)
            } else {
                return
            }
        } catch Error as e {
            return
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

    StrSplitPath(path) {
        path := StrReplace(path, "\\", "\")
        SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
        SplitPath(Dir,,&ParentDir)
        return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
    }
}

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    DoTest_IniFile()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
DoTest_IniFile() {

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
        INI := IniFile()
        MsgBox  "Sections: " INI.ReadSectionNames() "`n`n" . 
                "Key: " "INI_PATH" "`n`n" . "Value:`n`n" INI.ReadSettings("INI_PATH"), "Defaults"
    }

    Test2() {

        INI := IniFile()
 
        error := INI.Read("Settings", "Non-Existant-Key")

        ; not exist so return ''
        r := MsgBox("Attempt to read non-existant key:`n`nResult: [" error "]", "Non-Existant Key", "OKCancel")
        r = 'Cancel' ? ExitApp() : nop := true

        Loop 5
            INI.WriteSettings("Key" A_Index, "Value" A_Index)

        Loop 5
            INI.Write("RandomNumbers", "Random" A_Index, Random(10, 100))

        text := INI.ReadSectionNames()
        r := MsgBox("SectionNames:`n`n" text, "IniFileExample", "OKCancel")
        r = 'Cancel' ? ExitApp() : nop := true

        ; message := ""
        ; Loop 5 {
        ;     message .= INI.Read("Settings", "Key" A_Index)
        ; }
        ;MsgBox( message, "IniFileExample", "OK Icon!")

        text := INI.ReadSection("sEtTiNgS")
        r := MsgBox("[Settings]`n`n" text, "IniFileExample", "OKCancel")
        r = 'Cancel' ? ExitApp() : nop := true

        message := ""
        Loop 5
            message .= "Key" A_Index "=" INI.Read("Settings", "Key" A_Index) "`n"
        r := MsgBox(message, "Settings", "OKCancel Icon!")
        r = 'Cancel' ? ExitApp() : nop := true

        text := INI.ReadSection("RANDOMNUMBERS")
        r := MsgBox("[RandomNumbers]`n`n" text, "IniFileExample", "OKCancel")
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

        INI := IniFile(defaultPath)

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
