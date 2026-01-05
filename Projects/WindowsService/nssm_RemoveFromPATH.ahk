; TITLE:    MyScript v0.0
; SOURCE:   
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; #region Admin Check

; Requires Administrator privileges
full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\\ S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp  ; Exit the current, non-elevated instance
}

NSSMx64Path := "D:\Software\DEV\Work\AHK2\Projects\WindowsService\nssm\win64\nssm.exe"
NSSMx86Path := "D:\Software\DEV\Work\AHK2\Projects\WindowsService\nssm\win32\nssm.exe"

NSSMx64ProgramFilesDir := EnvGet("ProgramFiles")
NSSMx86ProgramFilesDir := EnvGet("ProgramFiles(x86)")

; user selecty
MyExePath           := NSSMx64Path
MyProgramFilesDir   := NSSMx64ProgramFilesDir "\NSSM"
SplitPath(MyExePath, &OutName)
MyProgramFilesPath  := MyProgramFilesDir ; no OutName

msg := "Press OK to Remove NSSM from the PATH."

r:= MsgBox(msg, "NSSM Remove", "OKCancel icon?")

if (r != "OK")
    ExitApp()

; Title: Remove Directory from System PATH (HKLM)

RemoveFromSystemPath(dirToRemove) {
    global RegKey, RegValueName
    
    ;RegKey := "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    RegKey := "HKCU\Environment"
    RegValueName := "Path"

    ; Normalize directory (remove trailing backslash)
    dirToRemove := RTrim(dirToRemove, "\")

    ; 1. Read the current System PATH value
    try {
        oldPath := RegRead(RegKey, RegValueName)
    } catch {
        MsgBox("ERROR: Could not read the System PATH registry value.", "Error", "IconStop")
        return ""
    }
    
    ; 2. Prepare the old path string for safe removal
    ; Add leading/trailing semicolons to handle all cases (start, middle, end)
    pathWithDelimiters := ";" . oldPath . ";"
    targetString := ";" . dirToRemove
    
    ; 3. Remove all occurrences of the target string (e.g., replace ";C:\MyTool" with ";")
    ; The resulting string may have " ; ; " which will be cleaned in the next step.
    newPathWithDelimiters := StrReplace(pathWithDelimiters, targetString, "")

    ; 4. Clean up any resulting double semicolons (";;")
    ; This ensures a clean path list.
    newPathWithDelimiters := StrReplace(newPathWithDelimiters, ";;", ";")
    
    ; 5. Trim leading/trailing semicolons to get the final clean path
    newPath := Trim(newPathWithDelimiters, ";")


; MsgBox "PathToRemove:`n`n" PathToRemove "`n`noldPath:`n`n" oldPath "`n`nNewPath:`n`n" newPath
; ExitApp

    ; 6. Check if a change actually occurred
    if (newPath = oldPath) {
        MsgBox("The path '" . dirToRemove . "' was not found in the System PATH. No changes made.", "Result", "Icon!")
        return oldPath
    }

    ; 7. Write the new path back to the registry
    ; We use REG_EXPAND_SZ (type 2) as this is the standard type for PATH.
    ;RegWrite(newPath, 2, RegKey, RegValueName)
    RegWrite(newPath, "REG_EXPAND_SZ", "HKCU\Environment", "Path")

    ; 8. Broadcast WM_SETTINGCHANGE message
    ; This is REQUIRED for the change to take effect immediately in other running programs.
        HWND_BROADCAST:=0xFFFF
        WM_SETTINGCHANGE:=0x1A
        SMTO_ABORTIFHUNG:=0x0002
        timeoutMS:= 5000
        timeoutResult:=0
        
        DllCall("SendMessageTimeoutW", 
            "Ptr", HWND_BROADCAST,
            "UInt", WM_SETTINGCHANGE,
            "Ptr", 0, 
            "WStr", "Environment", 
            "UInt", SMTO_ABORTIFHUNG, 
            "UInt", timeoutMS, 
            "Ptr*", &timeoutResult)
    
    MsgBox("SUCCESS: The directory was removed from the permanent System PATH.`n`n"
         . "Removed: " dirToRemove
         . "`n`nNew PATH successfully broadcasted.", "System PATH Updated", "IconI")
         
    return newPath
}

; =========================================================================
; 4. USAGE EXAMPLE
; =========================================================================

;PathToRemove := "C:\Your\Old\Tool\Bin"
PathToRemove := MyProgramFilesPath
;PathToRemove := "C:\Users\Jim\AppData\Local\Programs\Microsoft VS Code\binM"

; MsgBox "PathToRemove:`n`n" PathToRemove
; ExitApp

r := RemoveFromSystemPath(PathToRemove)

MsgBox "PathToRemove:`n`n" PathToRemove "`n`nResult:`n`n" r
;ExitApp

; if (r = PathToRemove) {
;     MsgBox "Failed to Remove:`n`n" PathToRemove
;     ExitApp()
; }

;MsgBox("The script is ready, but the modification command is currently commented out (`RemoveFromSystemPath(PathToRemove)`).`n`n"
;     . "Review the code and replace the example path with the actual path you wish to remove.", "Action Needed")

;ShowPath()

ShowPath() {

    ; The command we want to run: query the User PATH registry value
    RegQueryCommand := 'REG QUERY "HKCU\Environment" /v Path'

    ; The full command passed to the 'Run' function needs two components:
    ; 1. cmd.exe: The executable for the Windows Command Prompt.
    ; 2. /k: This switch tells CMD to "Execute the command and **Keep** the window open."
    ;        (The alternative '/c' executes the command and **Closes** the window.)
    FullCommand := 'cmd.exe /k "' RegQueryCommand '"'

    try {
        Run(FullCommand)
        MsgBox("Successfully launched CMD window to display the User PATH.")

    } catch as e {
        MsgBox("ERROR: Failed to run the command.`n`n"
            . "Command attempted: " FullCommand
            . "`n`nError: " e.Message, "Execution Error", "IconX")
    }

    ; Note: The CMD window will remain open until you manually close it.
}
