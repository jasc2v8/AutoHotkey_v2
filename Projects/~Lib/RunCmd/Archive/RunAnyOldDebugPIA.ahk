; ABOUT: Run v2.0

#Requires AutoHotkey 2.0+
#SingleInstance Force
#Warn Unreachable, Off

/*

    output := RunAny(command, 'StdOutStdErr')

    RunAny(command, 'NoWait')



*/

;#Include <RunAsAdmin>
#Include RunAnyOld.ahk

Esc::ExitApp()

; This particular command won't work with RunWait (like RunCMD)
PiaCtlPath := "C:\Program Files\Private Internet Access\piactl.exe"

output:= Run("C:\Program Files\Private Internet Access\pia-client.exe")
MsgBox output, "Start PIA"
;Sleep 2000
output := RunAnyOld(["C:\Program Files\Private Internet Access\piactl.exe", "connect"])
MsgBox output, "Connect PIA"
;Sleep 2000
output := RunAnyOld(["C:\Program Files\Private Internet Access\piactl.exe", "get", "connectionstate"])
MsgBox output, "State of PIA"
output := RunAnyOld(["C:\Program Files\Private Internet Access\piactl.exe", "disconnect"])
MsgBox output, "Disconnect PIA"
ProcessClose("pia-client.exe")
MsgBox output, "Close PIA"


;ok
;Run("C:\Program Files\Private Internet Access\pia-client.exe",, "Hide")
;Sleep 1000
;Run("C:\Program Files\Private Internet Access\piactl.exe connect",, "Hide")

; NO !!! output := RunAnyOld(["C:\Program Files\Private Internet Access\piactl.exe", "get connectionstate"])
; ok !!! output := RunAnyOld(["C:\Program Files\Private Internet Access\piactl.exe", "get", "connectionstate"])
;output := RunAnyOld(["C:\Program Files\Private Internet Access\piactl.exe", "get", "connectionstate"])



;cmd := '"C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe" "TEST WITH SPACES"'
;cmd := ["C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe", "TEST WITH SPACES"]
;output := SmartRun(cmd)

;output := RunAnyOld(["D:\TEST\StdOutArgs.exe", "-switch", "D:\List Vars.ahk", "D:\ShowArgs.exe"])
;output := RunAnyOld(["D:\TEST\StdOut Args.exe", "-switch", "D:\List Vars.ahk", "D:\ShowArgs.exe"])

; ok output := RunAnyOld("D:\TEST\StdOut Args.exe, -switch, D:\List Vars.ahk, D:\ShowArgs.exe")

; ok output := RunAnyOld(["ipconfig", "/all"])

