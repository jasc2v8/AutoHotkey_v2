
#Requires AutoHotkey v2.0+

filePath:="D:\WatchFolder\WatchFile.txt"

MsgBox("Read: " filePath)

text:=FileRead(filePath)

MsgBox("Modify: " filePath)

text:="New Text"

FileAppend(text, filePath)

MsgBox FileRead(filePath)
