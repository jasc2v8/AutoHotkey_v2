; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

;#Include IPCConstants.ahk ?

WM_COPYDATA := 0x004A

class COPYDATASTRUCT {
    dwData := 0
    cbData := 0
    lpData := 0
}

class IPCClient {
    serverHwnd := 0

    __New() {
        ;this.serverHwnd := serverHwnd

        this.serverHwnd := WinExist("AHK_IPC_SERVER")

        if !this.serverHwnd
            throw Error("IPC server window not found")
    }

    Send(text, &reply := "") {
        buf := Buffer((StrLen(text) + 1) * 2)
        StrPut(text, buf, "UTF-16")

        cds := Buffer(A_PtrSize * 3)
        NumPut("ptr", 1, cds, 0)
        NumPut("uint", buf.Size, cds, A_PtrSize)
        NumPut("ptr", buf.Ptr, cds, A_PtrSize * 2)

        result := SendMessage(
            WM_COPYDATA,
            A_ScriptHwnd,
            cds.Ptr,
            ,
            "ahk_id " this.serverHwnd
        )

        reply := result
        return result
    }
}
