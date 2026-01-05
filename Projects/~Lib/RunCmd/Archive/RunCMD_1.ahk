; TITLE: RunCMD initial version

/**
 * TODO:
 * 
 * SUMMARY:
 *  Helper function to run a command line with switched and parameters.
 *  This will handle the finicky quotest and double quotes for you.
  */
#Requires AutoHotkey 2.0+

exe := '"C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"'

;OK r := RunCMD(, "dir", "C:\*.log")
;ok r := RunCMD(, "dir", "C:\*.log")

;ok r := RunCMD(, "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe", "TEST")

;YES!
r := RunCMD(, "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe", "TEST")


;OK r := RunCMD(, exe, '"~Backup JIM-PC folders to JIM-SERVER"')
;NO r := RunCMD(, exe, "~Backup JIM-PC folders to JIM-SERVER")

MsgBox r


#Warn Unreachable, Off
return
;-------------------------------------------------
; SUMMARY:
;   Helper function to run a command line and wait until finished.
;   This will handle the finicky quotest and double quotes for you.
;   The Outfile is always appended. Run FileDelete("OldOutFile.txt") first if needed.
;   Example: RunCMD("D:\outfile.txt", "dir", "C:\)
;-------------------------------------------------
RunCMD(Outfile:="", ProgramExe:="", Parts*) {

    DQ := '"'
    SQ := "'"
    SP := A_Space

    ; C:\WINDOWS\system32\cmd.exe /D /Q /C " "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe" TEST  > "D:\outfile.txt""

    ;ok C:\WINDOWS\system32\cmd.exe /D /Q /C ""C:\Windows\System32\ipconfig.exe" "/all""  > "D:\outfile.txt""
    ;ok C:\WINDOWS\system32\cmd.exe /D /Q /C "dir /all"  > "D:\outfile.txt""

    Outfile := (Outfile != "") ? Outfile : "D:\outfile.txt"

    ProgramExe := InStr(ProgramExe, "\") ? DQ ProgramExe DQ : ProgramExe

    ;OK cmd := A_ComSpec . " /D /Q /C " DQ ; . sCommand . ')>"' . sStdOutFileName . '"'
    cmd := A_ComSpec . " /D /Q /C " DQ ProgramExe SP

    for index, value in Parts {
        if (value) {
            ; if InStr(value, "\") {
            ;     cmd .= DQ value DQ SP
            ; } else {
                ;cmd .= value SP
                cmd .= DQ value DQ SP
            ; }
        }
    }

    ;if (Outfile)
        ;cmd .= " >> " DQ Outfile DQ

    cmd .= " > " DQ Outfile DQ DQ

    msgbox "cmd: " cmd
    
    r := RunWait(cmd,,'Hide')
    return r
}