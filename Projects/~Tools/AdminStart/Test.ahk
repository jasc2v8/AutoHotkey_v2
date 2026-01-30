#Requires AutoHotkey v2+
#SingleInstance

#Include <LogFile>

logger:= LogFile("D:\Test.log", "CONTROL", true)

logger.Write("Test")

Exit 69

