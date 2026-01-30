; Version 1.0.2
#Include EventLib.ahk

; Open existing handles (Ensure Server is running first)
hCtoS := EventLib.Open("Event_CtoS")
hStoC := EventLib.Open("Event_StoC")

if (hCtoS = 0 || hStoC = 0)
{
    MsgBox("Error: Could not open events. Is Server running?")
    ExitApp()
}

; 1. Signal the Server
MsgBox("Client: Sending signal to Server...")
EventLib.Set(hCtoS)

; 2. Wait for Server to respond
if (EventLib.Wait(hStoC) = 0)
{
    MsgBox("Client: Server responded! Communication successful.")
    EventLib.Reset(hStoC)
}

EventLib.Close(hCtoS)
EventLib.Close(hStoC)