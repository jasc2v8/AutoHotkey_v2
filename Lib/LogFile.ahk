; TITLE  :  LogFileHelper v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

class LogFile
{

    LogFilePath := ""
    Label       := ""
    Disabled    := false

    __New(LogFilePath:="", Label:="", Enabled:=true)
    {
        if LogFilePath
            this.LogFilePath := LogFilePath
        else
            this.LogFilePath := "D:\LogFile.txt"

        if Label
            this.Label := Label
        else
            this.Label := "DEBUG"

        this.Disabled := !Enabled
    }

    Clear()
    {
        this.Delete()
        FileAppend("", this.LogFilePath)
    }

    Delete()
    {
        if FileExist(this.LogFilePath)
            FileDelete(this.LogFilePath)
    }

    Disable(Bool:=true)
    {
        this.Disabled := Bool
    }

    Write(Message, Label:=this.Label)
    {
        if (this.Disabled)
            return

        msg:= FormatTime(A_Now, "HH:mm:ss") . ":" . A_MSec . " " Label . ": " . Message . "`n"

        FileAppend(msg, this.LogFilePath)
    }

    Save()
    {
        newPath:= StrReplace(this.LogFilePath, ".txt", "_" FormatTime(A_Now, "HH_mm_ss") ".txt")

        if FileExist(this.LogFilePath)
            FileMove(this.LogFilePath, newPath)

    }
}
