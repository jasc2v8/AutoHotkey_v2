;ABOUT: BittonAlignLeft, center, rigth WORKS!

;SOURCE: V1 https://www.autohotkey.com/boards/viewtopic.php?f=6&t=9043

; A_DefaultGui warning post above by pnewmatic

/**
 * TODO:
 * 
 */

#Requires AutoHotkey v2.0+
#SingleInstance Force

TestButtons:="Default &OK, &Abort, &Retry, &Ignore, &Yes, &No, &Cancel"
TestButtons:="Default &OK, &Abort, &Cancel, AlignLeft"

longMessage := unset
Loop 30
    ;longMessage .= Format("{:02}", A_Index) ": The quick brown fox jumps over the lazy dog's back. The quick brown fox jumps over the lazy dog's back.`n"
    longMessage .= Format("{:02}", A_Index) ": The quick brown fox jumps over the lazy dog's back. The.`n"
MsgBoxEx(longMessage, "TEST", TestButtons)

;show defaults
r := MsgBoxEx()
;if (r = "&Cancel")   MsgBoxEx("r: " r)
(r = "&Cancel") ? ExitApp() : nop:=true
; MsgBox()

;show side-by-side comparison
Title := "Gui or MsgBox?"
Text  := "One of these windows is a Gui.`nThe other one is a MsgBox.`n`nCan you tell the difference?"

;MsgBoxEx(Text, Title)
; WinGetPos(&X, &Y, &W, &H, Title)
; WinMove(X -= W*1.05, Y+30,,,Title)   ; Move the MsgBoxGui to the left of the center of the window

; MsgBox Text, Title


