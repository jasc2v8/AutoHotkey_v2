;SOURCE: V1 https://www.autohotkey.com/boards/viewtopic.php?f=6&t=9043

; A_DefaultGui warning post above by pnewmatic

#Requires AutoHotkey v2.0+
#SingleInstance Force

longMessage := unset
Loop 60
    longMessage .= Format("{:02}", A_Index) ": The quick brown fox jumps over the lazy dog's back. The quick brown fox jumps over the lazy dog's back.`n"
;MsgBoxEx(longMessage, "TEST")

;show defaults
MsgBoxEx()
MsgBox()

;show side-by-side comparison
Title := "Gui or MsgBox?"
Text  := "One of these windows is a Gui.`nThe other one is a MsgBox.`n`nCan you tell the difference?"

MsgBoxEx(Text, Title)
WinGetPos(&X, &Y, &W, &H, Title)
WinMove(X -= W*1.05, Y+30,,,Title)   ; Move the MsgBoxGui to the left of the center of the window

MsgBox Text, Title

MsgBoxEx(Text:="Press OK to continue.", Title:=A_ScriptName, Buttons:="OK") {
   ;static WhiteBox,TextBox
   
   FontName     := "Segoe UI"    ; Name of font for text in Gui
   FontSize     := 9             ; Gui font size
   Gap          := 17 ; 26            ; Spacing above and below text in top area of the Gui
   LeftMargin   := 12            ; Left Gui margin
   RightMargin  := 8             ; Space between right side of button and right Gui edge
   ButtonWidth  := 75 ; 88            ; Width of OK button
   ButtonHeight := 23 ; 26            ; Height of OK button
   ButtonOffset := 30            ; Offset between the right side of text and right edge of button
   MinGuiWidth  := 138           ; Minimum width of Gui
   SS_WHITERECT := 0x0006        ; Gui option for white rectangle (http://ahkscript.org/boards/viewtopic.php?p=20053#p20053)

   BottomGap := LeftMargin                          ; Set the distance between the bottom of the white box and the top of the OK button
   BottomHeight := ButtonHeight+2*LeftMargin+3-4      ; Calculate the height of the bottom section of the Gui
   MyGui := Gui()
   MyGui.SetFont("s" FontSize, FontName)
   MyGui.Opt("+ToolWindow -MinimizeBox -MaximizeBox")       ; Set the MyGui so it doesn't have the icon, the minimize button, and the maximize button
   MyWhiteBox := MyGui.AddText("x0 y0 " SS_WHITERECT " vWhiteBox")   ; Add a white box at the top of the window
   if Text                                                                    ; If the text field is not blank ...
   {  MyText := MyGui.AddText(" x" LeftMargin " y" Gap " BackgroundTrans vTextBox", Text)   ; Add the text to the Gui
      ControlGetPos &SizeX, &SizeY, &SizeW, &SizeH, MyText.Hwnd                 ; Get the position of the text box
      GuiWidth := LeftMargin+SizeW+ButtonOffset+RightMargin+1-9                 ; Calculate the Gui width
      GuiWidth := GuiWidth < MinGuiWidth ? MinGuiWidth : GuiWidth             ; Make sure that it's not smaller than MinGuiWidth
      WhiteBoxHeight := SizeY+SizeH+Gap                                       ; Calculate the height of the white box
   }
   else                                                                       ; If the text field is blank ...
   {  GuiWidth := MinGuiWidth                                                 ; Set the width of the Gui to MinGuiWidth
      WhiteBoxHeight := 2*Gap+1                                               ; Set the height of the white box
      BottomGap++                                                             ; Increase the gap above the button by one
      BottomHeight--                                                          ; Decrease the height of the bottom section of the Gui
   }
   ControlMove(, , GuiWidth, WhiteBoxHeight, MyWhiteBox.Hwnd)   ; Adjust the width and height of the white box
   ButtonX := GuiWidth-RightMargin-ButtonWidth                 ; Calculate the horizontal position of the button
   ButtonY := WhiteBoxHeight+BottomGap                         ; Calculate the vertical position of the button
   MyGui.AddButton("x" ButtonX " y" ButtonY " w" ButtonWidth " h" ButtonHeight " Default", "OK").OnEvent("Click",ButtonOK)   ; Add the OK button
   MyGui.Title := Title
   GuiHeight := WhiteBoxHeight+BottomHeight                    ; Calculate the overall height of the Gui

   MyGui.OnEvent("Close",Gui_Escape)
   MyGui.OnEvent("Escape",Gui_Escape)

   MyGui.Show("w" GuiWidth " h" GuiHeight)                ; Show the Gui
   MyGui.Opt("-ToolWindow")                               ; Remove the ToolWindow option so that the Gui has rounded corners and no icon
                                                          ; Trick from http://ahkscript.org/boards/viewtopic.php?p=11519#p11519
   ;Return
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
