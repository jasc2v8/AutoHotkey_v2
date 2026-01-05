; ABOUT:    Sharedfile v0.3 - Change to Mutex
; SOURCE:  
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

	Mutex.dat
	 R = Acquired
	-R = Released

    ???
    DisableMutex()
    EnableMutex()

*/

#Requires AutoHotkey v2.0

class SharedFile {

    ClientOrServer  := "Server"
    SharedFileDir   := A_AppDataCommon "\AhkApps\SharedFile\"
    SharedFileName  := "SharedBuffer.txt"
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

            ; Wait forever until Client Acquires the Mutex
            this.SetEmpty()

        } else {
            Throw "Error: Must specify 'Client' or 'Server'."
        }
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

    SetEmpty() {
            ;FileAttributes := FileGetAttrib(this.SharedFilePath)
            ;if (InStr(FileAttributes, "R") = 0)
                FileSetAttrib("-R", this.SharedFilePath)
    }

    SetFull() {
            ;FileAttributes := FileGetAttrib(this.SharedFilePath)
            ;if (InStr(FileAttributes, "R") = 0)
                FileSetAttrib("+R", this.SharedFilePath)
    }

    ; success=true, timeout=false, don't wait=0Ms, wait forever=-1Ms
    WaitEmpty(TimeoutMs:=-1) {

        ; If no wait then reutrn IsEmpty() true or false
        if (TimeoutMs = 0) {
            return this.IsEmpty() ? true : false
        }

        ; Wait until a different process SetEmpty()
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
    WaitFull(TimeoutMs:=-1) {

        ; If no wait then reutrn IsFull() true or false
        if (TimeoutMs = 0) {
            return this.IsFull() ? true : false
        }

        ; Wait until a different process SetEmpty()
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

    Read() {
        f:= FileOpen(this.SharedFilePath, "r")
        text:= f.Read()
        f.Close()
        this.SetEmpty()
        return text
    }

    Write(text) {
        f:= FileOpen(this.SharedFilePath, "w")
        f.Write(text)
        f.Close()
        this.SetFull()
    }

    __Delete() {

        ; if the Client exits, do NOT delete the shared files
        if (this.ClientOrServer = "Client")
            return

        if FileExist(this.SharedFilePath) {
           this.SetEmpty()
           FileDelete(this.SharedFilePath)
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
