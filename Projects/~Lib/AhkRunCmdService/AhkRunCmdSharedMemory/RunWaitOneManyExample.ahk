; TITLE: BackupControlTool v2.3, 
; 
/*
    TODO:
        SharedMemory("AhkRunCmdService")

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <Debug>
;#Include <IniLite>
;#Include .\RunCMD.ahk
;#Include <RunCMD>
;#Include <SharedMemory>

OnExit(ExitFunc)

RunWaitOne(command) {
    shell := ComObject("WScript.Shell")
    ; Execute a single command via cmd.exe
    exec := shell.Exec(A_ComSpec " /C " command)
    ; Read and return the command's output
    return exec.StdOut.ReadAll()
}

RunWaitMany(commands) {
    shell := ComObject("WScript.Shell")
    ; Open cmd.exe with echoing of commands disabled
    exec := shell.Exec(A_ComSpec " /Q /K echo off")
    ; Send the commands to execute, separated by newline
    exec.StdIn.WriteLine(commands "`nexit")  ; Always exit at the end!
    ; Read and return the output of all commands
    return exec.StdOut.ReadAll()
}

; MsgBox RunWaitMany("
; (
; dir d:\test.txt,
; dir D:\My Test Folder\icacls.exe .
; )"), "RunWaitMany"

; correct on cmd line: "D:\My Test Folder\icacls.exe" "D:\Lock Me" /deny everyone:f


cmd:= '"' '"' "D:\My Test Folder\icacls.exe" '"' A_Space '"'
cmd.= '"' '"' "D:\Lock Me" '"' A_Space '"'
cmd.= '"' "/deny everyone:f" '"'

exe     := "D:\My Test Folder\icacls.exe"
;param1  .= "D:\Lock Me" A_Space
param1  .= "D:\Lock"
param2  .= "/deny everyone:f"

;MsgBox RunWaitOne(exe " " param1 " " param2), "RunWaitOne"

; ok cmd:= " dir C:\ > D:\DirTest.txt"
; ok cmd:= " dir " '"' "D:\My Test Folder" '"'
; no cmd:= '"' "D:\My Test Folder\icacls.exe" '"' '"' "D:\Lock" '"' "/deny everyone:f"
; ok cmd:= "C:\Windows\System32\notepad.exe " '"' "D:\My Test Folder\test.txt" '"'
; no cmd:= '"D:\"My Test Folder"\notepad.exe"' ;  A_Space " D:\test.txt"

;Run A_ComSpec ' /c ""C:\My Utility.exe" "param 1" "second param" >"C:\My File.txt""'

; no Run A_ComSpec ' /c ""D:\notepad.exe" "D:\test.txt" "" >"D:\MyFile.txt""'

;Run 'MyProgram.exe Param1 Param2'
; NO Run 'D:\notepad.exe D:\test.txt'

;Run '"D:\"My Test Folder"\notepad.exe " "D:\test.txt"'

; ok Run A_ComSpec ' /c ""explorer" "%TEMP%"'
; ok Run A_ComSpec " /c notepad.exe D:\test.txt"
; NO Run A_ComSpec " /c " '"' "D:\My Test Folder\notepad.exe" '"' "D:\test.txt"

;filename := "D:\test.txt"
; ok RunWait "notepad " . filename

;ok filename := "D:\My Test Folder\test.txt"
;ok RunWait "notepad " . filename

; ok Run A_ComSpec ' /c "notepad " ' . filename ; filename := "D:\test.txt"
; ok filename := "D:\My Test Folder\test.txt"
; ok Run A_ComSpec ' /c "notepad " ' . filename ; filename := "D:\test.txt"

exe := "D:\My Test Folder\notepad.exe"
filename := "D:\My Test Folder\test.txt"
; no Run A_ComSpec ' /c ' '"D:\My Test Folder\notepad.exe "'  . filename


; Define your executable path and parameters
; executable := "D:\My Test Folder\notepad.exe"
; param1 := "" ; "first parameter with spaces"
; param2 := "" ; "second parameter"
; outputFile := "D:\My Test Folder\test.txt"

; ; Construct the command string for cmd.exe
; ; The entire string after /c needs to be quoted.
; ; Individual paths/parameters with spaces also need to be quoted within that string.
;command := A_ComSpec . " /c '" . Chr(34) . executable . Chr(34) . " " . Chr(34) . param1 . Chr(34) . " " . Chr(34) . param2 . Chr(34) . " >" . Chr(34) . outputFile . Chr(34) . "'"

;YES!!!!!!!!!!!!!!!
; myProgram := "C:\Windows\System32\notepad.exe"
; filePath := "D:\My Test Folder\test.txt"
;commandLine := myProgram . " " . Chr(34) . filePath . Chr(34)
;Run A_ComSpec . " /c " . Chr(34) . commandLine . Chr(34)

;YES!!!!!!!!!!!!!!!
;DQ:='"'
DQ:=Chr(34)
SQ:=Chr(39)
 myProgram :=  "C:\Windows\System32\notepad.exe"
 filePath := "D:\My Test Folder\test.txt"
commandLine := myProgram . A_Space . DQ . filePath . DQ
;Run A_ComSpec . " /c " . DQ . commandLine . DQ
;RunWaitOne(commandLine), "RunWaitOne"

; MsgBox RunWaitOne(commandLine) "`n`nCommand:`n`n" commandLine, "RunWaitOne"
; ExitApp
;YES!!!!!!!!!!!!!!!
; https://www.autohotkey.com/boards/viewtopic.php?t=97365
;App := "C:\a b\a.exe"
;Arg := "hello world"
;Run A_ComSpec ' /c " "' App '" "' Arg '" " '

;App := "C:\Windows\System32\notepad.exe"
;Arg := "D:\My Test Folder\test.txt"
;Run A_ComSpec ' /c " "' App '" "' Arg '" " '

;MsgBox "?", "RunWaitOne"
;ExitApp

;YES!!!!!!!!!!!!!!!
;YES!!!!!!!!!!!!!!!
;YES!!!!!!!!!!!!!!!
DQ:=Chr(34)

App := "D:\My Test Folder\ShowArgs.exe"
;App := "C:\Windows\System32\notepad.exe"
Arg := "D:\My Test Folder\test.txt"
Arg2 := "D:\MyTestFolder\test.txt"

EndQuote := ""
EndQuote := '"'

;YES!!!!!!!!!!!!!!!
;App := "D:\My Test Folder\icacls.exe"
;Arg := "D:\Lock Me"
;Arg2 := "/deny everyone:f"
;Arg2 := "/remove everyone"

; CommandLine := '"' '"' App '"' A_Space
; CommandLine .= '"' Arg '"' A_Space
; CommandLine .= Arg2 A_Space
; EndQuote := ""

CommandLine := DQ DQ App DQ A_Space
CommandLine .= DQ Arg DQ A_Space
CommandLine .= Arg2 A_Space
CommandLine .= '"'

;MsgBox CommandLine

;MsgBox RunWaitOne(CommandLine)

App := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
Arg := "" ; "", "-shutdown", "-standby"
;SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
Arg2 := "TEST"

MsgBox RunCMD(App, Arg, Arg2)
;Run(A_ComSpec " /C " CommandLine, , "Hide")

ExitApp






























; The cmd variable now holds: "\"D:\My Test Folder\icacls.exe\" \"D:\Lock Me /deny everyone:f\""
;cmd := '"\"D:\My Test Folder\notepad.exe\" \"D:\My Test Folder\test.txt\""'
;Run(A_ComSpec " /C " cmd, , "Hide")

;FullCmd := DQ . App . DQ . A_Space . DQ . Arg . DQ

;Run(A_ComSpec " /C " FullCmd, , "Hide")

;Run A_ComSpec " /C "  DQ . App . DQ  ; . A_Space . DQ . Arg . DQ
MsgBox "?", "RunWaitOne"
ExitApp

;YES!!!!!!!!!!!!!!!
;DQ:='"'
DQ:=Chr(34)

;SyncBackPath := '"C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"'
SyncBackPath := DQ . "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe" . DQ
SyncBackAction := "" ; "", "-shutdown", "-standby"
;SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
SyncBackProfile := "TEST"
commandLine := SyncBackPath . A_Space . SyncBackAction . A_Space . SyncBackProfile

if InStr(SyncBackPath, "\") AND InStr(SyncBackPath, A_Space) {
    exePath := DQ . SyncBackPath . DQ
} else {
    exePath := SyncBackPath
}
commandLine := exePath . A_Space . SyncBackAction . A_Space . SyncBackProfile

;  cmd := '"D:\My Test Folder\icacls.exe" "D:\Lock Me" /deny everyone:f'

myProgram := "D:\My Test Folder\icacls.exe"
MyFilePath := "D:\Lock Me"
MyParam := "/deny everyone:f"

if InStr(myProgram, "\") AND InStr(myProgram, A_Space) {
    exePath := DQ . myProgram . DQ
} else {
    exePath := myProgram
}

if InStr(MyFilePath, "\") AND InStr(MyFilePath, A_Space) {
    filePath := DQ . MyFilePath . DQ
} else {
    filePath := MyFilePath
}

if InStr(MyParam, "\") AND InStr(MyParam, A_Space) {
    param := DQ . MyParam . DQ
} else {
    param := MyParam
}

CommandLine := '"' '"' myProgram '"' A_Space
EndQuote := '"'
CommandLine .= '"' MyFilePath '"' A_Space
EndQuote := ""
CommandLine .= MyParam A_Space
;commandLine := myProgram . A_Space . DQ . filePath . DQ . A_Space . DQ . param . DQ 
commandLine := myProgram . A_Space . filePath . A_Space .  param . EndQuote



MsgBox RunWaitOne(commandLine) "`n`nCommand:`n`n" commandLine, "RunWaitOne"

ExitApp

MsgBox RunWaitMany("
(
"D:\My Test Folder\icacls.exe "D:\Lock Me" /deny everyone:f .
)"), "RunWaitMany"

ExitApp

MsgBox RunWaitOne("dir " A_ScriptDir), "RunWaitOne"

MsgBox RunWaitMany("
(
dir d:\test.txt,
dir "D:\My Test Folder" .
)"), "RunWaitMany"

; RunWaitOne(command) {
;     shell := ComObject("WScript.Shell")
;     ; Execute a single command via cmd.exe
;     exec := shell.Exec(A_ComSpec " /C " command)
;     ;exec := shell.Exec(A_ComSpec command)
;     ; Read and return the command's output
;     return exec.StdOut.ReadAll()
; }

; RunWaitMany(commands) {
;     shell := ComObject("WScript.Shell")
;     ; Open cmd.exe with echoing of commands disabled
;     exec := shell.Exec(A_ComSpec " /Q /K echo off")
;     ; Send the commands to execute, separated by newline
;     exec.StdIn.WriteLine(commands "`nexit")  ; Always exit at the end!
;     ; Read and return the output of all commands
;     return exec.StdOut.ReadAll()
; }

ExitApp

ExitFunc(*) {
    mem:=""
    ExitApp()
}