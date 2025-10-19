;ABOUT: Scante <Lib>, classes > Include_classes.ahk, functions > Include_functions.ahk

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#Include String.ahk
#Include <AhkFunctions>

class String3 {
  	static SplitPath(arg) => (SplitPath(arg, &a1, &a2, &a3, &a4, &a5), {FileName: a1, Dir: a2, Ext: a3, NameNoExt: a4, Drive: a5})
}

path := "C:\Windows\Shell32\ping.exe"

MsgBox(path.SplitPath().FileName, "Class String2")

MsgBox(String3.SplitPath(path).Dir, "Class String3")

MsgBox(StrSplitPath(path).NameNoExt, "StrSplitPath")
