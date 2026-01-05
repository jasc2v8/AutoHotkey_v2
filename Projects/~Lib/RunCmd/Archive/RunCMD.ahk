; TITLE: RunCMD v1.0 

#Requires AutoHotkey 2.0+

;----------------------------------------------------------------------------------------------
; SUMMARY:      Handles CSV parsing, Command Arrays, Invisible Execution, Timeouts, and Errors.
;               This will handle the finicky quotes and double quotes for you.
; PARAMETERS:   ExeFile, P1, P2, PN ...
; EXAMPLE:      r := RunCMD("C:\My Dir\My App\My App.exe", "/q", "FileName")
;               r := RunCMD("MyApp.exe", '"My Parameter With Spaces"', "FileName")
; RETURN:       If success r = Output, else ""
;               If error A_LastError = Exit Code.
;----------------------------------------------------------------------------------

RunCMD(InputVar, TimeoutMS := 5000) {

    ; 1. ARRAY INPUT: Build a command string with auto-quoting
    if (InputVar is Array) {
        FullCmd := ""
        for Item in InputVar {
            ; Wrap in quotes if there's a space and not already quoted
            if InStr(Item, " ") && !RegExMatch(Item, '^".*"$')
                Item := '"' Item '"'
            FullCmd .= Item " "
        }
        return RunWaitStdOut(Trim(FullCmd), TimeoutMS)
    }

    ; 2. STRING INPUT: Check if it's CSV data or a system command
    if (Type(InputVar) = "String") {
        Rows := StrSplit(Trim(InputVar, "`r`n"), "`n", "`r")

        ; Detect CSV: More than 1 column in the first row
        ColCount := 0
        Loop Parse, Rows[1], "CSV"
            ColCount++

        if (ColCount > 1) {
            FlatArray := []
            for RowText in Rows {
                Loop Parse, RowText, "CSV"
                    FlatArray.Push(A_LoopField)
            }
            return FlatArray
        }

        ; Not CSV? Treat as a shell command
        return RunWaitStdOut(InputVar, TimeoutMS)
    }

    throw Error("Invalid Input Type: " Type(InputVar))
}

RunWaitStdOut(command, timeout) {

    ;command := "'" command "'"

    MsgBox "Command:`n`n" command

    shell := ComObject("WScript.Shell")
    ; Use A_ComSpec to ensure internal CMD commands work
    exec := shell.Exec(A_ComSpec " /c " command)
    startTime := A_TickCount

    ; Monitor process status
    while exec.Status = 0 {
        if (A_TickCount - startTime > timeout) {
            exec.Terminate()
            return "ERROR: Process timed out after " (timeout / 1000) "s."
        }
        Sleep(10)
    }

    ; Retrieve output and error streams
    stdOut := exec.StdOut.ReadAll()
    stdErr := exec.StdErr.ReadAll()
    exitCode := exec.ExitCode

    ; Return Error Report if ExitCode is non-zero
    if (exitCode != 0) {
        return "COMMAND FAILED (ExitCode: " exitCode ")`n`n" .
               "STDERR:`n" (stdErr ? stdErr : "No error text provided.") . "`n`n" .
               "STDOUT:`n" stdOut
    }

    return stdOut
}
