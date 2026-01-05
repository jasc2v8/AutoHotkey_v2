#NoEnv

Title := "Gui or MsgBox?"
Text  := "One of these windows is a Gui.`nThe other one is a MsgBox.`n`nCan you tell the difference?"

MsgBox(Title,Text)
MsgBox, , %Title%, %Text%
Return

MsgBox(Title,Text) {
   static WhiteBox,TextBox
   
   FontName     := "Segoe UI"    ; Name of font for text in Gui
   FontSize     := 9             ; Gui font size
   Gap          := 26            ; Spacing above and below text in top area of the Gui
   LeftMargin   := 12            ; Left Gui margin
   RightMargin  := 8             ; Space between right side of button and right Gui edge
   ButtonWidth  := 88            ; Width of OK button
   ButtonHeight := 26            ; Height of OK button
   ButtonOffset := 30            ; Offset between the right side of text and right edge of button
   MinGuiWidth  := 138           ; Minimum width of Gui
   SS_WHITERECT := 0x0006        ; Gui option for white rectangle (http://ahkscript.org/boards/viewtopic.php?p=20053#p20053)

   BottomGap := LeftMargin                          ; Set the distance between the bottom of the white box and the top of the OK button
   BottomHeight := ButtonHeight+2*LeftMargin+3      ; Calculate the height of the bottom section of the Gui
   Gui, Font, s%FontSize%, %FontName%               ; Set the font size and name
   Gui, +ToolWindow -MinimizeBox -MaximizeBox       ; Set the Gui so it doesn't have the icon, the minimize button, and the maximize button
   Gui, Add, Text, x0 y0 %SS_WHITERECT% vWhiteBox   ; Add a white box at the top of the window
   if Text                                                                    ; If the text field is not blank ...
   {  Gui, Add, Text, x%LeftMargin% y%Gap% BackgroundTrans vTextBox, %Text%   ; Add the text to the Gui
      GuiControlGet, Size, Pos, TextBox                                       ; Get the position of the text box
      GuiWidth := LeftMargin+SizeW+ButtonOffset+RightMargin+1                 ; Calculate the Gui width
      GuiWidth := GuiWidth < MinGuiWidth ? MinGuiWidth : GuiWidth             ; Make sure that it's not smaller than MinGuiWidth
      WhiteBoxHeight := SizeY+SizeH+Gap                                       ; Calculate the height of the white box
   }
   else                                                                       ; If the text field is blank ...
   {  GuiWidth := MinGuiWidth                                                 ; Set the width of the Gui to MinGuiWidth
      WhiteBoxHeight := 2*Gap+1                                               ; Set the height of the white box
      BottomGap++                                                             ; Increase the gap above the button by one
      BottomHeight--                                                          ; Decrease the height of the bottom section of the Gui
   }
   GuiControl, Move, WhiteBox, w%GuiWidth% h%WhiteBoxHeight%   ; Adjust the width and height of the white box
   ButtonX := GuiWidth-RightMargin-ButtonWidth                 ; Calculate the horizontal position of the button
   ButtonY := WhiteBoxHeight+BottomGap                         ; Calculate the vertical position of the button
   Gui, Add, Button, x%ButtonX% y%ButtonY% w%ButtonWidth% h%ButtonHeight% Default, OK   ; Add the OK button
   GuiHeight := WhiteBoxHeight+BottomHeight                    ; Calculate the overall height of the Gui
   Gui, Show, w%GuiWidth% h%GuiHeight%, %Title%                ; Show the Gui
   Gui, -ToolWindow                                            ; Remove the ToolWindow option so that the Gui has rounded corners and no icon
                                                               ; Trick from http://ahkscript.org/boards/viewtopic.php?p=11519#p11519
   Return

   ButtonOK:
   GuiClose:
   GuiEscape:
   Gui Destroy
   Return
}