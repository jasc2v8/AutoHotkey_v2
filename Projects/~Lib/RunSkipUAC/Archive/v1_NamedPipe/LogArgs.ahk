; TITLE: LogArgs v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFileHelper>

logger:= LogFile("D:\LogArgs.txt")

;logger.Clear()

logger.Write("Log Arguments.")
