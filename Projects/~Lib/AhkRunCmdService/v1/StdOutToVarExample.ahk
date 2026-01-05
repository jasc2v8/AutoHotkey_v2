; TITLE: BackupControlTool v2.3, 
; 
/*
    TODO:
        SharedMemory("AhkRunCmdService")

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

;#Include <Debug>
;#Include <IniLite>
;#Include .\RunCMD.ahk
;#Include <RunCMD>
;#Include <SharedMemory>

OnExit(ExitFunc)

StdOutToVar(cmd) {
    ; 1. Allocate a console that AHK itself can use (it's hidden by default for non-console-host processes).
    DllCall("AllocConsole")
    ; 2. Get the handle of the newly created console window.
    consoleHwnd := DllCall("GetConsoleWindow", "ptr")
    ; 3. Hide the console window instantly to prevent flickering.
    WinHide("ahk_id " consoleHwnd)
    ; 4. Get the WScript.Shell object.
    shell := ComObject("WScript.Shell")
    ; 5. Execute the command. This will use the now-hidden console.
    exec := shell.Exec(A_ComSpec " /C " cmd)
    ; 6. Read the output.
    output := exec.StdOut.ReadAll()
    ; 7. Free the console memory and close the associated process.
    DllCall("FreeConsole")
    
    return output
}

StdOutErrToVar(cmd) {
    DllCall("AllocConsole")
    consoleHwnd := DllCall("GetConsoleWindow", "ptr")
    WinHide("ahk_id " consoleHwnd)

    shell := ComObject("WScript.Shell")
    exec := shell.Exec(A_ComSpec " /C " cmd)
    out   := exec.StdOut.ReadAll()
    err   := exec.StdErr.ReadAll()

    DllCall("FreeConsole")

    return out (err ? "`nERROR:`n" err : "")
}

;Test1()
Test2()

Test2() {

    ;C:\Windows\System32\cmd.exe /C "D:\My Test Folder\icacls.exe" "D:\Lock Me" /deny everyone:f

    icaclsExe := "D:\My Test Folder\icacls.exe"
    LockFolder := "D:\Lock Me"

    if !DirExist(LockFolder)
        DirCreate(LockFolder)

    cmd := icaclsExe " " LockFolder " " "/remove everyone"
    response := StdOutErrToVar(cmd)
    MsgBox("Output: " response, "StdOutErrToVar")


    icaclsExe := "C:\Windows\System32\icacls.exe"
    LockFolder := '"D:\Lock Me"'
    Param := "/deny everyone:f"

    cmd := icaclsExe " " LockFolder " " Param

    ;cmd := "'D:\My Test Folder\icacls.exe' 'D:\Lock Me' /deny everyone:f'"
    cmd := '"D:\My Test Folder\icacls.exe" "D:\Lock Me" /deny everyone:f'

;    cmd := "'"D:\My Test Folder\icacls.exe"'" "D:\Lock Me" /deny everyone:f"

exe := "D:\My Test Folder\icacls.exe"
target := "D:\Lock Me"
cmd := Format('"{}" "{}" /deny everyone:f', exe, target)

cmd:= '"' '"' "D:\My Test Folder\icacls.exe" '"' A_Space '"'
cmd.= '"' '"' "D:\Lock Me" '"' A_Space '"'
cmd.= '"' "/deny everyone:f" '"'
;cmd.= "/deny everyone:f"

exe:= "D:\My Test Folder\icacls.exe"
path:= "D:\Lock Me"
param:= "/deny everyone:f" 

cmd := A_ComSpec . " /D /Q /C " 
cmd .= '"' '"' exe '"' A_Space
cmd .= '"' '"' path '"' A_Space
cmd .= param A_Space '"'

;MsgBox cmd
    response := StdOutErrToVar(cmd)
    MsgBox("Output: " response, "StdOutErrToVar")

    cmd := icaclsExe " " LockFolder " " "/remove everyone"
    response := StdOutErrToVar(cmd)
    MsgBox("Output: " response, "StdOutErrToVar")

;    r := RunCMD(icaclsExe, LockFolder, "/deny everyone:f")
;     MsgBox("Exit Code: " r ", Output:`n`n" RunCMD.Output, "Test 1 Lock Folder Result")

;     r := RunCMD(icaclsExe, LockFolder, "/remove everyone")
;     MsgBox("Exit Code: " r ", Output:`n`n" RunCMD.Output, "Test 0 Result")

}

Test1(){

    cmd := "echo Hello World & ping -n 1 127.0.0.1" ; Example command

    response := StdOutToVar(cmd)
    MsgBox("Output: " response, "StdOutToVar")

    cmd := "dir d:\invalid.txt"
    response := StdOutErrToVar(cmd)
    MsgBox("Output: " response, "StdOutErrToVar")

}
; Example usage:
ExitApp

ExitFunc(*) {
    mem:=""
    ExitApp()
}