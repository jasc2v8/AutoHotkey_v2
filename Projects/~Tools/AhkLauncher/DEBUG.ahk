#Requires Autohotkey v2.0+
#SingleInstance Force

#Include <Debug>

#Warn Unreachable, Off

targetPath := "D:\Software\DEV\Work\AHK2\Projects\BackupControlTool\BackupControlTool.ahk"

MsgBox FileGetScriptTitle(targetPath)

; Search the first 10 lines of the script for ";TITLE:"
; If found return the text after the ":"
; Else return ""
; Example: "; TITLE: BackupControlTool v3.0" returns "BackupControlTool v3.0"
;----------------------------------------------------------------------------------
FileGetScriptTitle(ScriptPath) {

    if !FileExist(ScriptPath)
        return ""

    content := FileRead(ScriptPath)
    count := 10
    title:= ""

    Loop Parse content, "`r", "`n" {
        if (SubStr(StrReplace(A_LoopField, A_Space, ''), 1, 7) = ";TITLE:") {
            title := SubStr(A_LoopField, InStr(A_LoopField, ":") +1)
        }
        count--
        if (count < 0)
            break
    }
    return title
}

ExitApp()

