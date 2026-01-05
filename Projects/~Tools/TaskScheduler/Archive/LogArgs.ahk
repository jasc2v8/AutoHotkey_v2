; TITLE: LogArgs v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

global LogFile:= "D:\LogArgs.txt"

if FileExist(LogFile)
    FileDelete(LogFile)

;text:= "The rain in Spain falls mainly on the plain.`n"

text:= A_Clipboard

WriteLog(text)

WriteLog(command) {
    FileAppend(FormatTime(A_Now, "HH:mm:ss") ": " command "`n", LogFile)
}
