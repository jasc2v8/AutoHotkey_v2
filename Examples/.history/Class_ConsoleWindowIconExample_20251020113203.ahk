#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#Include <Class_ConsoleWindowIcon>
#Include <ChangeWindowIcon>

MyGui := Gui(, "Change Icon")

buttonReload := MyGui.AddButton("w64", "Reload")
buttonWrite := MyGui.AddButton("x+m yp W64 ", "Write")
buttonCancel := MyGui.AddButton("x+m yp W64 Default", "Cancel")

buttonReload.OnEvent("Click", ButtonReload_Click)
buttonWrite.OnEvent("Click", buttonWrite_Click)
buttonCancel.OnEvent("Click", ButtonCancel_Click)

MyGui.OnEvent("Close", OnGui_Close)

; Show the GUI
MyGui.Show()

Console := ConsoleWindowIcon("My Console Window", , 400, 200, 10, 10)

Console.hWnd := WinExist('A')

; Redirect stdout to the new console window
Console.WriteLine("MyGui.Hwnd : " MyGui.Hwnd)
Console.WriteLine("hWndConsole: " Console.hWnd)

;r := ChangeWindowIcon("D:\Software\DEV\Work\AHK2\Icons\under-construction.ico", , "ahk_id" MyGui.Hwnd)
;Console.WriteLine("Result Gui Under Construction: " r)

icoFile := "C:\Windows\SystemApps\MicrosoftWindows.Client.Core_cw5n1h2txyewy\StartMenu\Assets\UnplatedFolder\UnplatedFolder.ico"

;r :=ChangeWindowIcon(icoFile, , "ahk_id" MyGui.hWnd)
r := ChangeWindowIcon("C:\Windows\System32\shell32.dll", "Icon16","ahk_id" MyGui.hWnd) 
Console.WriteLine("Result Gui: " r)

;r := ChangeWindowIcon(icoFile, "Icon1" ,"ahk_id" Console.hWnd) 
r := ChangeWindowIcon("C:\Windows\System32\shell32.dll", "Icon16","ahk_id" Console.hWnd) 
Console.WriteLine("Result Console: " r)

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
    ;MsgBox('OnGui_Close')
    DllCall("FreeConsole")
    ExitApp()
}
