#Requires AutoHotkey v2

; USER — Event-Driven Client

class UserBridge {
    static PIPE := "\\.\pipe\Global\AdminBridge"

    __New() {
        this.events := Map()
        this.Connect()
    }

    Connect() {
        while !this.hPipe := DllCall(
            "CreateFileW",
            "Str", UserBridge.PIPE,
            "UInt", 0xC0000000,
            "UInt", 0,
            "Ptr", 0,
            "UInt", 3,
            "UInt", 0,
            "Ptr", 0,
            "Ptr"
        )
            Sleep 250

        this.Listen()
    }

    On(event, fn) {
        this.events[event] := fn
    }

    Call(cmd, payload := "") {
        this.Send("CALL|" cmd "|" payload)
    }

    Send(msg) {
        buf := Buffer(StrLen(msg) * 2 + 2, 0)
        StrPut(msg, buf, "UTF-16")
        DllCall("WriteFile", "Ptr", this.hPipe, "Ptr", buf, "UInt", buf.Size, "UInt*", 0, "Ptr", 0)
    }

    Listen() {
        SetTimer(this.Read.Bind(this), 10)
    }

    Read() {
        buf := Buffer(4096, 0)
        if !DllCall("ReadFile", "Ptr", this.hPipe, "Ptr", buf, "UInt", buf.Size, "UInt*", &bytes := 0, "Ptr", 0)
            return

        msg := StrGet(buf, bytes / 2, "UTF-16")
        parts := StrSplit(msg, "|", , 3)

        if parts[1] = "EVENT" {
            if this.events.Has(parts[2])
                this.events[parts[2]](parts[3])
        }
        else if parts[1] = "REPLY" {
            MsgBox "Reply from admin:`n" parts[3]
        }
    }
}

; ===== Example Usage =====

MsgBox 

bridge := UserBridge()

bridge.On("Heartbeat", t => ToolTip("Admin heartbeat: " t))
bridge.Call("GetAdminPID")

Sleep -1
