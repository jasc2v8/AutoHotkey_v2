; ABOUT: RunCMD initial version

/**
 * TODO:
 * 
 * SUMMARY:
 *  Helper function to run a command line with switched and parameters.
 *  This will handle the finicky quotest and double quotes for you.
  */
#Requires AutoHotkey 2.0+

;-------------------------------------------------
; SUMMARY:
;   Helper function to run a command line and wait until finished.
;   This will handle the finicky quotest and double quotes for you.
;   The Outfile is always appended. Run FileDelete("OldOutFile.txt") first if needed.
;   Example: RunCMD("D:\outfile.txt", "dir", "C:\)
;-------------------------------------------------
RunCMD(Outfile:="", Parts*) {
    Outfile := "test"
    RunCMD.Error := -1
    try {

        r := RunWait("nop",,"Hide")

    } catch {

        MsgBox "Catch: " A_LastError

    }
    return Outfile
}

MsgBox RunCMD()
MsgBox RunCMD.Error
MsgBox A_LastError

