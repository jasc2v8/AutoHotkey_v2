; ABOUT:    MyScript v0.0
; SOURCE:   Copilot
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    msg := "Hello from server!"

    client ony received "Hello fro"
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

Persistent

global PipeName := "\\.\pipe\global\AHK_UTF16_Loop"

; --- Corrected Security Descriptor Logic ---
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

MsgBox "Server (Admin) starting on: " PipeName

Loop {
    ; Pass the 'sa' buffer as the lpSecurityAttributes parameter
    hPipe := DllCall("CreateNamedPipe", "Str", PipeName, "UInt", 3, "UInt", 0, "UInt", 255, "UInt", 0, "UInt", 0, "UInt", 0, "Ptr", sa, "Ptr")
    
    if (hPipe = -1)
        Continue

    if DllCall("ConnectNamedPipe", "Ptr", hPipe, "Ptr", 0) {
        pipeFile := FileOpen(hPipe, "h", "UTF-16")
        
        try {
            query := Trim(pipeFile.ReadLine(), "`r`n ")
            
            if (StrLower(query) = "bye") {
                pipeFile.WriteLine("Goodbye! Closing Global Server.")
                pipeFile.Read(0)
                pipeFile := ""
                DllCall("DisconnectNamedPipe", "Ptr", hPipe)
                DllCall("CloseHandle", "Ptr", hPipe)
                ExitApp
            }
            
            pipeFile.WriteLine("Admin Server says: Received [" . query . "]")
            pipeFile.Read(0)
        }
        pipeFile := "" 
    }
    
    DllCall("DisconnectNamedPipe", "Ptr", hPipe)
    DllCall("CloseHandle", "Ptr", hPipe)
}