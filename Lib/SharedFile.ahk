; ABOUT  :  SharedFile v1.0 (with Events Sync)
; SOURCE :  jasc2v8 12/30/2025
; LICENSE:  The Unlicense, see https://unlicense.org

#Requires AutoHotkey v2.0+

class SharedFile {

    DefaultPath     := EnvGet("TEMP") "\AHK_SharedFile.txt"
    SharedFilePath  := ""
    Role            := "" ; 'Server' or 'Client'
    IsServer        := false
        
    __New(Role:="Client", SharedFilePath:=this.DefaultPath) {

        ; Set Role
        this.Role:= Role

        ; Set SharedFilePath
        this.SharedFilePath:= SharedFilePath

        ; If Server then create the SharedFile
        if (Role="Server") {
            this.IsServer:= true
            this.Create(this.SharedFilePath)
        } else {
            this.IsServer:= false
        }
 
        ; Setup Security Descriptor (Grant Everyone access)
        SD := Buffer(100, 0)
        DllCall("Advapi32\ConvertStringSecurityDescriptorToSecurityDescriptor", "Str", "D:(A;;GA;;;WD)", "UInt", 1, "Ptr*", &pSD := 0, "Ptr", 0)
        SA := Buffer(A_PtrSize == 8 ? 24 : 12, 0)
        NumPut("UInt", SA.Size, SA, 0), NumPut("Ptr", pSD, SA, A_PtrSize)

        ; Setup Events
        this.hEventServer := DllCall("CreateEvent", "Ptr", SA, "Int", 0, "Int", 0, "Str", "SharedFile_Server")
        this.hEventClient := DllCall("CreateEvent", "Ptr", SA, "Int", 0, "Int", 0, "Str", "SharedFile_Client")
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

    ; Automatically writes and then signals the OTHER side
    Write(Text) {
        
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write(text)
        f.Close()

        hEvent := this.IsServer ? this.hEventServer : this.hEventClient
        DllCall("SetEvent", "Ptr", hEvent)
    }

    ; Waits for a signal from the OTHER side and then returns the string
    WaitRead(Timeout := -1) {
        
        ; If I am server, wait for Client event. If I am client, wait for Server event.
        hEventWait := this.IsServer ? this.hEventClient : this.hEventServer
        result := DllCall("WaitForSingleObject", "Ptr", hEventWait, "UInt", Timeout)
        
        if (result == 0) { ; WAIT_OBJECT_0 (Success)
            f:= FileOpen(this.SharedFilePath, "r")
            text:= f.Read()
            f.Close()
            return text
        }
        return "" ; Timeout or error
    }

    Read() {
        f:= FileOpen(this.SharedFilePath, "r")
        text:= f.Read()
        ;???f.Write("") ; clear stale data
        f.Close()
    }

    __Delete() {
        if (this.hEventServer)
            DllCall("CloseHandle", "Ptr", this.hEventServer)
        if (this.hEventClient)
            DllCall("CloseHandle", "Ptr", this.hEventClient)

        Sleep 200 ; Short wait for ACK to complete

        if FileExist(this.SharedFilePath) {
            FileDelete(this.SharedFilePath)
        }
    }
}