MsgBoxEx(Text:="Press OK to continue.", Title:=A_ScriptName, Buttons:="&Yes, No, Cancel, AlignCenter") { ; "&OK, Cancel"
   ;static WhiteBox,TextBox
   global MyGui := unset
   global buttonPressed := ''

  	buttonArray := StrSplit(Buttons, ",", "`t")
   buttonCount := buttonArray.Length
   
   FontName     := "Segoe UI"    ; Name of font for text in Gui
   FontSize     := 9             ; Gui font size
   Gap          := 17 ; 26            ; Spacing above and below text in top area of the Gui
   LeftMargin   := 12            ; Left Gui margin
   RightMargin  := 8             ; Space between right side of button and right Gui edge
   ButtonWidth  := 75 ; 88            ; Width of OK button
   ButtonHeight := 23 ; 26            ; Height of OK button
   ButtonOffset := 30            ; Offset between the right side of text and right edge of button
   ButtonMargin := 4 ; 8
   ;MinGuiWidth  := 138 + (ButtonWidth*buttonCount-138+LeftMargin)           ; Minimum width of Gui
   MinGuiWidth  := LeftMargin + (ButtonWidth + ButtonMargin) * buttonCount    ; Minimum width of Gui
   SS_WHITERECT := 0x0006        ; Gui option for white rectangle (http://ahkscript.org/boards/viewtopic.php?p=20053#p20053)

   BottomGap := LeftMargin                          ; Set the distance between the bottom of the white box and the top of the OK button
   ;BottomHeight := ButtonHeight+2*LeftMargin+3-4      ; Calculate the height of the bottom section of the Gui
   BottomHeight := ButtonHeight*2      ; Calculate the height of the bottom section of the Gui
   MyGui := Gui()
   MyGui.SetFont("s" FontSize, FontName)
   MyGui.Opt("+ToolWindow -MinimizeBox -MaximizeBox")       ; Set the MyGui so it doesn't have the icon, the minimize button, and the maximize button
   MyWhiteBox := MyGui.AddText("x0 y0 " SS_WHITERECT " vWhiteBox")   ; Add a white box at the top of the window

   if Text                                                                   ; If the text field is not blank ...
   {  ; Add the text to the Gui
      MyText := MyGui.AddText(" x" LeftMargin " y" Gap " BackgroundTrans vTextBox Border", Text)   ; Add the text to the Gui

      ; Get the position of the text box
      ControlGetPos &SizeX, &SizeY, &SizeW, &SizeH, MyText.Hwnd

      ; Calculate the height of the white box
      WhiteBoxHeight := SizeY + SizeH + 0 ; Gap

      ; Calculate the space required for the text and buttons
      TextSpace   := LeftMargin+SizeW+RightMargin
      ButtonSpace := LeftMargin + (buttonCount * (ButtonWidth + ButtonMargin)) + RightMargin
      LargerWidth := TextSpace > ButtonSpace ? TextSpace : ButtonSpace

;MsgBox("TextSpace: " TextSpace " ButtonSpace: " ButtonSpace " LargerWidth: " LargerWidth)

      ; Calculate the Gui width
      GuiWidth := LargerWidth + RightMargin
      
      ; Make sure that it's not smaller than MinGuiWidth
      GuiWidth := GuiWidth < MinGuiWidth ? MinGuiWidth : GuiWidth
   }
   else                                                                       ; If the text field is blank ...
   {  GuiWidth := MinGuiWidth                                                 ; Set the width of the Gui to MinGuiWidth
      WhiteBoxHeight := 2*Gap+1                                               ; Set the height of the white box
      BottomGap++                                                             ; Increase the gap above the button by one
      BottomHeight--                                                          ; Decrease the height of the bottom section of the Gui
   }

   ; Adjust the width and height of the white box
    ControlMove(, , GuiWidth, WhiteBoxHeight, MyWhiteBox.Hwnd)
   
   ; Calculate the vertical position of the button
   ButtonY := WhiteBoxHeight+BottomGap

   ; Calculate the horizontal alignment of the buttons
   ButtonSpace := (buttonWidth * buttonCount) + (ButtonMargin * buttonCount - 1)
   ButtonAlignLeft := LeftMargin
   ButtonAlignCenter := (GuiWidth / 2) - (ButtonSpace / 2)
   ButtonAlignRight := GuiWidth - ButtonSpace

   ; Manually select the desir3ed alignment of the buttons - will become "AlignLeft, AlignCenter, AlignRight"
   ;ButtonX := ButtonAlignLeft
   ButtonX := ButtonAlignCenter
   ;ButtonX := ButtonAlignRight

   ;========= add buttons
	Loop buttonArray.Length { ;for item in buttonArray {

      index :=A_Index

      buttonText := Trim(buttonArray[index])

      ; Preset options
		opt := "x" ButtonX " y" ButtonY " w" ButtonWidth " h" ButtonHeight

;MsgBox "buttonText: " buttonText ", X:" ButtonX " Index: " buttonArray.Length - (1 * A_Index-1)

      ; If Default then add to the options
		if InStr(buttonText, "Default") OR (buttonArray.Length = 1) {
			buttonText := StrReplace(buttonText, "Default", "")
			buttonText := Trim(buttonText)
			opt := opt . " " . "Default"
		}

      ; Add the button with a common click handler
		MyGui.AddButton(opt, buttonText).OnEvent("Click", Button_Click)

      ;Calculate the horizontal position of the next button
      ButtonX += (ButtonMargin + ButtonWidth) 

	}

   ; #Region Gui.Show()

   MyGui.Title := Title
   GuiHeight := WhiteBoxHeight+BottomHeight                    ; Calculate the overall height of the Gui

   MyGui.OnEvent("Close",Gui_Escape)
   MyGui.OnEvent("Escape",Gui_Escape)

   ; Show the Gui
   MyGui.Show("w" GuiWidth " h" GuiHeight) 

   ; Remove the ToolWindow option so that the Gui has rounded corners and no icon
   ; Trick from http://ahkscript.org/boards/viewtopic.php?p=11519#p11519
   MyGui.Opt("-ToolWindow")

   ; Wait or a button press or window close
  	WinWaitClose(MyGui)
   ; Destroy the gui
	MyGui.Destroy()
   ; Return the text of the button pressed
	return buttonPressed

   ; #Region Handlers

	Button_Click(GuiCtrlObj, Info) {
      global MyGui
		buttonPressed := GuiCtrlObj.Text
		PostMessage(WM_CLOSE:=0x10, 0, 0, MyGui.Hwnd)
		;Send('!{F4}') ; close the gui, destroy, return buttonPressed
	}

   ButtonOK(*){
    MyGui.Destroy()
    ;return "OK"
   }
   Gui_Close(*){
    MyGui.Destroy()
   }
   Gui_Escape(*) {
    MyGui.Destroy()
   }
   ;Return
}
