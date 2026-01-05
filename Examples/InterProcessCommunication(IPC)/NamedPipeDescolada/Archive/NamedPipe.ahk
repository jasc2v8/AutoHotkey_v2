; ABOUT:    NamedPipe v1.0
; SOURCE:   Copilot and https://www.autohotkey.com/boards/viewtopic.php?t=124720
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

CreateNamedPipe_TEST(Name, OpenMode:=3, PipeMode:=0, MaxInstances:=255) {
    DllCall("CreateNamedPipe", 
    "str", Name, 
    "uint", OpenMode, 
    "uint", PipeMode, 
    "uint", MaxInstances, "uint", 0, "uint", 0, "uint", 0, "ptr", 0, "ptr")
}

ConnectNamedPipe(hPipe) {
    DllCall("ConnectNamedPipe", "ptr", hPipe, "ptr", 0)
}

CloseHandle(hPipe) {
    DllCall("CloseHandle", "ptr", hPipe)
}

WriteNamedPipe(hPipe, msg) {
    ; Wrap the handle in a file object
    f := FileOpen(hPipe, "h")
    ; If the new-line is not included then the message can't be read from the pipe
    f.Write(msg "`n")
    ; Wait for the response
    while !(msg := f.ReadLine())
        Sleep 200
    MsgBox "Response: " msg
    ;f.Close() wouldn't close the handle
    DllCall("CloseHandle", "ptr", hPipe)
}

ReadNamedPipe(hPipe, msg) {
    f := FileOpen(hPipe, "h")
    while !(msg := f.ReadLine())
        Sleep 200
    MsgBox "Response: " msg
    ;f.Close() wouldn't close the handle
    DllCall("CloseHandle", "ptr", hPipe)
}

; NEW CODE

Pipe_Create(Name, OpenMode:=3, PipeMode:=0, MaxInstances:=255) {
    DllCall("CreateNamedPipe", 
    "str", Name, 
    "uint", OpenMode, 
    "uint", PipeMode, 
    "uint", MaxInstances, "uint", 0, "uint", 0, "uint", 0, "ptr", 0, "ptr")
}

Pipe_Connect(hPipe) {
    DllCall("ConnectNamedPipe", "ptr", hPipe, "ptr", 0)
}

Pipe_Read(PipeName) {
    f := FileOpen(PipeName, "r")
    msg:= f.ReadLine()
    f.Close()
    return msg
}

Pipe_Wait(PipeName) {
    DllCall("WaitNamedPipe", "Str", PipeName, "UInt", 0xffffffff)
}

Pipe_Write(hPipe, msg) {
    f := FileOpen(hPipe, "h")
    f.Write(msg "`n")
    f.Close()
}

Pipe_Close(hPipe) {
    DllCall("CloseHandle", "ptr", hPipe)
}

; OLD CODE

Pipe_Wait_OLD(PipeName) {
    DllCall("WaitNamedPipe", "Str", PipeName, "UInt", 0xffffffff)
}
; Server

Pipe_Create_OLD(PipeName) {
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
Pipe_Connect_OLD(name) {
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
Pipe_Write_OLD(hPipe, msg) {
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
Pipe_Read_OLD(hPipe, size := 1024) {
    buf := Buffer(1024, 0)
    DllCall("ReadFile", "Ptr", hPipe, "Ptr", buf, "UInt", 1024, "UInt*", &bytesRead := 0, "Ptr", 0)
    return StrGet(buf, bytesRead)
}

; Server or Client
Pipe_Close_OLD(hPipe) {
    DllCall("CloseHandle", "Ptr", hPipe)
}
