
#Requires AutoHotkey 2+
#SingleInstance Force
#Warn Unreachable, Off

logFile:= EnvGet("TEMP") "\write-log.tmp"

FileAppend("This is a test of write-log.ahk", logFile)

