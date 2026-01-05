
#SingleInstance force

#include ..\src\SharedMemory.ahk

mem := SharedMemory()

OnExit(ExitFunc)

SetTimer(ReadMessage) ; default 250ms

ReadMessage() {

    ClientMessage := mem.Read()
    
    if (ClientMessage = "TERMINATE")  {
        mem.Write("ACK TERMINATE")
        SetTimer(, 0)
        ExitFunc()
    }

    ServerMessage := "ACK" ; ClientMessage

    mem.Write(ServerMessage)

}

ExitFunc(*) {
    mem:=""
    ExitApp()
}