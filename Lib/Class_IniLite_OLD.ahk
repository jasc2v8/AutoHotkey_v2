; ABOUT Initial version
#Requires AutoHotkey v2.0

#Include <Class_LogLite>

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
    MyIniPath := ''

    __New(iniPath)
    {
  
		static MyIniPath := iniPath

		if !FileExist(iniPath) {

            ;LogOut("Create INI: " iniPath)

            try {
                SplitPath(iniPath, &FileName, &Dir)

            LogOut("Create Dir: " Dir)

                DirCreate(Dir)

            LogOut("Append [Settings]: " MyIniPath)
                FileAppend("[Settings]`n", MyIniPath)

            ; LogOut("Append INI_PATH=" MyIniPath)
            ;     FileAppend("INI_PATH=", MyIniPath "`n")

            LogOut("Append DefaultPath=" MyIniPath)
                FileAppend("DefaultPath=", MyIniPath "`n")

            } catch Error as e {
                Throw("ERROR creating ini file: " e.Message)
            }
		}
    }

    LogOut(Message:='') {
        FileAppend(Message "`n", "Class_IniLite.log")
    }

    Read(section, key) {
        try {
            if FileExist(this.MyIniPath) {
                return IniRead(this.MyIniPath, section, key)
            } else {
                return ; default is ''
            }
        } catch Error as e {

            MsgBox("INI READ ERROR " e.Message)

            return ; default is ''
        }
	}

    ReadSection(section) {
        try {
            if FileExist(this.MyIniPath) {
                return IniRead(this.MyIniPath, section)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    ReadSectionNames() {
        try {
            if FileExist(this.MyIniPath) {
                return IniRead(this.MyIniPath)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    Write(section, key, value) {
		try {
			if FileExist(this.MyIniPath) {
				IniWrite(value, this.MyIniPath, section, key)
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
            if FileExist(this.MyIniPath) {
                IniWrite(pairs, this.MyIniPath, section) 
                return true
            } else {
                return false
            }
        } catch Error as e {
            return false
        }
	}

	WriteSettings(key, value) {
		r := IniWrite("Settings", key, value) 
		return r
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

    iniPath := A_Temp "\AhkApps\IniLiteExample\IniLiteExampleTests.ini"

    INI := IniLite(iniPath)

    INI.LogOut("iniPath: " iniPath)

    if FileExist(iniPath)
        FileDelete(iniPath)

    INI := IniLite(iniPath)

    return

    defaultPath := INI.Read("Settings", "DefaultPath")

    ; Note WritePairs must come first in the series as it erases all
    INI.WritePairs("settings", "Random0=" Random(0, 10))

    INI.Write("settings", "Random1", Random(10, 100))

    INI.Write("settings", "Random2", Random(100, 200))

    INI.WriteSettings("Random3", Random(300, 400))

    ;WARNING WritePairs can overwrite everyting in the ini file
    ;   Note WritePairs must come first in the series
    ; uncomment to test:
    ;INI.WritePairs("settings", "Random4=" Random(0, 10))

    MsgBox( "Random0: " INI.Read("settings", "Random0") "`n`n"  . 
            "Random1: " INI.Read("settings", "Random1") "`n`n"  . 
            "Random2: " INI.Read("settings", "Random2") "`n`n" .
            "Random3: " INI.Read("settings", "Random3") "`n`n" .
            "Random4: " INI.Read("settings", "Random4"),
            "IniLiteExample", "OK Icon!")

    INI.Write("Settings_2", "Random1", Random(10, 100))
    INI.Write("Settings_3", "Random1", Random(10, 100))
    INI.Write("Settings_4", "Random1", Random(10, 100))

    text := INI.ReadSection("settings")
    MsgBox( "[Settings] = `n" . text, "IniLiteExample", "OK Icon!")

    text := INI.ReadSectionNames()
    MsgBox( "SectionNames = `n" . text, "IniLiteExample", "OK Icon!")

    Run("notepad " INI.MyIniPath)

    Run("explore " A_Temp)

    INI := ""

    #Warn Unreachable, Off
}
