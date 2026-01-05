;ABOUT: Added Context Menu, Copy to Clipboard

;SOURCE: V1 https://www.autohotkey.com/boards/viewtopic.php?f=6&t=9043

; A_DefaultGui warning post above by pnewmatic

/**
 * TODO:
 *    fix short alias to includ iconopt etc.
 * 
 *    This could conflict with other function names if included e.g. MyGui    
 *    Either, Make names very unique e.g. MyGui1010
 *    Or, make a static class:  MsgBoxEx.Show(text, title)
 *    Or, make an inherited class:  MB := MsgBoxEX(options), MB.Show(text, title)
 *
 */

#Requires AutoHotkey v2.0+
#SingleInstance Force

;DEBUG
#Include <Debug>
Escape::ExitApp()

; #Region Alias functions

; Short name alias functions
MsgBoxB(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK", GuiSize:="", SoundOpt:="") {
	return MsgBoxBSOD(Text, Title, Buttons, GuiSize, , , , , SoundOpt)
}
MsgBoxC(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK", GuiSize:="", SoundOpt:="") {
	return MsgBoxCMD(Text, Title, Buttons, GuiSize, , , , , SoundOpt)
}
MsgBoxM(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK", GuiSize:="", SoundOpt:="") {
	return MsgBoxMatrix(Text, Title, Buttons, GuiSize, , , , , SoundOpt)
}
MsgBoxT(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK", GuiSize:="", SoundOpt:="") {
	return MsgBoxTerminal(Text, Title, Buttons, GuiSize, , , , , SoundOpt)
}

