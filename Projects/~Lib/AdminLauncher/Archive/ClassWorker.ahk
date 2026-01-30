
#Requires AutoHotkey v2+

/*
    Version: 1.0.1
*/

class Worker {
    __New() {
        ; Create an error object to capture the current call stack
        err := Error()
        
        ; err.Stack contains a string of the call history.
        ; The first line is usually __New itself, 
        ; and the second line is the code that instantiated the class.
        stackLines := StrSplit(err.Stack, "`n")
        
        if (stackLines.Length > 1) {
            callerInfo := stackLines[2] ; This is the line that called "Worker()"
            ;MsgBox("This instance was created by:`n`n" callerInfo)
            ;MsgBox err.Stack, "Stack"

            if (InStr(err.Stack, "ClassCreatorOne.ahk")>0)
                MsgBox("This instance was created by: ClassCreatorOne.ahk")
            else if  (InStr(err.Stack, "ClassCreatorTwo.ahk")>0)
                MsgBox("This instance was created by: ClassCreatorTwo.ahk")
            else
                MsgBox("This instance was created by: UNKNOWN")
        }
    }
}