; ok output := RunAnyOld(["dir", "D:\"])
; ok output := RunAnyOld(["dir", "x:\"]) ; force StdErr

;output := RunCMD("D:\TEST\StdOutArgs.exe, -switch, D:\List Vars.ahk, D:\ShowArgs.exe")

;output := RunAny(cmd, 'StdOutStdErr')
;Run Format('"{}" {}', exe, params)
;exe := "D:\TEST\StdOut Args.exe"
;params :=  "-switch D:\List Vars.ahk D:\ShowArgs.exe"
;cmd := Format('"{}" {}', exe, params)
;output := RunAny(cmd)
MsgBox output
ExitApp()



cmd := 'C:\Program Files\App.exe p1 "two words" p3 "C:\Path With Spaces\file.txt"'
args := ParseArgs(cmd)
;ListObj("args", args)


ExitApp
path :="D:\ListVars.ahk"
path :="D:\List Vars.ahk"

cmd :="D:\Show Args.exe D:\List Vars.ahk D:\ListVars.ahk"
ParseCommand(cmd, &exe, &params)
MsgBox "Exe:`n" exe "`n`nParams:`n" params
Run(exe " " params)

cmd :="D:\ShowArgs.exe -switch D:\List Vars.ahk D:\ListVars.ahk"
ParseCommand(cmd, &exe, &params)
MsgBox "Exe:`n" exe "`n`nParams:`n" params
Run(exe " " params)


ExitApp

out := SplitExeAndParams(path)

MsgBox "Exe:`n" out.exe "`n`nParams:`n" out.params

Run(out.exe " " out.params)

MsgBox
ExitApp

FullString := '"C:\Program Files\App.exe" p1 p2'
FullString := 'C:\Program Files\App.exe p1 p2'
FullString := 'C:\ProgramFiles\App.exe p1 p2'

exe:="D:\Show Args.ahk"

;Run Format('"{}" {}', exe, params)
;exe := "C:\Program Files\App.exe"
params:= "p1 p2"

;FullString := Format('"{}" {}', exe, params)
input := "C:\Program Files\App.exe p1 p2"
input := "C:\Program Files\App.exe p1 C:\Program Files\App2.exe"

out := SplitExeAndParams(input)

MsgBox "Exe:`n" out.exe "`n`nParams:`n" out.params


;obj:= SplitExeAndParams(FullString)
;ListObj("test", obj)

ParseArgs(str) {
    out := []

    ; Matches:
    ;   "quoted strings"
    ;   unquoted segments without spaces
    ;
    ; Does NOT try to detect .exe boundaries.
    ; Produces tokens exactly like:
    ;   C:\Program
    ;   Files\App.exe
    ;   p1
    ;   two words
    ;   p3
    ;   C:\Path With Spaces\file.txt

    pos := 1
    while RegExMatch(str, '"([^"]*)"|(\S+)', &m, pos) {
        arg := m[1] != "" ? m[1] : m[2]
        out.Push(arg)
        pos := m.Pos + m.Len
    }

    return out
}

ParseParams(str) {
    out := []

    ; Regex explanation:
    ; "([^"]*)"   → quoted argument, no escaping inside quotes
    ; |           → OR
    ; (\S+)       → unquoted argument (no spaces)
    ; g           → global match

    while RegExMatch(str, '"([^"]*)"|(\S+)', &m, A_Index = 1 ? 1 : m.Pos + m.Len) {
        arg := m[1] != "" ? m[1] : m[2]
        out.Push(arg)
    }

    return out
}


ParseCommand(cmd, &exe, &params) {
    if RegExMatch(cmd, '^(.*?\.exe)\s*(.*)$', &m) {
        exe    := m[1]
        params := m[2]
    } else {
        exe := cmd
        params := ""
    }
}

SplitExeAndParams(cmdLine) {
    cmdLine := Trim(cmdLine)

    ; 1) Extract exe:
    ;    - "C:\Program Files\App.exe"
    ;    - C:\Program Files\App.exe
    ; 2) Capture the rest as a raw string (rest) for param parsing.

    if !RegExMatch(cmdLine, '^\s*(?:"([^"]+)"|(.+?\.exe))\s*(.*)$', &m) {
        ; If it doesn't match, no clear exe/params structure
        return { exe: cmdLine, params: [] }
    }

    exe  := m[1] != "" ? m[1] : m[2]
    rest := m[3]

    ; 3) Tokenize rest into params, preserving quoted segments.
    params := []
    pos := 1
    while RegExMatch(rest, '"([^"]*)"|(\S+)', &p, pos) {
        params.Push(p[1] != "" ? p[1] : p[2])
        pos := p.Pos + p.Len
    }

    return { exe: exe, params: params }
}


SplitExeAndParams_old(cmdLine) {
    cmdLine := Trim(cmdLine)

    ; 1) Quoted exe: "C:\Program Files\App.exe"
    ; 2) Unquoted exe ending in .exe (non-greedy): C:\Program Files\App.exe
    ; 3) Params: everything after it

    if RegExMatch(cmdLine, '^\s*(?:"([^"]+)"|(.+?\.exe))\s*(.*)$', &m) {
        exe    := m[1] != "" ? m[1] : m[2]
        params := m[3]
        return { exe: exe, params: params }
    }

    return { exe: cmdLine, params: "" }
}

SplitExeAndParams_nospaces(cmdLine) {
    cmdLine := Trim(cmdLine)

    ; Regex logic:
    ; 1) ^\s*                             → ignore leading spaces
    ; 2) (?: "([^"]+)" | (\S+) )          → capture quoted exe OR unquoted exe
    ; 3) \s*(.*)$                         → capture the rest as params

    if RegExMatch(cmdLine, '^\s*(?:"([^"]+)"|(\S+))\s*(.*)$', &m) {
        exe    := m[1] != "" ? m[1] : m[2]
        params := m[3]
        return { exe: exe, params: params }
    }

    ; Fallback (should never happen)
    return { exe: cmdLine, params: "" }
}


SplitExeAndParams_DEBUG(cmdLine) {
    ; Trim leading/trailing whitespace
    cmdLine := Trim(cmdLine)

    ; Case 1: Path is quoted → "C:\Program Files\App.exe" p1 p2
    if (SubStr(cmdLine, 1, 1) = '"') {
        endQuote := InStr(cmdLine, '"', , 2)
        exe := SubStr(cmdLine, 2, endQuote - 2)
        params := Trim(SubStr(cmdLine, endQuote + 1))
        return { exe: exe, params: params }
    }

    ; Case 2: Unquoted path → C:\Program Files\App.exe p1 p2
    ; Find first space that separates path from params
    parts := StrSplit(cmdLine, " ")
    exe := parts[1]

    ; If the path contains spaces, rebuild until the file exists
    if !FileExist(exe) {
        exe := ""
        loop parts.Length {
            exe .= (A_Index = 1 ? "" : " ") parts[A_Index]
            if FileExist(exe) {
                params := Trim(SubStr(cmdLine, StrLen(exe) + 1))
                return { exe: exe, params: params }
            }
        }
    }

    ; Fallback: first token is exe, rest are params
    params := Trim(SubStr(cmdLine, StrLen(exe) + 1))
    return { exe: exe, params: params }
}


