; TITLE  :  UnitText for RunLib v1.0.0.4
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Test all the command formats used by RunLib.

#Requires AutoHotkey 2+
#SingleInstance Force
#Warn Unreachable, Off

/*

*/

;#Include <RunLib>
#Include ..\RunLib.ahk

runner:= RunLib()
output:= ""

delay:=500

reply:= MsgBox("Test RunLib with command formats:`n`n" .
    "1. array`n2. ahk`n3. bat`n3. cmd`n4. csv`n5. exe`n6. ps1`n7. String`n8. StdOut & StdErr`n`n" .
    "Press OK to start Tests.", "Unit Tests", "OkCancel icon!")

if (reply !="ok")
    ExitApp()

CenterToolTip("Array")
;output:= runner.RunWait(["stdout-args.ps1", "hello world", "ps1"]) ; stdout-args.exe will read 3 params; hello, world, ps1
output:= runner.RunWait(["stdout-args.ps1", '"hello world"', "ps1"]) ; force stdout-args.exe to read 2 params; hello world, ps1
if (Trim(output, "`r`n") != "Arg: hello world`r`nArg: ps1")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("ahk")
logFile:= EnvGet("TEMP") "\write-log.tmp"
if FileExist(logFile)
    FileDelete(logFile)
sleep 100
command:=runner.ToCSV("write-log.ahk")
runner.Run(command)
sleep 300
output:= FileRead(logFile)
if (Trim(output, "`r`n") != "This is a test of write-log.ahk")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("bat")
output:= runner.RunWait("hello-world.bat")
if (Trim(output, "`r`n") != "Hello World .bat")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("cmd")
output:= runner.RunWait("hello-world.cmd")
if (Trim(output, "`r`n") != "Hello World .cmd")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("csv")
output:= runner.RunWait("StdOut Args.exe, one, two, three")
if (Trim(output, "`r`n") != "Arg 1: one`nArg 2: two`nArg 3: three")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("exe")
output:= runner.RunWait("hello-world.exe")
if (Trim(output, "`r`n") != "Hello World .exe")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("ps1")
;output:= runner.RunWait("stdout-args.ps1, hello, world, ps1")              ; stdout-args.exe will read 3 params; hello, world, ps1
output:= runner.RunWait("stdout-args.ps1, hello world, ps1")                ; stdout-args.exe will read 2 params; hello world, ps1
;output:= runner.RunWait("stdout-args.ps1," '"' "hello world" '"' ", ps1")  ; force stdout-args.exe to read 2 params; hello world, ps1 - AWKWARD!
;output:= runner.RunWait(["stdout-args.ps1", '"hello world"', "ps1"])       ; force stdout-args.exe to read 2 params; hello world, ps1 - Array
;output:= runner.RunWait("stdout-args.ps1 `"hello world`" ps1")             ; force stdout-args.exe to read 2 params; hello world, ps1 - String with quotes

if (Trim(output, "`r`n") != "Arg: hello world`r`nArg: ps1")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("String")
; different ways to handle spaces with quotes:
;output:= runner.RunWait("StdOutArgs.exe one two three")        ; no space in file path
;output:= runner.RunWait('"StdOut Args.exe" one two three')     ; space in file path
output:= runner.RunWait("`"StdOut Args.exe`" one two three")   ; space in file path
if (Trim(output, "`r`n") != "Arg 1: one`nArg 2: two`nArg 3: three")
    MsgBox '[' output ']', "error"


Sleep delay
CenterToolTip("StdOut and StdErr")
StdOut:= runner.RunWait('echo test & dir /b "C:abc.xyz"', &StdErr)
 
if (Trim(StdOut, "`r`n") != "test") AND (Trim(StdErr, "`r`n") != "File not found")
    MsgBox 'StdOut:`n`n[' StdOut ']`n`nStdErr:`n`n[' StdErr ']', "StdOut, StdErr"

Sleep delay
ToolTip
MsgBox "Test End.`n`nIf no errors then all tests were successful.", "Unit Tests", "icon!"

ExitApp()

CenterToolTip(Text := "Hello World", Duration := 500) {
    ToolTip
    if (Text = "")
        return
    CoordMode("ToolTip", "Screen")
    MonitorGetWorkArea(1, &Left, &Top, &Right, &Bottom)
    CenterX := (Right - Left) / 2
    CenterY := (Bottom - Top) / 2
    ToolTip("Running Test:  `n`n" Text, CenterX, CenterY)
    SetTimer(() => ToolTip(), -Duration)
}