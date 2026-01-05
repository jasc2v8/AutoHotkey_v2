; ABOUT: ShowArgs.ahk v10
; 
/*
    TODO:

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
;#NoTrayIcon

#Include <LogFile>
#Include SharedMemory.ahk
;#Include <RunAsAdmin>

; Initialize as Client (3rd param = false/omitted)
mem := SharedMemory("MyBridge", 4096, false)

; 1. Send data (automatically signals the server)
mem.Write("Hello Server!")

; 2. Wait for response
if (response := mem.ReadWait(2000)) {
    MsgBox "Response: " response
} else {
    MsgBox "No response from Server."
}