SplitCommand(FullSTring)

SplitCommand(FullSTring) {
    ; 1. Identify if the path is quoted
    if SubStr(FullString, 1, 1) = '"' {
        ; Find the position of the closing quote
        EndPos := InStr(FullString, '"', , 2)
        ExePath := SubStr(FullString, 2, EndPos - 2)
        Params  := LTrim(SubStr(FullString, EndPos + 1))
    } 
    ; 2. If no quotes, split at the first space
    else {
        SpacePos := InStr(FullString, " ")
        if SpacePos {
            ExePath := SubStr(FullString, 1, SpacePos - 1)
            Params  := SubStr(FullString, SpacePos + 1)
        } else {
            ExePath := FullString
            Params  := ""
        }
    }

    ; Display results
    MsgBox "Executable:`n" ExePath "`n`nParameters:`n" Params
}
return

global PiaPath    := "C:\Program Files\Private Internet Access\pia-client.exe"
global PiaCtlPath := "C:\Program Files\Private Internet Access\piactl.exe"



;ok RunExe('notepad.exe')

StartVPN()

ExitApp()


StartVPN(){

  if !ProcessExist("pia-client.exe") {

    ; ok Run("C:\Program Files\Private Internet Access\pia-client.exe",, "Hide") ; PIA settings: UNcheck Connect on Launch
    ; ok Run(PiaPath,, "Hide")
    ; hangs RunWait(PiaPath,, "Hide")
    ; ok Run('"' PiaPath '"')

    RunExe(PiaPath, 'NoWait')

    ;output:= RunExe('"' PiaPath '"', false)

    ; no RunAny(PiaPath, 'None')
    ; no RunAny(PiaPath ", ")
    ; no RunAny(PiaPath, "None")

    ;output:= RunExe(PiaPath, 'StdOutStdErr')
    MsgBox 'PAUSE', "PIA OUTPUT"

    if WinWait("ahk_exe pia-client.exe", "", 5)
    {
      WinActivate()

      MsgBox "PIA ACTIVATED?"

    }
    else
    {
      MsgBox("Error: VPN did not start.")
      return 0
    }
  }





  ;MsgBox "PIA STARTED?"

  Sleep(250) ; delay until ready

  ; ok output := Run('"' PiaCtlPath '"' " connect ")

  ;Run("C:\Program Files\Private Internet Access\piactl.exe connect",, "Hide") ; make sure its connected


  ; ok RunExe(PiaCtlPath " connect", "NoWait")
  RunExe('"' PiaCtlPath '"' " connect ", 'NoWait')

  ;output := RunExe('"' PiaCtlPath '" connect', 'StdOutStdErr')

  MsgBox 'DEBUG', "PIA connected?"

  return 1

}

    ; StdOut, StdErr, StdOutStdErr, NoWait

    RunExe(cmd, Output:="Stdin") {

        if (Output = 'NoWait') {

            ;MsgBox 'cmd: ' cmd, "DEBUG"

            Run(cmd,, "Hide")
            return
        }

        DetectHiddenWindows(true)
        Run(A_ComSpec, , 'Hide', &pid)
        WinWait('ahk_pid ' pid) 
        if (DllCall("AttachConsole", "UInt", pid)) {
            try {
                shell := ComObject("WScript.Shell")
                if (Type = "CMD")
                    exec := shell.Exec(A_ComSpec ' /Q /C ' cmd)
                else
                    exec := shell.Exec(cmd)

                switch Output {
                    case "StdOut":
                        result := exec.StdOut.ReadAll()
                    case "StdErr":
                        result := exec.StdErr.ReadAll()
                    case "StdOutStdErr":
                        result := exec.StdOut.ReadAll() . "`n" . exec.StdErr.ReadAll()
                    default:
                        result := exec.StdOut.ReadAll() . "`n" . exec.StdErr.ReadAll()
                }

                DllCall("FreeConsole")
                ProcessClose(pid)                
                return result
            } catch {
                DllCall("FreeConsole")
                ProcessClose(pid)
                throw
            }
        }
        return 'Error: Could not attach console.'
    }

