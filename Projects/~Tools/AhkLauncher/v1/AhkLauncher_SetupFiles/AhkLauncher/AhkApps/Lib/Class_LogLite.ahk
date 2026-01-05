; TITLE Initial version
#Requires AutoHotkey v2.0

/*
	This is a very lighweight Ini class that implements:

		_New(LogPath)

		Write(Tag, Message)

	TODO
		Really no plan to make this more comprehensive
*/

#Include <Path>

class LogLite
{
    static Path := ''
   
    __New(LogFilePath := '')
    {
        if (LogFilePath = '')
            LogFilePath := StrReplace(A_ScriptFullPath, ".ahk", ".log")

		this.Path := LogFilePath

		if FileExist(this.Path)
            FileDelete(this.Path)

        try {

            DirCreate(SplitPathObj(this.Path).Dir)

            TimeStr := FormatTime(A_Now, 'HH:mm:ss')

            FileAppend(TimeStr ": RESET: " this.Path "`n", this.Path)

        } catch Error as e {
            Throw("ERROR creating Log file: " e.Message)
        }

    }

    Delete() {

        try {
            
		if FileExist(this.Path)
            FileDelete(this.Path)

        } catch Error as e {

            Throw("ERROR deleting Log File Directory: " e.Message)
        }
    }

    Debug(Message:='') {
        this.Write(Tag:="DEBUG", Message:='')
    }

    Write(Tag:="DEBUG", Message:='') {

		try {
			if FileExist(this.Path) {
	            TimeStr := FormatTime(A_Now, 'HH:mm:ss')
                FileAppend(TimeStr ": " Tag ": " Message "`n",  this.Path)
				return true
			} else {
				return false
			}
		} catch Error as e {
			Throw("ERROR Writing to Log File: " e.Message)
		}
	}	
}

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    DoTest_LogLite()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
DoTest_LogLite() {

    ;#Warn Unreachable

    ; comment out to run tests:
    SoundBeep()
    return

    ;LogPath := A_Temp "\AhkApps\IniLiteExample\IniLiteExample.ini"

    ;OutputDebug("DEBUG LogPath: " LogPath)

    LOG := LogLite()

    LOG.Write(,"Start...")
    LOG.Write(,"Progress...")
    LOG.Write(,"End...")

    Run("notepad " LOG.Path)

    MsgBox("Press OK to delete log file and exit.`n`n" 
        "The Dir will open to verify the log file is deleted.", 'IniLite')

    LOG.Delete()

    Run("explore " SplitPathObj(LOG.Path).Dir)

    #Warn Unreachable, Off
}
