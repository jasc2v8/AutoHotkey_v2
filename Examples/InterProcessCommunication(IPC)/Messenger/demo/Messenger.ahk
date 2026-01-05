; TITLE  :  Messenager v1.0
; SOURCE :  Gemini and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Helper class to Send/Receive messages between scripts.
; USAGE  :  ipcListen:=Messenger(A_ScriptName, 1234), ipcSender:=Messenger(TargetHWND, 1234)
; NOTES  :

/*

    TODO:

*/

#Requires AutoHotkey v2.0+

class Messenger {

    WM_COPYDATA     := 0x4A
    MSGFLT_ALLOW    := 1
    TargetTitle     := ""    
    PassKey         := 0

    /**
     * Constructor.
     * @param ListenerTitle The Title or the HWND of the receiving window.
     * @param PassKey The unique key to validate sending to the correct Listener. Defaults to 0.
     */
    __New(TargetTitle, PassKey:=0) {

        this.TargetTitle:= "" ; TargetTitle
        this.PassKey:=PassKey
    }

    /**
     * Sends a string to another window/script.
     * @param TargetTitle The Title or the HWND of the receiving window.
     * @param DataString The text you want to send.
     * @param Timeout In Milliseconds. 0=Infinite.
     * @return True if success, else False.
     */
    Send(TargetTitle, DataString, Timeout:=0) {

        oldDHW:= DetectHiddenWindows(True)
        oldSMM:= SetTitleMatchMode(2) ; contains (default)

        if (Type(TargetTitle)="String")
            TargetHWND := WinExist(TargetTitle)
        else
            TargetHWND := TargetTitle

        if !TargetHWND
            throw Error("Target window does not exist.", -1)

        ; Calculate size: (Chars + null terminator) * 2 bytes for UTF-16
        SizeInBytes := (StrLen(DataString) + 1) * 2
        
        ; Create COPYDATASTRUCT: [dwData, cbData, lpData]
        cds := Buffer(A_PtrSize * 3, 0)
        ;NumPut("UPtr", TypeCode, cds, 0)
        NumPut("UPtr", this.PassKey, cds, 0)
        NumPut("UInt", SizeInBytes, cds, A_PtrSize)
        NumPut("UPtr", StrPtr(DataString), cds, A_PtrSize * 2)

        try {
            ; SendMessage waits for the receiver to process the data
            ; WM_COPY returns true or false
            return SendMessage(this.WM_COPYDATA, A_ScriptHwnd, cds.Ptr,, "ahk_id " TargetHWND,,,,Timeout)
        } catch any as e {
            ; catch TargetError, TimeoutError, OSError
            return false
        } finally {
            DetectHiddenWindows oldDHW
            SetTitleMatchMode oldSMM
        }
    }

    /**
     * Sets up the script to listen for incoming messsages.
     * @param Callback Function to call when a message arrives. 
     */
    Listen(Callback) {

            ; CRITICAL: Bypass UIPI (User Interface Privilege Isolation)
            ; This allows a non-admin Sender to talk to this Admin Receiver
            try {
                DllCall("User32.dll\ChangeWindowMessageFilterEx", 
                        "Ptr", A_ScriptHwnd,
                        "UInt", this.WM_COPYDATA, 
                        "UInt", this.MSGFLT_ALLOW, 
                        "Ptr", 0)
            } catch {
                MsgBox "Failed to set message filter. Sending may fail if scripts have different Privileges."
            }

        OnMessage(this.WM_COPYDATA, (wParam, lParam, msg, hwnd) => this._HandleIncoming(wParam, lParam, Callback))
    }

    _HandleIncoming(wParam, lParam, UserCallback) {
        if (lParam == 0)
            return false
        
        ; Extract data from the pointer provided by Windows
        SenderKey   := NumGet(lParam, 0, "UPtr")
        DataSize    := NumGet(lParam, A_PtrSize, "UInt")
        pData       := NumGet(lParam, A_PtrSize * 2, "Ptr")
        
        ; If Passkey mismatch return false
        if (SenderKey != this.PassKey)
            return false

        if (pData != 0) {
            StringData := StrGet(pData)
            UserCallback(StringData, wParam)
            return true ; Acknowledge success
        }
        return false
    }

}
