
;https://autohotkey.com/board/topic/61783-solved-getting-the-autosize-size-of-scripts-gui/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#NoEnv
#SingleInstance force

#Include <AutoXYWH>

BW := 60
BH := 30, BN := 380
Gui, New, Resize ; -Caption
Gui, Margin, 15, 15
Gui, Add, Edit, HwndhEdit w600 h400, DEFAULT TEXT
;Gui, Add, Edit
;Gui, Add, Listview
Gui, Add, Button,      w%BW% h%BH%, Clear
Gui, Add, Button, x+10 w%BW% h%BH%, Close
Gui, Add, Button, x+10 w%BW% h%BH%, ExitApp
Gui, Add, Button, x+10 w%Bn% h%BH%, , Resume
Gui, Show
return

AddButton:
Gui, Add, Button
Gui_GetAutoSize(width, height, 5, 5)
Msgbox, %width%x%height%
Gui, Show, Autosize

return

GuiEscape:
GuiClose:
ExitApp

/**
 * Calculates the size the default GUI would have after using 
 * "Gui, Show, Autosize". You need to pass the x/y margin of the GUI.
 *
 * WARNING: May change the Last Found Window.
 */ 
Gui_GetAutoSize(ByRef width, ByRef height, marginX, marginY) {
Gui, +Lastfound
WinGet, ctrls, ControlList
width := 0, height := 0
Loop, Parse, ctrls, `n
  { ctrl := A_LoopField
    ControlGetPos, x, y, w, h, % ctrl
    offsetX := x+w, offsetY := y+h
    width := offsetX > width ? offsetX : width
    height := offsetY > height ? offsetY : height
  } width += marginX, height += marginY
}

/*
Launched when the window is resized, minimized, maximized, or restored.
A_GuiWidth and A_GuiHeight excluding title bar, menu bar, and borders.
A_EventInfo and ErrorLevel will both contain one of the following digits:
0: The window has been restored, or resized normally such as by dragging its edges.
1: The window has been minimized.
2: The window has been maximized.
*/

GuiSize:
If (A_EventInfo != 1) ; window not minimized.
	AutoResizeAll()
Return

/*
GuiSize:
	width := A_GuiWidth
	height := A_GuiHeight
	marginX := 10
	marginY := 10
	
	;width := 0, height := 0
	
	WinGet, ctrls, ControlList
	
	Loop, Parse, ctrls, `n
	{
		ctrl := A_LoopField
		ControlGetPos, x, y, w, h, % ctrl
		offsetX := x+w, offsetY := y+h
		width := offsetX > width ? offsetX : width
		height := offsetY > height ? offsetY : height
		width += marginX, height += marginY
		GuiControl, Move, % ctrl, % " H" . (height) . " W" . (width)
	}

Return
	GuiControl, Move, % hEdit, % " H" . (H-5-60) . " W" . (W-5-25)
			
	;GuiControl, Move, % this.controls.hClearButton,		% " Y" . (GuiH-40)
	;GuiControl, Move, % this.controls.hCopyButton,		% " Y" . (GuiH-40)
	;GuiControl, Move, % this.controls.hExitAppButton,	% " Y" . (GuiH-40)
	GuiControl, Move, % HwndhClickMe,	% " Y" . (H-40)
Return
*/

;
; AutoResize
;
; Added by Jim Dreher 11/22/2020
AutoResizeAll() {
	WinGet, ActiveControlList, ControlList, A
	Loop, Parse, ActiveControlList, `n
	{
		;MsgBox % "Control=[" A_LoopField "]"
		if (SubStr(A_LoopField,1,7) = "Button4") {
			GuiControl, -Redraw, Resume
			AutoXYWH(A_LoopField, "wy")
			GuiControl, +Redraw, Resume
		} else if (SubStr(A_LoopField,1,6) = "Button") {
			AutoXYWH(A_LoopField, "y")
		} else {
			AutoXYWH(A_LoopField, "wh")	
		}
	}
}
; =================================================================================
; Function:     AutoXYWH
;   Move and resize control automatically when GUI resized.
; Parameters:
;   ctrl_list  - ControlID list separated by "|".
;                ControlID can be a control HWND, associated variable name or ClassNN.
;   Attributes - Can be one or more of x/y/w/h  followed by fractions
;   Redraw     - True to redraw controls
; Examples:
;   AutoXYWH("Btn1|Btn2", "xy")
;   AutoXYWH(hEdit      , "w0.5 h0.75")
; ---------------------------------------------------------------------------------
; Release date: 2014-6-25           http://ahkscript.org/boards/viewtopic.php?t=1079
; Author      : tmplinshi (mod by toralf)
; requires AHK version : 1.1.13.01+
; =================================================================================
AutoXYWH_OLD(ctrl_list, Attributes="wh", Redraw = False){
	static cInfo := {}
	Loop, Parse, ctrl_list, |
	{
		ctrl := A_Gui ":" A_LoopField
		If ( cInfo[ctrl].x = "" ){
			GuiControlGet, i, %A_Gui%:Pos, %A_LoopField%
			a := RegExReplace(Attributes, "i)[^xywh]")  
			fx := fy := fw := fh := 0
			Loop, Parse, a
				If !RegExMatch(Attributes, "i)" A_LoopField "\s*\K[\d.-]+", f%A_LoopField%)
					f%A_LoopField% := 1
			cInfo[ctrl] := { x:ix, fx:fx, y:iy, fy:fy, w:iw, fw:fw, h:ih, fh:fh, gw:A_GuiWidth, gh:A_GuiHeight, a:StrSplit(a) }
		}Else If ( cInfo[ctrl].a.1) {
			x := (A_GuiWidth  - cInfo[ctrl].gw) * cInfo[ctrl].fx + cInfo[ctrl].x
			y := (A_GuiHeight - cInfo[ctrl].gh) * cInfo[ctrl].fy + cInfo[ctrl].y
			w := (A_GuiWidth  - cInfo[ctrl].gw) * cInfo[ctrl].fw + cInfo[ctrl].w
			h := (A_GuiHeight - cInfo[ctrl].gh) * cInfo[ctrl].fh + cInfo[ctrl].h
			For i, a in cInfo[ctrl]["a"]
				Options .= a %a% A_Space
			GuiControl, % A_Gui ":" (Redraw ? "MoveDraw" : "Move"), % A_LoopField, % Options
		}
	}
}