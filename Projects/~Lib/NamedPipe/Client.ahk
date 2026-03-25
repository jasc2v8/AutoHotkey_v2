#Include NamedPipe.ahk

MyGui := Gui("+AlwaysOnTop", "Client-Sender")
EditInput := MyGui.Add("Edit", "w300", "Responsive Test")
SendBtn := MyGui.Add("Button", "Default", "Send")
StatusText := MyGui.Add("Text", "w300", "Status: Ready")

MyGui.OnEvent("Close", (*) => ExitApp())
SendBtn.OnEvent("Click", (*) => SendAndReceive())
MyGui.Show()

SendAndReceive() {

    StatusText.Value := "Status: Connecting..."

    ipc := NamedPipe()

    StatusText.Value := "Status: Sending..."

    ipc.Send(EditInput.Value)

    response := ipc.Receive()

    StatusText.Value := "Server: " response
}