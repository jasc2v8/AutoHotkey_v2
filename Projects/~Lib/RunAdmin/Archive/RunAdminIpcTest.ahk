
#Requires AutoHotkey v2.0+
#SingleInstance

CommandCSV:= "/RunWait, PROGRAM, PARAM1, PARAMn"

GetRunArgs(CommandCSV, &RunSwitch, &CommandArgsCSV)

MsgBox CommandCSV "`n`n[" RunSwitch "]`n`n[" CommandArgsCSV "]"

;CommandCSV      := "/RunWait,Script.exe,p1,p2,p3"
;CommandArgsCSV  :=          "Script.exe,p1,p2,p3"
;=================================================
GetRunArgs(CommandCSV, &RunSwitch, &CommandArgsCSV) {
    split       := StrSplit(CommandCSV, ",")
    RunSwitch   := Trim(split[1])
    CommandArgsCSV := Trim(StrReplace(CommandCSV, split[1] ","))
}