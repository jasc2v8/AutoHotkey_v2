;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2+
#SingleInstance Force
#NoTrayIcon

    ArgString := ""
    for arg in A_Args
    {
        ; Use double quotes around each argument to handle spaces/special characters
        ArgString .= ' "' . arg . '"'
    }
    MsgBox ArgString, "ArgString"

; RegKey := "HKEY_CLASSES_ROOT\AutoHotkeyScript\Shell\uiAccess\Command"

; try 
; {
;     RegValue := RegRead(RegKey)
;     MsgBox("UIAccess is REGISTERED.`n`nCommand: " RegValue)
; }
; catch
; {
;     MsgBox("UIAccess is NOT registered.`n`nYou may need to run 'AutoHotkey Dash' -> 'Launch Settings' to enable it.")
; }
; Version 1.1.1
; Explicitly passing params to UIAccess without relying on console mode

FullCmdLine := DllCall("GetCommandLine", "str")

; Check if we need to elevate to UIA
if !InStr(A_AhkPath, "_UIA.exe") && !RegExMatch(FullCmdLine, "i) /restart(?!\S)")
{
    ; Build argument string
    Args := ""
    for param in A_Args
    {
        Args .= ' "' . param . '"'
    }

    try 
    {
        ; We use /restart to ensure the new process replaces this one
        Run('*UIAccess /restart "' . A_ScriptFullPath . '"' . Args)
        ExitApp
    }
    catch as err
    {
        MsgBox("UIAccess Launch Failed: " . err.Message)
    }
}

; Display results
if (A_Args.Length > 0)
{
    MsgBox("Parameters Found: " . A_Args.Length . "`n`nValue: " . A_Args[1])
}
else
{
    MsgBox("No parameters detected.`nTry calling via: AutoHotkey64.exe script.ahk hello")
}

ExitApp
d
; Version 1.0.9
; Enhanced argument passing for UIAccess relaunch

FullCmdLine := DllCall("GetCommandLine", "str")

; Check if we are NOT using the UIA interpreter AND we haven't already restarted
if !InStr(A_AhkPath, "_UIA.exe") && !RegExMatch(FullCmdLine, "i) /restart(?!\S)")
{
    ; Build the argument string carefully
    ArgString := ""
    for arg in A_Args
    {
        ; Use double quotes around each argument to handle spaces/special characters
        ArgString .= ' "' . arg . '"'
    }

    try 
    {
        ; Combine everything. The double quotes around A_ScriptFullPath are critical.
        Target := '*UIAccess /restart "' . A_ScriptFullPath . '"' . ArgString
        ;Target := " /restart " . "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe " . A_ScriptFullPath . '"' . ArgString
        ;Target := '*UIAccess /restart "' . "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe " . A_ScriptFullPath . '"' . ArgString
        Run(Target)
        ExitApp
    }
    catch as err
    {
        MsgBox("Relaunch failed:`n" . err.Message)
        ExitApp
    }
}

; --- Verification ---
if (A_Args.Length > 0)
{
    MsgBox("Success! Found " . A_Args.Length . " parameters.`n`nFirst: " . A_Args[1])
}
else
{
    ; If this shows up, it means the script restarted but lost its 'memory' of the args
    MsgBox("No parameters detected.`nInterpreter: " . A_ScriptFullPath)
}

;
;
;

; Msgbox "A_Args.Length : " A_Args.Length
; for i,v in A_Args
;     Msgbox "A_Args[" i "] :`n" v

; Msgbox "A_.CommandLine :`n" A_.CommandLine
; Msgbox "A_.Argv.Length : " A_.Argv.Length
; for i,v in A_.Argv
;     Msgbox "A_.Argv[" i "] :`n" v

; Msgbox "A_.CommandLineExecutablePath :`n" A_.CommandLineExecutablePath
; Msgbox "A_.CommandLineArguments :`n" A_.CommandLineArguments



Class A_ ;  v2.0
{
    /*
    A_.CommandLine
    A_.Argv
        A_.Argv[i]
    A_.Argc
    A_.CommandLineExecutablePath
    A_.CommandLineArguments
    */
    static CommandLine    {
        get  {
            static vCommandLine:=GetCommandLine()
            return vCommandLine
        }
    }
    static Argv    {
        get  {
            static vArgv:=CommandLineToArgvW(A_.CommandLine)
            return vArgv
        }
    }
    static Argc    {
        get  {
            static vArgc:=A_.Argv.Length
            return vArgc
        }
    }
    static CommandLineExecutablePath    {
        get  {
            static vCommandLineExecutablePath:=A_.Argv[1]
            return vCommandLineExecutablePath
        }   
    }
    static CommandLineArguments    {
        get  {
            static vArguments:=RegExReplace(RegExReplace(GetCommandLine(),"s)^(?:`"\Q" A_.CommandLineExecutablePath "\E`"|\Q" A_.CommandLineExecutablePath "\E)(.*)","${1}"),"s)^ (.*)","${1}")
            return vArguments
        }
    }
}
GetCommandLine()    { ;  v1.1  v2.0
	return DllCall("Kernel32.dll\GetCommandLine", "Str")
}
CommandLineToArgvW(CmdLine:="")    { ;  v2.0
	args:=[]
	if (pArgs:=DllCall("Shell32.dll\CommandLineToArgvW", "WStr",CmdLine, "Ptr*",&nArgs:=0, "Ptr"))    {
		Loop nArgs
			args.Push(StrGet(NumGet((A_Index-1)*A_PtrSize+pArgs,"Ptr"),"UTF-16"))
		DllCall("Kernel32.dll\LocalFree", "Ptr",pArgs)
	}
	return args
}