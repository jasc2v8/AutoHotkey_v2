; TITLE  :  UnitText for RunLib v1.0.0.4
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Test all the command formats used by RunLib.

#Requires AutoHotkey 2+
#SingleInstance Force
#Warn Unreachable, Off

/*

*/

#Include ..\RunLib.ahk

runner:= RunLib()
output:= ""

delay:=500

reply:= MsgBox("Test RunLib with command formats:`n`n" .
    "1. array`n2. bat`n3. cmd`n4. csv`n5. exe`n6. ahk`n7. ps1`n8. String`n`n" .
    "Press OK to start Tests.", "Unit Tests", "OkCancel icon?")

if (reply !="ok")
    ExitApp()

CenterToolTip("Array...")
output:= runner.RunWait(["stdout-args.ps1", "hello world", "ps1"])

if (Trim(output, "`r`n") != "Arg: hello world`r`nArg: ps1")
    MsgBox '[' output ']', "error"

Sleep delay
CenterToolTip( "ahk...")
output:= runner.RunWait("hello-world.ahk")

if (Trim(output, "`r`n") != "Hello World .ahk")
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
MsgBox "Test End.", "Unit Tests"

ExitApp()

CenterToolTip(Text := "Hello World", Duration := 1000) {
    if (Text = "")
        return
    CoordMode("ToolTip", "Screen")
    MonitorGetWorkArea(1, &Left, &Top, &Right, &Bottom)
    CenterX := (Right - Left) / 2
    CenterY := (Bottom - Top) / 2
    ToolTip("Running Test:`n`n" Text, CenterX, CenterY)
    SetTimer(() => ToolTip(), -Duration)
}