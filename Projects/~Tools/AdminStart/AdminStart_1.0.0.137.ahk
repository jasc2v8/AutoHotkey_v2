; TITLE  :  AdminStart v1.0.0.136
; SOURCE :  
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Reads A_Args and runs A_Arg[1]=program.exe, A_Args[2]=param1, A_Args[2]=param2, A_Args[N]=paramn 
; USAGE  :  This is run by a Schedule Task "AdminStart" at runLevel='highest'
; NOTES  :

#Requires AutoHotkey v2+
#SingleInstance

#Include <AdminLauncher>
#Include <LogFile>
#Include <NamedPipe>
#Include <RunShell>

;
; Init
;

logger:= LogFile("D:\AdminStart.log", "CONTROL", false)

;
; Get args from command line
;

if (A_Args.Length = 0 )
    return

;
; Combine args into a command line e.g. MyApp.exe p1 p2 p3
;

cmdLine := RunShell.ArrayToCmdLine(A_Args)

;logger.Write("cmdLine: " cmdLine)

;
; Start AdminLauncher task
;

logger.Write("Start Task AdminLauncher...")

launcher:= AdminLauncher()

launcher.StartTask()

;
; run the cmdLine
;

logger.Write("Run: " cmdLine)

launcher.Send(cmdLine) ; most reliable rather than run (doesn't check path)

