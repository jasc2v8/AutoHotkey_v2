; TITLE  :  AdminLauncher v1.0.0.8
; SOURCE :  AHK Forums and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt.
; SUMMARY:  Controller.ahk starts TaskName 'AdminLauncher', who runs AdminLauncher.ahk, who then runs Worker.ahk.
; USAGE  :  On-Demand Task must be in Task Scheduler: Name=AdminLauncher, Target=AdminLauncher.ahk.
;           Two Scripts: Controller and Worker.
;           Controller Launches Worker Elevated, Worker perofrms work and replies when finished.
; FLOW   :  Controller.exe StartTask AdminLauncher, launches AdminLauncher.ahk at runLeve='highest'
;           AdminLauncher.Listen()
;        	Controller.exe Send(Worker.exe, Params) to AdminLauncher
; 	        AdminLauncher.RunWait(Worker.exe, Params)
; 	        AdminLauncher.Send(reply)
; 	        Controller.exe Receive()
; 	        Controller.exe performs post-action

/*
    TODO:
        Do NOT implement AutoStart, stick with StartTask (much simpler, don't have to identify which script will listen)

        Two use cases:
        1. Task:     Controller script starts Task, the Task starts the Worker, then the Controller will IPC with Worker to Run commands.
        2. Shortcut: Shortcut starts AdminLauncher who reads Args, form a command line, start the Task, then IPC with Task to Run command line.
*/

#Requires AutoHotkey v2+
#SingleInstance Off ; must allow multiple instanaces

#Include <LogFile>
#Include <NamedPipe>
#Include <RunShell>

class AdminLauncher {

    logger := LogFile("D:\AdminLauncher.log", "AdminLauncher", true)
    TaskName := "AdminLauncher"
    PipeName := "AdminLauncherPipe"
    result := true

    __New(TaskName:="", PipeName:="") {

        if (TaskName)
            this.TaskName := TaskName
        if (PipeName)
            this.PipeName := PipeName

        this.logger.Write("IsListener:" this.IsListener())

        ;if this.IsListener()
        ;    this.StartTask(this.TaskName)

    }

    IsListener() {
        err := Error()
        return (InStr(err.Stack, "AhLauncher.ahk")>0)
    }

    Listen(PipeName:=this.PipeName) {
        this.logger.Write("Create pipe")
        pipe := NamedPipe(PipeName)
        pipe.Create()
        this.logger.Write("Pipe Listen")
        commandLine:= pipe.Receive()
        pipe.Close()
        pipe:=""
        ;this.logger.Write("Received: " path)
        this.logger.Write("Run     : " commandLine)
        ;result := RunShell(this.GetExePath(path))
        result := RunShell(commandLine)
        this.Send("ACK: " result)
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
; Else if run directly, execute the following block of code
If (A_LineFile == A_ScriptFullPath) {

    launcher:= AdminLauncher() ; Starts Task AdminLauncher

    launcher.Listen()

}

