; TITLE  :  AdminLauncher v1.0.0.4
; SOURCE :  AHK Forums and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt.
; SUMMARY:  Controller.ahk starts TaskName 'AdminLauncher', who runs AdminLauncher.ahk, who then runs Worker.ahk.
; USAGE  :  On-Demand Task must be in Task Scheduler: AdminLauncher, Target=AdminLauncher.ahk.
;           Two Scripts: one Controller, one Worker.
;           Controller starts TaskName AdminLauncher
;           AdminLauncher runs AdminLauncher.ahk at runLevel='highest'.
;           Controller Sends the WorkerPath to AdminLauncher using NamedPipe IPC.
;           AdminLauncher runs the WorkerPath with runLevel = 'highest'.
;           Controller now communicates with the Worker using NamedPipe IPC.
;           Controllser sends Request to Worker, Worker runs Request.
;           Worker send reply "ACK".
;           Controller receives the reply.
;           Controller ExitApp.

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Ignore
#Include <LogFile>
#Include <NamedPipe>
#Include <RunShell>

class AdminLauncher {

    logger := LogFile("D:\AdminLauncher.log", "AdminLauncher", true)
    TaskName := "AdminLauncher"
    PipeName := "AdminLauncherPipe"
    result := true

    __New(TaskName:="", PipeName:="", AutoStart:=true) {

        if (TaskName)
            this.TaskName := TaskName
        if (PipeName)
            this.PipeName := PipeName

        if (AutoStart)
            this.StartTask()
    }

    Listen(PipeName:=this.PipeName) {
        this.logger.Write("Create pipe")
        pipe := NamedPipe(PipeName)
        pipe.Create()
        this.logger.Write("Pipe Listen")
        path:= pipe.Receive()
        pipe.Close()
        pipe:=""
        this.logger.Write("Received: " path)
        this.logger.Write("Run     : " this.GetExePath(path))
        Run(this.GetExePath(path))
        return true
    }

    ; if ahk then run with A_AhkPath. This enables the ahk to read A_Args if needed
    GetExePath(path) {
        if (InStr(path, ".ahk")>0)
            path := A_AhkPath . A_Space . path
        return path
    }

    Run(Path) {
        if !FileExist(Path)
            return false
        this.Send(Path)
        return true
    }

    StartWorker(WorkerPath) {
        if !FileExist(WorkerPath)
            return false
        this.Send(WorkerPath)
        return true
    }

    Send(Request, PipeName:=this.PipeName) {
        pipe:= NamedPipe(PipeName)
        r := pipe.Wait(5000)
        if (!r) {
            this.logger.Write("Timeout Waiting for SEND pipe.")
            return false
        }
        pipe.Send(Request)
        pipe.Close()
        pipe:=""
        return true
    }

    Receive(PipeName:=this.PipeName) {
        pipe:= NamedPipe(PipeName)
        pipe.Create()
        reply:= pipe.Receive()
        pipe.Close()
        pipe:=""
        return reply
    }

    StartTask(TaskName:="") {

        if (TaskName)
            this.TaskName := TaskName

        cmd := Format('schtasks /run /tn "{}"', this.TaskName)

        r := RunWait(A_ComSpec ' /c ' cmd, , "Hide")

        if (r) 
            throw Error("Failed to run task: " this.TaskName)

    }

    Kill() {

        DetectHiddenWindows true

        if WinExist("AdminLauncher.ahk ahk_class AutoHotkey") {
            TargetPID := WinGetPID()
            ProcessClose(TargetPID)
        }
    }

    __Delete() {
        ; Nothing needs to be cleaned up here - the GC will do it.
        ;this.logger.Write("Delete!")
    }
}

; If included, skip the following block of code.
; If run directly, execute the following block of code
If (A_LineFile == A_ScriptFullPath) {

    launcher:= AdminLauncher()

    r:= launcher.Listen()

    ;FileAppend("Exit r: " r "`r`n", "D:\AdminLauncher.log")

}

