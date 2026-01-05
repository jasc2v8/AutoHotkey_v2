; TITLE: BackupControlTool v2.3, 
; 
/*
    TODO:
        SharedMemory("AhkRunCmdService")

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <Debug>
;#Include <IniLite>
;#Include .\RunCMD.ahk
#Include <RunCMD>
;#Include <SharedMemory>
#Warn Unreachable, Off

Esc::ExitApp()

;OnExit(ExitFunc)

; full_command_line := DllCall("GetCommandLine", "str")

; if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\\ S)"))
; {
;     try
;     {
;         if A_IsCompiled
;             Run '*RunAs "' A_ScriptFullPath '" /restart'
;         else
;             Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
;     }
;     ExitApp  ; Exit the current, non-elevated instance
; }

class RunWaitOne {
    static Call(command) {
        shell := ComObject("WScript.Shell")
        exec := shell.Exec(A_ComSpec " /C " command)
        return exec.StdOut.ReadAll()
    }
}

class RunWaitMany_OLD {

    static Call(Parameters*) {

        DQ:= '"'
        EndQuote:= '"'
        ;CommandLine := A_ComSpec . " /D /Q /C "
        CommandLine := ""

        for index, value in Parameters {

            MsgBox index ": " value , 'DEBUG index, value'

            ; If the first parameter is a file path, add extra quotes and EndQuote
            if (index = 1) {
                ; If a file path with spaces, add a leading double quote and double quotes around the file path
                if InStr(value, "\") AND InStr(value, A_Space){
                    CommandLine .= DQ DQ value DQ A_Space
                    ;EndQuote := DQ
                } else {
                    ; Not a file path, no quotes
                    CommandLine .= value A_Space
                }
            } else {
                ; If a Parameter is a file path with spaces, add quotes
                if InStr(value, "\") AND InStr(value, A_Space) {
                    CommandLine .= DQ value DQ A_Space
                    ;EndQuote := ""
                } else {
                    ; Not a file path, no quotes
                    CommandLine .= value A_Space
                }
            }

            MsgBox index ": " CommandLine , 'DEBUG forming CommandLine'

        }

        CommandLine :=  RTrim(CommandLine, A_Space)
        CommandLine .=  EndQuote

        MsgBox "[" CommandLine "]", 'DEBUG final CommandLine'

        shell := ComObject("WScript.Shell")
        exec := shell.Exec(A_ComSpec " /C " CommandLine)
        ;exec := shell.Exec(CommandLine)
        return exec.StdOut.ReadAll()
    }
}

class RunWaitMany_OLD2 {

    static Call(Parameters*) {

        DQ:= '"'
        EndQuote:= '"'
        ;CommandLine := A_ComSpec . " /D /Q /C "
        CommandLine := ""

        for index, value in Parameters {

            MsgBox index ": " value , 'DEBUG index, value'

            ; If the first parameter is a file path, add extra quotes and EndQuote
            if (index = 1) {
                ; If a file path with spaces, add a leading double quote and double quotes around the file path
                if InStr(value, "\") AND InStr(value, A_Space){
                    CommandLine .= DQ DQ value DQ A_Space
                    ;EndQuote := DQ
                } else {
                    ; Not a file path, no quotes
                    CommandLine .= value A_Space
                }
            } else {
                ; If a Parameter is a file path with spaces, add quotes
                if InStr(value, "\") AND InStr(value, A_Space) {
                    CommandLine .= DQ value DQ A_Space
                    ;EndQuote := ""
                } else {
                    ; Not a file path, no quotes
                    CommandLine .= value A_Space
                }
            }

            MsgBox index ": " CommandLine , 'DEBUG forming CommandLine'

        }

        CommandLine :=  RTrim(CommandLine, A_Space)
        CommandLine .=  EndQuote

        MsgBox "[" CommandLine "]", 'DEBUG final CommandLine'

        shell := ComObject("WScript.Shell")
        exec := shell.Exec(A_ComSpec " /C " CommandLine)
        ;exec := shell.Exec(CommandLine)
        return exec.StdOut.ReadAll()
    }
}

class RunCMD_TEST {

    static Call(Parameters*) {

        this.CommandLine := ""

        if this.IsStringArray(Parameters) {
            ; Loop Parse, Parameters[1], "," {
            ;     MsgBox A_Index ": " A_LoopField, "ParseCSV - String Array (CSV)"
            ; }
            this.CommandLine := this.ParseCSV(Parameters*)

        } else {
            ; for value in Parameters {
            ;     MsgBox A_Index ": " value, "ParseCSV - Array"
            ; }
            this.CommandLine := this.ParseArray(Parameters*)
        }

        MsgBox "[" this.CommandLine "]", 'DEBUG final CommandLine'

        shell := ComObject("WScript.Shell")
        exec := shell.Exec(A_ComSpec " /C " this.CommandLine)
        return exec.StdOut.ReadAll()
    }

    static ParseArray(Parameters*) {

        for index, value in Parameters {
            cmdLine := this.GetCommandLine(A_Index, value)
        }

        MsgBox "[" cmdLine "]", 'DEBUG ParseArray'

        return cmdLine

    }

    static ParseCSV(Parameters*) {
        return cmdLine:="EMPTY"

        Loop Parse, Parameters, "," {
            cmdLine := this.GetCommandLine(A_Index, A_LoopField)
        }

        MsgBox "[" cmdLine "]", 'DEBUG ParseCSV'

        return cmdLine
    }

    static GetCommandLine(index, value) {

        static DQ       := '"'
        static EndQuote := '"'

        ;MsgBox index ": " value , 'DEBUG GetCommandLine'

        ; If the first parameter is a file path, add extra quotes and EndQuote
        if (index = 1) {
            ; If a file path with spaces, add a leading double quote and double quotes around the file path
            if InStr(value, "\") AND InStr(value, A_Space){
                this.CommandLine .= DQ DQ value DQ A_Space
                ;EndQuote := DQ
            } else {
                ; Not a file path, no quotes
                this.CommandLine .= value A_Space
            }
        } else {
            ; If a Parameter is a file path with spaces, add quotes
            if InStr(value, "\") AND InStr(value, A_Space) {
                this.CommandLine .= DQ value DQ A_Space
                ;EndQuote := ""
            } else {
                ; Not a file path, no quotes
                this.CommandLine .= value A_Space
            }
        }
        this.CommandLine :=  RTrim(this.CommandLine, A_Space)
        this.CommandLine .=  EndQuote
        ;MsgBox index ": " CommandLine , 'DEBUG forming CommandLine'
        return this.CommandLine
    }
 
    static IsStringArray(val) {
        returnValue:= false
        if Type(val) = "Array" {
            for item in val {
                if Type(item) = "String" AND InStr(item, ",") {
                    returnValue:= true
                    break
                }
            }
        } else {
            returnValue:= false
        }
        return returnValue
    }
}

ExeFile:= "D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\StdOutArgs.exe"
;ExeFile:= "D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\ShowArgs.exe"
p1 := "one"
p2 := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
;p3 := "three"

; ExeFile := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
; p1 := "" ; "", "-shutdown", "-standby"
; ;SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
; p2 := "TEST"

;r := RunWaitMany(ExeFile, p1, p2)
r := RunCMD_TEST(ExeFile, p1, p2)

cmd := ConvertToCSV(ExeFile, P1, P2)
; MsgBox GetType(cmd)
;MsgBox IsStringArray(cmd)

GetType(val) {
    if Type(val) = "String" && InStr(val, ",")
        return "CSV String"
    else
        return Type(val)
}
IsStringArray(val) {
        if Type(val) = "String" AND InStr(val, ",")
            return true
        else
            return false
}
;r := RunWaitMany(cmd)
r := RunCMD_TEST(cmd)
;MsgBox r , "StdOut"

ExitApp()

; convert to CSV string = the format for SharedMemory
cmd := ConvertToCSV(ExeFile, P1, P2)
;cmd := ConvertToCSV(ExeFile, P1, P2)
;cmd := ConvertToCSV(ExeFile, P2)
;MsgBox cmd "`n`n" InStr(cmd, ","), "cmd CSV"

Debug.ListVar(cmd, "ListVars")
;r := ParseCSV(ExeFile, P1, P2)
r := RunCMD_TEST(cmd)

ExitApp()
; char by char
;  for value in cmd
;      MsgBox value , "StrSplit"

;r := RunWaitMany(cmd)

; split := StrSplit(cmd, ",")
; for value in split
;     MsgBox value , "StrSplit"

; Loop Parse, cmd, "," {
;     MsgBox A_Index ": " A_LoopField, "RunWaitMany"
; }

;MsgBox r , "RunWaitMany"




; this works:
; cmd := DQ DQ ExeFile DQ A_Space
; cmd .= DQ P1 DQ A_Space
; cmd .= P2 A_Space
; cmd .= '"'



; RunWaitOne(command) {
;     shell := ComObject("WScript.Shell")
;     ; Execute a single command via cmd.exe
;     exec := shell.Exec(A_ComSpec " /C " command)
;     ; Read and return the command's output
;     return exec.StdOut.ReadAll()
; }

; RunWaitMany(commands) {
;     shell := ComObject("WScript.Shell")
;     ; Open cmd.exe with echoing of commands disabled
;     exec := shell.Exec(A_ComSpec " /Q /K echo off")
;     ; Send the commands to execute, separated by newline
;     exec.StdIn.WriteLine(commands "`nexit")  ; Always exit at the end!
;     ; Read and return the output of all commands
;     return exec.StdOut.ReadAll()
; }

; MsgBox RunWaitMany("
; (
; dir d:\test.txt,
; dir D:\My Test Folder\icacls.exe .
; )"), "RunWaitMany"


;YES!!!!!!!!!!!!!!!
; myProgram := "C:\Windows\System32\notepad.exe"
; filePath := "D:\My Test Folder\test.txt"
;commandLine := myProgram . " " . Chr(34) . filePath . Chr(34)
;Run A_ComSpec . " /c " . Chr(34) . commandLine . Chr(34)

;YES!!!!!!!!!!!!!!!
;DQ:='"'
DQ:=Chr(34)
SQ:=Chr(39)
 myProgram :=  "C:\Windows\System32\notepad.exe"
 filePath := "D:\My Test Folder\test.txt"
commandLine := myProgram . A_Space . DQ . filePath . DQ
;Run A_ComSpec . " /c " . DQ . commandLine . DQ
;RunWaitOne(commandLine), "RunWaitOne"

; MsgBox RunWaitOne(commandLine) "`n`nCommand:`n`n" commandLine, "RunWaitOne"
; ExitApp
;YES!!!!!!!!!!!!!!!
; https://www.autohotkey.com/boards/viewtopic.php?t=97365
;App := "C:\a b\a.exe"
;Arg := "hello world"
;Run A_ComSpec ' /c " "' App '" "' Arg '" " '

;App := "C:\Windows\System32\notepad.exe"
;Arg := "D:\My Test Folder\test.txt"
;Run A_ComSpec ' /c " "' App '" "' Arg '" " '

;MsgBox "?", "RunWaitOne"
;ExitApp

;YES!!!!!!!!!!!!!!!
;YES!!!!!!!!!!!!!!!
;YES!!!!!!!!!!!!!!!
DQ:=Chr(34)

App := "D:\My Test Folder\ShowArgs.exe"
;App := "C:\Windows\System32\notepad.exe"
Arg := "D:\My Test Folder\test.txt"
Arg2 := "D:\MyTestFolder\test.txt"

EndQuote := ""
EndQuote := '"'

;YES!!!!!!!!!!!!!!!
;App := "D:\My Test Folder\icacls.exe"
;Arg := "D:\Lock Me"
;Arg2 := "/deny everyone:f"
;Arg2 := "/remove everyone"

RunMe(ExeFile, P1, P2) {

}

ExeFile:= "D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\StdOutArgs.exe"
;ExeFile:= "D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\ShowArgs.exe"
p1 := "one"
;p2 := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
p2 := "two"

cmd := DQ DQ ExeFile DQ A_Space
cmd .= DQ P1 DQ A_Space
cmd .= P2 A_Space
cmd .= '"'

r := RunWaitOne(cmd)

MsgBox r
ExitApp()

;MsgBox RunWaitOne(CommandLine)

App := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
Arg := "" ; "", "-shutdown", "-standby"
;SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
Arg2 := "TEST"

cmd := App ", " Arg ", " Arg2

params := StrSplit(cmd, ",")

;MsgBox RunCMD(App, Arg, Arg2)

 text := ""
 for index, value in params {
    text .= index ": " value "`n"
 }

;MsgBox "text: " text
;cmd := ConvertToCSV(App, Arg, Arg2)


ExeFile := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
P1 := "" ; "", "-shutdown", "-standby"
;SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
P2 := "TEST"
P3 := ""

ExeFile:= "D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\StdOutArgs.exe"
;ExeFile:= "D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\ShowArgs.exe"
p1 := "-switch"
;p2 := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
p2 := "-anotherSwitch"
p3 := ""

; convert to CSV string = the format for SharedMemory
cmd := ConvertToCSV(ExeFile, P1, P2, P3)
;cmd := ConvertToCSV(ExeFile, P1, P2)
;cmd := ConvertToCSV(ExeFile, P2)
MsgBox cmd "`n`n" InStr(cmd, ","), "cmd CSV"

Debug.ListVar(cmd)

ShowParams(cmd)

;myArray:= Array()

;     IsCSV:=false
;     for index, value in cmd {
;         if InStr(value, ",") {
;             IsCSV:=true
;             break
; ;            myArray.Push(value)
;         }
;     }
;     if (IsCSV)
;         Parameters := StrSplit(cmd, ",")


;MsgBox IsCSV, "IsCSV"
;Debug.ListVar(Parameters)

; cmdLine:=""
; for index, value in Parameters {
;     cmdLine .= value A_Space
; }

; MsgBox cmdLine, "cmdLine"

; ExitApp
; ;
;Debug.ListVar(cmd)

;ShowParams(cmd)
;ShowParams(ExeFile, P1, P2, P3)

; cmdArray := Array()

; for index, value in cmd {
;     cmdArray.Push(value)
; }

;split:= StrSplit(cmd, ",")

;Debug.ListVar(split)

;ExitApp

; split:= StrSplit(cmd, ",")
; Loop split.Length {
;     finalCmd .= split[A_Index] A_Space
; }
; MsgBox finalCmd, "finalCmd"


; convert to array() = the format for RunCMD()

; cmdArray := Array()

; for index, value in cmd {
;     cmdArray.Push(value)
; }

; Debug.ListVar(cmdArray)

;ExitApp()

; for index, value in cmdArray {
;     MsgBox index ": " index ", value: " value
; }

; ExitApp()

; cmdArray.Push(value)


; cmd := cmdArray

; split:= StrSplit(cmd, ",")
; Loop split.Length {
;     finalCmd .= split[A_Index] A_Space
; }

; cmd := ExeFile ", " p1 ", " p2

StdOut := RunCMD(cmd)

MsgBox StdOut, "StdOut"

;MsgBox RunCMD(cmd)
;MsgBox RunCMD(ExeFile, P1, P2, P3)

;ShowParams(ExeFile, P1, P2, P3)

ExitApp

; ExitFunc(*) {
;     mem:=""
;     ExitApp()
; }

; Convert string and number variables into a CSV string
ConvertToCSV(Params*) {
    myString:= ""
    for item in Params {
        if IsSet(item)
            myString .= item . ","
    }
    return RTrim(myString, ",")
}

ShowParams(Parameters*) {

    MsgBox Parameters "`n`n" InStr(Parameters, ","), "cmd CSV"

    ;no MsgBox "Parameters: " Parameters, "ShowParams"
    ;Debug.ListVars("ShowParams", "Spacing2", "Parameters", Parameters)
    Debug.ListVar(Parameters)
}
