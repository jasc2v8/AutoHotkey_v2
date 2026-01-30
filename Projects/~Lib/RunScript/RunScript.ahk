; TITLE  :  RunScript v0.1
; SOURCE :  Gemini and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

/**
 * Runs an AHK script with optional parameters.
 * @param {String} ScriptPath - Path to the .ahk file.
 * @param {String} Args - (Optional) Command line arguments to pass to the script.
 * @param {String} WorkingDir - (Optional) Working directory. Defaults to script folder.
 */
RunScript(ScriptPath, Args := "", WorkingDir := "") {
    ; Resolve paths
    FullScriptPath := FileExist(ScriptPath) ? ScriptPath : ""
    
    if (FullScriptPath = "")
    {
        MsgBox("Script not found: " ScriptPath)
        return
    }

    if (WorkingDir = "")
    {
        SplitPath(FullScriptPath,, &Dir)
        WorkingDir := Dir
    }

    ; Construct the command string
    ; Format: "AutoHotkey.exe" "ScriptPath.ahk" Parameters
    Command := '"' A_AhkPath '" "' FullScriptPath '"' (Args != "" ? " " Args : "")

    try {
        Run(Command, WorkingDir)
    }
    catch Error as err {
        MsgBox("Failed to run script:`n" err.Message)
    }
}

; --- Examples ---

; Example 1: Passing a simple string parameter
; RunScript("Logger.ahk", "/mode:debug")

; Example 2: Passing multiple parameters
 RunScript(A_ScriptDir "\TestLogArgs.ahk", "Param1 Param2")

