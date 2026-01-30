#Requires AutoHotkey v2+
#SingleInstance Force

#Include Runshell.ahk
;#Include <Runshell>

;#Include <RunAsAdmin>
;cmd := '"C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe" "TEST WITH SPACES"'
;cmd := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST WITH SPACES"
;cmd := ["C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe", "TEST WITH SPACES"]
;out := RunShell(cmd)
;MsgBox out
;ExitApp


;out := RunShell('dir /b "e:\Test Manuals"')
;out := RunShell("dir /b e:\Test Manuals")
;out := RunShell("dir, /b, e:\Test Manuals")
;out := RunWait("dir /b e:\Downloads")
;MsgBox out


;out := RunShell("D:\TEST\StdOutArgs.exe one two three")
;out := RunShell("D:\TEST\StdOut Args.exe, one, two, three")

;out:= RunShell("xcopy d:\test D:\test2 /E /H /C /I")
;RunShell.Run("xcopy d:\test D:\test2 /E /H /C /I")
RunShell.Run("D:\TEST\ShowArgs.exe one two three")
MsgBox

ExitApp


;RunNoWait("dir /b d:\ > d:\test.txt")

RunNoWait("D:\TEST\ShowArgs.exe one two three")

RunNoWait('"' A_AhkPath '"' " D:\TEST\ShowArgs.ahk one two three")

;MsgBox '"A_AhkPath"' " D:\TEST\ShowArgs.ahk one two three"


RunWait(command) {
    shell := ComObject("WScript.Shell")
    exec := shell.Exec(A_ComSpec ' /Q /C ' command)
    ;exec := shell.Exec(command)
    result := exec.StdOut.ReadAll() . "`n" . exec.StdErr.ReadAll()
    return result
}

RunWaitTemp(command) {
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
    shell := ComObject("WScript.Shell")
    launch := "cmd.exe /c " . command . " > temp.txt"
    exec := shell.Run(launch, 0, true)
    ; Read and return the command's output
    output := FileRead("temp.txt")
    FileDelete("temp.txt")
    return output
}

; .Run(strCommand, [intWindowStyle], [bWaitOnReturn]) 

RunNoWait(command) {
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
    shell := ComObject("WScript.Shell")
    exec := shell.Run(command, 0, false)
}

RunNoWaitCMD(command) {
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
    shell := ComObject("WScript.Shell")
    launch := "cmd.exe /c " . command
    exec := shell.Run(launch, 0, false)
    ; Read and return the command's output
    ;output := FileRead("temp.txt")
    ;FileDelete("temp.txt")
    ;return output
}