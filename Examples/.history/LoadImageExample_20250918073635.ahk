#Requires AutoHotkey v2.0

; Directives, keywords
#SingleInstance Force
#NoTrayIcon

; --- Start of Version Info Block ---
;@Ahk2Exe-Set ProductName, Gui Example
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-Set LegalCopyright, © 2025 jasc2v8
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Gui Example
;@Ahk2Exe-Set OriginalFilename, GuiExample.exe
; --- End of Version Info Block ---

MySpaces := StrRepeat(" ", 64)
MyFiller := "[" . MySpaces . "]"    ; brackets are just for debugging

global MyCount
MyCount := 0

; Create a new Gui object
MyGui := Gui(, "AHK2 Gui Example") ; "ToolWindow" does not have tray icon
;MyGui.Title := "New Title"
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S12 CBlack w480", "Segouie UI")

; Add a Text control to the GUI
MyGui.Add("Text", "xm ym", MyFiller) ; dummy text control to set gui width
global myTextControl := MyGui.Add("Text", "xm+10 yp", "Hello, AutoHotkey v2!")

; Add a Button control to the GUI
MyButton := MyGui.Add("Button", "w64", "OK")  ; "x+5 y+5"
;~ MyButtonOpt1 := MyGui.Add("Button", "x+m yp W64 Default", "Opt1")
;~ MyButtonOpt2 := MyGui.Add("Button", "x+m yp W64 Default", "Opt2")
;~ MyButtonOpt3 := MyGui.Add("Button", "x+m yp W64 Default", "Opt3")
MyButtonCancel := MyGui.Add("Button", "x+m yp W64 Default", "Cancel")

; Assign a function to be called when the button is clicked
MyButton.OnEvent("Click", ButtonClicked)
MyButtonCancel.OnEvent("Click", ButtonCancelClicked)

; Show the GUI
MyGui.Show()

SetTimer CountTimer, 1000
; Function to be executed when the button is clicked
ButtonClicked(Ctrl, Info) {
 MsgBox("Button clicked!", "My Title")
}

ButtonCancelClicked(Ctrl, Info) {
 ExitApp()
}

; This function is called when the window is closed
MyGui.OnEvent("Close", (*) => ExitApp())

StrRepeat(text, times) {
 return StrReplace(Format("{:" times "}", ""), " ", text)
}

CountTimer()
{
 global
 MyCount += 1

 ;MsgBox("Count = " . Mycount, "My Title")

myTextControl.Value := MyCount

   if (MyCount < 10)
    return

   ; Otherwise:
   SetTimer , 0  ; i.e. the timer turns itself off here.

   myTextControl.Value := "Timeout!"
}