; TITLE: LogArgs v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFile>

logger:= LogFile("D:\LogFileTest.log", "TEST")

logger.Write("Create server.")

logger.Write("Read request.")

logger.Write("Send reply.")

logger.Write("Pipe close.")

SoundBeep

MsgBox("Check log file.")

logger.Clear()

logger.Write("Cleared?")

logger.Disable()

logger.Write("Disabled?")

MsgBox("Check log file.")


