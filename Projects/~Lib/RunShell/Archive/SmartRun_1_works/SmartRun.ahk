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

        ; 2. Execute via WScript.Shell
        shell := ComObject("WScript.Shell")
        exec := shell.Exec(fullCmd)

        ; 3. Read the StdOut stream
        out := ""
        while !exec.StdOut.AtEndOfStream {
            out .= exec.StdOut.ReadAll()
        }

        return out
    }
}