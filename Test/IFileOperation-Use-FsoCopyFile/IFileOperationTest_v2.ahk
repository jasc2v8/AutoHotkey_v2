;ABOUT: Update version info and ISS templates
/*
*/
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include IFileOperation.ahk


Source := "D:\SOURCE\source.txt" ; A_Desktop . "\~IFileOperation.txt"
Target   := "D:TARGET" ; A_MyDocuments

Sourcefile := File()
FilSourcefile := FileOpen(Source, "w")
Sourcefile.Length :=  2000 * (1024**2)    ; 2 GB
Sourcefile.Close()

FileOp := IFileOperation()
Source := FileOp.ShellItem(Source)
Target := FileOp.ShellItem(Target)
MsgBox "Source: " . Source . "`nTarget: " . Target

FileOp.CopyItem(Source, Target)

MsgBox "PerformOperations: " . (FileOp.PerformOperations() ? "ERROR" : "OK!")

ObjRelease(Source)
ObjRelease(Target)
ExitApp()