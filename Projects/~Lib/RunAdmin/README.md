# RunAdmin README

## Setup - Must perform the following before running the Demo!

    1. Copy RunAdmin.ahk to your desired location, e.g. %LOCALAPPDATA% "\Programs\AutoHotkey\RunAdmin\RunAdmin.ahk"
    2. Copy RunAdminIPC.ahk to your desired lib location, e.g. %USEDRPROFILE% "\Documents\AutoHotkey\Lib\RunAdminIPC.ahk"
    3. Use RunAdminCreateTask to run target, e.g. %LOCALAPPDATA% "\Programs\AutoHotkey\RunAdmin\RunAdmin.ahk"
    4. Use RunAdminDemo.ahk to test.
    5. Use RunAdminDemoController.ahk for another test. This test will run RunAdminDemoWorker.ahk.

## Use Cases:

        1. Run Directly
        2. Run via NamedPipe IPC
        3. Run via Shortcut.lnk
        4. Setup

###	Case 1. Run Directly

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

###	Case 2. Run via NamedPipe IPC

		Start Task RunAhk then send Command via NamedPipe IPC:
		
			ipc := RunAdminIPC()
			ipc.StartTask()	; Starts Task AhkRun which starts AhkRun.ahk elevated in Receive() mode.
			ipc.Send("/Run, Script.ahk[.exe], Parameters") ; CSV
		-or-
			ipc.Send("/RunWait, Script.ahk[.exe], Parameters") ; CSV
			reply := ipc.Receive()
			
###	Case 3. Run via Shortcut.lnk
    
        /Run no reply only. /RunWait with reply not supported:
	
            Shortcut Target: A_AhkPath RunAdmin.ahk /Run PROGRAM PARAMETERS
            Shortcut Target:           RunAdmin.exe /Run PROGRAM PARAMETERS

		Shortcut Target Examples:
            %PROGRAMFILES%\AutoHotkey\v2\AutoHotkey64.exe "%USERPROFILE%\Documents\AutoHotkey\Lib\RunAdmin.ahk" "/Run" "%ProgramFiles(x86)%\SyncBackSE\SyncBackSE.exe" "-monoff" "MY PROFILE"
            %USERPROFILE%\Documents\AutoHotkey\Lib\RunAdmin.exe /Run "D:\Software\DEV\Work\AHK2\Projects\~Tools\SearchBarReset\SearchBarReset.exe"