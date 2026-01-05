; TITLE: RunCMD initial version

#Requires AutoHotkey 2.0+

;----------------------------------------------------------------------------------
; SUMMARY:      Helper function to run a command line with switches and parameters.
;               This will handle the finicky quotes and double quotes for you.
; PARAMETERS:   ExeFile, P1, P2, PN ...
; EXAMPLE:      RunCMD("C:\Program Files (x86)\MyApp\MyApp.exe", "/q", FileName)
; RETURN:       If success with StdOut, return StdOut, else 0
;               If error with StdOut, return StdOut, else -1
;----------------------------------------------------------------------------------
RunCMD(Parts*) {

    DQ := '"'
    SQ := "'"
    SP := A_Space
  
    fso := ComObject("Scripting.FileSystemObject")
    randomFileame := fso.GetTempName()
    tempFilename := A_Temp "\" randomFileame

    cmd := A_ComSpec . " /D /Q /C " DQ

    for index, value in Parts {
        if (value) {

            ; The first parameter is the executable file
            ; This can be C:\My Folder\My App.exe, or dir, ipconfig, etc.
            if A_Index = 1 {
                if InStr(value, "\") AND InStr(value, A_Space)
                    ; C:\Program Files (x86)\MyApp\MyApp.exe = spaces
                    cmd .= DQ value DQ SP
                else
                    ; C:\MyPathWithoutSpaces\MyApp\MyApp.exe = no spaces
                    cmd .= value SP
            } else if (SubStr(Trim(value), 1, 1) = "/") OR (SubStr(Trim(value), 1, 1) = "-") {
                ; switches "-" or "/" = -h, --help, /s, etc.
                cmd .= value SP
            } else {
                ; dir, ipconfig, etc.
                cmd .= DQ value DQ SP
            }
        }
    }

    cmd .= " 2>&1 > " DQ tempFilename DQ

    cmd .= DQ

    ;MsgBox cmd, "cmd"

    r := RunWait(cmd,,'Hide')

    contents := FileRead(tempFilename)

    FileDelete(tempFilename)

    ;If success
    if (r=0)
        ; With contents, return contents, else 0
        ReturnValue := (contents != "") ? contents : 0
    ; else error
    else
        ; With contents, return contents, else -1
        ReturnValue := (contents != "") ? contents : -1

    return ReturnValue
}

; #region Tests

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    RunCmd__Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

RunCmd__Tests() {

    ; comment out to run tests
    SoundBeep(), ExitApp()

    ;comment out tests to skip:
    Test0()
    Test1()
    Test2()
    Test3()

    ; test methods
    Test0(){
        SyncBackPath    := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
        SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
        SyncBackProfile := "TEST"
        ;MsgBox(RunCMD("C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe", "~Backup JIM-PC folders to JIM-SERVER"), "Output of SyncBackSE")
        MsgBox(RunCMD(SyncBackPath, SyncBackProfile), "Output of SyncBackSE")
    }
    Test1() {

        LockFolder := "D:\Lock"

        if !DirExist(LockFolder)
            DirCreate(LockFolder)

        icaclsExe := "C:\Windows\System32\icacls.exe"

        r := RunCMD(icaclsExe, LockFolder, "/deny everyone:f")

        MsgBox(r, "Output of Lock Folder")

        r := RunCMD(icaclsExe, LockFolder, "/remove everyone")

        MsgBox(r, "Output of Unlock Folder")

    }
    Test2() {

         ;r := RunCMD("dir","/s", "D:\Docs_Backup")
        r := RunCMD("dir", "/s", "D:\ROOT")
        MsgBox(r, 'Output of "dir", "/s"')

         ;r := RunCMD("dir","/s", "D:\Docs_Backup")
        r := RunCMD("dir /s", "D:\ROOT")
        MsgBox(r, 'Output of "dir/s"')

        r := RunCMD("dir /s", "C:\Program Files (x86)")
        MsgBox(r, 'Output of "dir/s"')

    }

    Test3() {

        MsgBox(RunCMD("C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe", "TEST"), "Output of SyncBackSE")
    }
}
