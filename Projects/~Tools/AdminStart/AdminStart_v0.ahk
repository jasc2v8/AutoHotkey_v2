; TITLE  :  AdminStart v1.0
; SOURCE :  
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Reads A_Args and runs A_Arg[1]=program.exe, A_Args[2]=param1, A_Args[2]=param2, A_Args[N]=paramn 
; USAGE  :  This is run by a Schedule Task "AdminStart" at runLevel='highest'
; NOTES  :

#Requires AutoHotkey v2+
#SingleInstance

#Include <LogFile>
#Include <NamedPipe>
#Include <AdminLauncher>

logger:= LogFile("D:\AdminStart.log", "CONTROL", true)

if (A_Args.Length = 0 )
    return

Params := ""

; Loop through the arguments to build the parameter string
for index, value in A_Args
{
    if (index=1) {
        TargetExe:=value
        continue
    }
    Params .= A_Space . value
}

;MsgBox "TargetExe: " TargetExe "`n`nParams: " Params

logger.Write("TargetExe: " TargetExe)
logger.Write("Params   : " Params)

; Start Task AdminLauncher
;MsgBox(,"Search Bar Reset")

runner:= AdminLauncher()

logger.Write("Start Task AdminLauncher...")

runner.StartTask()

; Send the command line to AdminLauncher

logger.Write("Run: " TargetExe " " Params)

runner.Run(TargetExe Params)

runner.Send("START")

reply:= runner.Receive()

logger.Write("Reply Received: " reply)

;MsgBox("Reset Complete.","Search Bar Reset")
