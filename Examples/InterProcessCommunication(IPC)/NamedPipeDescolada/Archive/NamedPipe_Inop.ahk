; ABOUT:    NamedPipe v1.0
; SOURCE:   Copilot and https://www.autohotkey.com/boards/viewtopic.php?t=124720
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

Pipe_Wait(PipeName) {
    DllCall("WaitNamedPipe", "Str", PipeName, "UInt", 0xffffffff)
}
; Server
Pipe_Create(PipeName) {
    hPipe := DllCall("CreateNamedPipe", 
    "Str" , PipeName, 
    "UInt", 3,            ; PIPE_ACCESS_DUPLEX (read/write)
    "UInt", 0,            ; PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT
    "UInt", 1,            ; Max instances
    "UInt", 1024,         ; Out buffer size
    "UInt", 1024,         ; In buffer size
    "UInt", 0,            ; Default timeout
    "Ptr" , 0,            ; Security attributes
    "Ptr")
    return hPipe
}

; Client
Pipe_Connect(name) {
    hPipe := DllCall("CreateFile",
        "Str" , name,
        "UInt", 0xC0000000,   ; GENERIC_READ | GENERIC_WRITE
        "UInt", 0,            ; No sharing
        "Ptr" , 0,            ; Default security
        "UInt", 4,            ; OPEN_ALWAYS
        "UInt", 0,            ; No flags
        "Ptr" , 0,            ; No template
        "Ptr")
    return hPipe
}

; Server or Client
Pipe_Write(hPipe, msg) {
    buf := Buffer(StrPut(msg, "UTF-16"))
    len := StrPut(msg, buf, "UTF-16") - 1 ; get byte length (exclude null terminator)
    DllCall("WriteFile",
        "Ptr"  , hPipe,
        "Ptr"  , buf,
        "UInt" , len,
        "UInt*", &bytesWritten := 0,
        "Ptr"  , 0)
    return bytesWritten
}

; Server or Client
Pipe_Read(hPipe, size := 1024) {
    buf := Buffer(1024, 0)
    DllCall("ReadFile", "Ptr", hPipe, "Ptr", buf, "UInt", 1024, "UInt*", &bytesRead := 0, "Ptr", 0)
    return StrGet(buf, bytesRead)
}

; Server or Client
Pipe_Close(hPipe) {
    DllCall("CloseHandle", "Ptr", hPipe)
}
