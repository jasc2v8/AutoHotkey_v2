; TITLE  :  RunLib v1.0.0.5
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Library to run any Command line without a Command window. Handles spaces in the arguments as needed.
; USAGE  :  runner := RunLib()
;           runner.Run(Array, bat, cmd, CSV, Executable, Script.ahk, Script.ps1, or String)
;           output := runner.RunWait(Array, bat, CMD, CSV, Executable, Script.ahk, Script.ps1, or String)
; RETURNS: StdOut and StdErr: success=Instr(output, "Error")=0, error=Instr(output, "Error")>0
; EXAMPLE:
;   runner.Run(Command)                         ; Determines if Array, bat, CMD, CSV, Executable, Script.ahk, Script.ps1, or String.
;   runner.Run([My App.exe, p1, p2, pN])        ; Array (Adds quotes as needed).
;   runner.Run("My App.ahk, p1, p2, pN")        ; CSV   (Adds quotes as needed).
;   runner.Run('dir /b "D:\My Dir"'')           ; String, CMD (User must add quotes as needed, or pass an Array or CSV Command.)
;   runner.Run("MyApp.exe D:\MyDir")            ; String, EXE (User must add quotes as needed, or pass an Array or CSV Command.)
;   runner.Run(Format('"{}" {}', exe, params))  ; String, EXE (User must add quotes as needed, or pass an Array or CSV Command.)
; NOTES:
;   If FileExist(program[.exe]) then run as exe, else run as A_ComSpec cmd.
;   If Script.ahk then prepend A_AhkPath to command.
;   If Script.ps1 then prepend powershell policy to command.
;   WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99

/*
    TODO:
*/

#Requires AutoHotkey v2+

; runner := RunLib()
; runner.Run(Array, CMD, CSV, Executable, Script.ahk, or String)
; output := runner.RunWait(Array, CMD, CSV, Executable, Script.ahk, or String)
; RETURNS: StdOut and StdErr: success=Instr(output, "Error")=0, error=Instr(output, "Error")>0
;=============================================================================================
class RunLib {

    ; --- Public/External Methods ---

    __New() {
    }

    ; Run a Command without waiting for StdOut. Console window is hidden.
    Run(Command) {

        cmdLine := this._ParseCommand(Command, &IsExe)

        shell := ComObject("WScript.Shell")

        if (IsExe)
            shell.Run(cmdLine, ShowWindow:=false, Wait:=false)
        else
            shell.Run(A_ComSpec ' /Q /C ' cmdLine, ShowWindow:=false, Wait:=false)
    }

    ; Run a Command and return StdOut+StdErr. Console window is hidden.
    RunWait(Command) {

        cmdLine := this._ParseCommand(Command, &IsExe)

        DetectHiddenWindows(true)
        Run(A_ComSpec, , 'Hide', &pid)
        WinWait('ahk_pid ' pid) 
        if (DllCall("AttachConsole", "UInt", pid)) {
            try {
                shell := ComObject("WScript.Shell")
                if (IsExe)
                    exec := shell.Exec(cmdLine)
                else
                    exec := shell.Exec(A_ComSpec ' /Q /C ' cmdLine)
                result := exec.StdOut.ReadAll() . "`n" . exec.StdErr.ReadAll()
                DllCall("FreeConsole")
                ProcessClose(pid)                
                return result
            } catch any as e {
                DllCall("FreeConsole")
                ProcessClose(pid)
                return "Error: " e.Message
            }
        }
        return 'Error: Could not attach console.'
    }

    ; Utility Functions to form command with program and parameters
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

    ; Determines if Array, bat, CMD, CSV, Executable, ahk, ps1, or String and returns a command line with quotes added as needed.
    _ParseCommand(Command, &IsExe) {

        if (Type(Command)="String") and (InStr(Command,',')) {

            CommandArray := this.CSVToArray(Command)

        } else if (Type(Command) = "Array") {

            CommandArray := Command

        } else if (Type(Command) = "String") {

            CommandArray := this.ToArray(Command)

        } else {
            return "Error: Invalid Type: " Type(Command) "`n`nMust be Array, CSV, or String."
        }

        ; If ahk then prepend with autohotkey.exe
        ; Else if ps1 then prepend with powershell policy
        SplitPath(CommandArray[1],,,&Ext)

        if (Ext = "ahk") {
            newArray:= Array()
            newArray.Push(A_AhkPath)
            for param in CommandArray
                newArray.Push(param)
            CommandArray:= newArray
            
        } else if (Ext = "ps1") {
            newArray:= Array()
            newArray.Push("powershell.exe")
            newArray.Push("-ExecutionPolicy")
            newArray.Push("Bypass")
            newArray.Push("-File")
            for param in CommandArray
                newArray.Push(param)
            CommandArray:= newArray
        }

        ; Check if Exe or Cmd
        IsExe:= this._IsExe(CommandArray[1])

        ; Return the parsed command line
        return this._ArrayToCommand(CommandArray)
    }

    _ArrayToCommand(CommandArray) {
        DQ:= '"'
        CommandLine := ""
        for part in CommandArray {
            part := Trim(part)
            ; RegExMatch pattern checks if the entire string starts and ends with a double quote.                  
            if InStr(part, A_Space) && !RegExMatch(part, '^".*"$')
                CommandLine .= DQ part DQ A_Space
            else
                CommandLine .= part A_Space
        }
        return RTrim(CommandLine, A_Space)
    }

    _IsExe(Param) {

        ; SplitPath will return ext and params after the extension.
        ; Example: 'MyApp.exe param' will return 'exe params'
        SplitPath(Param,,,&Ext)

        if (SubStr(Ext, 1, 3) = "exe")
            return true
        else
            return false
    }
}