; SUMMARY : Helper class to run a command line with spaces in the exceutable or parameters.
; RETURNS : StdOut, StdErr, or both "StdOutStdErr"
; EXAMPLES:
;   _Run := RunAny("Server")
;   _Run(Command) (Will determine if Array, CSV, Executable,or CMD).
;   _Run([exe, p1, p2])                                       ; Array (_Run will add quotes as needed).
;   _Run("exe, p1, p2")                                       ; CSV   (_Run will add quotes as needed).
;   _Run("dir /b c:\ProgramData")                             ; CMD   (user must add quotes as needed).
;   _Run('dir /b "C:\Program Files (x86)"')                   ; CMD   (user must add quotes as needed.
;   _Run("MyProgram.exe Param1 Param2")                       ; EXE   (user must add quotes as needed).
;   _Run('C:\Windows\notepad.exe "D:\My Folder\My File.txt"') ; EXE (user must add quotes as needed).
;   _Run.SetOutput(Output)  ; Output := "StdOut", "StdErr", "StdOutStdErr"
;------------------------------------------------------------------------------------------------
class RunAny_DEBUG {

    static Output := "StdOut"

    static Call(CommandLine) {

        if this.IsType(CommandLine, "CSV") {
            
            ;MsgBox "Array", "CSV"

            split := StrSplit(CommandLine, ",")

            if InStr(split[1], "\") > 0
                ;MsgBox "CSV Exe", "DEBUG"
                return this.CSV(CommandLine)
            else
                ;MsgBox "Array CMD", "DEBUG"
                return this.CSV(CommandLine, "CMD")

        } else if this.IsType(CommandLine, "Array") {

            ;MsgBox "Array", "DEBUG"

            if InStr(CommandLine[1], "\") > 0
                ;MsgBox "Array Exe", "DEBUG"
                return this.Array(CommandLine)
            else
                ;MsgBox "Array CMD", "DEBUG"
                return this.Array(CommandLine, "CMD")

        } else {
            ;MsgBox "CMD", "DEBUG"
            return this.Exe(CommandLine, "CMD")
        }
        return
    }

    static Array(ParametersArray, Type:="Array") {

        DQ:= '"'
        CommandLine := ""

        for value in ParametersArray {
            if (Type = "CMD")
                if InStr(value, "\") > 0
                    CommandLine .= DQ value DQ A_Space
                else
                    CommandLine .= value A_Space
            else
                CommandLine .= DQ value DQ A_Space
        }

        CommandLine :=  RTrim(CommandLine, A_Space)

        ;MsgBox CommandLine, "Array CommandLine"

        return this.Exe(CommandLine, Type)

    }

    static CSV(ParametersCSV, Type:="CSV") {

        DQ:= '"'
        
        CommandLine := ""

         Loop Parse, ParametersCSV, "," {
            if (Type = "CMD")
                if InStr(A_LoopField, "\") > 0
                    CommandLine .= DQ A_LoopField DQ A_Space
                else
                    CommandLine .= A_LoopField A_Space
            else
                CommandLine .= DQ Trim(A_LoopField) DQ A_Space
        }

        CommandLine :=  RTrim(CommandLine, A_Space)

        ;MsgBox CommandLine, "CSV CommandLine"

        return this.Exe(CommandLine, Type)
    }
    
    static Exe(cmd, Type:="CMD") {

        DetectHiddenWindows(true)
        Run(A_ComSpec, , 'Hide', &pid)
        WinWait('ahk_pid ' pid) 
        if (DllCall("AttachConsole", "UInt", pid)) {
            try {
                shell := ComObject("WScript.Shell")
                if (Type = "CMD")
                    exec := shell.Exec(A_ComSpec ' /Q /C ' cmd)
                else
                    exec := shell.Exec(cmd)

                switch this.Output {
                    case "StdOut":
                        result := exec.StdOut.ReadAll()
                    case "StdErr":
                        result := exec.StdErr.ReadAll()
                    case "StdOutStdErr":
                        result := exec.StdOut.ReadAll() . "`n" . exec.StdErr.ReadAll()
                    default:
                        result := exec.StdOut.ReadAll()                        
                }

                DllCall("FreeConsole")
                ProcessClose(pid)                
                return result
            } catch {
                DllCall("FreeConsole")
                ProcessClose(pid)
                throw
            }
        }
        return 'Error: Could not attach console.'
    }
    static ConvertToArray(Params*) {
        myArray:=Array()
        for item in Params {
            ;if IsSet(item)
                myArray.Push(item)
        }
        return MyArray
    }

    static ConvertToCSV(Params*) {
        myString:= ""
        for item in Params {
            if IsSet(item)
                myString .= item . ","
        }
        return RTrim(myString, ",")
    }

    static SetOutput(Output:="StdOut") {        
        this.Output := Output
    }

    ; Returns String: Array, Class, CSV, Float, Func, Integer, Map, String
    static IsType(val, guess:="") {      
    if (guess="") {
        if Type(val) = "String" && InStr(val, ",")
            return "CSV"
        else
            return Type(val)        
    }
    valType  := Type(val)
    valGuess := Type(guess)
    if (valType = guess)
        return true
    else if (valType = "String" && InStr(val, ",") && guess = "CSV")
        return true
    else
        return false
    }
}

