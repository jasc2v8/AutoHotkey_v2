#Requires AutoHotkey v2+
#SingleInstance

#Include <LogFile>

logger:= LogFile("D:\Test.log", "TestLog", true)

logger.Write("Test Log.")

;FileAppend("TestLog completed successfully.`n", "*")

