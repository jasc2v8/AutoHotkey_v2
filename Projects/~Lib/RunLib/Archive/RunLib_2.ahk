; Version 1.0.0.8
#Requires AutoHotkey v2.0


exec := GetExecObject("dir C:\ > D:\test.txt")
;result := exec.StdOut.ReadAll()
result := exec
MsgBox(result)


/**
 * Enhanced Execution Logic
 * Determines if a command is a CMD internal, a PowerShell script, or a standard EXE.
 */
GetExecObject(Command) {
    shell := ComObject("WScript.Shell")
    Command := Trim(Command)
    
    ; 1. PowerShell Detection (.ps1 files)
    SplitPath(Command, , , &ext)
    if (StrLower(ext) = "ps1")
    {
        ; Wrap in powershell execution logic
        psCmd := 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' Command '"'
        return shell.Exec(psCmd)
    }

    ; 2. CMD Internal Commands List
    internalList := "assoc,break,call,cd,chdir,chcp,cls,color,copy,date,del,dir,echo," 
                  . "endlocal,erase,exit,for,ftype,goto,if,md,mkdir,mklink,move,path," 
                  . "pause,popd,prompt,pushd,rd,rem,ren,rename,rmdir,set,setlocal," 
                  . "shift,start,time,title,type,ver,verify,vol"

    ; 3. Detect Shell Operators (Pipes, Redirection, Chaining)
    if (RegExMatch(Command, "[|><&]"))
    {
        return shell.Exec(A_ComSpec ' /Q /C ' Command)
    }

    ; 4. Detect Internal CMD Commands by first word
    FirstWord := StrLower(StrSplit(Command, " ")[1])
    isInternal := false
    
    loop parse internalList, ","
    {
        if (FirstWord = A_LoopField)
        {
            isInternal := true
            break
        }
    }

    if (isInternal)
    {
        return shell.Exec(A_ComSpec ' /Q /C ' Command)
    }

    ; 5. Standard Execution Fallback
    try {
        return shell.Exec(Command)
    } catch Error {
        ; Final fallback: if direct execution fails, try via ComSpec
        return shell.Exec(A_ComSpec ' /Q /C ' Command)
    }
}