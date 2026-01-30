#Requires AutoHotkey v2.0
#include Anchor.ahk  ; older v2 style, no `new`

; -----------------------------
; First GUI
; -----------------------------
grui1 := Gui("+Resize +MinSize700x450")
grui1.Text := "Anchor - Fluid Layout Test"

anchor1 := Anchor(grui1)

; ===== Navigation panel =====
grpLeft1 := grui1.AddGroupBox("x10 y10 w200 h250", "Navigation")
lstNav1  := grpLeft1.AddListBox("x10 y20 w180 h220", ["Item 1","Item 2","Item 3","Item 4"])

; ===== Toolbar panel (below navigation) =====
grpTop1 := grui1.AddGroupBox("x10 y270 w200 h100", "Toolbar")
btnNew1  := grpTop1.AddButton("x10  y15 w80 h30", "New")
btnOpen1 := grpTop1.AddButton("x110 y15 w80 h30", "Open")
btnSave1 := grpTop1.AddButton("x10 y55 w80 h30", "Save")
btnExit1 := grpTop1.AddButton("x110 y55 w80 h30", "Exit")

; ===== Status bar at bottom =====
grpStatus1 := grui1.AddGroupBox("x10 y370 w670 h30", "Status")
txtStatus1 := grpStatus1.AddText("x10 y10 w650 h20", "Ready")

; ===== Main editor =====
grpMain1 := grui1.AddGroupBox("x220 y10 w460 h350", "Editor")
editMain1 := grpMain1.AddEdit("x10 y20 w440 h320", "Resize the window aggressively...")

; ===== Anchors =====

; --- Navigation panel ---
anchor1.Add(grpLeft1, "y")  ; panel grows vertically
anchor1.Add(lstNav1, "h")    ; ListBox grows vertically inside panel

; --- Toolbar panel ---
anchor1.Add(grpTop1, "y")    ; panel grows vertically
anchor1.Add(btnNew1, "x y")  ; buttons keep position relative to panel
anchor1.Add(btnOpen1, "x y")
anchor1.Add(btnSave1, "x y")
anchor1.Add(btnExit1, "x y")

; --- Main editor ---
anchor1.Add(grpMain1, "w h")   ; panel grows width + height
anchor1.Add(editMain1, "w h")  ; Edit control grows with panel

; --- Status bar ---
anchor1.Add(grpStatus1, "w y")  ; bar stretches horizontally
anchor1.Add(txtStatus1, "w y")  ; text stretches horizontally

; Exit button
btnExit1.OnEvent("Click", (*) => grui1.Destroy())

grui1.Show("w700 h450")

; -----------------------------
; Second GUI
; -----------------------------
grui2 := Gui("+Resize +MinSize500x350")
grui2.Text := "Anchor - Fluid Test 2"

anchor2 := Anchor(grui2)

edit2 := grui2.AddEdit("x10 y10 w480 h290", "Second window edit control")
btnClose2 := grui2.AddButton("x400 y310 w80 h30", "Close")

anchor2.Add(edit2, "w h")  ; edit grows
anchor2.Add(btnClose2, "x y") ; button stays

btnClose2.OnEvent("Click", (*) => grui2.Destroy())

grui2.Show("w500 h350")
