; TITLE  :  RunLib v1.2.0.1
; SOURCE :  jasc2v8, Gemini, and the Ahk Forum
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any Command line without a Command window. Adds quotes around spaces in the arguments as needed.
; USAGE  :  runner := RunLib()
;           runner.Run(CommandLine)
;           StdOut := runner.RunWait(CommandLine, &StdErr:="") ; returns StdOut, StdErr is output to &StdErr
; INPUT  :  CommandLine: Array, CSV, or String.
;           Extensions: ahk, bat, cmd, exe, ps1, or none (built-in command e.g. dir).
; RETURNS:  StdOut, StdErr
; EXAMPLE:
;   runner.Run(CommandLine)                     ; Determines if Array, CSV, or String.
;   runner.Run([My App.exe, p1, p2, pN])        ; Array (Adds quotes as needed).
;   runner.Run("My App.ahk, p1, p2, pN")        ; CSV   (Adds quotes as needed).
;   runner.Run('dir /b "D:\My Dir"')            ; String, CMD (User must add quotes as needed, or pass an Array or CSV Command.)
;   runner.Run("MyApp.exe D:\MyDir")            ; String, EXE (User must add quotes as needed, or pass an Array or CSV Command.)
;   runner.Run(Format('"{}" {}', exe, params))  ; String, EXE (User must add quotes as needed, or pass an Array or CSV Command.)
; NOTES:
;   If the executable is .ahk then prepend A_AhkPath to command.
;   If the executable is .ps1 then prepend powershell bypass execution policy to command.
; ALGORITHM:
;   Parameters are passed as an array to make it easy to group or separate parameters, and to add quotes as needed.
;       runner.RunWait([StdOutArgs.exe, hello, world, everyone])    will output 3 args: hello world everyone
;       runner.RunWait([StdOutArgs.exe, hello world, everyone])     will output 2 args: "hello world" everyone
;   The equivalent with the AHK Run command is:
;       Run("StdOutArgs.exe hello world everyone")                  will output 3 args: hello world everyone
;       Run("StdOutArgs.exe `"hello world`" everyone")              will output 2 args: "hello world" everyone
;   These commands are input as Strings and will have the same output as the equivalent AHK run commands above:
;       runner.RunWait("StdOutArgs.exe hello world everyone")      will output 3 args: hello world everyone
;       runner.RunWait("StdOutArgs.exe `"hello world`" everyone")  will output 2 args: "hello world" everyone
; OTHER:
;   WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99

/*
    TODO:
*/

#Requires AutoHotkey v2+

; CommandLine: Array, CSV, or String.
; Extensions: ahk, bat, cmd, exe, ps1, or none (built-in command e.g. dir).
; runner := RunLib()
; runner.Run(CommandLine)
; StdOut := runner.RunWait(CommandLine, &StdErr:="") ; returns StdOut, StdErr, is output to &StdErr
;=========================================================================================================================
class RunLib {

    ; --- Public/External Methods ---

    __New() {
    }

    ; Run a Command without waiting for StdOut. Console window is hidden.
    Run(Command) {
        cmdLine := this._ParseCommand(Command)
        shell := ComObject("WScript.Shell")
        shell.Run(cmdLine, ShowWindow:=false, Wait:=false)
    }

    ; Run a Command and return StdOut+StdErr. Console window is hidden.
    RunWait(Command, &StdErr:="") {
        cmdLine := this._ParseCommand(Command)
        DetectHiddenWindows(true)
        Run(A_ComSpec, , 'Hide', &pid)
        WinWait('ahk_pid ' pid) 
        if (DllCall("AttachConsole", "UInt", pid)) {
            try {
                shell := ComObject("WScript.Shell")
                exec := shell.Exec(cmdLine)
                stdOut := exec.StdOut.ReadAll()
                stdErr := exec.StdErr.ReadAll()
                DllCall("FreeConsole")
                ProcessClose(pid)
                StdErr:= stdErr
                return stdOut
            } catch any as e {
                DllCall("FreeConsole")
                ProcessClose(pid)
                return "Error: " e.Message
            }
        }
        return 'Error: Could not attach console.'
    }

    ; Utility Functions to build CommandLine with program and parameters
    ArrayToCSV(ParamsArray) {
        if (ParamsArray.Length = 0)
             return ""
        CSVString := ""       
        for Index, Value in ParamsArray {
            CurrentVal := String(Value)
            CSVString .= (Index = 1 ? "" : ",") . CurrentVal
        }
        return CSVString
    }

    CSVToArray(Param) {
        if !InStr(Param,',')
            return
        MyArray:=Array()
        split:= StrSplit(Param, ",")
        for item in split
            MyArray.Push(Trim(item))
        return MyArray
    }

    ToArray(Params*) {
        MyArray:=Array()
        for item in Params {
            MyArray.Push(item)
        }
        return MyArray
    }

    ToCSV(Params*) {
        CSVString:= ""
        for index, item in Params {
            CSVString .= (index=Params.Length) ? item : item . ","
        }
        return CSVString
    }

    ; --- Private/Internal Methods ---

    ; Determines if Array, CSV, or String.
    ; Returns a command line with quotes added as needed.
    _ParseCommand(Command) {

        if (Type(Command)="String") and (InStr(Command,',')) {
            ; Command is CSV
            CommandArray := this.CSVToArray(Command)
            return this._ArrayToCommandLine(CommandArray)

        } else if (Type(Command) = "Array") {
            ; Command is Array
            return this._ArrayToCommandLine(Command)

        } else {
            ; Command is String
            return this._ArrayToCommandLine(this._ParseCommandLineToQuotedArray(Command))
        }
    }

    _ArrayToCommandLine(CommandArray) {

        newArray:= Array()

        ; If no ext then prepend with A_ComSpec
        ; Else if ahk then prepend with autohotkey.exe
        ; Else if ps1 then prepend with powershell policy
        SplitPath(CommandArray[1],,,&Ext)

        if (Ext = "") {
            newArray.Push(A_ComSpec)
            newArray.Push("/Q")
            newArray.Push("/C" )
            
        } else if (Ext = "ahk") {
            newArray:= Array()
            newArray.Push(A_AhkPath)
            
        } else if (Ext = "ps1") {
            newArray:= Array()
            newArray.Push("powershell.exe")
            newArray.Push("-ExecutionPolicy")
            newArray.Push("Bypass")
            newArray.Push("-File")
        }

        for param in CommandArray
            newArray.Push(param)

        DQ := '"'
        CommandLine := ""
        for part in newArray {
            part := Trim(part)
            ; if parameters with a space and not quoted, then quote the parameters together.
            ; RegExMatch pattern checks if the entire string starts and ends with a double quote.                  
            if InStr(part, A_Space) and !RegExMatch(part, '^".*"$')
                CommandLine .= DQ part DQ A_Space
            else
                CommandLine .= part A_Space
        }
        return RTrim(CommandLine, A_Space)
    }

    _ParseCommandLineToQuotedArray(CommandLine) {
        if (CommandLine = "")
            return []

        Results := []
        
        ; Pattern: Captures content within "quotes" OR sequences of non-space characters
        Pattern := '(?:"([^"]*)"|([^ ]+))'
        
        Pos := 1
        while (Pos := RegExMatch(CommandLine, Pattern, &Match, Pos)) {
            ; Extract the value (preferring the quoted capture group first)
            Val := (Match[1] != "") ? Match[1] : Match[2]
            
            ; If the value contains a space, wrap it in double quotes
            if (InStr(Val, " "))
                Val := '"' Val '"'
            
            Results.Push(Val)
            Pos += Match.Len
        }

        return Results
    }
}