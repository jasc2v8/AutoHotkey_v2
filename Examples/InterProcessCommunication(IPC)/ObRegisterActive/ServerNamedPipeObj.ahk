#Requires AutoHotkey v2
;#Requires Admin
#Include <RunAsAdmin>

class AdminBridge {
    static PIPE := "\\.\pipe\Global\AdminBridge"

    __New() {
        this.handlers := Map()
        this.Start()
    }

    Start() {
        this.hPipe := DllCall(
            "CreateNamedPipeW",
            "Str", AdminBridge.PIPE,
            "UInt", 0x00000003, ; PIPE_ACCESS_DUPLEX
            "UInt", 0x00000004 | 0x00000002, ; MESSAGE | WAIT
            "UInt", 1,
            "UInt", 4096,
            "UInt", 4096,
            "UInt", 0,
            "Ptr", 0,
            "Ptr"
        )

        if this.hPipe = -1
            throw Error("Failed to create pipe")

        DllCall("ConnectNamedPipe", "Ptr", this.hPipe, "Ptr", 0)
        this.Listen()
    }

    On(event, fn) {
        this.handlers[event] := fn
    }

    Emit(event, payload := "") {
        this.Send("EVENT|" event "|" payload)
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

        if parts[1] = "CALL" {
            cmd := parts[2]
            payload := parts[3]

            if this.handlers.Has(cmd) {
                result := this.handlers[cmd](payload)
                this.Send("REPLY|" cmd "|" result)
            }
        }
    }
}

; ===== Example Usage =====

MsgBox

bridge := AdminBridge()

bridge.On("GetAdminPID", (*) => DllCall("GetCurrentProcessId"))
bridge.On("DeleteFile", path => (FileDelete(path), "OK"))

SetTimer(() => bridge.Emit("Heartbeat", A_TickCount), 1000)

MsgBox "Admin bridge running"
Sleep -1
