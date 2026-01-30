; Gemini

#Requires AutoHotkey v2.0

Esc::ExitApp

#Requires AutoHotkey v2.0

; Global variables separated on two lines as requested
global IL_Large := 0
global IL_Small := 0

; Create the GUI
MediaGui := Gui("+AlwaysOnTop", "Standard Media Controls")
MediaGui.SetFont("s18", "Segoe UI") ; Standard font at a readable size

; --- Media Button Row ---
; Play (▶), Pause (⏸), Stop (⏹), Record (⏺)
BtnPrev  := MediaGui.Add("Button", "w50 h50", "⏮")
BtnPlay  := MediaGui.Add("Button", "x+5 w50 h50", "▶")
BtnPause := MediaGui.Add("Button", "x+5 w50 h50", "⏸")
BtnStop  := MediaGui.Add("Button", "x+5 w50 h50", "⏹")
BtnNext  := MediaGui.Add("Button", "x+5 w50 h50", "⏭")

; --- Volume Row ---
MediaGui.SetFont("s14") ; Slightly smaller for the secondary row
BtnMute  := MediaGui.Add("Button", "xm w75 h40", "🔇")
BtnDown  := MediaGui.Add("Button", "x+5 w95 h40", "🔉 Down")
BtnUp    := MediaGui.Add("Button", "x+5 w95 h40", "🔊 Up")

; --- Event Handling ---
BtnPlay.OnEvent("Click", (*) => Send("{Media_Play_Pause}"))
BtnPause.OnEvent("Click", (*) => Send("{Media_Play_Pause}"))
BtnStop.OnEvent("Click", (*) => Send("{Media_Stop}"))
BtnPrev.OnEvent("Click", (*) => Send("{Media_Prev}"))
BtnNext.OnEvent("Click", (*) => Send("{Media_Next}"))
BtnMute.OnEvent("Click", (*) => Send("{Volume_Mute}"))
BtnDown.OnEvent("Click", (*) => Send("{Volume_Down}"))
BtnUp.OnEvent("Click", (*) => Send("{Volume_Up}"))

MediaGui.Show()
