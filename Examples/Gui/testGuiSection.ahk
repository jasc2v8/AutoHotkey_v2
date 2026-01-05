
#Requires Autohotkey v2
#SingleInstance Force

;AutoGUI 2.5.8 creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;Easy_AutoGUI_for_AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2

g := Gui()
g.AddText(,"Selected:")     ; by default, the first control begins the first section
g.AddEdit("ys w500")    ; Add an edit to the right of the text.
g.AddButton("ys", "Select")
g.AddButton("ys", "Explore")
g.AddText("xm w500 h100 Border Section","test")
g.AddButton("xm", "OK")
g.AddButton("yp", "Cancel")
g.AddButton("ys", "Clear")

; MyGui.Add("Text", "Section", "First Name:")  ; Save this control's position and start a new section.
; MyGui.Add("Text",, "Last Name:")
; MyGui.Add("Edit", "ys")  ; Start a new column within this section.
; MyGui.Add("Edit")
; MyGui.AddButton("ys", "OK")  ; Start a new column within this section.
; MyGui.AddButton(,"Edit")

; MyGui.Add("Text", "xm Section", "Address:")  ; Save this control's position and start a new section.
; MyGui.Add("Text",, "City:")
; MyGui.Add("Edit", "ys")  ; Start a new column within this section.
; MyGui.Add("Edit")
; MyGui.AddButton("ys", "OK")  ; Start a new column within this section.
; MyGui.AddButton(,"Edit")

g.Show()


; myGui := Gui()
; Edit1 := myGui.AddEdit("x24 y24 w409 h21")
; ;ogcButtonOK := myGui.AddButton("x476 y23 w80 h23", "&OK")
; ogcButtonOK := myGui.AddButton("w80 h23", "&OK")
; ogcButtonCancel := myGui.AddButton("Section ys w80 h23", "&Cancel")
; Edit1.OnEvent("Change", OnEventHandler)
; ogcButtonOK.OnEvent("Click", OnEventHandler)
; myGui.OnEvent('Close', (*) => ExitApp())
; myGui.Title := "Window"
; myGui.Show("w620 h420")

; OnEventHandler(*)
; {
; 	ToolTip("Click! This is a sample action.`n"
; 	. "Active GUI element values include:`n"  
; 	. "Edit1 => " Edit1.Value "`n" 
; 	. "ogcButtonOK => " ogcButtonOK.Text "`n", 77, 277)
; 	SetTimer () => ToolTip(), -3000 ; tooltip timer
; }
