; TITLE:    Messenger v1.0
; SOURCE:   Gemini, Copilot, chageGPT, and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

class Messenger {

    WM_COPYDATA  := 0x4A
    MSGFLT_ALLOW := 1
    Handler      := 0
    GUI_HWND     := 0
    PID          := 0
    ServerName   := ""
    ServerKey    := 0

    __New(ServerName, ServerKey, Callback) {

        this.ServerName := ServerName

        this.Listen(ServerName, ServerKey, Callback)
    }

    GetHwnd() {
        return WinExist(this.ServerName)
    }

    /**
     * Prepares a script to act as a Server.
     * @param Role          "Server" or "Client". Server owns the Gui.
     * @param ServerName    A string to identify this server (e.g. "MyService")
     * @param Callback      Function to call when data is received: (text, senderHwnd)
     */
     Listen(ServerName, ServerKey, Callback) {

        ;if (Role="Server") {

            ; Create the hidden window to receive messages
            MyGui := Gui()
            MyGui.Show("Hide")
            ;MyGui.Show("w300 h150")
            ; Because this script owns the Gui, we need to set the unique title so clients can find us
            WinSetTitle(ServerName, A_ScriptHwnd)
            this.GUI_HWND := MyGui.Hwnd
            this.PID:= WinGetPID(this.ServerName)

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
       ; }
        
        this.ServerKey := ServerKey

        this.Handler := Callback

        OnMessage(this.WM_COPYDATA, this._OnReceive.Bind(this))

        ; if Client then just return the hWnd of the server
        ;if (Role = "Client")
            return WinExist(this.ServerName)
    }

    /**
     * Sends data to a target window.
     * @param Target - HWND or ServerName string
     * @param Text - Data to send
     * @param Timeout - How long to wait for the other side to process (ms)
     */
     Send(Target, Text, Timeout := 1000) {

        DetectHiddenWindows true

        targetHwnd := (Target is Number) ? Target : WinExist(Target)

        if !targetHwnd
            return false

        ; Prepare Buffer
        cbData := (StrLen(Text) + 1) * 2
        cds := Buffer(A_PtrSize * 3, 0)
        NumPut("Ptr", this.ServerKey, cds, 0)
        NumPut("UInt", cbData, cds, A_PtrSize)
        NumPut("Ptr", StrPtr(Text), cds, A_PtrSize * 2)
        
        Timeout:=0 ; indefinate

        try {
            Response := SendMessage(this.WM_COPYDATA, A_ScriptHwnd, cds.Ptr, , "ahk_id " targetHwnd,,,, Timeout)
        }
            catch any as e {
                Response:= e.Message
        }
        return Response
    }

     _OnReceive(wParam, lParam, msg, hwnd) {

        ; Check the Key stored in dwData (first member of the struct)
        IncomingKey := NumGet(lParam, 0, "Ptr")
    
        if (IncomingKey != this.ServerKey) {
            return 0 ; Reject Potential unauthorized attempt
        }

        lpData := NumGet(lParam, A_PtrSize * 2, "Ptr")
        
        receivedText := StrGet(lpData)
        
        ; Check if it's a standard exit command
        if (receivedText == "IPC_EXIT") {
            MsgBox "IPCBridge Exit..."
            ExitApp()
        }
            
        this.Handler.Call(receivedText, wParam)
        
    }

    __Destroy() {

        if ProcessExist(this.PID)
            ProcessClose(this.PID)
    }
}
