
#SingleInstance force

#Include <ConsoleWindow>
#include ..\src\SharedMemory.ahk

mem := SharedMemory()
mem.Clear()

;console:= ConsoleWindow("Server",,800,400,10,10)
; console.WriteLine("Hellow World!")
; MsgBox

OnExit(ExitFunc)

Loop { 

    ClientMessage := mem.Read()
    
    if (ClientMessage = "TERMINATE")
        ExitFunc()

    ServerMessage := "ACK " ClientMessage

    ;Sleep 200

    mem.Write(ServerMessage)
    
    Sleep 200

}

ExitFunc(*) {
    mem:=""
    ExitApp()
}