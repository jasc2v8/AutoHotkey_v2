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

Esc::ExitApp()

ScriptFullPath := "D:\Software\DEV\Work\AHK2\Test\ColorPicker\ColorPicker\ColorPicker.ahk"

InCommentBlock := false

ScriptText := FileRead(ScriptFullPath)

    Loop Parse, ScriptText, "`n", "`r" {

        line := A_LoopField
        lineNumber := A_Index

        if Str.IsEmpty(line)
            continue

        line := Trim(line)

        if Str.StartsWith(line, "/*")
            InCommentBlock := true
        else if Str.StartsWith(line, "*/")
            InCommentBlock := false

        if (InCommentBlock)
            continue

        if Str.StartsWith(line, ";")
            continue

            
        ; Check for Class
        if RegExMatch(Line, "i)^class\s+(?P<Name>[a-zA-Z0-9_]+)", &Match) {
            itemType := "Class"
            itemName := Match["Name"]
            itemLine := A_Index
            ;CountBraces := true

        ; Check for Function (standard or fat-arrow: QuickLog(msg) => FileAppend(msg "`n", "log.txt"))
        } else if RegExMatch(Line, "(?i)(?:if\s+)?(?<![\.\w])(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match) {
            itemType := "Function"
            itemName := Match["Name"]
            itemLine := A_Index
            ;CountBraces := true

        ; Continue scanning
        } else {
            continue
        }

        MsgBox  "key: " itemType "_" itemName .
                "`n`nitemLine: " itemLine .
                "`n`nPath: " ScriptFullPath , "ScanScriptToMap"


    }
