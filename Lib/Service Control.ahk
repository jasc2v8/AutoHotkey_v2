; ABOUT: 		ServiceControl v1.0
; SOURCE:		jasc2v8 12/15/2025
; LICENSE:		The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

; Requires Admin

; --- Service Control Wrapper ---
ServiceControl(action, serviceName) {
    ; action: "start", "stop", "query"
    ; serviceName: internal service name (not display name)

    ; Build command
    cmd := Format('sc {} "{}"', action, serviceName)

    ; Run and capture output
    shell := ComObject("WScript.Shell")
    exec  := shell.Exec(cmd)
    output := ""
    while !exec.StdOut.AtEndOfStream {
        output .= exec.StdOut.ReadLine() . "`n"
    }

    ; Return object result
    return {
        Action: action,
        Service: serviceName,
        Output: output,
        ExitCode: exec.ExitCode
    }
}
