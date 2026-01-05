; TITLE  :  Messenager v0.0
; SOURCE :  Gemini and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

class Messenger {

    static WM_COPYDATA := 0x4A
    static MSGFLT_ALLOW := 1
    
    /**
     * Sends a string to another window/script.
     * @param TargetHWND The HWND of the receiving window.
     * @param DataString The text you want to send.
     * @param TypeCode Optional integer to categorize the message.
     */
    static Send(TargetHWND, DataString, TypeCode := 0, Timeout:=0) {
        if !WinExist(TargetHWND)
            throw Error("Target window does not exist.", -1)

        ; Calculate size: (Chars + null terminator) * 2 bytes for UTF-16
        SizeInBytes := (StrLen(DataString) + 1) * 2
        
        ; Create COPYDATASTRUCT: [dwData, cbData, lpData]
        cds := Buffer(A_PtrSize * 3, 0)
        NumPut("UPtr", TypeCode, cds, 0)
        NumPut("UInt", SizeInBytes, cds, A_PtrSize)
        NumPut("UPtr", StrPtr(DataString), cds, A_PtrSize * 2)

        try {
            ; SendMessage waits for the receiver to process the data
            ; WM_COPY returns true or false
            return SendMessage(this.WM_COPYDATA, A_ScriptHwnd, cds.Ptr,, "ahk_id " TargetHWND,,,,Timeout)
        } catch any as e {
            ; catch TargetError, TimeoutError, OSError
            return false
        }
    }

    /**
     * Sets up the script to listen for incoming strings.
     * @param Callback Function to call when a message arrives. 
     * Expects: MyFunc(StringData, TypeCode, SenderHWND)
     */
    static Listen(Callback) {

            ; CRITICAL: Bypass UIPI (User Interface Privilege Isolation)
            ; This allows a non-admin Sender to talk to this Admin Receiver
            try {
                DllCall("User32.dll\ChangeWindowMessageFilterEx", 
                        "Ptr", A_ScriptHwnd, ; MyGui.Hwnd, 
                        "UInt", this.WM_COPYDATA, 
                        "UInt", this.MSGFLT_ALLOW, 
                        "Ptr", 0)
            } catch {
                MsgBox "Failed to set message filter. Sending may fail if scripts have different integrity levels."
            }

        OnMessage(this.WM_COPYDATA, (wParam, lParam, msg, hwnd) => this._HandleIncoming(wParam, lParam, Callback))
    }

    static _HandleIncoming(wParam, lParam, UserCallback) {
        if (lParam == 0)
            return false
        
        ; Extract data from the pointer provided by Windows
        TypeCode := NumGet(lParam, 0, "UPtr")
        DataSize := NumGet(lParam, A_PtrSize, "UInt")
        pData    := NumGet(lParam, A_PtrSize * 2, "Ptr")
        
        if (pData != 0) {
            StringData := StrGet(pData)
            UserCallback(StringData, TypeCode, wParam)
            return true ; Acknowledge success
        }
        return false
    }
}
