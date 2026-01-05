
#SingleInstance force

#Include <ConsoleWindow>
#include ..\src\SharedMemory.ahk
#Include .\GenerateLoremIpsum.ahk

global defaultPrompt:= "This is a message from the CLIENT"

mem := SharedMemory()

console:= ConsoleWindow("Server",,320,240,10,10)

OnExit(ExitFunc)

Loop {

     ClientMessage := InputBox(  "Start the Server, then Create a message", "CLIENT",,defaultPrompt)

    If ClientMessage.Result = "Cancel" {
        ExitApp
    } else if (ClientMessage.Value = "BYE") {
        ExitApp
    } else if (ClientMessage.Value = "") {
        SoundBeep
        continue
    } else {
         ClientMessage := ClientMessage.Value 
    }
   
    mem.Write(ClientMessage)
   
    ServerMessage := mem.ReadWait(20)

    if (ServerMessage = "NO_RESPONSE")
        defaultPrompt:= ServerMessage

    console.WriteLine(ServerMessage)    

}

ExitFunc(*) {
    mem:=""
    ExitApp()
}