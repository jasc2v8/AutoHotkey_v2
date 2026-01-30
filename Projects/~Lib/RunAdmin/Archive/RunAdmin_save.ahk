; TITLE  :  RunAdmin v2.0.0.3
; SOURCE :  AHK Forums and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run a script.ahk or program.exe elevated without the UAC prompt.

/*

    Use Cases:

	1. Script.ahk or Script.exe
	2. Shortcut.lnk

	Case 1. Script.ahk or Script.exe

		Options:
			1. RunAhk /Run with arguments (no reply. RunWait without the Task is not supported.)
			2. Start Task RunAhk then send Run(Command) or RunWait(Command) via NamedPipe IPC
			3. (Rarely used) Start Task then RunLib.Run(RunAhk /RunWait) with arguments. Receive reply via NamedPipe IPC.
		
		Option 1: Run or RunWait with arguments
		
			A_AhkPath RunAdmin.ahk /Run PROGRAM PARAM1 PARAMn
					  RunAdmin.exe /Run PROGRAM PARAM1 PARAMn
			-or-
			
			ipc.StartTask()
			A_AhkPath RunAdmin.ahk /RunWait PROGRAM PARAM1 PARAMn
					  RunAdmin.exe /RunWait PROGRAM PARAM1 PARAMn
			reply:=ipc.Receive()

		Option 2: Start Task RunAhk then send Command via NamedPipe IPC
		
			ipc := RunAdminIPC()
			ipc.StartTask()	; Starts Task AhkRun which starts AhkRun.ahk elevated in Listen() mode.
			ipc.Send( "/Run," CommandCSV)
			
			-or-
			
			ipc := RunAdminIPC()
			ipc.StartTask()
			ipc.Send( "/RunWait," CommandCSV)
			reply:=ipc.Receive()
		
	Case 2. Shortcut (/Run no reply only. /RunWait with reply not supported):
	
		Shortcut Target: A_AhkPath RunAdmin.ahk /Run PROGRAM PARAM1 PARAMN
		Shortcut Target:           RunAdmin.exe /Run PROGRAM PARAM1 PARAMN

		Shortcut Target Examples:
		%PROGRAMFILES%\AutoHotkey\v2\AutoHotkey64.exe "%USERPROFILE%\Documents\AutoHotkey\Lib\RunAdmin.ahk" "/Run" "%ProgramFiles(x86)%\SyncBackSE\SyncBackSE.exe" "-monoff" "MY PROFILE"
		%USERPROFILE%\Documents\AutoHotkey\Lib\RunAdmin.exe /Run "D:\Software\DEV\Work\AHK2\Projects\~Tools\SearchBarReset\SearchBarReset.exe"

*/

#Requires AutoHotkey v2+
#SingleInstance Off

#Include <LogFile>
#Include <RunLib>

Enabled:=false
global log_file_1 := LogFile("D:\RunAdmin_1.log", "log_file_1", Enabled)
global log_file_2 := LogFile("D:\RunAdmin_2.log", "log_file_2", Enabled)

global run_lib  := RunLib()

 ; CommandCSV := "/RunWait,Script.exe,p1,p2,p3"
 ; CommandCSV := "/RunWait,Script.exe,p1,p2,p3"
;=====================================
if (A_Args.Length>0) {

    log_file_1.Write("Start Task")

    ipc:= RunAdminIPC()

    ipc.StartTask()

    CommandCSV  := run_lib.ArrayToCSV(A_Args)

    log_file_1.Write("Send CommandCSV: " CommandCSV)

    ipc.Send(CommandCSV)

} else {

    log_file_2.Write("Listening...")

    ipc:= RunAdminIPC()

    commandCSV:= ipc.Receive()

    log_file_2.Write("Receive CommandCSV: " CommandCSV)

    _GetRunArgs(CommandCSV, &RunSwitch, &CommandArgsCSV)

    log_file_2.Write("GetRunArgs: " RunSwitch ", " CommandArgsCSV)

    if (RunSwitch="/Run")
        run_lib.Run(CommandArgsCSV)

    else if (RunSwitch="/RunWait") {

        log_file_2.Write("/RunWait CommandArgsCSV: " CommandArgsCSV)

        reply := run_lib.RunWait(CommandArgsCSV)

        log_file_2.Write("reply: " reply)

        ipc.Send("ACK: " reply)
    }

    ;CommandCSV      := "/RunWait,Script.exe,p1,p2,p3"
    ;CommandArgsCSV  :=          "Script.exe,p1,p2,p3"
    ;=================================================
    _GetRunArgs(CommandCSV, &RunSwitch, &CommandArgsCSV) {
        split       := StrSplit(CommandCSV, ",")
        RunSwitch   := Trim(split[1])
        CommandArgsCSV := Trim(StrReplace(CommandCSV, split[1] ","))
    }
}

#Include <NamedPipe>

class RunAdminIPC {

    PipeName := ""

    pipe := 0

    __New(PipeName:= "RunAdminPipe") {
        this.PipeName:= PipeName
    }

    Send(CommandCSV) {
        this.pipe := NamedPipe(this.PipeName)
        this.pipe.Wait()
        this.pipe.Send(CommandCSV)
        this.pipe.Close()
    }

    Receive() {
        this.pipe := NamedPipe(this.PipeName)
        this.pipe.Create()
        reply:= this.pipe.Receive()
        this.pipe.Send(reply)
        this.pipe.Close()
        return reply
    }

    StartTask(TaskName:="RunAdmin") {
        cmd := Format('schtasks /run /tn "{}"', TaskName)
        r := RunWait(A_ComSpec ' /c ' cmd, , "Hide")
        if (r) 
            throw Error("Failed to run task: " TaskName)
    }

    __Delete() {
        ;this.pipe.Close()
    }

}
