; TITLE  :  RunAdmin v2.0.0.1
; SOURCE :  AHK Forums and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run a script.ahk or program.exe elevated without the UAC prompt.

/*
    Use Cases:
    blah, blah, blah...
*/

#Requires AutoHotkey v2+
#SingleInstance Off ; must allow multiple instances to work with shortcuts (Use Case #2)

#Include <LogFile>

;#Include <NamedPipe>
#Include RunAdminIPC.ahk

#Include <RunLib>

global log_file_1 := LogFile("D:\RunAdmin_1.log", "log_file_1", Enabled:=true)
global log_file_2 := LogFile("D:\RunAdmin_2.log", "log_file_2", Enabled:=true)

global run_lib  := RunLib()

global TaskName := "RunAdmin"
global PipeName := "RunAdminPipe"

global ipc:= RunAdminIPC()
;ipc := RunAdminIPC("RunAdminPipe")
;ipc    := RunAdminIPC("")

if (A_Args.Length>0) {

    log_file_1.Write("Start Task")

    StartTask(TaskName)

    ;Wait for Task
    ;Sleep 1000

    ;pipe := NamedPipe(PipeName)
    ;pipe.Create()

    ;CommandCSV := "/RunWait,Script.exe,p1,p2,p3"
    CommandCSV  := run_lib.ArrayToCSV(A_Args)

    log_file_1.Write("Send CommandCSV: " CommandCSV)

    ;pipe.Send(CommandCSV)
    ;pipe.Close()

    ipc.Send(CommandCSV)

} else {

    log_file_2.Write("Listening...")

    ;pipe := NamedPipe(PipeName)
    ;pipe.Wait()
    ;pipe.Close()

    ;commandCSV:= pipe.Receive()

    commandCSV:= ipc.Receive()

    log_file_2.Write("Receive CommandCSV: " CommandCSV)

    GetRunArgs(CommandCSV, &RunSwitch, &CommandArgsCSV)

    log_file_2.Write("GetRunArgs: " RunSwitch ", " CommandArgsCSV)

    if (RunSwitch="/Run")
        run_lib.Run(CommandArgsCSV)

    else if (RunSwitch="/RunWait") {

        log_file_2.Write("/RunWait CommandArgsCSV: " CommandArgsCSV)

        reply := run_lib.RunWait(CommandArgsCSV)

        log_file_2.Write("reply: " reply)

        ;pipe := NamedPipe(PipeName)
        ;pipe.Create()
        ;pipe.Send("ACK: " "TEST reply")

        ipc.Send("ACK: " reply)
    }
    ;pipe.Close()

    ;Persistent false
}

;CommandCSV      := "/RunWait,Script.exe,p1,p2,p3"
;CommandArgsCSV  :=          "Script.exe,p1,p2,p3"
;=================================================
GetRunArgs(CommandCSV, &RunSwitch, &CommandArgsCSV) {
    split       := StrSplit(CommandCSV, ",")
    RunSwitch   := Trim(split[1])
    CommandArgsCSV := Trim(StrReplace(CommandCSV, split[1] ","))
}

StartTask(TaskName:="RunAdmin") {
    cmd := Format('schtasks /run /tn "{}"', TaskName)
    r := RunWait(A_ComSpec ' /c ' cmd, , "Hide")
    if (r) 
        throw Error("Failed to run task: " TaskName)
}
