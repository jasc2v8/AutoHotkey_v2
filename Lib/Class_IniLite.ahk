; ABOUT Initial version
#Requires AutoHotkey v2.0

 #Include <String>
/*
	This is a very lighweight Ini class that implements:
		_New(iniPath)
		Read(section, key)
		ReadSection(section)
		ReadSectionNames()

		Write(section, key, value)
		WriteSettings(key, value) ; section := "Settings"
		*WritePairs(section, pairs) ; pairs := "NAME=JANE DOE"

		*=ProblemS noted in example below
	TODO
		Really no plan to make this more comprehensive
*/

class IniLite
{
    IniPath := ''

    static privateVar := 'private'

    __New(IniFilePath)
    {
        this.IniPath := IniFilePath

        if FileExist(this.IniPath)
            return

        if !DirExist(StrSplitPath(this.IniPath).Dir)
            return

    ;OutputDebug("defaultPath: " defaultPath)

        this.IniPath := IniFilePath

        DirCreate(StrSplitPath(this.IniPath).Dir)

        FileAppend("[Settings]`r`n", this.IniPath)

        ;FileAppend("IniPath=" this.IniPath "`r`n", this.IniPath)
	}

    ; static example
    static _GetIniPath() {
        return this.privateVar
    }

    ; LogOut(Message:='') {

    ;     static  LogPath := IniPath := StrSplitPath(A_ScriptFullPath).Dir "\IniLite.log"

    ;     FileAppend(Message "`n", LogPath)
    ; }

    Read(section, key) {

        try {
            if FileExist(this.IniPath) {
                return IniRead(this.IniPath, section, key)
            } else {
                return ; default is ''
            }
        } catch Error as e {

            ;this.LogOut("INI READ ERROR " e.Message)

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
	
    WritePairs(section, pairs) {
        try {
            if FileExist(this.IniPath) {
                IniWrite(pairs, this.IniPath, section) 
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

#Include <Class_LogLite>

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    DoTest_IniLite()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
DoTest_IniLite() {

    #Warn Unreachable
        Run_Tests := true

    if !Run_Tests
        SoundBeep(), ExitApp()

    ; comment out tests to skip:
    ;Test1()
    ;Test2()
    Test3()

    ; test methods

    Test1() { 

        iniPath := ""

        if FileExist(iniPath)
            FileDelete(iniPath)

        INI := IniLite(iniPath)

        ;INI.LogOut("iniPath: " INI.IniPath)

        defaultPath := INI.Read("Settings", "DefaultPath")

        ; not exist so return ''
        OutputDebug("defaultPath: " defaultPath)

        ; Note WritePairs must come first in the series as it erases all
        INI.WritePairs("RandomNumbers", "Random1=" Random(0, 10))
        INI.Write("RandomNumbers", "Random2", Random(10, 100))
        INI.Write("RandomNumbers", "Random3", Random(100, 200))
        INI.WriteSettings("Random4", Random(300, 400))

        ;WARNING WritePairs can overwrite everyting in the ini file
        ;   Note WritePairs must come first in the series
        ; uncomment to test:
        ;INI.WritePairs("settings", "Random4=" Random(0, 10))

        MsgBox( "Random1: " INI.Read("RandomNumbers", "Random1") "`n`n"  . 
                "Random2: " INI.Read("RandomNumbers", "Random2") "`n`n"  . 
                "Random3: " INI.Read("RandomNumbers", "Random3") "`n`n" .
                "Random4: " INI.Read("Settings", "Random4"),
                "IniLiteExample", "OK Icon!")

        INI.Write("RandomNumbers", "Random1", Random(10, 100))
        INI.Write("RandomNumbers", "Random2", Random(10, 100))
        INI.Write("RandomNumbers", "Random3", Random(10, 100))

        text := INI.ReadSection("settings")
        OutputDebug("[Settings] = `n" text "IniLiteExample")

        text := INI.ReadSectionNames()
        OutputDebug( "SectionNames = `n" text "IniLiteExample")

        Run("notepad " INI.IniPath)

        Run("explore " A_ScriptDir)

        INI := ""

    }

    Test2() {

    }

    Test3() {
    
        AhkAppsDir := '' ;A_ScriptDir
        IniPath := ''

        defaultAhkAppsDir := A_ScriptDir
        defaultIniPath := StrJoin('\', defaultAhkAppsDir, "default.ini")

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
