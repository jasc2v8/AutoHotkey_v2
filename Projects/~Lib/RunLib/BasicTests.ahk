; TITLE  :  BasicTests for RunLib v1.0.0.4
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Test all the command formats used by RunLib.

#Requires AutoHotkey 2+
#SingleInstance Force
#Warn Unreachable, Off

/*

*/

#Include RunLib.ahk

runner:= RunLib()

reply:= MsgBox("Basic Tests of RunLib with command formats:`n`n" .
    "1. array`n`n2. csv`n`n3. String`n`n4. StdOut & StdErr.`n`n" .
    "Press OK to start Tests.", "Basic Tests", "OkCancel icon!")

if (reply !="ok")
    ExitApp()

; Array: RunLib will add quotes as needed for file path with space
output:= runner.RunWait(["dir", "/b", "C:\Program Files\Windows Defender\DefenderCSP.dll"])

if (Trim(output, "`r`n") != "DefenderCSP.dll")
    MsgBox '[' output ']', "error"

; CSV: RunLib will add quotes as needed for file path with space
output:= runner.RunWait("dir, /b, C:\Program Files\Windows Defender\DefenderCSP.dll")

if (Trim(output, "`r`n") != "DefenderCSP.dll")
    MsgBox '[' output ']', "error"

; String: User must add quotes as needed for file path or parameters with space
 output:= runner.RunWait('dir /b "C:\Program Files\Windows Defender\DefenderCSP.dll"')
 
 if (Trim(output, "`r`n") != "DefenderCSP.dll")
    MsgBox '[' output ']', "error"


; StdOut and StdErr
StdOut:= runner.RunWait('echo test & dir /b "C:abc.xyz"', &StdErr)
 
if (Trim(StdOut, "`r`n") != "test") AND (Trim(StdErr, "`r`n") != "File not found")
    MsgBox 'StdOut:`n`n[' StdOut ']`n`nStdErr:`n`n[' StdErr ']', "StdOut, StdErr"

 MsgBox "Test End.`n`nIf no errors then all tests were successful.", "Basic Tests", "icon!"

