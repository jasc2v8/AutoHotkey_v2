; TITLE:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0

class SharedFile {

    ClientOrServer:= "Server"
    SharedFileName:= "SharedFile"
    ClientLockName:= "Client"
    ServerLockName:= "Server"
    SharedFilePath:= this.GetFilePath(this.SharedFileName)
    ClientLockPath:= this.GetFilePath(this.ClientLockName)
    ServerLockPath:= this.GetFilePath(this.ServerLockName)
    FileEncodingEx:= "UTF-16"
    LastWait      := ""

    __New(ClientOrServer:="Server") {

        if (ClientOrServer = "Client") {

            if  !FileExist(this.SharedFilePath) or 
                !FileExist(this.ClientLockPath) or 
                !FileExist(this.ServerLockPath)
            {
                MsgBox("Shared files not found.`n`nServer must be started first.`n`nPress OK to Exit.", 
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
            if !FileExist(this.ClientLockPath) {
                f:= FileOpen(this.ClientLockPath, "w")
                f.Close()
            }
            if !FileExist(this.ServerLockPath) {
                f:= FileOpen(this.ServerLockPath, "w")
                f.Close()
            }

            this.Lock(this.ClientLockName)
            this.Lock(this.ServerLockName)

        } else {
            Throw "Error: Must specify 'Client' or 'Server'."
        }

        FileEncoding this.FileEncodingEx

        this.ClientOrServer := ClientOrServer
    }

    GetFilePath(FileNameNoExt) {
        return A_AppDataCommon "\AhkApps\SharedFile\" FileNameNoExt ".dat"
    }

    ; Locked=True=1, UnLocked=False=0
    IsLocked(LockName) {
        FileAttributes := FileGetAttrib(this.GetFilePath(LockName))
        if (InStr(FileAttributes, "R")>0)
            return true
        else
            return false
    }

    ; GetSharedFilepath() {
    ;     return this.SharedFilePath
    ; }

    Lock(LockName) {
        lockFile:= this.GetFilePath(LockName)
        FileSetAttrib("+R", lockFile)
    }

    ReceivedFrom(LockName:="") {
        if (LockName = "")
            LockName:= this.LastWait
        ;this.Lock(LockName)
        lockFile:= this.GetFilePath(LockName)
        FileSetAttrib("+R", lockFile)
    }
    
    Read() {
        f:= FileOpen(this.SharedFilePath, "r")
        text:= f.Read()
        f.Close()
        return text
    }

    ; ShowAttributes() {
    ;     ClientAttrib := FileGetAttrib(this.GetFilePath("Client"))
    ;     ServerAttrib := FileGetAttrib(this.GetFilePath("Server"))
    ;     MsgBox "ClientAttrib: " ClientAttrib "`n`ServerAttrib: " ServerAttrib, "Show Attributes"

    ; }

    Write(text) {
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write(text)
        f.Close()
    }

    UnLock(LockName) {
        lockFile:= this.GetFilePath(LockName)
        if (InStr(FileGetAttrib(lockFile), "R")>0)
            FileSetAttrib("-R", lockFile)
    }

    SentFrom(LockName) {
        this.UnLock(LockName)

        ; lockFile:= this.GetFilePath(LockName)
        ; if (InStr(FileGetAttrib(lockFile), "R")>0)
        ;     FileSetAttrib("-R", lockFile)
    }

    ; success=true, timeout=false, wait forever=-1Ms
    Wait(LockName, TimeoutMs:=-1) {

        StartTime := A_TickCount
        EndTime := StartTime + TimeoutMs

        Loop {

            if not this.IsLocked(LockName) {
                this.LastWait:=LockName
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

    ; success=true, timeout=false, wait forever=-1Ms
    WaitUnLock(LockName, TimeoutMs:=-1) {

        StartTime := A_TickCount
        EndTime := StartTime + TimeoutMs

        Loop {

            if not this.IsLocked(LockName) {
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

    __Delete() {

        ; if the Client exits, do NOT delete the shared files
        if (this.ClientOrServer = "Client")
            return

        if FileExist(this.SharedFilePath) {
            this.UnLock(this.SharedFileName)
            FileDelete(this.SharedFilePath)
        }
        if FileExist(this.ClientLockPath) {
            this.UnLock(this.ClientLockName)
            FileDelete(this.ClientLockPath)
        }
        if FileExist(this.ServerLockPath) {
            this.UnLock(this.ServerLockName)
            FileDelete(this.ServerLockPath)
        }
    }
}

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    SharedFile__Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

SharedFile__Tests() {

    ; comment out to run tests
    SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    Test2()
    ;Test3()

    ; test methods
    Test1() {
        ; Create, Lock, UnLock, IsLocked, __Delete

        MsgBox "Start of Test1", "Test1"

        ; Create a shared file and lock files
        SF:= SharedFile()

        if FileExist(SF.SharedFilePath) {
            ;MsgBox "Success Create Shared File", "Test1"
        } else {
            MsgBox "Failure Create Shared File", "Test1"
        }

        lockFile:= SF.GetFilePath("Client")
        if FileExist(lockFile) {
            ;MsgBox "Success Create Client File", "Test1"
        } else {
            MsgBox "Failure Create Client File", "Test1"
        }

        lockFile:= SF.GetFilePath("Server")
        if FileExist(lockFile) {
            ;MsgBox "Success Create Server Lock", "Test1"
        } else {
            MsgBox "Failure Create Server Lock", "Test1"
        }

        ; Check if locked
        r := SF.IsLocked("Client")
        if (r) {
           ;MsgBox "Locked: Client", "SB: Locked"
        } else {
            MsgBox "UnLocked: Client", "SB: Locked"
        }

        r := SF.IsLocked("Server")
        if (r) {
           ;MsgBox "Locked: Server", "SB: Locked"
        } else {
            MsgBox "UnLocked: Server", "SB: Locked"
        }

        ; Toggle the locks
        if (SF.IsLocked("Client"))
            SF.UnLock("Client")
        else
            SF.Lock("Client")

        if (SF.IsLocked("Server"))
            SF.UnLock("Server")
        else
            SF.Lock("Server")

        ; Check if UnLocked
        r := SF.IsLocked("Client")
        if (r) {
           MsgBox "Locked: Client", "SB: UnLocked"
        } else {
            ;MsgBox "UnLocked: Client", "SB: UnLocked"
        }

        r := SF.IsLocked("Server")
        if (r) {
           MsgBox "Locked: Server", "SB: UnLocked"
        } else {
            ;MsgBox "UnLocked: ClServerient", "SB: UnLocked"
        }

        ; test __Delete
   
        SavedSharedFilePath:= SF.SharedFilePath
        SavedClientLockPath:= SF.ClientLockPath
        SavedServerLockPath:= SF.ServerLockPath
        
        SF:=""

        if FileExist(SavedSharedFilePath) {
            MsgBox "Failure Delete Shared File"
        } else {
            ;MsgBox "Success Delete Shared File"
        }

        if FileExist(SavedClientLockPath) {
            MsgBox "Failure Delete Client Lock"
        } else {
            ;MsgBox "Success Delete Client Lock"
        }

        if FileExist(SavedServerLockPath) {
            MsgBox "Failure Delete Server Lock"
        } else {
            ;MsgBox "Success Delete Server Lock"
        }

        MsgBox "End of Test1", "Test1"

    }
    Test2() {
        ; WaitUnlock, Read, Write

        MsgBox "Start of Test2", "Test2"

        ; Create a shared file and lock files
        SF:= SharedFile("Server")

        ; Test WaitUnLock
        ; NOTE: you must comment out the UnLock in this.Unlock, then run this test
        ; r := SF.WaitUnLock(LockName, 1000)
        ; if (r) {
        ;     MsgBox "UNLOCKED (NO TIMEOUT).", "SB TIMEOUT"
        ; } else {
        ;     MsgBox "TIMEOUT.", "SB TIMEOUT"
        ; }

        ; Test UnLock, WaitUnLock
        SF.UnLock("Client")
        r := SF.WaitUnLock("Client", 1000)
        if (r) {
            ;MsgBox "UNLOCKED (NO TIMEOUT).", "SB UNLOCKED"
        } else {
            MsgBox "TIMEOUT.", "SB UNLOCKED"
        }

        ; Test Write
        SF.Write("Hello World!")

        ; Test Read
        MsgBox SF.Read(), "Test Write/Read"

        ;not needed, handled by Ahk garbage colletor: SF:=""

        MsgBox "End of Test2", "Test2"

    }

    Test3() {
    }
}
