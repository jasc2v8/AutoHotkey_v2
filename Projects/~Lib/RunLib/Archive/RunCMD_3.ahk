; TITLE: RunCMD initial version

#Requires AutoHotkey 2.0+

;----------------------------------------------------------------------------------
; SUMMARY:      Helper function to run a commandLine line with switches and parameters.
;               This will handle the finicky quotes and double quotes for you.
; PARAMETERS:   ExeFile, P1, P2, PN ...
; EXAMPLE:      RunCMD("C:\Program Files (x86)\MyApp\MyApp.exe", "/q", FileName)
; RETURN:       If success with StdOut, return StdOut, else 0
;               If error with StdOut, return StdOut, else -1
;----------------------------------------------------------------------------------
RunCMD(Parameters*) {

    DQ := '"'
    SQ := "'"
    SP := A_Space
  
    fso := ComObject("Scripting.FileSystemObject")
    randomFileame := fso.GetTempName()
    TempFile := A_Temp "\" randomFileame

    CommandLine := A_ComSpec . " /D /Q /C " 

    for index, value in Parameters {

        ; If the first parameter is an executable, add extra quotes and EndQuote
        if (index = 1) {
            ; If an executable, add quotes
            if InStr(value, "\") AND InStr(value, A_Space){
                CommandLine .= '"' '"' value '"' A_Space
                EndQuote := '"'

            } else {
                ; Not an executable, no quotes
                CommandLine .= value A_Space
            }
        } else {
            ; If a Parameter is an executable, add quotes
            if InStr(value, "\") AND InStr(value, A_Space) {
                CommandLine .= '"' value '"' A_Space
                EndQuote := ""

            } else {
                ; Not an executable, no quotes
                CommandLine .= value A_Space
            }
        }
    }

    CommandLine .= " > " '"' TempFile '"' " 2>&1" EndQuote

MsgBox CommandLine, "DEBUT RunCMD"

    r := RunWait(A_ComSpec ' /C ' CommandLine, , 'Hide')

MsgBox r, "DEBUG Result"

    contents := FileRead(TempFile)

    FileDelete(TempFile)

    ; If Success return Output, else Error return ""
    ReturnValue := (contents != "") ? contents : ""

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
    ;SoundBeep(), ExitApp()

    #Warn Unreachable, Off

    ;comment out tests to skip:
    ;Test0()
    ;Test1()
    Test2()
    ;Test3()

    ;Test10()
    ;Test11()
    ;Test12()
    ;Test13()

    ; test methods
    Test0(){

        SQ := "'"
        DQ := '"'
        SP := A_Space

        SyncBackPath    := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
        SyncBackProfile := "~Backup JIM-PC folders to JIM-SERVER"
        SyncBackProfile := "TEST"
        SyncBackProfile := "'TEST WITH SPACES'"
        NotepadPath := "C:\Windows\notepad.exe"

        PiaPath := "C:\Program Files\Private Internet Access"
        PiaCtlPath := "C:\Program Files\Private Internet Access\piactl.exe"
        Executable := "C:\Program Files\Private Internet Access\piactl.exe"
        ExeParameters := "-h"
        ExeParameters := "get connectionstate"

        Command := "dir"
        CmdParameters := "/b " "C:\ProgramData\"
        CmdParameters := "/b " '"' "C:\Program Files\" '"'

        if DirExist("D:\Docs_Backup")
            DirDelete("D:\Docs_Backup",1)

        ; if the value is a command or switch for the Executable, don't add quotes.
        ; if the value is a Parameter variable, then add quotes.

        ; ok r := RunCMD(SyncBackPath, "TEST")               ; so spaces, no quotes
        ; ok r := RunCMD(SyncBackPath, '"TEST WITH SPACES"') ; Variable, manually add quotes
        ; NO r := RunCMD(SyncBackPath, "'TEST WITH SPACES'") ; quotes are wrong

        ; ok
         r := RunCMD(PiaCtlPath, "get connectionstate")      ; Parameter or Switch, no quotes

        ; ok r := RunCMD("dir", "/b", "C:\Program Files")
        ; ok r := RunCMD("dir", "/b", "C:\ProgramData")

        MsgBox r, "Test0 Result"
        
    }

    Test10() {

        ; Get RunWait to work with executable, parameters, and return StdOut + StdErr

        PiaCtlPath := "C:\Program Files\Private Internet Access\piactl.exe"

        TempFile := "D:\My Test.tmp"
        if FileExist(TempFile)
            FileDelete(TempFile)

        ; This works and output is saved
        PIA_CommandLine := '"C:\Program Files\Private Internet Access\piactl.exe" -h 2>&1> D:\My Test.tmp'
        ;r := RunWait(A_ComSpec ' /C ' PIA_CommandLine, , 'Hide')

        ;PIA_CommandLine := '"C:\Program Files\Private Internet Access\piactl.exe" -h 2>&1> "' TempFile '"'

        PIA_CommandLine := '"' PiaCtlPath '"' " -h 2>&1> D:\MyTest.tmp"     ; wrong syntax
        PIA_CommandLine := '"' PiaCtlPath '"' " -h > D:\MyTest.tmp 2>&1"    ; correct syntax

        PIA_CommandLine := '"' PiaCtlPath '"' " -h > " TempFile " 2>&1"    ; filename no spaces

        ;PIA_CommandLine := '"' '"' PiaCtlPath '"' " > " '"' TempFile '"' " 2>&1" '"' ; Error returned with StdErr to TempFile

        PIA_CommandLine := '"' '"' PiaCtlPath '"' " -h > " '"' TempFile '"' " 2>&1" '"'

        MsgBox PIA_CommandLine, "PIA_CommandLine"

        r := RunWait(A_ComSpec ' /C ' PIA_CommandLine, , 'Hide')

        ; This won't work because we need the output from A_Comspec
        ;r := RunWait(PIA_CommandLine, , 'Hide')

        MsgBox r

    }

    Test11() {

        ; Get RunWait to work with commandLine, parameters, and return StdOut + StdErr

        Command := "dir"
        Parameters := "/b"

        TempFile := "D:\My Test.tmp"
        if FileExist(TempFile)
            FileDelete(TempFile)

        ; NO because we can't have "dir", just dir
        ;CommandLine := '"' '"' ExePath '"' " -h > " '"' TempFile '"' " 2>&1" '"'

        CommandLine := '"' Command A_Space Parameters " > " '"' TempFile '"' " 2>&1" '"'

        MsgBox CommandLine, "CommandLine"

        r := RunWait(A_ComSpec ' /C ' CommandLine, , 'Hide')

        MsgBox r, "Result"

    }

    Test12() {

        ; Determine if Command or Executable
        ; TODO: quotes around parameters with spaces

        Executable := "C:\Program Files\Private Internet Access\piactl.exe"
        ExeParameters := "-h"
        ExeParameters := "get connectionstate"

        Command := "dir"
        CmdParameters := "/b " "C:\ProgramData\"
        CmdParameters := "/b " '"' "C:\Program Files\" '"'

        Executable    := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
        ExeParameters := "~Backup JIM-PC folders to JIM-SERVER"
        ExeParameters := "TEST"
        ExeParameters := '"' "TEST WITH SPACES" '"'

        if DirExist("D:\Docs_Backup")
            DirDelete("D:\Docs_Backup",1)

        ; Begin

        TempFile := "D:\My Test.tmp"

        if FileExist(TempFile)
            FileDelete(TempFile)

        WhichFile := Executable
        ;WhichFile := Command

        if InStr(WhichFile, "\") != 0 {
            CommandLine := '"' '"' Executable '"' A_Space ExeParameters ; " > " '"' TempFile '"' " 2>&1" '"'

        } else {
            CommandLine := '"' Command A_Space CmdParameters ; " > " '"' TempFile '"' " 2>&1" '"'
        }

        CommandLine .= " > " '"' TempFile '"' " 2>&1" '"'

        MsgBox CommandLine, "Test 12 CommandLine"

        r := RunWait(A_ComSpec ' /C ' CommandLine, , 'Hide')

        MsgBox r, "Result"

    }

    Test13() {

        ; Add quotes around parameters with spaces

        Executable := "C:\Program Files\Private Internet Access\piactl.exe"
        ExeParameters := "-h"
        ExeParameters := "get connectionstate"

        Command := "dir"
        CmdParameters := "/b " "C:\ProgramData\"
        CmdParameters := "/b " '"' "C:\Program Files\" '"'

        Executable    := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
        ExeParameters := "~Backup JIM-PC folders to JIM-SERVER"
        ExeParameters := "TEST"
        ; fixed ExeParameters := '"' "TEST WITH SPACES" '"'
        ExeParameters := "TEST WITH SPACES"

        if DirExist("D:\Docs_Backup")
            DirDelete("D:\Docs_Backup",1)

        ; Begin

        TempFile := "D:\My Test.tmp"

        if FileExist(TempFile)
            FileDelete(TempFile)

        WhichFile := Executable
        ;WhichFile := Command

        if InStr(ExeParameters, A_Space) != 0 {
            ExeParameters := '"' ExeParameters '"'
        }

        if InStr(CmdParameters, A_Space) != 0 {
            CmdParameters := '"' CmdParameters '"'

        }

        if InStr(WhichFile, "\") != 0 {
            CommandLine := '"' '"' Executable '"' A_Space ExeParameters ; " > " '"' TempFile '"' " 2>&1" '"'

        } else {
            CommandLine := '"' Command A_Space CmdParameters ; " > " '"' TempFile '"' " 2>&1" '"'
        }

        CommandLine .= " > " '"' TempFile '"' " 2>&1" '"'

        MsgBox CommandLine, "Test 12 CommandLine"

        r := RunWait(A_ComSpec ' /C ' CommandLine, , 'Hide')

        MsgBox r, "Result"

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

        ; OK
        
        Executable      := "C:\Program Files\Google\Chrome\Application\chrome.exe"
        
        ExeParameters   := "--incognito https://snowfl.com"

        ExeParam1   := "--incognito"
        ExeParam2   := "https://snowfl.com"

        ; r := RunCMD(Executable, ExeParameters)
        ; MsgBox(r, "Test2 Result")

        r := RunCMD(Executable, ExeParam1, ExeParam2)
        MsgBox(r, "Test2 Result")

    }

    Test3() {

        MsgBox(RunCMD("C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe", "TEST"), "Output of SyncBackSE")
    }
}
