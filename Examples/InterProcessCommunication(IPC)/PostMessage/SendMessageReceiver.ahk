; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; 1. Define a Custom Message ID
; RegisterWindowMessage is used to generate a unique ID for cross-application messages.
Global WM_CUSTOM_STRING := DllCall("RegisterWindowMessage", "Str", "AHK_CUSTOM_STRING_MSG", "UInt")

; 2. Set up the Message Handler (OnMessage)
; When the message is received, call the ProcessString function.
OnMessage(WM_CUSTOM_STRING, ProcessString)

; 3. Main Handler Function
ProcessString(wparam, lparam, msg, hwnd)
{
    ; wparam is the pointer (address) to the string buffer.
    ; lparam is the length (in characters) of the string.
    
    StringLength := lparam
    StringPointer := wparam
    
    ; Use StrGet to copy the string from the memory address (pointer) 
    ; provided by the sender script into a local AHK variable.
    ;ReceivedString := StrGet(StringPointer, StringLength, "UTF-8")
    ReceivedString := StrGet(StringPointer, StringLength, "UTF-16")

    ; Display the received string and the sender's window title for context.
    SenderTitle := WinGetTitle("ahk_id " . hwnd)
    
    MsgBox("Received String: " . ReceivedString 
        . "`nLength: " . StringLength 
        . "`nFrom Window: " . SenderTitle,
        "Message Received!")
    
    ; Return True or 0 to indicate the message was handled.
    return 0
}

; Show the message ID and the script's own HWND (Window ID) in the tray tip
; so the sender script knows where to send the message.
;TraySetInfo("Ready to receive messages. HWND: " . A_ScriptHwnd . " | Message ID: " . WM_CUSTOM_STRING)

MsgBox("Ready to receive messages. HWND: " . A_ScriptHwnd . " | Message ID: " . WM_CUSTOM_STRING, "Message Received!")

; Keep the script running
Persistent