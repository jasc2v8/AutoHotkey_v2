; ABOUT  :  Sharedfile v1.0 (with Sent/Received Sync)
; SOURCE :  jasc2v8 12/24/2025
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    SharedFile.txt Attributes
    -------------------------
     A = Sent
    -A = Received

    SharedFile PsuedoCode
    -------------------------
    SERVER:
    Create()
    SetReceived()
    Loop
        WaitSent
            Read
            SetReceived
        Do Work
        Write Reply
            Write
            SetSent
            WaitReceived
    Loop

    CLIENT:
    Loop
        ; not needed: WaitReceived
        Write request
            Write
            SetSent
            WaitReceived
        Read reply
            WaitSent
            Read
            SetReceived
    Loop

*/

#Requires AutoHotkey v2.0+

; PURPOSE : Manages Inter-Process Communication with a Shared File.
; OVERVIEW: Uses the FileAttributes of the shared file to signal "Sent" or "Received". (A=Sent, -A=Received)
; USAGE   : Enables a normal user to send a command to a Windows Service or Task running as Admin.
;           The Service or Task then runs a process that requires Admin and bypasses the UAC prompt.
; TYPE    : "Server" is typically a Windows Service always running that receives commands from the Client.
;           "Server" can also be an on-demand task scheduled in the Task Scheduler.
;           "Server" creates and destroys the SharedFile.
;           "Client" sends commands to the Server or Task then recevies it's StdOutErr.
;-----------------------------------------------------------------------------------------------------------
class SharedFile {

    DefaultPath     := EnvGet("TEMP") "\AHK_SharedFile.txt"
    DefaultEncoding := "UTF-16"

    Role            := "" ; 'Server' or 'Client'
    SharedFilePath  := ""

    __New(Role:="Server", NewSharedFilePath:=this.DefaultPath, Encoding:=this.DefaultEncoding) {

        this.Role:= Role

        if (NewSharedFilePath!="")
            this.SharedFilePath:= NewSharedFilePath

        FileEncoding Encoding

        if (this.Role = "Server") {
            this.Create(NewSharedFilePath)
            this.SetReceived()
        }
    }

    ; Create a new SharedFile if not exist, grant access to 'everyone', SetFull()
    Create(NewSharedFilePath) {
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

    Delete() {
        if FileExist(this.SharedFilePath) {
           FileDelete(this.SharedFilePath)
        }
    }
    
    Exist() {
        return FileExist(this.SharedFilePath)
    }

    Clear() {
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write("")
        f.Close()
        this.SetSent()
    }

    GetAttributes(FilePath) {
        return FileGetAttrib(FilePath)
    }

    IsSent() {
        FileAttributes := FileGetAttrib(this.SharedFilePath)
        if (InStr(FileAttributes, "A") > 0)
            return true
        else
            return false
    }

    SetSent() {
        FileSetAttrib "A", this.SharedFilePath
        Loop {
            if (this.IsSent())
                break
            else
                Sleep 100
        }
    }

    IsReceived() {
        FileAttributes := FileGetAttrib(this.SharedFilePath)
        if (InStr(FileAttributes, "A") = 0)
            return true
        else
            return false
    }

    SetReceived() {
        FileSetAttrib "-A", this.SharedFilePath
        Loop {
            if (!this.IsSent())
                break
            else
                Sleep 100
        }
    }

    ; timeout=true, success=false, don't wait=0Ms, wait forever=-1Ms
    WaitSent(TimeoutMs:=-1) {

        StartTime := A_TickCount
        EndTime := StartTime + TimeoutMs

        Loop {

            if (this.IsSent()) {
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
    WaitReceived(TimeoutMs:=-1) {

        StartTime := A_TickCount
        EndTime := StartTime + TimeoutMs

        Loop {

            if (this.IsReceived()) {
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
        this.WaitSent(-1)
        f:= FileOpen(this.SharedFilePath, "r")
        text:= f.Read()
        f.Write("")
        f.Close()
        this.SetReceived()
        return text
    }

    Write(text) {
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write(text)
        f.Close()
        this.SetSent()
        this.WaitReceived(-1)
    }

    __Delete() {
        if (this.Role = "Server")
            this.Delete()
    }
}
