; Version 1.0.0.6
#Requires AutoHotkey v2.0

/**
 * Determines and executes the correct shell command format.
 * @param Command The command string to execute.
 * @returns The WScript.Shell Exec object.
 */
ExecuteCommand(Command) {
    shell := ComObject("WScript.Shell")
    
    ; List of common internal CMD commands that require A_ComSpec
    InternalCmds := "dir,copy,move,del,type,echo,set,cls,pushd,popd,assoc,ftype"
    
    ; Check for redirection characters or internal commands
    needsShell := false
    
    ; 1. Check for pipes or redirection: | > < &
    if (RegExMatch(Command, "[|><&]"))
    {
        needsShell := true
    }
    
    ; 2. Check if the first word is an internal CMD command
    FirstWord := StrLower(StrSplit(Command, " ")[1])
    if (HasVal(StrSplit(InternalCmds, ","), FirstWord))
    {
        needsShell := true
    }

    ; Execute based on detection
    if (needsShell)
    {
        return shell.Exec(A_ComSpec ' /Q /C ' Command)
    }
    
    return shell.Exec(Command)
}

; Helper function to check value in array
HasVal(Haystack, Needle) {
    for index, value in Haystack
    {
        if (value = Needle)
            return index
    }
    return 0
}