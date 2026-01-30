#Requires AutoHotkey 2+

; TITLE   : RunShell v1.0.0.2
; SUMMARY : Runs a command (handles spaces in the arguments) and returns the Output.
; RETURNS : StdOut and StdErr: success=Instr(output, "Error")=0, error=Instr(output, "Error")>0
; EXAMPLES:
;   RunShell(Command)                         ; Determines if Array, CSV, String, and Executable,or CMD.
;   RunShell([My App.exe, p1, p2])            ; Array (RunShell will add quotes as needed).
;   RunShell("My App.exe, p1, p2")            ; CSV   (RunShell will add quotes as needed).
;   RunShell("dir /b D:\My Dir")              ; String, CMD
;   RunShell("MyApp.exe D:\MyDir")            ; String, EXE (User must add quotes as needed.)
;   RunShell(Format('"{}" {}', exe, params))  ; String, EXE (User must add quotes as needed.)
;------------------------------------------------------------------------------------------------
class RunShell{

    static Call(CommandLine) {

        if this.IsType(CommandLine, "CSV") {
            
            ;MsgBox CommandLine, "CSV"

            splitCSV := StrSplit(CommandLine, ",")

            return this.RunArray(splitCSV)

        } else if this.IsType(CommandLine, "Array") {

            ;MsgBox CommandLine[1], "Array"

            return this.RunArray(CommandLine)

        } else if this.IsType(CommandLine, "String") {

            ;MsgBox CommandLine, Type(CommandLine)

            split := StrSplit(CommandLine, " ")

            thisType := (InStr(split[1], "\") > 0) ? "EXE" : "CMD"

            return this.RunWait(CommandLine, thisType)

        } else {
            return "Error: Invalid command line: " Type(CommandLine) "`n`nMust be Array, CSV, or String."
        }
    }

    static RunArray(CommandArray) {

        DQ:= '"'
        CommandLine := ""
        Type := (InStr(CommandArray[1], "\") > 0) ? "EXE" : "CMD"
        for part in CommandArray {
            part := Trim(part)
            if (Type = "CMD")
                ;if InStr(value, "\") > 0
                ; Add quotes if the part contains a space and isn't already quoted
                if InStr(part, " ") && !RegExMatch(part, '^".*"$')                  
                    CommandLine .= DQ part DQ A_Space
                else
                    CommandLine .= part A_Space
            else
                CommandLine .= DQ part DQ A_Space
        }
        CommandLine :=  RTrim(CommandLine, A_Space)
        return this.RunWait(CommandLine, Type)
    }

    static RunWait(Command, Type:="CMD") {

        ;MsgBox "Cmd:`n`n" Command, Type

        DetectHiddenWindows(true)
        Run(A_ComSpec, , 'Hide', &pid)
        WinWait('ahk_pid ' pid) 
        if (DllCall("AttachConsole", "UInt", pid)) {
            try {
                shell := ComObject("WScript.Shell")
                if (Type = "CMD")
                    exec := shell.Exec(A_ComSpec ' /Q /C ' Command)
                else
                    exec := shell.Exec(Command)
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

    static ToArray(Params*) {
        myArray:=Array()
        for item in Params {
            ;if IsSet(item)
                myArray.Push(item)
        }
        return MyArray
    }

    static ToCSV(Params*) {
        myString:= ""
        for item in Params {
            if IsSet(item)
                myString .= item . ","
        }
        return RTrim(myString, ",")
    }

    static ArrayToCSV(InputArray) {

        if (InputArray.Length = 0)
                return ""
            
        CSVString := ""
        
        for Index, Value in InputArray {
            CurrentVal := String(Value)
            CSVString .= (Index = 1 ? "" : ",") . CurrentVal
        }
        
        return CSVString
    }

    static ArrayToCmdLine(paramArray) {
        str := ""
        for index, value in paramArray {
            if (InStr(value, A_Space)>0) {
                value := '"' . value . '"'
            }
            str .= value . A_Space
        }
        return RTrim(str) ; Remove the trailing space
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