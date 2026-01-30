; Version 1.0.0.7
#Requires AutoHotkey v2.0

GetExecObject("dir /b d:\ > d:\test.txt")

GetExecObject(Command) {
    shell := ComObject("WScript.Shell")
    
    ; Full list of internal commands
    internalList := "assoc,break,call,cd,chdir,chcp,cls,color,copy,date,del,dir,echo," 
                  . "endlocal,erase,exit,for,ftype,goto,if,md,mkdir,mklink,move,path," 
                  . "pause,popd,prompt,pushd,rd,rem,ren,rename,rmdir,set,setlocal," 
                  . "shift,start,time,title,type,ver,verify,vol"

    ; 1. Detect Shell Operators (Pipes, Redirection, Chaining)
    if (RegExMatch(Command, "[|><&]"))
    {
        return shell.Exec(A_ComSpec ' /Q /C ' Command)
    }

    ; 2. Detect Internal Commands
    FirstWord := StrLower(StrSplit(Trim(Command), " ")[1])
    
    ; Using a loop for the list check to keep logic clean
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

    ; 3. Standard Execution for .exe, .com, .vbs, etc.
    try {
        return shell.Exec(Command)
    } catch Error {
        ; Fallback to ComSpec if direct execution fails
        return shell.Exec(A_ComSpec ' /Q /C ' Command)
    }
}