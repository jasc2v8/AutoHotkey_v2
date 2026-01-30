; TITLE  :  RunAdmin v1.0.0.9
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
#Include <ObjList>

global EnableLogs:= true

class RunAdmin {

    logger := LogFile("D:\RunAdmin.log", "RunAdmin", EnableLogs)
    run_admin := RunLib()
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
        result := run_admin.RunWait(commandCSV)

        if (runAction = "/RunWait")
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

logger := LogFile("D:\RunAdminArgs.log", "RunAdminArgs", EnableLogs)

logger.Write("A_IsAdmin: " A_IsAdmin)

run_admin:= RunAdmin()

run_lib := RunLib()

if (A_IsAdmin) {

    logger.Write("Args len: " A_Args.Length)

    if (A_Args.Length > 0 ) {

        ;
        ; The Admin Task is already started. Combine args into a commandCSV
        ;
        commandCSV := run_lib.ArrayToCSV(A_Args)

        logger.Write("cmdLine: " commandCSV)

        ;
        ; Run the commandCSV, no wait and no reply
        ;
        run_lib.Run(commandCSV)

        logger.Write("Running: " commandCSV)

    } else {

        ;
        ; Wait for command CSV
        ;
        logger.Write("Listening...")

        run_admin.Listen()

    }

} else {
   
    ; Entry: RunAdmin.ahk MyApp.exe MyParam
    ; Start the Task RunAdmin which starts RunAdmin.ahk elevated
    ; RunAdmin.ahk elevated listens for a command to run elevated
    ; Send the args passed to this non-admin instance on the command line
    ; RunAdmin.ahk runs the args elevated
    if (A_Args.Length > 0 ) {
        run_admin.StartTask()
        commandCSV := run_lib.ArrayToCSV(A_Args)
        run_admin.Run(commandCSV)
    }
}


