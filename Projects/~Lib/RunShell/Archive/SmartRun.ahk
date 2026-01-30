#Requires AutoHotkey v2.0

class SmartRun {
    /**
     * Executes a command and captures its output.
     * @param {Array} cmdArray - An array of strings (e.g., ["ping", "google.com", "-n", "1"])
     * @returns {String} The standard output of the command.
     */
    static Call(cmdArray) {

        if !IsObject(cmdArray)
            throw Error("SmartRun requires an Array of commands.")

        fullCmd := ""
        
        
        ; 1. Sanitize and build the command string
        for index, part in cmdArray {
            ; Add quotes if the part contains a space and isn't already quoted
            if InStr(part, " ") && !RegExMatch(part, '^".*"$') {
                part := '"' . part . '"'
            }
            fullCmd .= (index = 1 ? "" : " ") . part
        }

        ;return this.RunShell(fullCmd)
        return this.RunShellConsole(fullCmd)
        ;return this.RunWaitStdOut(fullCmd)


        ; ; 2. Execute via WScript.Shell
        ; shell := ComObject("WScript.Shell")
        ; exec := shell.Exec(fullCmd)

        ; ; 3. Read the StdOut stream
        ; out := ""
        ; while !exec.StdOut.AtEndOfStream {
        ;     out .= exec.StdOut.ReadAll()
        ; }

        ; return out
    }

    static RunShellConsole(command) {

        ;MsgBox "Command:`n`n" command, "RunWaitStdOut"

        DetectHiddenWindows(true)
        Run(A_ComSpec, , 'Hide', &pid)
        WinWait('ahk_pid ' pid) 
        if (DllCall("AttachConsole", "UInt", pid)) {
            try {
                shell := ComObject("WScript.Shell")
                exec := shell.Exec(A_ComSpec ' /Q /C ' command)
                ;exec := shell.Exec(command)
                result := exec.StdOut.ReadAll() . "`n" . exec.StdErr.ReadAll()
                ;result := exec.StdOut.ReadAll()
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

    static RunShell(command) {
        ; 2. Execute via WScript.Shell
        shell := ComObject("WScript.Shell")
        exec := shell.Exec(command)

        ; 3. Read the StdOut stream
        out := ""
        while !exec.StdOut.AtEndOfStream {
            out .= exec.StdOut.ReadAll()
        }

        return out
    }

    static RunWaitStdOut(command, timeout:=5000) {

        ;command := "'" command "'"

        MsgBox "Command:`n`n" command, "RunWaitStdOut"

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

}