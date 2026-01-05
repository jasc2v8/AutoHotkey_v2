#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

#Include ConsoleWindow.ahk

TraySetIcon("shell32.dll", 16) ; blue screen terminal

; This can created before or after Gui is created.
Console := ConsoleWindowIcon("My Console Window", "Ready.", 400, 200, 10, 10)
Console.hWnd := WinExist('A')

MyGui := Gui(, "Example")
buttonReload := MyGui.AddButton("w64", "Reload")
buttonWrite := MyGui.AddButton("x+m yp W64 ", "Write")
buttonCancel := MyGui.AddButton("x+m yp W64 Default", "Cancel")
buttonReload.OnEvent("Click", ButtonReload_Click)
buttonWrite.OnEvent("Click", buttonWrite_Click)
buttonCancel.OnEvent("Click", ButtonCancel_Click)
MyGui.OnEvent("Close", OnGui_Close)
MyGui.Show()

; Redirect stdout to the new console window
Console.WriteLine("MyGui.Hwnd : " MyGui.Hwnd)
Console.WriteLine("hWndConsole: " Console.hWnd)

WinWaitClose(MyGui.hWnd)

; #region Functions

ButtonReload_Click(Ctrl, Info) {
    Reload()
}

buttonWrite_Click(*) {
    Console.WriteLine("The rain in Spain falls mainly on the plain.")
}
ButtonCancel_Click(Ctrl, Info) {
    OnGui_Close()
}

OnGui_Close(*) {
    DllCall("FreeConsole")
    ExitApp()
}
