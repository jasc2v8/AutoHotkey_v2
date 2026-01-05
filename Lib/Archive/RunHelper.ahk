; ABOUT: RunCMD v2.0

#Requires AutoHotkey 2.0+

; SUMMARY : Helper class to run a command line with spaces in the exceutable or parameters.
; RETURNS : StdOut, StdErr, or both "StdOutStdErr"
; EXAMPLES:
;   _Run := RunHelper("Server")
;   _Run(Command) (Will determine if Array, CSV, Executable,or CMD).
;   _Run([exe, p1, p2])                                       ; Array (_Run will add quotes as needed).
;   _Run("exe, p1, p2")                                       ; CSV   (_Run will add quotes as needed).
;   _Run("dir /b c:\ProgramData")                             ; CMD   (user must add quotes as needed).
;   _Run('dir /b "C:\Program Files (x86)"')                   ; CMD   (user must add quotes as needed.
;   _Run("MyProgram.exe Param1 Param2")                       ; EXE   (user must add quotes as needed).
;   _Run('C:\Windows\notepad.exe "D:\My Folder\My File.txt"') ; EXE (user must add quotes as needed).
;   _Run.SetOutput(Output)  ; Output := "StdOut", "StdErr", "StdOutStdErr"
;------------------------------------------------------------------------------------------------
class RunHelper {

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

; #region Tests

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    _Run_Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
;Esc::ExitApp()

_Run_Tests() {

    ; comment out to run tests
    SoundBeep(), ExitApp()

    #Warn Unreachable, Off

    _Run:= RunHelper

    ;comment out tests to skip:
    Test_Debug()

    Test_Debug() {
        
        cmd:= "dir"
        p1 := "/b"
        p2 := "C:\Program Files (x86)"

        cmdCSV := _Run.ConvertToCSV(cmd, p1, p2)
        MsgBox(cmdCSV, "Test CSV CMD")
        Output:= _Run(cmdCSV)
        MsgBox(Output, "Test CSV CMD Output")

        cmdArray := _Run.ConvertToArray(cmd, p1, p2)
        MsgBox(cmdArray[1], "Test Array CMD")
        Output:= _Run(cmdArray)
        MsgBox(Output, "Test Array CMD Output")

        cmd := 'dir /b "C:\Program Files (x86)"'
        MsgBox(cmd, "Test CMD")
        Output:= _Run(cmd)
        MsgBox(Output, "Test CMD Output")

        exe:= "D:\Software\DEV\Work\AHK2\Projects\RunResolved\StdOut Args.exe"
        p1 := "D:\NSSM\nssm.exe"
        p2 := "D:\2025 London Paris\Hotel London.odt"

        cmdArray := _Run.ConvertToArray(exe, p1, p2)

        MsgBox(cmdArray[1], "Test Array Exe")
        Output:= _Run(cmdArray)
        MsgBox(Output, "Test Array Exe Output")

        cmdCSV := _Run.ConvertToCSV(exe, p1, p2)

        MsgBox(cmdCSV, "Test CSV Exe")
        Output:= _Run(cmdCSV)
        MsgBox(Output, "Test CSV Exe Output")

        ; can't figure how how to get quotes around the executable other than this"
        cmd := 'D:\Software\DEV\Work\AHK2\Projects\RunResolved\"StdOut Args".exe  "D:\2025 London Paris\Hotel London.odt"'
        MsgBox(cmd, "Test CMD With Spaces")
        Output:= _Run(cmd)
        MsgBox(Output, "Test CMD With Spaces Output")

    }
}