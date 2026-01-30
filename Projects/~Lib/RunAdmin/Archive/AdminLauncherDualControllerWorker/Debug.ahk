
#Requires AutoHotkey v2.0+
#SingleInstance

#Include <LogFile>
#Include <NamedPipe>

workerPath      := "D:\Software\DEV\Work\AHK2\Projects\~Lib\AdminLauncher\TestWorkerRun.ahk"

msgbox SubStr(workerpath, -4)

MsgBox("The current AHK path is:`n" . A_AhkPath)