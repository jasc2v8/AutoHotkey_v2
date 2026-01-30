; Version 1.0.1
#Include EventLib.ahk

; Remember: PrivateExtractIcons and named events are case sensitive
EventName := "MySharedEvent" 
hEvent := EventLib.Open(EventName)

if (hEvent = 0)
{
    MsgBox("Could not open event. Is the Server running?")
    ExitApp()
}

MsgBox("Click OK to signal the Server.")
EventLib.Set(hEvent)

EventLib.Close(hEvent)
ExitApp()