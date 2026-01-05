; ABOUT  :  AddRemovePATH.ahk v1.0
; SOURCE :  Copilot, Gemini, myself. 
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

AddToSystemPath(DirToAdd) {

    static RegKey       := "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    static RegValueName := "Path"

    if (not A_IsAdmin) {
        MsgBox("AddToPath requires Admin privledge.", "Admin Required", "IconX")
        return ""
    }

    ; Normalize directory (remove trailing backslash if present)
    DirToAdd:= RTrim(DirToAdd, "\")

    try {
        oldPath := RegRead(RegKey, "Path")
    } catch {
        oldPath := ""
    }
    ; Avoid duplicate entries
    if InStr(oldPath, DirToAdd . ";") OR InStr(oldPath, DirToAdd) {
        ;MsgBox("Path already contains: " DirToAdd, "Duplicate Found", "Icon!")
        return "Duplicate Found"
    }

    newPath := (oldPath = "") ? DirToAdd : oldPath . ";" . DirToAdd

    if (InStr(newPath, "%") > 0)
        RegWrite(newPath, "REG_EXPAND_SZ", RegKey, RegValueName)
    else
        RegWrite(newPath, "REG_SZ", RegKey, RegValueName)

    ; Broadcast environment change so Explorer and apps see it
    ; Need to open a new cmd window for the new environment to take effect.
    SendMessageSettingChange()

    return newPath
}
    

AddToUserPath(DirToAdd) {

    static RegKey := "HKCU\Environment"
    static ValueName := "Path" 

    try
    {
        ExistingPath := GetUserPath()
    }
    catch
    {
        ExistingPath := ""
    }

    if (ExistingPath == "")
        return ""

    ; if the path is already present (prevent duplicates) then return ""
    if InStr(ExistingPath, DirToAdd)
        return ""
    
    ; else append the new directory to the existing path
    NewCombinedPath := ExistingPath . ";" . DirToAdd

    ; no RegWrite "REG_SZ", RegKey, ValueName, NewCombinedPath
    if (InStr(NewCombinedPath, "%") > 0)
        RegWrite(NewCombinedPath, "REG_EXPAND_SZ", RegKey, ValueName)
    else
        RegWrite(NewCombinedPath, "REG_SZ", RegKey, ValueName)


    SendMessageSettingChange()
    return NewCombinedPath
}

RemoveFromSystemPath(DirToRemove) {
    
    static RegKey       := "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    static RegValueName := "Path"

    if (not A_IsAdmin) {
        MsgBox("RemoveFromSystemPath requires Admin privledge.", "Admin Required", "IconX")
        return ""
    }

    ; Normalize directory (remove trailing backslash if present)
    DirToRemove := RTrim(DirToRemove, "\")

    ; Read the current System PATH value
    oldPath := GetSystemPath()

    if (oldPath == "")
        return ""
    
    ; StrReplace algorithm:
    ; ------------------------------------------------------------------------------------------
    ; old path                       c:\dir1;c:\dir2;c:\dir3
    ; remove dir1, dir2, dir3       ;c:\dir2;c:\dir3          c:\dir1;;c:\dir3    c:\dir1;c:\dir2;
    ; replace ';;'' with ';''       ;c:\dir2;c:\dir3          c:\dir1;c:\dir3     c:\dir1;c:\dir2;
    ; remove leading/ending ';'      c:\dir2;c:\dir3          c:\dir1;c:\dir3     c:\dir1;c:\dir2
    ; done!

    ; Remove the DirToRemove from the PATH (case-insensitive replacement)
    ; Replace double ;; with single ;
    ; Remove leading and ending single ;
    newPath := StrReplace(oldPath, DirToRemove, "")
    newPath := StrReplace(newPath, ";;", ";")
    newPath := Trim(newPath, ";")

;MsgBox "CHECK: PathToRemove:`n`n" DirToRemove "`n`noldPath:`n`n" oldPath "`n`nNewPath:`n`n" newPath 

    ; Write the new path back to the registry
    ; if environment variables then expand, e.g. expand %SystemRoot% to C:\WINDOWS
    ; else write the path as-is
    if (InStr(newPath, "%") > 0)
        RegWrite(newPath, "REG_EXPAND_SZ", RegKey, RegValueName)
    else
        RegWrite(newPath, "REG_SZ", RegKey, RegValueName)

    ; Broadcast WM_SETTINGCHANGE message
    ; This is REQUIRED for the change to take effect immediately in other running programs.
    SendMessageSettingChange()
         
    return newPath
}

RemoveFromUserPath(DirToRemove) {

    static RegKey       := "HKCU\Environment"
    static RegValueName := "Path"

    ; Normalize directory (remove trailing backslash if present)
    DirToRemove:= RTrim(DirToRemove, "\")

    ; Get the current process PATH
    oldPath := GetUserPath()

    if (oldPath == "")
        return ""

    ; Remove the DirToRemove from the PATH (case-insensitive replacement)
    ; Replace double ;; with single ;
    ; Remove leading and ending single ;
    newPath := StrReplace(oldPath, DirToRemove, "")
    newPath := StrReplace(newPath, ";;", ";")
    newPath := Trim(newPath, ";")

    ; Set the new, modified PATH back to the environment
    ; Write the new path back to the registry
    ; if environment variables then expand, e.g. expand %SystemRoot% to C:\WINDOWS
    ; else write the path as-is
    if (InStr(newPath, "%") > 0)
        RegWrite(newPath, "REG_EXPAND_SZ", RegKey, RegValueName)
    else
        RegWrite(newPath, "REG_SZ", RegKey, RegValueName)

    return newPath
}

GetSystemPath() {
   static RegKey       := "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
   static RegValueName := "Path"
    try {
        return RegRead(RegKey, RegValueName)
    } catch {
        return ""
    }
}

GetUserPath() {

    static RegKey    := "HKCU\Environment"
    static ValueName := "Path" 
    UserPath         := ""

    try
    {
        UserPath := RegRead(RegKey, ValueName)
    }
    catch as e
    {
        throw e.Message
    }
    return UserPath
}

SendMessageSettingChange() {

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

    return timeoutResult
}