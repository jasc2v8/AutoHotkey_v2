

;out := RunWait("dir /b d:\")
;MsgBox out

;out := RunWait("D:\TEST\StdOutArgs.exe one two three")
out := RunWait('"D:\TEST\StdOut Args.exe" one two three')
MsgBox out

;RunNoWait("dir /b d:\ > d:\test.txt")

RunNoWait("D:\TEST\ShowArgs.exe one two three")

RunNoWait('"' A_AhkPath '"' " D:\TEST\ShowArgs.ahk one two three")

;MsgBox '"A_AhkPath"' " D:\TEST\ShowArgs.ahk one two three"

RunWait(command) {
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