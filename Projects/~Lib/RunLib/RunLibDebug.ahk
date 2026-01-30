#Requires AutoHotkey v2+
#SingleInstance Force

#Include <ObjList>

#Include RunLib.ahk
;#Include <Runshell>

runner := RunLib()

p1 := "one"
p2 := "two"
p3 := "three"

;cmd:= "D:\TEST\ShowArgs.exe one two three"
;RunWait(cmd)

;
; Run Tests
;

;OK:
;cmd:= '"D:\TEST\Show Args.exe" one two three'
;cmd:= "D:\TEST\Show Args.exe, one, two, three"
;cmd:= ["D:\TEST\Show Args.exe", "one", "two", "three"]
;cmd:= "D:\TEST\Test Log.exe"
;cmd:= "D:\TEST\Test Log.ahk"
;cmd:= "dir /b  D:\TEST\ > D:\test.log"
;cmd:= "D:\TEST\TestLog.ahk"
; NO cmd:= "D:\TEST\StdOutArgs.exe one two three"
;runner.Run(cmd)

;
; RunWait Tests
;

;cmd:= "dir /b  D:\TEST\ > D:\test.log" ; stdout not returned
cmd:= "dir /b D:\TEST\"

;no but why?cmd:= "D:\TEST\StdOutArgs.exe one 'D:\2025 London Paris' three"

; dot := InStr(cmd, ".")

; if (dot) {  
;     exe := SubStr(cmd, 1, dot+3)
;     params := SubStr(cmd, dot+4)
;     newExe := '"' exe '"'
;     newCmd:= StrReplace(cmd, exe, newExe)

;     newLine := "'" newExe params '"' "'"


;     ; split:=StrSplit(newCmd, A_Space)
;     ; newLine:=""
;     ; for index, item in split {
;     ;     newLine.= (index>1) ? '"' . item . '"' . A_Space : A_Space . item
;     ; }
;     ; newLine:= RTrim(NewLine, A_Space)
;     MsgBox cmd "`n`n" newLine
; }
;cmd:= newLine
;cmd:= newCmd
;cmd:= "D:\TEST\StdOutArgs.exe" one two three"
; ok cmd:= '"D:\TEST\StdOutArgs.exe" "one" "two" "three"'
;ok cmd:= '"D:\TEST\StdOutArgs.exe" one two three"'

;cmd:= "D:\TEST\StdOut Args.ahk, one, two, three"

;no cmd:= "D:\TEST\ShowArgs.exe one two three"
;no cmd:= '"D:\TEST\ShowArgs.exe" one two three'
;ok cmd:= '"D:\TEST\ShowArgs.exe" one two three"'


;cmd:= "D:\TEST\Show Args.exe, one, two, three"
;cmd:= ["D:\TEST\Show Args.exe", "one", "two", "three"]
cmd:= ["D:\TEST\Show Args.ahk", "one", "two", "three"]

;ok cmd:= ["D:\TEST\StdOutArgs.exe", "one", "D:\2025 London Paris", "three"]

out:= runner.RunWait(cmd)
MsgBox out

;cmd:= "dir, /b,  D:\TEST\"
;cmdArray:=runner.CSVToArray(cmd)
;ObjList(cmdArray, "TITLE")
;SplitPath(cmdArray[1],,,&Ext)
;MsgBox cmdArray[1] ", Ext: " Ext ", IsExe: " runner._IsExe(cmdArray[1]) ", Exist: " FileExist(cmdArray[1])
;OK:
;MsgBox runner.ToCSV("one", "two", "three")
;MsgBox runner.ToCSV(p1, p2, p3)
;MsgBox "[" runner.ToCSV() "]"

;ObjList(runner.ToArray("one", "two", "three"), "TITLE")
;ObjList(runner.ToArray(p1, p2, p3), "TITLE")
;ObjList(runner.ToArray(), "TITLE")

;OK:
;var := runner.ToArray()
;MsgBox Type(var) ": " var.Length ; isLength = 0

;OK:
;var := runner.ArrayToCSV([p1, p2, p3])
;MsgBox var "`n`n", Type(var)

; Text CSV to array
;var := runner.ToArray("one, two, three")
;ObjList(var, "TITLE")

;cmd := runner.CSVToArray("D:\TEST\ShowArgs.exe, one, two, three")
;out := runner.RunWait(cmd)



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
;;ObjList(runner.ToArray("one", "two", "three"), "TITLE")


;out:= RunShell("xcopy d:\test D:\test2 /E /H /C /I")
;RunShell.Run("xcopy d:\test D:\test2 /E /H /C /I")
;RunShell.Run("D:\TEST\ShowArgs.exe one two three")
MsgBox

ExitApp


;RunNoWait("dir /b d:\ > d:\test.txt")

;RunNoWait("D:\TEST\ShowArgs.exe one two three")

;RunNoWait('"' A_AhkPath '"' " D:\TEST\ShowArgs.ahk one two three")

;MsgBox '"A_AhkPath"' " D:\TEST\ShowArgs.ahk one two three"


; RunWait(command) {
;     shell := ComObject("WScript.Shell")
;     exec := shell.Exec(A_ComSpec ' /Q /C ' command)
;     ;exec := shell.Exec(command)
;     result := exec.StdOut.ReadAll() . "`n" . exec.StdErr.ReadAll()
;     return result
; }

; RunWaitTemp(command) {
;     ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
;     shell := ComObject("WScript.Shell")
;     launch := "cmd.exe /c " . command . " > temp.txt"
;     exec := shell.Run(launch, 0, true)
;     ; Read and return the command's output
;     output := FileRead("temp.txt")
;     FileDelete("temp.txt")
;     return output
; }

; ; .Run(strCommand, [intWindowStyle], [bWaitOnReturn]) 

RunNoWait(command) {
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
    shell := ComObject("WScript.Shell")
    shell.Run(command, 0, false)
}

; RunNoWaitCMD(command) {
;     ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
;     shell := ComObject("WScript.Shell")
;     launch := "cmd.exe /c " . command
;     exec := shell.Run(launch, 0, false)
;     ; Read and return the command's output
;     ;output := FileRead("temp.txt")
;     ;FileDelete("temp.txt")
;     ;return output
; }