; TITLE  :  RunAdmin v1.0.0.10
; SOURCE :  AHK Forums and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt.
; SUMMARY:  On-Demand Task must be in Task Scheduler: Name=RunAdmin, Target=RunAdmin.ahk.
;           Controller Script must #Include <RunAdmin>.
; USAGE  :  Two Use Cases:
;               1. Controller Script Launches Worker Elevated, Controller Script sends Run (no Reply) or RunWait (Reply) to Worker.
;               2. ShortCut Target="RunAdmin CommandLine" Launches RunAdmin Elevated, RunAdmin sends Run (no Reply) "CommandLine".
; CASE #1:  Controller Script Launches Worker Elevated, Controller Script sends Run (no Reply) or RunWait (Reply) to Worker.
;               Controller StartTask which runs RunAdmin.ahk Elevated in Listen mode.
;               Controller sends Run(Worker) or RunWait(Worker) 
;               Controller Receives reply from Worker
;               Controller performs post-run actions
; CASE #2:  ShortCut Target="RunAdmin CommandLine" Launches RunAdmin Elevated, RunAdmin sends Run (no Reply) "CommandLine".
;               ShortCut Launches RunAdmin
;               RunAdmin StartTask which runs RunAdmin Elevated in Listen mode.
;               RunAdmin sends Run(MyApp) (No Reply)

/*
    TODO:
        Do NOT implement AutoStart, stick with StartTask (much simpler, don't have to identify which script will listen)
*/

#Requires AutoHotkey v2+
#SingleInstance Off ; must allow multiple instances to work with shortcuts (Use Case #2)

#Include <LogFile>
#Include <NamedPipe>
#Include <RunLib>

global EnableLogs:= true

class RunAdmin {

    logger := LogFile("D:\RunAdmin.log", "RunAdmin", EnableLogs)
    run_lib := RunLib()
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

        split:= StrSplit(commandCSV, ",")
        runAction:=split[1]
        this.logger.Write("runAction: [" runAction "]")

        commandCSV := StrReplace(commandCSV, runAction ",")
        this.logger.Write("commandCSV: " commandCSV)

        commandCSV := this.CheckIfAhkCommand(commandCSV)
        this.logger.Write("CheckIfAhkCommand: " commandCSV)

        this.logger.Write(runAction ": " commandCSV)

        if (runAction = "/Run") {
            run_lib.Run(commandCSV)
        } else if (runAction = "/RunWait") {
            result := run_lib.RunWait(commandCSV)
            this.Send("ACK: " result)
        }
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

logger2 := LogFile("D:\RunAdminArgs.log", "RunAdminArgs", EnableLogs)

;logger.Write("A_IsAdmin: " A_IsAdmin)

run_admin:= RunAdmin()

run_lib := RunLib()

if (A_IsAdmin) {

    logger2.Write("Admin Args len: " A_Args.Length)

    if (A_Args.Length > 0 ) {

        ;
        ; The Admin Task is already started. Combine args into a commandCSV
        ;
        commandCSV := run_lib.ArrayToCSV(A_Args)

        logger2.Write("cmdLine: " commandCSV)

        ;
        ; Run the commandCSV, no wait and no reply
        ;
        run_lib.Run(commandCSV)

        logger2.Write("Running: " commandCSV)

    } else {

        ;
        ; Wait for command CSV
        ;
        logger2.Write("Listening...")

        run_admin.Listen()

    }

} else {

    logger2.Write("Non-Admin Args len: " A_Args.Length)

    if (A_Args.Length > 0 ) {
        commandCSV := run_lib.ArrayToCSV(A_Args)

        logger2.Write("Non-Admin Run: " commandCSV)

        run_admin.StartTask()
        run_admin.Run(commandCSV)
    }
}


