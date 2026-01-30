; TITLE   : WinExist v1.0
; SOURCE  : jasc2v8
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : 

/*
  TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
TraySetIcon("shell32.dll", 24) ; Blue circle with white ?

DetectHiddenWindows true
SetTitleMatchMode 2 ; contains=default

defaultText:="MyScriptTitle"

Loop {

    title := InputBox("Enter title: ", "WinExist", , defaultText)

    if (title.Result = "Cancel")
        ExitApp()

    timeout := WinWait(title.Value, , 5)

    if (timeout = 0)
        MsgBox "NOT exist!", "WinExist", "Iconi"
    else
        MsgBox "Exist!", "WinExist", "Iconi"

    if title.Value
        defaultText := title.Value

}

