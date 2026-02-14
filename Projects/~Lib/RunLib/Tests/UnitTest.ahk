; TITLE  :  UnitText for RunLib v1.0.0.4
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
output:= ""

delay:=500

reply:= MsgBox("Test RunLib with command formats:`n`n" .
    "1. array`n2. bat`n3. cmd`n4. csv`n5. exe`n6. ahk`n7. ps1`n8. String`n`n" .
    "Press OK to start Tests.", "Unit Tests", "OkCancel icon!")

if (reply !="ok")
    ExitApp()

CenterToolTip("Array...")
output:= runner.RunWait(["stdout-args.ps1", "hello world", "ps1"])
if (Trim(output, "`r`n") != "Arg: hello world`r`nArg: ps1")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip( "ahk...")
logFile:= EnvGet("TEMP") "\write-log.tmp"
if FileExist(logFile)
    FileDelete(logFile)
sleep 100
runner.Run("write-log.ahk")
sleep 100
output:= FileRead(logFile)
if (Trim(output, "`r`n") != "This is a test of write-log.ahk")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("bat...")
output:= runner.RunWait("hello-world.bat")
if (Trim(output, "`r`n") != "Hello World .bat")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("cmd...")
output:= runner.RunWait("hello-world.cmd")
if (Trim(output, "`r`n") != "Hello World .cmd")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("csv...")
output:= runner.RunWait("StdOut Args.exe, one, two, three")
if (Trim(output, "`r`n") != "Arg 1: one`nArg 2: two`nArg 3: three")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("exe...")
output:= runner.RunWait("hello-world.exe")
if (Trim(output, "`r`n") != "Hello World .exe")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("ps1...")
output:= runner.RunWait("hello-world.ps1")
if (Trim(output, "`r`n") != "Hello World .ps1")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("ps1 with args...")
output:= runner.RunWait("stdout-args.ps1, hello world, ps1")
if (Trim(output, "`r`n") != "Arg: hello world`r`nArg: ps1")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip("String with args...")
output:= runner.RunWait('"StdOut Args.exe" one two three"')
if (Trim(output, "`r`n") != "Arg 1: one`nArg 2: two`nArg 3: three")
    MsgBox '[' output ']', "error"

ToolTip
MsgBox "Test End.", "Unit Tests", "icon!"

ExitApp()

CenterToolTip(Text := "Hello World", Duration := 500) {
    ToolTip
    if (Text = "")
        return
    CoordMode("ToolTip", "Screen")
    MonitorGetWorkArea(1, &Left, &Top, &Right, &Bottom)
    CenterX := (Right - Left) / 2
    CenterY := (Bottom - Top) / 2
    ToolTip("Running Test:    `n`n" Text, CenterX, CenterY)
    SetTimer(() => ToolTip(), -Duration)
}