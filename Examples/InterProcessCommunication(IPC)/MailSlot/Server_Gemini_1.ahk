; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Requires AutoHotkey v2.0

; --- Mailslot Constants ---
global MAILSLOT_NAME := "\\\\.\\mailslot\\AHKv2MailSlot"
global MAX_MESSAGE_SIZE := 1024  ; Max message size in bytes
global MAILSLOT_WAIT_FOREVER := -1 ; Timeout value for reading
global INVALID_HANDLE_VALUE := -1

; --- Global Variables ---
global hSlot := 0  ; Handle for the mailslot

; --- Main execution ---
; Create the mailslot and store the handle
hSlot := CreateMailslot(MAILSLOT_NAME, MAX_MESSAGE_SIZE, MAILSLOT_WAIT_FOREVER, 0)

if (hSlot == INVALID_HANDLE_VALUE) {
    MsgBox("Error creating mailslot: " . A_LastError, "Mailslot Error", "IconX")
    ExitApp
}

MsgBox("Mailslot Server is running. Name: " . MAILSLOT_NAME . "`n`nClick OK to start listening.", "Mailslot Server")

; Set up a loop to poll the mailslot for messages
SetTimer(ListenForMessages, 500) ; Check every 500 ms (0.5 seconds)

; Keep the script running
#HotIf
F12:: {
    CloseMailslot(hSlot)
    ExitApp
}

; =================================================================
; Mailslot Server Functions
; =================================================================

CreateMailslot(lpName, nMaxMessageSize, lReadTimeout, lpSecurityAttributes) {
    ; HANDLE CreateMailslot(LPCSTR lpName, DWORD nMaxMessageSize, DWORD lReadTimeout, LPSECURITY_ATTRIBUTES lpSecurityAttributes);
    return DllCall("kernel32.dll\CreateMailslot",
        "Str", lpName,
        "UInt", nMaxMessageSize,
        "UInt", lReadTimeout,
        "Ptr", lpSecurityAttributes,
        "Ptr")
}

CloseMailslot(h) {
    if (h) {
        DllCall("kernel32.dll\CloseHandle", "Ptr", h)
        h := 0
        MsgBox("Mailslot closed.", "Info")
    }
}

ListenForMessages() {
    ; Retrieve mailslot info to see if there are messages
    local cbMessage, cMessage, cbNextMessage
    
    ; Ptr: address of cbNextMessage
    ; Ptr: address of cbMessage
    ; Ptr: address of cMessage
    ; Ptr: NULL (or 0) for read timeout
    DllCall("kernel32.dll\GetMailslotInfo",
        "Ptr", hSlot,
        "Ptr", 0, 
        "UInt*", &cbNextMessage,  
        "UInt*", &cMessage,      
        "Ptr", 0)
    
    ; Error check
    if (A_LastError) {
        ; MsgBox("GetMailslotInfo failed: " . A_LastError) ; Uncomment for debugging
        return
    }

    if (cbNextMessage > 0) {
        ; Message found!
        local hReadBuffer := Buffer(cbNextMessage, 0)
        local cbBytesRead := 0

        ; BOOL ReadFile(HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToRead, LPDWORD lpNumberOfBytesRead, LPOVERLAPPED lpOverlapped);
        local Result := DllCall("kernel32.dll\ReadFile",
            "Ptr", hSlot,
            "Ptr", hReadBuffer,
            "UInt", cbNextMessage,
            "UInt*", &cbBytesRead,
            "Ptr", 0)

        if (Result != 0) {
            ; Read the string from the buffer. Use StrGet to handle AHK's Unicode (UTF-16)
            local Message := StrGet(hReadBuffer, cbBytesRead / 2 ) ; /2 for Unicode
            ToolTip("New Message: " . Message . "`nTotal Messages Left: " . (cMessage - 1))
            Sleep(2000)
            ToolTip() ; Clear ToolTip
        } else {
            ToolTip("ReadFile failed: " . A_LastError)
            Sleep(2000)
            ToolTip()
        }
    }
}