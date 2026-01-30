;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

;Function to run a command and return the output text
RunWaitStdOut(command) {
    shell := ComObject("WScript.Shell")
    ; Run the command via cmd /c, hidden (0), and capture the execution object
    exec := shell.Exec(A_ComSpec " /c " command)
    ; Read the entire output stream
    return exec.StdOut.ReadAll()
}

; --- Usage Example ---
Output := RunWaitStdOut("ipconfig /all")
MsgBox(Output)
