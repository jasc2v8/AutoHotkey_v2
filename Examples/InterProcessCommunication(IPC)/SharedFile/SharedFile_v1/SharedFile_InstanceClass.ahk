; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0

class SharedFile {

    static TERMINATING:=false

    SharedFilePath:= A_Temp "\SharedFile.tmp"
    SharedFileObj:= unset
    FileObjMap:= Map()

    ;myProperty := "Default Value"

    __New(SharedFilePath:="") {

        if (SharedFilePath != "") {
            this.SharedFilePath := SharedFilePath
        }

        FileEncoding "UTF-16"

        this.SharedFileObj:= FileOpen(this.SharedFilePath, "w")

    }

    ; getProperty() {
    ;     MsgBox "The current value of myProperty is: " this.myProperty
    ; }

    ; setProperty(newValue) {
    ;     this.myProperty := newValue
    ;     MsgBox "myProperty has been updated to: " this.myProperty
    ; }

    CreateLock(LockName, Info:="") {

        ; TODO: A_Temp\SharedFile\Server.tmp

        lockFile:= this.GetLockFilename(LockName)
        
        ; if the file has already been created, make sure it is locked
        if FileExist(lockFile) {

            this.Lock(LockName)

            ;FileAttributes := FileGetAttrib(this.GetLockFilename(LockName))
            ;MsgBox "Already created: " LockFile "`n`nAttributes: " FileAttributes, "DEBUG CreateLock"

            return true

            ; try {
            ;     this.Lock(lockFile)
            ;     return true
            ; } catch {
            ;     FileObj:= FileOpen(lockFile, "-w")
            ;     MsgBox "Already created: " LockFile, "DEBUG CreateLock"
            ;     return false
            ; }


        } else {
            ; create a new lock file
            FileObj:= FileOpen(lockFile, "w")

            if (Info != "")
                FileObj.Write(Info)

            ; close it immediately
            FileObj.Close()

            ; lock it by setting to read-only
            FileSetAttrib("+R", lockFile)
            ;Sleep 500
            ; lock it
            ;FileObj:= FileOpen(lockFile, "-rwd")
            ; save it in a map
            this.FileObjMap[LockName]:= FileObj
            ;MsgBox "Created: " LockFile, "DEBUG CreateLock"
        }
        
        ;MsgBox LockFile, "CreateLock"



        return true
        
    }

    GetLockFilename(LockName) {
        ; if not this.IsServerAlive() {
        ;     Throw "GetLockFilename: SERVER NOT RUNNING!"
        ; }

        lockFile:= A_Temp "\" LockName ".tmp"
        return lockFile
    }

    ; Locked=True=1, UnLocked=False=0, Timeout=2
    ; if IsLocked(LockName)=1 or 0, or 2
    IsLocked(LockName) {
        ; if not this.IsServerAlive() {
        ;     Throw "IsLocked: SERVER NOT RUNNING!"
        ; }

        ; if a lock file is missing then the client or server is not running
        if !FileExist(this.GetLockFilename(LockName)) {
            ;MsgBox "lock file not exist: " LockName, "DEBUG IsLocked"
            return false
        }

        FileAttributes := FileGetAttrib(this.GetLockFilename(LockName))
        if InStr(FileAttributes, "R")
            return true
        else
            return false
    }

    GetSharedFilepath() {
        return this.SharedFilePath
    }

    Lock(LockName) {
        lockFile:= this.GetLockFilename(LockName)
        if FileExist(lockFile) {
            FileSetAttrib("+R", lockFile)
            FileObj:= FileOpen(lockFile, "r")
            this.FileObjMap[LockName]:= FileObj
        }
    }

    Read() {
        if FileExist(this.SharedFilePath) {
            f:= FileOpen(this.SharedFilePath, "r")
            text:= f.Read()
            f.Close()
            return text
        } else {
            return ""
        }
    }

    ShowAttributes() {
        ClientAttrib := FileGetAttrib(this.GetLockFilename("Client"))
        ServerAttrib := FileGetAttrib(this.GetLockFilename("Server"))
        MsgBox "ClientAttrib: " ClientAttrib "`n`ServerAttrib: " ServerAttrib, "Show Attributes"

    }

    Write(text) {
        if FileExist(this.SharedFilePath) {
            f:= FileOpen(this.SharedFilePath, "w")
            f.Write(text)
            f.Close()
        }
    }

    UnLock(LockName) {
        lockFile:= this.GetLockFilename(LockName)

        if FileExist(lockFile) {

            if NOT InStr(FileGetAttrib(lockFile), "R")
                return true
            else {
                FileSetAttrib("-R", lockFile)
                return true
            }
        } else {
            return false
        }
   }

    WaitLock(LockName) {
        ;?
    }

