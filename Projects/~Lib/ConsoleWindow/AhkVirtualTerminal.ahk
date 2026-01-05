; AHK v2 Virtual Terminal Example
#Requires AutoHotkey v2.0
#SingleInstance Force
;#NoTrayIcon

; Create the Terminal GUI
MyGui := Gui("+Resize", "AHK Virtual Terminal")
MyGui.SetFont("s10", "Consolas") ; Use a monospaced font for terminal feel

; Output Display (Read-only)
TerminalLog := MyGui.Add("Edit", "r20 w600 ReadOnly vOutput")

; Input Field
InputCmd := MyGui.Add("Edit", "w600 vCommand")
InputCmd.OnEvent("Focus", (*) => ControlSetText("", InputCmd)) ; Optional: clear on focus

; Submit Button (Hidden, but allows Enter key to trigger it)
MyGui.Add("Button", "Default w0 h0 vRun", "Run").OnEvent("Click", RunCommand)

ControlFocus(InputCmd, MyGui)

MyGui.Show()



RunCommand(*) {
    Saved := MyGui.Submit(false)
    Cmd := Saved.Command
    
    if (Cmd = "")
        return

    ; Append the command to the log
    TerminalLog.Value .= "`n> " Cmd "`n"
    
    ; Execute via WScript.Shell to capture StdOut
    try {
        shell := ComObject("WScript.Shell")
        ; /c runs the command then terminates, /q is quiet
        exec := shell.Exec(A_ComSpec " /c " Cmd)
        
        ; Read the output (this is a simple synchronous read)
        output := exec.StdOut.ReadAll()
        TerminalLog.Value .= output
        
        ; Clear input field
        InputCmd.Value := ""
    } catch Error as err {
        TerminalLog.Value .= "Error: " err.Message "`n"
    }
    
    ; Auto-scroll to bottom
    SendMessage(0x0115, 7, 0, TerminalLog.Hwnd, "User32.dll") ; WM_VSCROLL = 0x0115, SB_BOTTOM = 7
}

; Cleanup on close
MyGui.OnEvent("Close", (*) => ExitApp())