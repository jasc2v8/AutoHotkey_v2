; Version 1.0.2
#Include EventLib.ahk

; Create both event handles
hCtoS := EventLib.Create("Event_CtoS") ; Client to Server
hStoC := EventLib.Create("Event_StoC") ; Server to Client

MsgBox("Server Ready. Waiting for Client...")

Loop {
    ; 1. Wait for Client signal
    if (EventLib.Wait(hCtoS) = 0)
    {
        MsgBox("Server: Received signal from Client. Sending Response...")
        EventLib.Reset(hCtoS)
        
        ; 2. Signal the Client back
        Sleep(500)
        EventLib.Set(hStoC)
    }
    SoundBeep
}

EventLib.Close(hCtoS)
EventLib.Close(hStoC)