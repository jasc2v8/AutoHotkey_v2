; ABOUT  :    MailBox v0.1
; SOURCE :  
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    MailBox.txt
    --------------------------------
     R = Read-Only	Ready	  (Full) 	
    -R = Read-Write	Not Ready (Empty)
*/

#Requires AutoHotkey v2.0

; PURPOSE : Manages Inter-Process Communication with a Shared File.
; OVERVIEW: Uses the FileAttributes of the shared file to signal "Buffer Full" or "Buffer Empty"  
;           R = Read-Only  = Buffer Full
;           -R = Read-Write = Buffer Empty
; USAGE   : This was designed for a Windows Service runnin as Admin to run Backups (requires Admin)
;           The user Control Gui runs with normal user privs.
;           No more pesky UAC popus for my Backups!
;-------------------------------------------------------------
class MailBox {

    ClientOrServer  := "Server"
    SharedFileDir   := A_AppDataCommon "\AhkApps\MailBox\"
    SharedFileName  := "MyMailBox.txt"
    SharedFilePath:= this.GetFilePath(this.SharedFileName)
    FileEncodingEx:= "UTF-16"

    __New(ClientOrServer:="Server") {

        this.ClientOrServer := ClientOrServer
        
        FileEncoding this.FileEncodingEx

        if (ClientOrServer = "Client") {

            if  !FileExist(this.SharedFilePath) {
                MsgBox( "Shared files not found.`n`nServer must be started first.`n`nPress OK to Exit.", 
                        "Shared Files Error", "iconX")
                ExitApp()
            }

        } else if (ClientOrServer = "Server") {

            SplitPath(this.SharedFilePath, , &OutDir)
            if !DirExist(OutDir) {
                DirCreate(OutDir)
            }

            if !FileExist(this.SharedFilePath) {
                f:= FileOpen(this.SharedFilePath, "w")
                f.Close()
            }

        } else {
            Throw "Error: Must specify 'Client' or 'Server'."
        }
    }

    ; Clear contents of the MailBox
    Clear() {
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write("")
        f.Close()
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

     GetFilePath(FileName) {
        dir := StrReplace(this.SharedFileDir . "\", "\\", "\")
        return dir . FileName
    }

    IsEmpty() {
            FileAttributes := FileGetAttrib(this.SharedFilePath)
            if (InStr(FileAttributes, "R") = 0)
                return true
            else
                return false
    }

    IsFull() {
            FileAttributes := FileGetAttrib(this.SharedFilePath)
            if (InStr(FileAttributes, "R") > 0)
                return true
            else
                return false
    }

    SetMailRead() {
            ;FileAttributes := FileGetAttrib(this.SharedFilePath)
            ;if (InStr(FileAttributes, "R") = 0)
                FileSetAttrib("-R", this.SharedFilePath)
    }

    SetNewMail() {
            ;FileAttributes := FileGetAttrib(this.SharedFilePath)
            ;if (InStr(FileAttributes, "R") = 0)
                FileSetAttrib("+R", this.SharedFilePath)
    }

    ; success=true, timeout=false, don't wait=0Ms, wait forever=-1Ms
    WaitMailRead(TimeoutMs:=-1) {

        ; If no wait then reutrn IsEmpty() true or false
        if (TimeoutMs = 0) {
            return this.IsEmpty() ? true : false
        }

        ; Wait until a different process SetMailRead()
        StartTime := A_TickCount
        EndTime := StartTime + TimeoutMs

        Loop {

            if (this.IsEmpty()) {
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
    WaitNewMail(TimeoutMs:=-1) {

        ; If no wait then reutrn IsFull() true or false
        if (TimeoutMs = 0) {
            return this.IsFull() ? true : false
        }

        ; Wait until a different process SetMailRead()
        StartTime := A_TickCount
        EndTime := StartTime + TimeoutMs

        Loop {

            if (this.IsFull()) {
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

    ReadMail() {
        f:= FileOpen(this.SharedFilePath, "r")
        text:= f.Read()
        f.Write("")
        f.Close()
        this.SetMailRead()
        return text
    }

    SendMail(text) {
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write(text)
        f.Close()
        this.SetNewMail()
    }

    __Delete() {

        ; if the Client exits, do NOT delete the shared files
        if (this.ClientOrServer = "Client")
            return

        if FileExist(this.SharedFilePath) {
           this.SetMailRead()
           FileDelete(this.SharedFilePath)
        }
    }
}
