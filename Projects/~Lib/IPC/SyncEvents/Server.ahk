; Version 1.0.2
#Include EventLib.ahk

; Create both event handles
hCtoS := EventLib.Create("Event_CtoS") ; Client to Server
hStoC := EventLib.Create("Event_StoC") ; Server to Client

MsgBox("Server Ready. Waiting for Client...")

Loop {
    ; 1. Wait for Client signal

    ; Wait(ClientSentMessage)

    if (EventLib.Wait(hCtoS) = 0)
    {
        ;ReadShared
  
        MsgBox("Server: Received signal from Client. Sending Response...")

        ;Reset(ClientSentMessage)
        EventLib.Reset(hCtoS)
        
        ; 2. Signal the Client back
        Sleep(500)

        ;WriteShared

        ;Set(ServerSentMessage))
        EventLib.Set(hStoC)
    }
    SoundBeep
}

EventLib.Close(hCtoS)
EventLib.Close(hStoC)