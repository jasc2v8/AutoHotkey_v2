; Version 1.0.1
#Include EventLib.ahk

EventName := "MySharedEvent"
hEvent := EventLib.Create(EventName)

if (hEvent = 0)
{
    MsgBox("Failed to create event.")
    ExitApp()
}

;MsgBox("Server is listening for event: " . EventName)
ToolTip("Server is listening for event: " . EventName)

; Wait indefinitely for the signal
result := EventLib.Wait(hEvent)

if (result = 0)
    MsgBox("Signal received from Client!")
else
    MsgBox("Wait failed or timed out.")

EventLib.Close(hEvent)
ExitApp()