; TITLE  :  RunAdmin v2.0.0.9
; SOURCE :  AHK Forums, Gemini, and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run a script.ahk or script.exe elevated without the UAC prompt.

/*
    Setup - Must perform the following before running the Demo!

        1. Copy RunAdmin.ahk to your desired location,    e.g. %USERPROFILE% "\Documents\AutoHotkey\Lib\RunAdmin.ahk"
        2. Copy RunAdminIPC.ahk to your desired location, e.g. %USERPROFILE% "\Documents\AutoHotkey\Lib\RunAdminIPC.ahk"
        3. Use RunAdminCreateTask to create the Task in the Task Scheduler.
        4. Use RunAdminDemo.ahk to test.
        5. Use RunAdminDemoController.ahk for another test. This test will run RunAdminDemoWorker.ahk.

    Use Cases:

        1. Run Directly
        2. Run via NamedPipe IPC
        3. Run via Shortcut.lnk
        4. Setup

	Case 1. Run Directly

		Used primarily to Run a script elevated with no reply.
		
            A_AhkPath RunAdmin.ahk /Run PROGRAM PARAMETERS
                      RunAdmin.exe /Run PROGRAM PARAMETERS

            RunAdmin.ahk starts the Task RunAdmin which runs RunAdmin.ahk elevated.
            RunAdmin.ahk captures the A_Args and sends via NamedPipe IPC to RunAdmin.ahk elevated.
            RunAdmin.ahk elevated runs the A_Args (PROGRAM PARAMETERS) elevated.

		Can also be used as RunWait with reply. Case 2 is recommended over this method.

            A_AhkPath RunAdmin.ahk /RunWait PROGRAM PARAMETERS
                      RunAdmin.exe /RunWait PROGRAM PARAMETERS
            
			ipc := RunAdminIPC()
            reply := ipc.Receive()

	Case 2. Run via NamedPipe IPC

		Start Task RunAhk then send Command via NamedPipe IPC:
		
			ipc := RunAdminIPC()
			ipc.StartTask()	; Starts Task AhkRun which starts AhkRun.ahk elevated in Receive() mode.
			ipc.Send("/Run, Script.ahk[.exe], Parameters") ; CSV
		-or-
			ipc.Send("/RunWait, Script.ahk[.exe], Parameters") ; CSV
			reply := ipc.Receive()
		
	Case 3. Run via Shortcut.lnk
    
        /Run no reply only. /RunWait with reply not supported:
	
            Shortcut Target: A_AhkPath RunAdmin.ahk /Run PROGRAM PARAMETERS
            Shortcut Target:           RunAdmin.exe /Run PROGRAM PARAMETERS

		Shortcut Target Examples:
            %PROGRAMFILES%\AutoHotkey\v2\AutoHotkey64.exe "%USERPROFILE%\Documents\AutoHotkey\Lib\RunAdmin.ahk" "/Run" "%ProgramFiles(x86)%\SyncBackSE\SyncBackSE.exe" "-monoff" "MY PROFILE"
            %USERPROFILE%\Documents\AutoHotkey\Lib\RunAdmin.exe /Run "D:\Software\DEV\Work\AHK2\Projects\~Tools\SearchBarReset\SearchBarReset.exe"
            
*/

#Requires AutoHotkey v2+
#SingleInstance Off ; must allow multiple instances to work with shortcuts (Use Case #2)

#Include <LogFile>
#Include <NamedPipe>
#Include <RunLib>

Enabled:=false
global log_file_1 := LogFile("D:\RunAdmin_1.log", "log_file_1", Enabled)
global log_file_2 := LogFile("D:\RunAdmin_2.log", "log_file_2", Enabled)

global runner := RunLib()

 ; CommandCSV := "/Run    ,Script.exe,p1,p2,p3"
 ; CommandCSV := "/RunWait,Script.exe,p1,p2,p3"
;==============================================
if (A_Args.Length>0) {

    log_file_1.Write("Start Task")

    ipc:= NamedPipe()

    StartTask()

    CommandCSV  := runner.ArrayToCSV(A_Args)

    log_file_1.Write("Send CommandCSV: " CommandCSV)

    ipc.Send(CommandCSV)

} else {

    log_file_2.Write("Listening...")

    ipc:= NamedPipe()

    commandCSV:= ipc.Receive()

    log_file_2.Write("Receive CommandCSV: " CommandCSV)

    _GetRunArgs(CommandCSV, &RunSwitch, &CommandArgsCSV)

    log_file_2.Write("GetRunArgs: " RunSwitch ", " CommandArgsCSV)

    if (RunSwitch="/Run")

        runner.Run(CommandArgsCSV)

    else if (RunSwitch="/RunWait") {

        log_file_2.Write("RunWait CommandArgsCSV: " CommandArgsCSV)

        reply := runner.RunWait(CommandArgsCSV)

        log_file_2.Write("reply: " reply)

        ipc.Send("ACK: " reply)

;        ipc.Close()
    }

    ; CommandCSV := "/Run    ,Script.exe,p1,p2,p3"
    ; CommandCSV := "/RunWait,Script.exe,p1,p2,p3"
    ;=============================================
    _GetRunArgs(CommandCSV, &RunSwitch, &CommandArgsCSV) {
        split       := StrSplit(CommandCSV, ",")
        RunSwitch   := Trim(split[1])
        CommandArgsCSV := Trim(StrReplace(CommandCSV, split[1] ","))
    }
}

StartTask(TaskName:="RunAdmin") {
    cmd := Format('schtasks /run /tn "{}"', TaskName)
    r := RunWait(A_ComSpec ' /c ' cmd, , "Hide")
    if (r) 
        throw Error("Failed to run task: " TaskName)
}

ArrayToCSV(ParamsArray) {
    if (ParamsArray.Length = 0)
            return ""
    CSVString := ""       
    for Index, Value in ParamsArray {
        CurrentVal := String(Value)
        CSVString .= (Index = 1 ? "" : ",") . CurrentVal
    }
    return CSVString
}

ToCSV(Params*) {
    CSVString:= ""
    for index, item in Params {
        CSVString .= (index=Params.Length) ? item : item . ","
    }
    return CSVString
}

