; TITLE  :  NamedPipeServer v0.0
; SOURCE :  Gemini and Copilot
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Inter-Process Communication (IPC) between scripts
; USAGE  :  Use AhkRunSkipUAC to run this as a Task with runLevel='highest'.
;        :  The Client script can be run with normal user privleges.
/*
    TODO:    
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

Persistent

global Logging := false
global LogFile := "D:\NamedPipeServer_log.txt"

global PipeName := "\\.\pipe\global\AHK_UTF16_Loop"

; SECURITY_ATTRIBUTES struct
sa := Buffer(A_PtrSize + 8, 0)
NumPut("UInt", sa.Size, sa, 0) ; nLength

; SECURITY_DESCRIPTOR struct
sd := Buffer(20 + A_PtrSize * 2, 0) 

; Initialize Security Descriptor
DllCall("Advapi32\InitializeSecurityDescriptor", "Ptr", sd, "UInt", 1)

; Set NULL DACL (Allow Everyone)
DllCall("Advapi32\SetSecurityDescriptorDacl", "Ptr", sd, "Int", 1, "Ptr", 0, "Int", 0)

; Put SD pointer into SA struct (Offset 4 on 32-bit, Offset 8 on 64-bit)
NumPut("Ptr", sd.Ptr, sa, A_PtrSize) 

; DLL Constants
PIPE_ACCESS_DUPLEX := DUPLEX := 0x00000003
BUFF_SIZE := 255

 WriteLog("Server START.")

Loop {

    ; Create named pipe and return its handle. Pass the 'sa' buffer as the lpSecurityAttributes parameter
    hPipe := DllCall("CreateNamedPipe", "Str", PipeName, "UInt", DUPLEX, "UInt", 0, "UInt", BUFF_SIZE, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", sa, "Ptr")
    
    if (hPipe = -1) {
        WriteLog("Error: Failed to create pipe. LastError: " A_LastError)
        Sleep 2000
        Continue
    }

    ; wait for Client to call CreateFile or CallNamedPipe
    if DllCall("ConnectNamedPipe", "Ptr", hPipe, "Ptr", 0) {

        pipeFile := FileOpen(hPipe, "h", "UTF-16")
        
        try {
            command := Trim(pipeFile.ReadLine(), "`r`n ")

            WriteLog("Received: " command)

            if (StrLower(command) = "bye") {
                pipeFile.WriteLine("Goodbye!")
                pipeFile.Read(0)
                WriteLog("Server STOP.")
                ExitApp()
            }
            
            pipeFile.WriteLine("ACK: [" . command . "]")
            pipeFile.Read(0)

        } catch Any as e {
            WriteLog("Communication Error: " e.Message)

        } finally {
            pipeFile := "" 
            DllCall("DisconnectNamedPipe", "Ptr", hPipe)
            DllCall("CloseHandle", "Ptr", hPipe)
        }

    } else {
        DllCall("CloseHandle", "Ptr", hPipe)
    }    
}

WriteLog(text) {
    if (Logging) {
        try {
            FileAppend(FormatTime(A_Now, "HH:mm:ss") ": " text "`n", LogFile)
        }
    }
}