    ; success=true, timeout=false, wait forever=-1
    WaitUnLock(LockName, TimeoutMs:=-1) {

        if !FileExist(this.GetLockFilename(LockName)) {
            MsgBox "lock file not exist: " LockName, "DEBUG WaitUnLock"
            return false
        }

        StartTime := A_TickCount
        EndTime := StartTime + TimeoutMs

        Loop {

            if NOT this.IsLocked(LockName) {
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

        ;MsgBox "__DELETE"

        ; close all FileObj's and delete the lock files
        for LockName, fileObj in this.FileObjMap {

            this.UnLock(LockName)
            
            fileObj.Close()

            ;MsgBox "DELETE: " LockName, "DEBUG __DELETE"

            if FileExist(this.GetLockFilename(LockName))
                FileDelete(this.GetLockFilename(LockName))
        }
        this.FileObjMap:= ""

        ; delete the shared file
        if FileExist(this.SharedFilePath)
            FileDelete(this.SharedFilePath)
    }
}
; If included, skip the following block of code.
; If run directly, execute the following block of code
If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    SharedFile__Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

SharedFile__Tests() {

    ; comment out to run tests
    SoundBeep(), ExitApp()

    ; comment out tests to skip:
    ;Test1()
    Test2()
    ;Test3()

    ; test methods
    Test1() {
        ; Create, Lock, UnLock, IsLocked, __Delete

        ; Create a shared file
        SF:= SharedFile()

        if FileExist(SF.SharedFilePath) {
            MsgBox "Success Create Shared File"
        } else {
            MsgBox "Failure Create Shared File"
        }

        ; Create a lock
        LockName:= "MyLock"

        SF.CreateLock(LockName)

        lockFile:= SF.GetLockFilename(LockName)
        if FileExist(lockFile) {
            MsgBox "Success Create Lock"
        } else {
            MsgBox "Failure Create Lock"
        }

        ; Check if locked
        r := SF.IsLocked(LockName)

        if (r) {
            MsgBox "Locked: " LockName, "SB: Locked"
        } else {
            MsgBox "UnLocked: " LockName, "SB: Locked"
        }

        ; Toggle the lock
        if (SF.IsLocked(LockName))
            SF.UnLock(LockName)
        else
            SF.Lock(LockName)

        ; Check if UnLocked
        r := SF.IsLocked(LockName)

        if (r) {
            MsgBox "Locked: " LockName, "SB: UnLocked"
        } else {
            MsgBox "UnLocked: " LockName, "SB: UnLocked"
        }

        SavedSharedFile:= SF.SharedFilePath

        SF:=""

        if FileExist(SavedSharedFile) {
            MsgBox "Failure Delete Shared File"
        } else {
            MsgBox "Success Delete Shared File"
        }

        if FileExist(lockFile) {
            MsgBox "Failure Delete Lock"
        } else {
            MsgBox "Success Delete Lock"
        }

    }
    Test2() {
        ; WaitUnlock, Read, Write

        ; Create a shared file
        SF:= SharedFile()

        LockName:= "MyLock"

        ; Create a lock
        SF.CreateLock(LockName)

        ; Check if locked
        r := SF.IsLocked(LockName)
        if (r) {
            MsgBox "Locked: " LockName, "SB: Locked"
        } else {
            MsgBox "UnLocked: " LockName, "SB: Locked"
        }

        ; Test WaitUnLock
        ; NOTE: you must comment out the UnLock in this.Unlock, then run this test
        ; r := SF.WaitUnLock(LockName, 1000)
        ; if (r) {
        ;     MsgBox "UNLOCKED (NO TIMEOUT).", "SB TIMEOUT"
        ; } else {
        ;     MsgBox "TIMEOUT.", "SB TIMEOUT"
        ; }

        ; Test UnLock, WaitUnLock
        SF.UnLock(LockName)
        r := SF.WaitUnLock(LockName, 1000)
        if (r) {
            MsgBox "UNLOCKED (NO TIMEOUT).", "SB UNLOCKED"
        } else {
            MsgBox "TIMEOUT.", "SB UNLOCKED"
        }

        ; Test Write
        SF.Write("Hello World!")

        ; Test Read
        MsgBox SF.Read(), "Test Read"

        ; Toggle the lock
        if (SF.IsLocked(LockName))
            SF.UnLock(LockName)
        else
            SF.Lock(LockName)

        ; Check if UnLocked
        r := SF.IsLocked(LockName)

        if (r) {
            MsgBox "Locked: " LockName, "SB: Locked"
        } else {
            MsgBox "UnLocked: " LockName, "SB: Locked"
        }

        ;not needed, handled by Ahk garbage colletor: SF:=""

    }

    Test3() {
    }
}
