; TITLE  :  MyScript v1.0.0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2+
#SingleInstance Force
#NoTrayIcon

#Include <Subprocess>

Gui, New,, Parent Process
Gui, Font, s9, Lucida Console
Gui, Font,, Consolas
Gui, Margin, 0, 0

global hEdit
Gui, Add, Edit, w600 r20 -Wrap HScroll ReadOnly HwndhEdit
Gui, Show
GuiEscape(hGui)
{
	ExitApp
}
GuiClose(hGui)
{
	ExitApp
}

script := Format("
(Join`r`n
stdout := FileOpen({1}*{1}, 1|4)
Loop {
	InputBox, input, Child Process, Type anything`, input will be sent to the parent process.``nType 'quit' to exit child process.
	
	stdout.WriteLine(input)
	stdout.Read(0) `; flush

	if (input = {1}quit{1})
		break
	
	Sleep, 150
}
stdout.Close(), stdout := {1}{1}
ExitApp
)", Chr(34))

global proc
global start_time

if (proc := Subprocess_Run([A_AhkPath, "/ErrorStdOut", "*"])) {
	start_time := A_TickCount
	proc.StdIn.Write(script)
	proc.StdIn.Close()

	SetTimer, ReadStdOut, 10
	
	while (proc.Status == 0)
		Sleep, 10

	SetTimer, ReadStdOut, Off

	proc := "" ; release
}
return

ReadStdOut()
{
	if (proc) {
	; check if there's available data to read
		proc.StdOut.Peek(,,, avail)
		if (avail > 0) {
			text := RTrim(proc.StdOut.ReadLine(), "`r`n")

			if (text = "quit") {
				end_time := (A_TickCount-start_time)/1000
				Edit_Append(hEdit, Format("[Finished in {1:.2f}s]", end_time))
				SetTimer, ReadStdOut, Off
				return
			}

			text .= "`r`n"
			Edit_Append(hEdit, text)
		}
	}
}

Edit_Append(hEdit, text)
{
	text := RegExReplace(text, "\R", "`r`n")
	pText := &text
	SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ; WM_GETTEXTLENGTH
	SendMessage, 0x00B1, %ErrorLevel%, %ErrorLevel%,, ahk_id %hEdit% ; EM_SETSEL
	SendMessage, 0x00C2, 0, %pText%,, ahk_id %hEdit% ; EM_REPLACESEL
}