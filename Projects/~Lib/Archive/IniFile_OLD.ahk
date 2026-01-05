#Requires AutoHotkey v2.0

/*
	This is a very lighweight Ini class that implements:
		_New(iniPath)
		Read(section, key, value)
		ReadSection(section)
		ReadSectionNames()

		Write(section, key, value)
		WriteSettings(key, value) ; section := "Settings"
		*WritePairs(section, pairs) ; pairs := "NAME=JANE DOE"

		*=Problem noted in example below
	TODO
		Really no plan to make this more comprehensive
*/

class IniFile
{
    MyIniPath := ''
   
    __New(iniPath)
    {
		this.MyIniPath := iniPath

		if !FileExist(iniPath) {
            try {
                SplitPath(iniPath, &FileName, &Dir)

                MsgBox("DEBUG DirCreate: " Dir, "DEBUG", "OK Icon!")
                DirCreate(Dir)
                FileAppend("[Settings]", this.MyIniPath)
            } catch Error as e {
                Throw("ERROR creating ini file: " e.Message)
            }
		}
    }

    Read(section, key) {
        try {
            if FileExist(this.MyIniPath) {
                return IniRead(this.MyIniPath, section, key)
            } else {
                return ; default is ''
            }
        } catch Error as e {
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

    ; IniWrite(MyValue, iniPath", Section, Key) writes 
    ; For example,
    ; IniWrite("MyValue", "C:\Settings.ini", "User", "Name") writes 
    ; "MyValue" to the Name key in the [User] section of C:\Settings.ini
    ; Pairs: IniWrite(Pairs, Filename, Section)
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
		r := this.Write("Settings", key, value) 
		return r
	}
}

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    DoTest()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
DoTest() {

    ;MsgBox("DEBUG NOT IMPLEMENTED", "IniFile_Class", "OK Icon!")
    
    iniPath := A_Temp "\~IniFileExample\IniFileExample.ini"

    INI := IniFile(iniPath)

    ; Note WritePairs must come first in the series as it erases all
    INI.WritePairs("settings", "Random0=" Random(0, 10))

    INI.Write("settings", "Random1", Random(10, 100))

    INI.Write("settings", "Random2", Random(100, 200))

    INI.WriteSettings("Random3", Random(300, 400))

    ;WARNING this will overwrite everyting in the ini file
    ;   Note WritePairs must come first in the series
    ; INI.WritePairs("settings", "Random4=" Random(0, 10))

    MsgBox( "Random0: " INI.Read("settings", "Random0") "`n`n"  . 
            "Random1: " INI.Read("settings", "Random1") "`n`n"  . 
            "Random2: " INI.Read("settings", "Random2") "`n`n" .
            "Random3: " INI.Read("settings", "Random3") "`n`n" .
            "Random4: " INI.Read("settings", "Random4"),
            "IniFileExample", "OK Icon!")

    INI.Write("Settings_2", "Random1", Random(10, 100))
    INI.Write("Settings_3", "Random1", Random(10, 100))
    INI.Write("Settings_4", "Random1", Random(10, 100))

    text := INI.ReadSection("settings")
    MsgBox( "[Settings] = `n" . text, "IniFileExample", "OK Icon!")

    text := INI.ReadSectionNames()
    MsgBox( "SectionNames = `n" . text, "IniFileExample", "OK Icon!")

    Run("notepad " INI.MyIniPath)

    Run("explore " A_Temp)
}
