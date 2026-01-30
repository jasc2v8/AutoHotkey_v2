#Requires AutoHotkey v2.0
#include Anchor.ahk  ; older v2 style, no `new`

; -----------------------------
; First GUI
; -----------------------------
grui1 := Gui("+Resize +MinSize700x450")
grui1.Text := "Anchor - Fluid Layout Test"

anchor1 := Anchor(grui1)  ; old v2 style

; ===== Left navigation =====
grpLeft1 := grui1.AddGroupBox("x10 y10 w200 h250", "Navigation")
lstNav1  := grui1.AddListBox("x20 y30 w180 h230", ["Item 1","Item 2","Item 3","Item 4"])

; ===== Toolbar (below navigation) =====
grpTop1 := grui1.AddGroupBox("x10 y270 w200 h60", "Toolbar")
btnNew1  := grui1.AddButton("x20  y285 w80 h30", "New")
btnOpen1 := grui1.AddButton("x110 y285 w80 h30", "Open")
btnSave1 := grui1.AddButton("x20 y320 w80 h30", "Save")
btnExit1 := grui1.AddButton("x110 y320 w80 h30", "Exit")

; ===== Status bar at bottom =====
grpStatus1 := grui1.AddGroupBox("x10 y370 w670 h30", "Status")
txtStatus1 := grui1.AddText("x20 y385 w650 h20", "Ready")

; ===== Main editor =====
grpMain1 := grui1.AddGroupBox("x220 y10 w460 h350", "Editor")
editMain1 := grui1.AddEdit("x230 y30 w440 h320", "Resize the window aggressively...")

; ===== Anchors =====

; Navigation & Toolbar: fixed width, grow vertically with window
;anchor1.Add(grpLeft1, "y")
;anchor1.Add(lstNav1, "y")
anchor1.Add(grpTop1, "y")
anchor1.Add(btnNew1, "y")
anchor1.Add(btnOpen1, "y")
anchor1.Add(btnSave1, "y")
anchor1.Add(btnExit1, "y")

; Main editor: fluid width + height
anchor1.Add(grpMain1, "w h")
anchor1.Add(editMain1, "w h")

; Status bar: full width, fixed height
anchor1.Add(grpStatus1, "w y")
anchor1.Add(txtStatus1, "w y")

; Exit button
btnExit1.OnEvent("Click", (*) => grui1.Destroy())

grui1.Show("w700 h450")

; -----------------------------
; Second GUI
; -----------------------------
grui2 := Gui("+Resize +MinSize500x350")
grui2.Text := "Anchor - Fluid Test 2"

anchor2 := Anchor(grui2)  ; old v2 style

edit2 := grui2.AddEdit("x10 y10 w480 h290", "Second window edit control")
btnClose2 := grui2.AddButton("x400 y310 w80 h30", "Close")

anchor2.Add(edit2, "w h")
anchor2.Add(btnClose2, "x y")

btnClose2.OnEvent("Click", (*) => grui2.Destroy())

grui2.Show("w500 h350")
