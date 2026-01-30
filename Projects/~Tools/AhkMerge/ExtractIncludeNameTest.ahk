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

ExtractIncludeName(Line) {
    if (Line = "")
        return ""

    CleanPath := ""

    if RegExMatch(Line, "i)^#Include(?:Again)?\s+(?P<Path>[^;]+)", &Match) {
        RawPath := Match["Path"]

        IsLib := (SubStr(Trim(RawPath), 1, 1) = "<")
        
        ; Character list for trim: space, double-quote, single-quote, <, >
        CleanPath := Trim(RawPath, " `"'<>")
    }
    return CleanPath
}

line := "#Include <MyLib>"
line := "#Include MyLib.ahk"
line := "#Include class_Color.ahk"
line := "#Include class_ColorPicker.ahk"

MsgBox ExtractIncludeName(line)