; Full name alias functions
MsgBoxBSOD(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK", GuiSize:="", GuiOpt:="", FontOpt:="", TextOpt:="", IconOpt:="", SoundOpt:="") {
	GuiOpt   :=["","Blue"]
	FontOpt  := ["s11","Consolas"]
	TextOpt  := " cWhite"
	IconOpt  := ["C:\Windows\System32\imageres.dll", "Icon313"] ; PS prompt with user
	return MsgBoxEx(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)	
}
MsgBoxCmd(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK", GuiSize:="", GuiOpt:="", FontOpt:="", TextOpt:="", IconOpt:="", SoundOpt:="") {
	GuiOpt  := ["","0x0c0c0c"]
	FontOpt := ["s11","Consolas"]
	TextOpt := " cWhite"
	IconOpt := ["C:\Windows\System32\imageres.dll", "Icon265"] ; cmd prompt with user
	return MsgBoxEx(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)
}
MsgBoxMatrix(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK", GuiSize:="", GuiOpt:="", FontOpt:="", TextOpt:="", IconOpt:="", SoundOpt:="") {
	GuiOpt  := ["","0x0c0c0c"]
	FontOpt := ["s11","Consolas"]
	TextOpt := " c0x00FF41"
	IconOpt := ["C:\Windows\System32\imageres.dll", "Icon145"] ; Terminal with green graph
	return MsgBoxEx(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)
}
MsgBoxTerminal(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK", GuiSize:="", GuiOpt:="", FontOpt:="", TextOpt:="", IconOpt:="", SoundOpt:="") {
	return MsgBoxCmd(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)
}
;-------------------------------------------------------------------------------
; Purpose: Custom MsgBox with options, icons, sounds, and context menu.
; Returns: A String with the name of the button pressed.
; Context: Right-click to copy the text to the clipboard.
; License: The Unlicense: https://unlicense.org/
; Params :
;     Title 	:= "Custom MsgBox"				               ; Gui title
;     Text 	   := "Text Message"				                  ; Text Control text
;     Buttons	:= "Default &Yes, &No, &All, &Cancel"        ; Default =Default button, &Y=Alt+Y shortcut
;     GuiSize  := "400, 223, 10, 10" 			               ; w, h, x, y
;     GuiOpt	:= ["+AlwaysOnTop", "White"]                 ; [Gui Opt, Gui.Background]
;     FontOpt  := ["s11", "Consolas", "s9", "Segoe UI"]     ; [TextFontSize, TextFontName, ButtonFontSize, ButtonFontName]
;     TextOpt  := "Border -Wrap" 				               ; Also: Background, Border, Color, Wrap, E0x200=WS_EX_CLIENTEDGE, etc.
;     IconOpt  := IconExclamation				               ; [IconFileName, IconNumber]
;     SoundOp  := "Info" 						                  ; Windows MsgBox sounds, or external audio sounds. See SoundMap() in the code above.
;-------------------------------------------------------------------------------
MsgBoxEx(Text:="Press OK to continue.", Title:=A_ScriptName, Buttons:="Default &OK, AlignCenter",
	GuiSize:="", GuiOpt:="", FontOpt:="", TextOpt:="", IconOpt:="", SoundOpt:="")
{
   ;static WhiteBox,TextBox
   global MyGui := unset
   global buttonPressed := ''
   global ButtonAlignment := unset
   global ButtonX := unset

   ; Split the Buttons into an array
  	buttonArray := StrSplit(Buttons, ",", "`t")
   
   ; Get alignment parameter and remove from buttonArray
   ButtonAlignment := "AlignCenter"
   i := buttonArray.Length
    ; Loop backwards to safely delete items without skipping elements due to index shifting.
    while (i >= 1) {
      buttonText := Trim(buttonArray[i])
      if (SubStr(buttonText, 1, 5) ="Align") {
         ButtonAlignment := buttonText
         buttonArray.RemoveAt(i)
         break
      }
      i--
    }

   ; Get the number of buttons after removing the alignment parameter
   buttonCount := buttonArray.Length

   ; Get paramter options

   if (GuiSize = "") {
		gW := gH := gX := gY := 0
	} else {
		split := StrSplit(GuiSize, ",")
      if (split.Length = 2) {
         gW := split[1] != '' ? split[1] : 0
         gH := split[2] != '' ? split[2] : 0
      } else if (split.Length = 4) {
         gW := split[1] != '' ? split[1] : 0
         gH := split[2] != '' ? split[2] : 0
		   gX := split[3] != '' ? split[3] : 0
		   gY := split[4] != '' ? split[4] : 0
      }
	}

   if (GuiOpt = "") {
		gOpt := gColor := ""
	} else {
		gOpt   := GuiOpt.Length >= 1 ? GuiOpt[1] : ''
		gColor := GuiOpt.Length >= 2 ? GuiOpt[2] : ''
	}

	if (FontOpt = "") {
		tfOpt := tfName := ""
		bfOpt := bfName := ""
	} else {
		tfOpt  := FontOpt.Length >= 1 ? FontOpt[1] : ''
		tfName := FontOpt.Length >= 2 ? FontOpt[2] : ''
		bfOpt  := FontOpt.Length >= 3 ? FontOpt[3] : ''
		bfName := FontOpt.Length >= 4 ? FontOpt[4] : ''
	}

   ;TODO use Font parameters
   FontName     := "Segoe UI"          ; Name of font for text in Gui
   FontSize     := 9                   ; Gui font size

   ;TODO adjust based on font size?
   TopMargin    := 8 ; FontSize * (96/72)  ; Spacing above and below text in top area of the Gui. Convert Font Point to Pixels
   LeftMargin   := 12                  ; Left Gui margin
   RightMargin  := 8                   ; Space between right side of button and right Gui edge
   BottomMargin := 8
   
   ;TODO adjust based on font size?
   ButtonMargin := 4                   ; Spacing between buttons
   ButtonWidth  := 75                  ; Width of OK button
   ButtonHeight := 23                  ; Height of OK button
   ButtonPanel := ButtonHeight*2      ; Calculate the height of the bottom section of the Gui

   ; Minimum width of Gui
   MinGuiWidth  := buttonCount * (ButtonWidth + ButtonMargin) + LeftMargin

   ; Gui option for white rectangle (http://ahkscript.org/boards/viewtopic.php?p=20053#p20053)
   SS_WHITERECT := 0x0006
   
   MyGui := Gui(gOpt)
  	MyGui.Title := Title
	MyGui.BackColor := gColor
   ;MyGui.SetFont("s" FontSize, FontName)
	MyGui.SetFont(tfOpt, tfName) ; Text Control Font

   if (IconOpt = "")
      MyGui.Opt("+ToolWindow -MinimizeBox -MaximizeBox")
   else
      MyGui.Opt("-MinimizeBox -MaximizeBox")

   ; #Region Add WhiteBox

   ; Add a Text Control with white rectangle background, a "WhiteBox"
   MyWhiteBox := MyGui.AddText("x0 y0 " SS_WHITERECT)
   ; DEBUG MyWhiteBox := MyGui.AddText("x0 y0 w10 h10 cRed", "WhiteBox")
   ; Hide if Gui color options present
   if (gColor != "" )
      MyWhiteBox.Visible := False

   if Text
   {
      ; Add the Text Control to the Gui
      TextOptions := " BackgroundTrans"
      if TextOpt
         TextOptions := TextOptions " " TextOpt

      MyText := MyGui.AddText(" x" LeftMargin " y" TopMargin TextOptions, Text)

      ; Get the position of the text box
      ControlGetPos &TextX, &TextY, &TextW, &TextH, MyText.Hwnd

      ; Calculate the height of the white box
      WhiteBoxHeight := TextY + TextH - BottomMargin

      ; Calculate the space required for the text and buttons
      TextSpace   := LeftMargin + TextW + RightMargin
      ButtonSpace := LeftMargin + (buttonCount * (ButtonWidth + ButtonMargin)) + RightMargin
      LargerWidth := TextSpace > ButtonSpace ? TextSpace : ButtonSpace

;MsgBox("TextSpace: " TextSpace " ButtonSpace: " ButtonSpace " LargerWidth: " LargerWidth)

      ; Calculate the WhiteBoxWidth
      WhiteBoxWidth := TextSpace + RightMargin
      
      ; Make sure that it's not smaller than MinGuiWidth
      ;GuiWidth := GuiWidth < MinGuiWidth ? MinGuiWidth : GuiWidth
   }
   else
   {  
      ; The text field is blank
      GuiWidth := MinGuiWidth
      WhiteBoxWidth := MinGuiWidth ; (ButtonMargin + ButtonWidth) * ButtonCount   ;LeftMargin - RightMargin                                              ; Set the width of the Gui to MinGuiWidth
      WhiteBoxHeight := 2*TopMargin+1                                               ; Set the height of the white box
      ;BottomGap++                                                             ; Increase the gap above the button by one
      ;ButtonPanel--                                                          ; Decrease the height of the bottom section of the Gui
   }

   ; Adjust the width and height of the white box
    ControlMove(, , WhiteBoxWidth, WhiteBoxHeight, MyWhiteBox.Hwnd)
   
   ; Calculate the vertical position of the button
   ButtonY := WhiteBoxHeight + ButtonHeight/2 ; BottomGap

   ; Calculate the horizontal alignment of the buttons
   ButtonSpace := (buttonWidth * buttonCount) + (ButtonMargin * buttonCount - 1)
   AlignLeft := LeftMargin
   AlignCenter := (WhiteBoxWidth / 2) - (ButtonSpace / 2)
   AlignRight := WhiteBoxWidth - ButtonSpace - RightMargin

   ;DEBUG
   ; Manually select the desir3ed alignment of the buttons - will become "AlignLeft, AlignCenter, AlignRight"
   ;ButtonX := AlignLeft
   ;ButtonX := AlignCenter
   ;ButtonX := AlignRight

   switch ButtonAlignment {
      case "AlignLeft":
         ButtonX := AlignLeft
      case "AlignCenter":
         ButtonX := AlignCenter
      case "AlignRight":
         ButtonX := AlignRight
      default:
         ButtonX := AlignCenter
   }

;MsgBox "ButtonX: " ButtonX ", AlignCenter:" AlignCenter
	MyGui.SetFont(bfOpt, bfName) ; Text Control Font

   ;========= add buttons
	Loop buttonArray.Length {

      ; Get the index number
      index :=A_Index

      ; Get the button text from the array[index]
      buttonText := Trim(buttonArray[index])

      ; Preset options
		opt := "x" ButtonX " y" ButtonY " w" ButtonWidth " h" ButtonHeight

;MsgBox "buttonText: " buttonText ", X:" ButtonX " Index: " buttonArray.Length - (1 * A_Index-1)

      ; If Default then add to the options
		if InStr(buttonText, "Default") OR (buttonArray.Length = 1) {
			buttonText := StrReplace(buttonText, "Default", "")
			buttonText := Trim(buttonText)
			opt := opt " Default"
		}

      ; Add the button with a common click handler
		MyGui.AddButton(opt, buttonText).OnEvent("Click", Button_Click)

      ;Calculate the horizontal position of the next button
      ButtonX += (ButtonMargin + ButtonWidth) 

	}

   ; #Region Gui.Show()

   GuiHeight := WhiteBoxHeight+ButtonPanel                    ; Calculate the overall height of the Gui

   MyGui.OnEvent("Close",Gui_Escape)
   MyGui.OnEvent("Escape",Gui_Escape)
	MyGui.OnEvent('ContextMenu', Gui_ContextMenu)

  	MyMenu := Menu()
	MyMenu.Add('Copy to Clipboard', MenuHandler)
	MyMenu.SetIcon('Copy to Clipboard', 'shell32.dll' , 135)

   ; Posiion the Gui according to parameters
   ; TODO: This only supports the primary monitor.
   ; TODO: Use MonitorGet to set other monitors
   ; TODO: Gemini: "ahkv2 show gui on secondary monitor"
   xPos := (gX = 0) ? "" : xPos:=" x" gX
   yPos := (gY = 0) ? "" : yPos:=" y" gY

   ; Show the Gui
   MyGui.Show("w" WhiteBoxWidth " h" GuiHeight xPos yPos) 

   ; Remove the ToolWindow option so that the Gui has rounded corners and no icon
   ; Trick from http://ahkscript.org/boards/viewtopic.php?p=11519#p11519
   MyGui.Opt("-ToolWindow")

   ; Set the icon, if any
   IconMap := Map()
   IconMap.Set("Iconx", ["C:\Windows\System32\user32.dll", "Icon4"])
   IconMap.Set("Icon?", ["C:\Windows\System32\user32.dll", "Icon3"])
   IconMap.Set("Icon!", ["C:\Windows\System32\user32.dll", "Icon2"])
   IconMap.Set("Iconi", ["C:\Windows\System32\user32.dll", "Icon5"])

   ;msgbox type(IconOpt)

   if Type(IconOpt) = "Array" {
      IconFile   := IconOpt[1] != '' ? IconOpt[1] : ''
      IconNumber := IconOpt[2] != '' ? IconOpt[2] : ''
   } else {
      if (IconOpt != "") {
         split := IconMap[IconOpt]
         IconFile   := split[1] != '' ? split[1] : ''
         IconNumber := split[2] != '' ? split[2] : ''
      }
   }

   if (IconOpt != "")
      ChangeWindowIconEx(IconFile, IconNumber, "ahk_id" MyGui.Hwnd)

   ; Play the designated sound
   ; #Region Define Sound Variables

   SoundBlip := "C:\Windows\Media\Windows Default.wav"
   SoundChimes := "C:\Windows\Media\chimes.wav" 
   SoundCriticalStop := "C:\Windows\Media\Windows Critical Stop.wav"
   SoundError := "C:\Windows\Media\Windows Error.wav"
   SoundNotifySystemGeneric := "C:\Windows\Media\Windows Notify System Generic.wav"

   SoundIconError       := SoundCriticalStop
   SoundIconQuestion    := SoundNotifySystemGeneric
   SoundIconExclamation := SoundChimes
   SoundIconInfo        := SoundError

   SoundMap := Map()
   SoundMap.Set("Iconx", SoundIconError)
   SoundMap.Set("Icon?", SoundIconQuestion)
   SoundMap.Set("Icon!", SoundIconExclamation)
   SoundMap.Set("Iconi", SoundIconInfo)
   SoundMap.Set("Beep", SoundBlip)

	if (SoundOpt != "") {
		if SoundMap.Has(SoundOpt)
			SoundPlay SoundMap[SoundOpt]
		else if FileExist(SoundOpt)
			SoundPlay SoundOpt
	}

   ; Wait or a button press or window close
  	WinWaitClose(MyGui)

   ; Destroy the gui
	MyGui.Destroy()

   ; Return the text of the button pressed
	return buttonPressed

   ; #Region Handlers

  	Gui_ContextMenu(GuiObj, GuiCtrlObj, Item, IsRightClick, X, Y) {
		MyMenu.Show(X, Y)
	}

	MenuHandler(Item, *) {
		if (Item == 'Copy to Clipboard')
			A_Clipboard := MyText.Text
 	}

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
If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    MsgBoxEx_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
MsgBoxEx_Test() {

   global longMessage := unset

    #Warn Unreachable

    ; comment out to run tests
    ;SoundBeep(), ExitApp()

	;Hotkey("Escape", "On")

	; global LongMessage := ''
	; Loop 50
	;  	LongMessage .= "1234567890123456789012345678901234567890`n" ; 123456789012345678901"

   ; TestButtons:="Default &OK, &Abort, &Cancel, AlignRight"
   longMessage := unset
   Loop 30
    longMessage .= Format("{:02}", A_Index) ": The quick brown fox jumps over the lazy dog. The.`n"

   ; MsgBoxEx(longMessage, "TEST", TestButtons)

   ; #Region Test Selection

    ; comment out tests to skip:
	;MsgBoxEx_Test_Standard()
	MsgBoxEx_Test_Defaults()
	;MsgBoxEx_Test_ShortName()
	;MsgBoxEx_Test_FullName()
	;MsgBoxEx_Test_Layouts()
   ;MsgBoxEx_Test_Sounds()
	;MsgBoxEx_Test_All()
}
MsgBoxEx_Test_Standard() {
	MsgBox()
	MsgBox("This is a Standard MsgBox with OK", "Standard MsgBox")
	MsgBox("This is a Standard MsgBox with OKCancel", "Standard MsgBox", "OKCancel")
	MsgBox(LongMessage, "Standard MsgBox")
}
MsgBoxEx_Test_Defaults() {

; DEBUG one button align right
;r := MsgBoxEx("DEBUG one button align right.", "Custom MsgBox", "Default &OK, AlignRight")
;(r = "&Cancel") ? ExitApp() : nop:=true

	; First example has no parameters, all defaults:
	r := MsgBoxEx()


   text := "Press OK to continue"
	r := MsgBoxEx(text, "Press OK",,,,,"Border")
	(r = "&Cancel") ? ExitApp() : nop:=true



   ;MsgBoxExOLD(Text:="Press OK to continue.", Title:=A_ScriptName, Buttons:="Default OK, AlignRight", 
	;  GuiSize:="", GuiOpt:="", FontOpt:="", TextOpt:="", IconOpt:="", SoundOpt:="")

   ;TestButtons:="Default &OK, &Abort, &Retry, &Ignore, &Yes, &No, &Cancel, AlignLeft"
   ;TestButtons:="Default &OK, &Abort, &Retry, &Ignore, &Yes, &No, &Cancel, AlignCenter"
   ;TestButtons:="Default &OK, &Abort, &Retry, &Ignore, &Yes, &No, &Cancel, AlignRight"
   TestButtons:="Default &Yes, &No, &Cancel, AlignRight"

   AlignLeft:="Default &Yes, &No, &Cancel, AlignLeft"
   AlignCenter:="Default &Yes, &No, &Cancel, AlignCenter"
   AlignRight:="Default &Yes, &No, &Cancel, AlignRight"
  
	; Next example is similar to standard MsgBox:
   Text := LongMessage
   ;Text := "This is similar to the standard MsgBox`n`nNote the buttons are centered."
   Title := "Custom MsgBox"
   r := MsgBoxEx(Text, "AlignLeft", AlignLeft)
	(r = "&Cancel") ? ExitApp() : nop:=true
   r := MsgBoxEx(Text, "AlignCenter", AlignCenter)
	(r = "&Cancel") ? ExitApp() : nop:=true
   r := MsgBoxEx(Text, "AlignRight", AlignRight)
	(r = "&Cancel") ? ExitApp() : nop:=true

  r := MsgBoxEx(Text, "Border", TestButtons,,,,"Border")
  MsgBox("You pressed: " r)

}
MsgBoxEx_Test_FullName() {
	;r := MsgBoxBsod("Test: BSOD Style Defaults.`n" longMessage, "Style: MsgBoxBSOD")
	r := MsgBoxBsod("Test: BSOD Style Defaults.", "Style: MsgBoxBSOD", , ",,100,100")
 	r := MsgBoxCmd("Test: Cmd Style Defaults.", "Style: MsgBoxCmd", , ",,500,100")
	r := MsgBoxMatrix("Test: Matrix Style Defaults.", "Style: MsgBoxMatrix", , ",,100,300")
	r := MsgBoxTerminal("Test: Terminal Style Defaults.`nNote: Same as Cmd.", "Style: MsgBoxTerminal", , ",,500,300")	
}
MsgBoxEx_Test_ShortName() {
	r := MsgBoxB("Test: BSOD Style Defaults.", "Style: MsgBoxB", , ",,100,100")
	r := MsgBoxC("Test: Cmd Style Defaults.", "Style: MsgBoxC", , ",,500,100")
	r := MsgBoxM("Test: Matrix Style Defaults.", "Style: MsgBoxM", , ",,100,300")
	r := MsgBoxT("Test: Terminal Style Defaults.`nNote: Same as Cmd.", "Style: MsgBoxT", , ",,500,300")	
}

MsgBoxEx_Test_Layouts() {

	; test Align Left, Center, Right
	r := MsgBoxEx("This is a test of the Layout with the name of: AlignLeft.", "MsgBox - AlignLeft", "Default &OK, &Cancel, AlignLeft")
	(r = "&Cancel") ? ExitApp() : nop:=true

	r := MsgBoxEx("This is a test of the Layout with the name of: AlignCenter", "MsgBox - AlignCenter", "Default &OK, &Cancel, AlignCenter")
	(r = "&Cancel") ? ExitApp() : nop:=true

	r := MsgBoxEx("This is a test of the Layout with the name of: AlignRight.", "MsgBox - AlignRight", "Default &OK, &Cancel, AlignRight")
	(r = "&Cancel") ? ExitApp() : nop:=true

}
MsgBoxEx_Test_Sounds() {

   ; MsgBoxTerminal(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK", GuiSize:="", GuiOpt:="", FontOpt:="", TextOpt:="", IconOpt:="", SoundOpt:="") {
	; return MsgBoxCmd(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)

   MyFontOpt := ["s12 ", "Consolas"]
   
   r := MsgBoxEx("Test: Sounds with MsgBox Icons.", "Test: Sounds",,",,100,100",,MyFontOpt,,"Iconx", "Iconx")
   (r = "&Cancel") ? ExitApp() : nop:=true
   r := MsgBoxEx("Test: Sounds with MsgBox Icons.", "Test: Sounds",,",,100,100",,MyFontOpt,,"Icon?", "Icon?")
   (r = "&Cancel") ? ExitApp() : nop:=true
   r := MsgBoxEx("Test: Sounds with MsgBox Icons.", "Test: Sounds",,",,100,100",,MyFontOpt,,"Icon!", "Icon!")
   (r = "&Cancel") ? ExitApp() : nop:=true
   r := MsgBoxEx("Test: Sounds with MsgBox Icons.", "Test: Sounds",,",,100,100",,MyFontOpt,,"Iconi", "Iconi")
   (r = "&Cancel") ? ExitApp() : nop:=true

   MyCustomFont := ["s14 Bold Italic underline", "Comic Sans MS"] ;["s11", "Consolas", "s9", "Segoe UI"]
   MyCustomIcon := ["C:\Windows\System32\imageres.dll", "Icon74"]
   MyCustomSound := "C:\Windows\Media\tada.wav"

   r := MsgBoxEx("Test: Custom Icon, Font, and Sound.", "Test: Sounds",,",,100,100",,MyCustomFont,,MyCustomIcon, MyCustomSound)
   (r = "&Cancel") ? ExitApp() : nop:=true

}
MsgBoxEx_Test_All() {

	; Finally, all options:
	MyText := ""
	loop 10 {
		MyText .= Format("{:02}", A_Index) ": text, text, text, text, text, text, text, text, text, text, text, text, text, text`r`n"
	}

   ;
	; these are NOT required, tailor to your needs
   ; no sound for iconQuestion
	IconExclamation 	:= ["C:\Windows\System32\user32.dll", "Icon2"]
	IconWarn		 	:= ["C:\Windows\System32\user32.dll", "Icon2"]
	IconQuestion		:= ["C:\Windows\System32\user32.dll", "Icon3"]
	IconStop			:= ["C:\Windows\System32\user32.dll", "Icon4"]
	IconError			:= ["C:\Windows\System32\user32.dll", "Icon4"]
	IconAsterisk		:= ["C:\Windows\System32\user32.dll", "Icon5"]
	IconInfo			:= ["C:\Windows\System32\user32.dll", "Icon5"]

	IconShield			:= ["C:\Windows\System32\user32.dll", "Icon7"]
	IconTerminal		:= ["C:\Windows\System32\shell32.dll", "Icon16"]
	IconCmd				:= ["C:\Windows\System32\cmd.exe", "Icon1"]

	SoundFile1 := "C:\Windows\Media\tada.wav"
	SoundFile2 := "C:\Windows\Media\chord.wav"
	SoundFile3 := "C:\Windows\Media\Windows Critical Stop.wav"
	SoundFile4 := "C:\Windows\Media\chimes.wav" 

	; I find it easier to have this block to initialze all the parameters
	Title 	:= "Custom MsgBox"				; Gui title
	Text 	:= MyText						; Text Control text
	Buttons	:= "Default &Yes, &No, &All, &Cancel"	; Default =Default button, &Y=Alt+Y shortcut
	GuiSize := "400, 223, 10, 10" 			; w, h, x, y
	GuiOpt	:= ["+AlwaysOnTop", "White"]  ; [Gui Opt, Gui.Background]
	FontOpt := ["s8", "Cascadia Mono", "s8", "Segoe UI"] ; [TextFontSize, TextFontName, ButtonFontSize, ButtonFontName]
	TextOpt	:= "" ;"Border -Wrap" 				; Also: Background, Border, Color, Wrap, E0x200=WS_EX_CLIENTEDGE, etc.
	IconOpt := IconExclamation				; [IconFileName, IconNumber]
	SoundOpt:= "Info" 						; Windows MsgBox sounds, or external audio sounds. See SoundMap() in the code above.

	; use all the parameters defined above
	r := MsgBoxEx(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)
	; change the Text and Button fonts, the Icon, and the Sound
	MsgBoxEx("You clicked: " r, Title,,,,["s20", "Segoe Print", "s20", "Impact"],,IconInfo, "Beep")
	(r = "&Cancel") ? ExitApp() : ''

	; other examples with various combinations
	r := MsgBoxEx(Text, Title " - Cmd Style", Buttons, GuiSize, ["","Black"], FontOpt, TextOpt " cWhite", IconCmd, SoundFile1)
	(r = "&Cancel") ? ExitApp() : nop:=true
	r := MsgBoxEx(Text, Title " - Matrix Style", Buttons, GuiSize, ["","Black"], FontOpt, TextOpt " c0x00FF41", IconQuestion, SoundFile2)
	(r = "&Cancel") ? ExitApp() : nop:=true
	r := MsgBoxEx(Text, Title " - Terminal Style", Buttons, GuiSize, ["","Blue"], FontOpt, TextOpt " cWhite", IconError, SoundFile3)
	(r = "&Cancel") ? ExitApp() : nop:=true
	r := MsgBoxEx(Text, Title, Buttons, GuiSize, ["","White"], FontOpt, TextOpt " cRed", IconInfo, SoundFile4)

	ExitApp

}
   ChangeWindowIconEx(IconFile, IconNumber:="Icon1", WinTitle := "A") {

      if !FileExist(IconFile)
         return "Icon File missing: " IconFile

         SplitPath(IconFile,,,&OutExt)

         if !InStr("ico,dll,exe", OutExt)
            return "Not a valid Icon File (dll, exe, ico)."
            
         hWnd  := WinExist(WinTitle)
         if (!hWnd)
            return "Window Not Found"

         hIcon := LoadPicture(IconFile, IconNumber, &IconType)
         if (!hIcon)
            Throw("Error loading icon: " IconFile)

         SendMessage(WM_SETICON:=0x80, ICON_SMALL:=0, hIcon,, WinTitle)
         SendMessage(WM_SETICON:=0x80, ICON_BIG:=1  , hIcon,, WinTitle)

         return
      }

