#Include NamedPipe.ahk
;#Include <RunAsAdmin>

MyGui := Gui("+AlwaysOnTop", "Server-Receiver")
EditLog := MyGui.Add("Edit", "r10 w400 ReadOnly")
StartBtn := MyGui.Add("Button", "Default", "Start")
;Status := MyGui.Add("StatusBar")
StatusText := MyGui.Add("Text", "w300", "Status: Ready")
StartBtn.OnEvent("Click", (*) => Start())
MyGui.Show()
Start()

Start() {
    StatusText.Value := "Listening..."

    ipc := NamedPipe()

    msg := ipc.Receive()

    if (msg != "") {

        EditLog.Value .= "Recv: " msg "`r`n"

        ipc.Send("ACK: Received " StrLen(msg) " characters.")

        SendMessage(0x0115, 7, 0, EditLog.Hwnd, "ahk_id " MyGui.Hwnd)
    }

    StatusText.Value := "Idle."
}
