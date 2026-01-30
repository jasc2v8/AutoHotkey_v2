; ABOUT  :  SharedFile v1.0 (with Events Sync)
; SOURCE :  jasc2v8 12/30/2025
; LICENSE:  The Unlicense, see https://unlicense.org

#Requires AutoHotkey v2.0+

class SharedFile {

    DefaultPath     := EnvGet("TEMP") "\AHK_SharedFile.txt"
    SharedFilePath  := ""
    Role            := "" ; 'Server' or 'Client'
    IsServer        := false
        
    __New(IsServer:=false, SharedFilePath:=this.DefaultPath) {

        ; Set SharedFilePath
        this.SharedFilePath:= SharedFilePath

        ; If Server then create the SharedFile
        if (IsServer)
            this.Create(this.SharedFilePath) 
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
        ;Sleep 200 ; Short wait for changes to take effect
    }

    Clear() {
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write("")
        f.Close()
    }

    Write(Text) {
        
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write(text)
        f.Close()
    }

    Read() {
        f:= FileOpen(this.SharedFilePath, "r")
        text:= f.Read()
        f.Close()
        return text
    }

    __Delete() {
        if (this.IsServer) and FileExist(this.SharedFilePath) {
            FileDelete(this.SharedFilePath)
        }
    }
}