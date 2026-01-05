; ABOUT  :  Sharedfile with Enmpty/Full Sync
; SOURCE :  jasc2v8 12/15/2025
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    SharedFile.txt Attributes
    -------------------------
     A = Full
    -A = Empty

*/

#Requires AutoHotkey v2.0+

; PURPOSE : Manages Inter-Process Communication with a Shared File.
; OVERVIEW: Uses the FileAttributes of the shared file to signal "Full" or "Empty". (A = Full, -A = Empty)
; USAGE   : Enables a normal user to send a command to a Windows Service or Task running as Admin.
;           The Service or Task then runs a process that requires Admin and bypasses the UAC prompt.
; TYPE    : "Server" is typically a Windows Service always running that receives commands from the Client.
;           "Server" can also be an on-demand task scheduled in the Task Scheduler.
;           "Server" creates and destroys the SharedFile.
;           "Client" sends commands to the Server or Task then recevies it's StdOutErr.
;-----------------------------------------------------------------------------------------------------------
class SharedFile {

    Type            := "Server" ; 'Server' or 'Client'
    DefaultPath     := EnvGet("PROGRAMDATA") "\AutoHotkey\SharedFile\SharedFile.txt"
    SharedFilePath  := ""
    FileEncodingEx  := "UTF-16"

    __New(Type:="Server", NewSharedFilePath:=this.DefaultPath) {

        this.Type := Type
        
        if (Type = "Server") {
            this.CreateSharedFile(NewSharedFilePath)            
        } else (
            this.SharedFilePath:= NewSharedFilePath
        )

        this.SetEmpty()
    }

    ; Create a new SharedFile if not exist, grant access to 'everyone', SetFull()
    CreateSharedFile(NewSharedFilePath) {
        SplitPath(NewSharedFilePath, , &OutDir)
        if !DirExist(OutDir) {
            DirCreate(OutDir)
        }
        if !FileExist(NewSharedFilePath) {
            f:= FileOpen(NewSharedFilePath, "w")
            f.Close()
        }
        this.SharedFilePath:= NewSharedFilePath
        Run 'icacls ' this.SharedFilePath ' /grant "Everyone:F'
        ; short wait for changes to take effect
        Sleep 200
    }

    DeleteSharedFile() {
        if FileExist(this.SharedFilePath) {
           this.SetFull()
           FileDelete(this.SharedFilePath)
        }
    }
    
    ; Clear contents of the SharedFile
    Clear() {
        FileSetAttrib("-R", this.SharedFilePath)
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write("")
        f.Close()
        this.SetFull()
    }

    ; Convert string and number variables into a CSV string
    ConvertToCSV(Params*) {
        myString:= ""
        for item in Params {
            if IsSet(item)
                myString .= item . ","
        }
        return RTrim(myString, ",")
    }

    GetFileAttributes(FilePath) {
        return FileGetAttrib(FilePath)
    }

    IsFull() {
        FileAttributes := FileGetAttrib(this.SharedFilePath)
        if (InStr(FileAttributes, "A") > 0)
            return true
        else
            return false
    }

    IsEmpty() {
        FileAttributes := FileGetAttrib(this.SharedFilePath)
        if (InStr(FileAttributes, "A") = 0)
            return true
        else
            return false
    }

    SetFull() {
        FileSetAttrib "A", this.SharedFilePath
    }

    SetEmpty() {
        FileSetAttrib "-A", this.SharedFilePath
    }

    ReSetFull(Reset:=true) {
        if (Reset) {
            FileSetAttrib "^A", this.SharedFilePath
        }
    }

    ; timeout=true, success=false, don't wait=0Ms, wait forever=-1Ms
    WaitFull(TimeoutMs:=-1) {

        StartTime := A_TickCount
        EndTime := StartTime + TimeoutMs

        Loop {

            if (this.IsFull()) {
                returnValue:= false
                break
            }

            if (TimeoutMs!=-1) and (A_TickCount >= EndTime) {
                returnValue:= true
                break
            }
            Sleep 100
        }
        return returnValue

    }

    ; timeout=true, success=false, don't wait=0Ms, wait forever=-1Ms
    WaitEmpty(TimeoutMs:=-1) {

        StartTime := A_TickCount
        EndTime := StartTime + TimeoutMs

        Loop {

            if (this.IsEmpty()) {
                returnValue:= false
                break
            }

            if (TimeoutMs!=-1) and (A_TickCount >= EndTime) {
                returnValue:= true
                break
            }
            Sleep 100
        }
        return returnValue

    }

    Read() {
        f:= FileOpen(this.SharedFilePath, "r")
        text:= f.Read()
        f.Write("")
        f.Close()
        return text
    }

    ; timeout=true="", success=false=text, don't wait=0Ms, wait forever=-1Ms
    WaitRead(Timeout:=-1) {

        timedOut:= this.WaitFull(Timeout)

        if (timedOut) {
            this.SetEmpty()
            Sleep 100
            return ""
        } else {
            text:= this.Read()
            this.SetEmpty()
            Sleep 100
            return text
        }
    }

    Write(text) {
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write(text)
        f.Close()
    }

    ; timeout=true="", success=false=text, don't wait=0Ms, wait forever=-1Ms
    WaitWrite(Text, Timeout:=-1) {

        timedOut:= this.WaitEmpty(Timeout)

        if (timedOut) {
            this.SetEmpty()
            Sleep 100
            return true
        } else {
            this.Write(Text)
            this.SetFull()
            Sleep 100
            return false
        }
    }

    __Delete() {

        if (this.Type = "Server")
            this.DeleteSharedFile()
        }
}
