; ABOUT: Beta 1
 /**
  * TODO:
  *     Fix Size (again) "400,200" bad,  "400,200,," good
  * 
  */
#Requires AutoHotkey v2.0
;#NoTrayIcon

;DEBUG
#SingleInstance Force
#Include <Debug>

#Include D:\Software\DEV\Work\AHK2\Test\MsgBoxNew\MsgBoxNew_Functions.ahk

Escape::ExitApp()

Persistent

SubQuickDemos:
MsgBoxNew()
AX_MsgBoxOpt.FontSize := 18
MsgBoxNew()
InputBoxNew(,,, "default")
AX_InputBoxOpt.FontSize := 18
InputBoxNew(,,, "default")
ProgressNew("", "hello", "hello"), Sleep(1500), ProgressNew("Off")
SplashImageNew(A_AhkPath), Sleep(1500), SplashImageNew("Off")
ToolTipNew("hello"), Sleep(3000), ToolTipNew()
AX_ToolTipOpt.FontSize := 18
ToolTipNew("hello"), Sleep(3000), ToolTipNew()
Borders(100, 100, 200, 200)
return