; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

;#Include IPCConstants.ahk ?

WM_COPYDATA := 0x004A

class COPYDATASTRUCT {
    dwData := 0
    cbData := 0
    lpData := 0
}

class IPCServer {
    hwnd := 0
    _callback := 0

    static TITLE := "AHK_IPC_SERVER"

    __New(callback) {

        if Type(callback) != "Func"
            throw Error("IPCServer requires a callback function")

        this._callback := callback
        this._CreateWindow()
        OnMessage(WM_COPYDATA, this._OnCopyData.Bind(this))
    }

    _CreateWindow() {
        ;grui := Gui("+ToolWindow -Caption +AlwaysOnTop")
        grui := Gui("+ToolWindow -Caption", IPCServer.TITLE)
        ;grui.Show("Hide")
        grui.Show("w200 h100")
        this.hwnd := grui.Hwnd
    }

    _OnCopyData(wParam, lParam, msg, hwnd) {

        text := StrGet(NumGet(lParam, A_PtrSize * 2, "Ptr"))

    ;ok MsgBox("Received: " text)

        reply := this._callback(text) ;, wParam)

        if (reply != "")
            this._SendReply(wParam, reply)

        return true
    }

    _SendReply(targetHwnd, text) {
        size := (StrLen(text) + 1) * 2
        cds := Buffer(A_PtrSize * 3, 0)
        NumPut("Ptr", 0, "Ptr", size, "Ptr", StrPtr(text), cds)
        SendMessage(0x004A, this.hwnd, cds, , "ahk_id " targetHwnd)

    }
}
