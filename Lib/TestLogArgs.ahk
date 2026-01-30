#Requires AutoHotkey v2+
#SingleInstance

#Include <LogFile>

logger:= LogFile("D:\TestLogArgs.log", "TEST", true)

Loop A_Args.Length {
    text:= "Arg " A_Index ": " A_Args[A_Index] 
	logger.Write(text)
}

;FileAppend("TestLog completed successfully.`n", "*")

