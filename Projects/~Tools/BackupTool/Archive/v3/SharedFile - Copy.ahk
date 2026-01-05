; TITLE  :  Sharedfile with Read/Write Sync
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
        If the Server is not responding, functions like IsRead() will error with SharedFile not found.

    SharedFile.txt Attributes
    --------------------------------
     R =  Read-Only =   Read
    -R = !Read-Only	=   Write

*/

#Requires AutoHotkey v2.0+

; PURPOSE : Manages Inter-Process Communication with a Shared File.
; OVERVIEW: Uses the FileAttributes of the shared file to signal "Read" or "Write"  
;               R = Read, -R = Write
; USAGE   : This was designed for a normal user to send a command to a
;               Windows Service running as Admin.
;           The Service then runs a process that requires Admin.
;           No more pesky UAC popus for my Backups!
; TYPE      : "Server" is typically a Windows Service always running that receives commands from the Client.
;               The Server creates and destroys the SharedFile.
;           : "Task" is run by, and receives commands from,  the Client.
;               The Client creates and destroys the SharedFile.
;           ; "Client" Sends commands to the Server or Task then recevied their StdOutErr
;------------------------------------------------------------------------------------------------------------------------------
class SharedFile {

    Type            := "Server" ; 'Client', 'Server', or 'Task'
    DefaultPath     := EnvGet("PROGRAMDATA") "\SharedFile\SharedFile.txt"
    SharedFilePath  := ""
    FileEncodingEx  := "UTF-16"

    __New(Type:="Server", NewSharedFilePath:=" ") { ; this.DefaultPath) {

        this.Type := Type
        
        if (Type = "Server") {
            this.CreateSharedFile(NewSharedFilePath)            
            this.SetWriteReady() ; Wait forever until Client writes a command
        } else (
            this.SharedFilePath:= NewSharedFilePath
        )
    }

    ; Clear contents of the SharedFile
    Clear() {
        FileSetAttrib("-R", this.SharedFilePath)
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write("")
        f.Close()
        this.SetWriteReady()
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

    IsWriteReady() {
        FileAttributes := FileGetAttrib(this.SharedFilePath)
        if (InStr(FileAttributes, "R") = 0)
            return true
        else
            return false
    }

    IsReadReady() {
        FileAttributes := FileGetAttrib(this.SharedFilePath)
        if (InStr(FileAttributes, "R") > 0)
            return true
        else
            return false
    }

    SetWriteReady() {
        FileAttributes := FileGetAttrib(this.SharedFilePath)
        if (InStr(FileAttributes, "R") > 0)
            FileSetAttrib("-R", this.SharedFilePath)
    }

    SetReadReady() {
        FileAttributes := FileGetAttrib(this.SharedFilePath)
        if (InStr(FileAttributes, "R") = 0)
            FileSetAttrib("+R", this.SharedFilePath)
    }

    ResetReady() {
        FileAttributes := FileGetAttrib(this.SharedFilePath)
        if (InStr(FileAttributes, "R") = 0)
            FileSetAttrib("+R", this.SharedFilePath)
        else
            FileSetAttrib("-R", this.SharedFilePath)
    }

    ; success=true, timeout=false, don't wait=0Ms, wait forever=-1Ms
    WaitWriteReady(TimeoutMs:=-1) {

        ; If no wait then return IsWrite() true or false
        if (TimeoutMs = 0) {
            return this.IsWriteReady() ? true : false
        }

        ; Wait until a different process SetWrite()
        StartTime := A_TickCount
        EndTime := StartTime + TimeoutMs

        Loop {

            if (this.IsWriteReady()) {
                returnValue:= true
                break
            }

            if (TimeoutMs!=-1) and (A_TickCount >= EndTime) {
                returnValue:= false
                break
            }
            Sleep 100
        }
        return returnValue

    }

    ; success=true, timeout=false, don't wait=0Ms, wait forever=-1Ms
    WaitReadReady(TimeoutMs:=-1) {

        ; If no wait then return IsRead() true or false
        if (TimeoutMs = 0) {
            return this.IsReadReady() ? true : false
        }

        ; Wait until a different process SetWrite()
        StartTime := A_TickCount
        EndTime := StartTime + TimeoutMs

        Loop {

            if (this.IsReadReady()) {
                returnValue:= true
                break
            }

            if (TimeoutMs!=-1) and (A_TickCount >= EndTime) {
                returnValue:= false
                break
            }
            Sleep 100
        }
        return returnValue

    }

    Read(ResetReady:=True) {
        f:= FileOpen(this.SharedFilePath, "r")
        text:= f.Read()
        f.Write("")
        f.Close()
        if (ResetReady)
            this.ResetReady()
        return text
    }

    Write(text, ResetReady:=True) {
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write(text)
        f.Close()
        if (ResetReady)
            this.ResetReady()
    }

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
    }

    DeleteSharedFile() {
        if FileExist(this.SharedFilePath) {
           this.SetWriteReady()
           FileDelete(this.SharedFilePath)
        }
    }

    __Delete() {

        if (this.Type = "Server")
            this.DeleteSharedFile()
        }
}
