;ABOUT: AhkMerge v0.0.0.0

;TODO:
;   FunctionsCSV.Txt
;       Exclude everything inside a class e.g. class Debug {}
;   [x] Exclude comments
;       also from #Include files
;   [Combine] [Merge] [Cancel]
;       Select ahk, press combine, choose multi files, combine, save as ahk_Combined.ahk

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <StringLib>

Clean(script) {

    cleanScript := ""
    
    Loop Parse script, "`n", "`r" {

        line := Trim(A_LoopField)

        line := Str.Replace(line, "#Include" , ";#Include")
        line := Str.Replace(line, "#Requires", ";#Requires")

        ; Exclude test functions at bottom of script
        if Str.StartsWith(LTrim(line), "If (A_LineFile == A_ScriptFullPath)") {
             break
        }

        if !Str.IsEmpty(line) ; (!StrLen(line)=0)
            cleanScript .= line "`n"
    }
    return cleanScript
}

filePath := "D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\BackupTool.ahk"

script := FileRead(filePath)

outFile := A_ScriptDir "\cleaned.ahk"

script := Clean(script)

if FileExist(outFile)
    FileDelete(outFile)

FileAppend(script, outFile)

Run("C:\Users\Jim\AppData\Local\Programs\Microsoft VS Code\Code.exe " outfile)

;MsgBox Clean(script)
;MsgBox outFile

;test := ""
;MsgBox StrLen(test)