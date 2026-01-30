; TITLE  :  RunAdmin v1.0.0.4
; SOURCE :  AHK Forums and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt.
; SUMMARY:  On-Demand Task must be in Task Scheduler: Name=RunAdmin, Target=RunAdmin.ahk.
;           Controller Script must #Include <RunAdmin>.
; USAGE  :  Two Use Cases:
;               1. Controller Script Launches Worker Elevated, Controller Script sends Run (no Reply) or RunWait (Reply) to Worker.
;               2. ShortCut Target="AdminRun CommandLine" Launches AdminRun Elevated, AdminRun sends Run (no Reply) "CommandLine".
; CASE #1:  Controller Script Launches Worker Elevated, Controller Script sends Run (no Reply) or RunWait (Reply) to Worker.
;               Controller StartTask which runs RunAdmin.ahk Elevated in Listen mode.
;               Controller sends Run(Worker) or RunWait(Worker) 
;               Controller Receives reply from Worker
;               Controller performs post-run actions
; CASE #2:  ShortCut Target="AdminRun CommandLine" Launches AdminRun Elevated, AdminRun sends Run (no Reply) "CommandLine".
;               ShortCut Launches AdminRun
;               AdminRun StartTask which runs RunAdmin Elevated in Listen mode.
;               AdminRun sends Run(MyApp) (No Reply)

/*
    TODO:
        Do NOT implement AutoStart, stick with StartTask (much simpler, don't have to identify which script will listen)
*/

#Requires AutoHotkey v2+
#SingleInstance Off ; must allow multiple instances

#Include <LogFile>
#Include <NamedPipe>
#Include <RunShell>

class RunAdmin {

    logger := LogFile("D:\RunAdmin.log", "RunAdmin", true)
    TaskName := "RunAdmin"
    PipeName := "RunAdminPipe"

    __New(TaskName:="", PipeName:="") {

        if (TaskName)
            this.TaskName := TaskName
        if (PipeName)
            this.PipeName := PipeName
    }

    Listen(PipeName:=this.PipeName) {

        this.logger.Write("Create pipe")
        pipe := NamedPipe(PipeName)
        pipe.Create()

        this.logger.Write("Pipe Listen")
        commandCSV:= pipe.Receive()
        pipe.Close()
        pipe:=""

        this.logger.Write("Received: " commandCSV)

        split:= StrSplit(commandCSV, ",")
        runAction:=split[1]
        this.logger.Write("runAction: [" runAction "]")

        commandCSV := StrReplace(commandCSV, runAction ",")
        this.logger.Write("commandCSV: " commandCSV)

        commandCSV := this.CheckIfAhkCommand(commandCSV)
        this.logger.Write("CheckIfAhkCommand: " commandCSV)

        this.logger.Write(runAction ": " commandCSV)
        result := RunShell(commandCSV)

        ; RunCMD(CommandCSV) ; will convert to commandLine?

        if (runAction = "/RunWait")
            this.Send("ACK: " result)
    }

    Listen_OK(PipeName:=this.PipeName) {
        this.logger.Write("Create pipe")
        pipe := NamedPipe(PipeName)
        pipe.Create()
        this.logger.Write("Pipe Listen")
        commandCSV:= pipe.Receive()
        pipe.Close()
        pipe:=""
        commandCSV := this.CheckIfAhkCommand(commandCSV)
        this.logger.Write("Run: " commandCSV)
        result := RunShell(commandCSV)
        this.Send("ACK: " result)
    }

    CheckIfAhkCommand(commandCSV) {
        split := StrSplit(commandCSV, ",")
        if (InStr(split[1], ".ahk")>0)
            commandCSV := A_AhkPath . ", " . commandCSV
        return commandCSV
    }

    Run(commandCSV) {
        this.Send("/Run," commandCSV)
    }

    RunWait(commandCSV) {
        this.Send("/RunWait," commandCSV)
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

    __Delete() {
        ; Nothing needs to be cleaned up here - the GC will do it.
        ;this.logger.Write("Delete!")
    }
}

logger2 := LogFile("D:\RunAdminArgs.log", "RunAdminArgs", true)

logger2.Write("A_IsAdmin: " A_IsAdmin)

 runner:= RunAdmin()

if (A_IsAdmin) {

    logger2.Write("Args len: " A_Args.Length)

    if (A_Args.Length > 0 ) {

        ;
        ; The Admin Task is already started
        ; Combine args into a command line e.g. MyApp.exe p1 p2 p3
        ;
        commandCSV := RunShell.ArrayToCSV(A_Args)

        logger2.Write("cmdLine: " commandCSV)

        ;
        ; Run the cmdLine, no wait and no return
        ;
        runner.Run(commandCSV)

        logger2.Write("Running: " commandCSV)

    } else {

        logger2.Write("Listening...")

        runner.Listen()

    }

} else {

    if (A_Args.Length > 0 ) {
        runner.StartTask()
        commandCSV := RunShell.ArrayToCSV(A_Args)
        runner.Run(commandCSV)
    }
}


