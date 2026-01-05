;ABOUT: Fixed Layouts, TextOpt "Border"

;Inspiration: https://www.autohotkey.com/board/topic/9327-a-handy-dialogue-technique-and-colorful-msgboxs

/** 
 * TODO
 *
*/

#Include <ConsoleWindowIcon>

	global Console := ConsoleWindowIcon()
	Console.WriteLine("Console is Active.")


Class _GuiLayout {

    static guiX:=gY:=gW:=gH:=MarginX:=MarginY:=0
    static clientW:=clientH:=clientX:=clientY:=0
    static controlX:=controlY:=controlW:=controlH:=0
	static guiBorderX:=0
	static guiBorderY:=0

    static _GetDimensions(MyGui, MyControl:=MyGui) {
            WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui
                this.guiX := OutX, this.gY := OutY, this.gW := OutWidth, this.gH := OutHeight
                this.MarginX := MyGui.MarginX, this.MarginY := MyGui.MarginY
            WinGetClientPos &OutClientX, &OutClientY, &OutClientWidth, &OutClientHeight, MyGui
                this.clientW := OutClientWidth, this.clientH := OutClientHeight
                this.clientX := OutClientX, this.clientY := OutClientY
				this.GuiBorderX := OutWidth - OutClientWidth, this.GuiBorderY := OutHeight - OutClientHeight
            MyControl.GetPos(&X, &Y, &W, &H)
                this.controlX := X, this.controlY := Y, this.controlW := W, this.controlH := H			
    }

    static Row(MyGui, Controls, Layout) {
		MyGui.Visible := false
		DllCall("LockWindowUpdate", "UInt", MyGui.Hwnd)
		switch Layout {
			case "AlignLeft":
			    Loop Controls.Length {
					control := Controls[A_Index]
					this._GetDimensions(MyGui, control)
					control.Move(this.MarginX + (this.controlW + this.MarginX) * (A_Index-1),
						this.clientH - (this.controlH + this.MarginY))
					;control.ReDraw()
	            }
			case "AlignCenter":
			    Loop Controls.Length {
					control := Controls[A_Index]
					this._GetDimensions(MyGui, control)
					newX := (this.clientW/2) - ((this.controlW + this.MarginX)* Controls.Length/2) + 
					 		((this.controlW + this.MarginX) * (A_Index-1)) 
					control.Move(newX, this.clientH - (this.controlH+this.MarginY))
					;control.ReDraw()
				}
			case "AlignRight":
				Loop Controls.Length {
					;loop backwards, right to left
					index := Controls.Length - (1 * A_Index-1)
					control := Controls[index]
					this._GetDimensions(MyGui, control)
					control.Move(this.gW - this.GuiBorderX - (this.MarginX + this.controlW * A_Index-1),
						this.clientH - (this.controlH+this.MarginY) )
					;control.ReDraw()
				}
			default:
				Layout := "AlignRight"
		}
		DllCall("LockWindowUpdate", "UInt", 0)
		WinWaitClose(MyGui)
		MyGui.Visible := true
    }
}

Escape::ExitApp()

MsgBoxEx(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK",
	GuiSize:="", GuiOpt:="", FontOpt:="", TextOpt:="", IconOpt:="", SoundOpt:="") {
	return CustomMsgBox(Text, Title, Buttons, GuiSize , GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)
}

MsgBoxB(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK") {
	return MsgBoxBSOD(Text, Title, Buttons)
}
MsgBoxC(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK") {
	return MsgBoxCMD(Text, Title, Buttons)
}
MsgBoxM(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK") {
	return MsgBoxMatrix(Text, Title, Buttons)
}
MsgBoxT(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK") {
	return MsgBoxTerminal(Text, Title, Buttons)
}
MsgBoxBSOD(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK") {
	GuiSize := ""
	GuiOpt:=["","Blue"]
	FontOpt := ["s11","Consolas"]
	TextOpt := " cWhite"
	IconOpt := ["C:\Windows\System32\imageres.dll", "Icon313"] ; PS prompt with user
	SoundOpt:= ""
	return CustomMsgBox(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)	
}
MsgBoxCmd(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK") {
	GuiSize := ""
	GuiOpt  := ["","0x0c0c0c"]
	FontOpt := ["s11","Consolas"]
	TextOpt := " cWhite"
	IconOpt := ["C:\Windows\System32\imageres.dll", "Icon265"] ; cmd prompt with user
	SoundOpt:= ""
	return CustomMsgBox(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)
}
MsgBoxMatrix(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK") {
	GuiSize := ""
	GuiOpt  := ["","0x0c0c0c"]
	FontOpt := ["s11","Consolas"]
	TextOpt := " c0x00FF41"
	IconOpt := ["C:\Windows\System32\imageres.dll", "Icon145"] ; Terminal with green graph
	SoundOpt:= ""
	return CustomMsgBox(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)
}
MsgBoxTerminal(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK") {
	return MsgBoxCmd(Text, Title, Buttons)
}

;-------------------------------------------------------------------------------
; Purpose: Custom MsgBox with options, icons, sounds, and context menu.
; Returns: A String with the name of the button pressed.
; Buttons: A button name starting with an asterisk "Default OK" is the default button.
; Context: Right-click to copy the text to the clipboard.
; License: The Unlicense: https://unlicense.org/
;-------------------------------------------------------------------------------

;Buttons:="OK", "Default Cancel"

;SHOULD BE "Default OK"
CustomMsgBox(Text:="Press OK to continue.", Title:=A_ScriptName, Buttons:="Default OK, AlignRight", 
	GuiSize:="", GuiOpt:="", FontOpt:="", TextOpt:="", IconOpt:="", SoundOpt:="")
{
	buttonPressed := ""

	if (GuiSize = "") {
		gW := gH := gX := gY := 0
		tW := 111
		tH :=  15
		boxWidth := Round(StrLen(Text)) / 61
		boxHeight := Round(StrLen(Text)) / boxWidth
		tW := (boxWidth < 111) ? 111 * 1.1 : boxWidth ;111 ;300
		tH := (boxHeight < 15) ? 15  * 10 : boxHeight ;15  ;200
		gW := tW +20
		gH := tH +20
		gX := 
		gY := "Center"
	} else {
		split := StrSplit(GuiSize, ",")
		gW := split[1] != '' ? split[1] : 0
		gH := split[2] != '' ? split[2] : 0
		gX := split[3] != '' ? split[3] : 0
		gY := split[4] != '' ? split[4] : 0
		boxWidth := Round(StrLen(Text)) / 61
		boxHeight := Round(StrLen(Text)) / boxWidth
		tW := (boxWidth < 111) ? 111 * 1.1 : boxWidth ;111 ;300
		tH := (boxHeight < 15) ? 15  * 10 : boxHeight ;15  ;200
		;tW := gW >= 20 ? gW-20 : 0
		;tH := gH >= 45 ? gH-45 : 0
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

	if (IconOpt = "") {
		IconFile := IconNumber := ""
	} else {
		IconFile   := IconOpt[1] != '' ? IconOpt[1] : ''
		IconNumber := IconOpt[2] != '' ? IconOpt[2] : ''	
	}

	cmbGui := Gui(gOpt)
	cmbGui.Title := Title
	cmbGui.BackColor := gColor
	cmbGui.SetFont(tfOpt, tfName) ; Text Control Font

	cmbText := cmbGui.AddText(TextOpt " xm w" tW " h" tH, Text)

	;Optionally, you can use an Edit control
	;Change the following as well as line 185: A_Clipboard := cmbText.Text
	; cmbEdit := cmbGui.AddEdit("HScroll VScroll ReadOnly xm w" tW " h" tH, Text)
	; cmbEdit.Focus()
	; PostMessage(EM_SETSEL:=0xB1, -1, 0, cmbEdit.Hwnd) ; Deselect all text

	cmbDummy := cmbGui.AddText("xm w0 h0 +Hidden") ; dummy control to start new row
	cmbDummy.Focus() ; If using Edit control, this will shift focus to enable the Default Button

	cmbGui.SetFont(bfOpt, bfName) ; Button Control Font

	; Common Button Names: "OK, Retry, Ignore, Yes, No, Abort, Try Again, Continue, Cancel"

Console.WriteLine("`nButtons: " Buttons)

	buttonArray := StrSplit(Buttons, ",", "`t")

Console.WriteLine("Button Count: " 	buttonArray.Length)

	rowArray := []
	for item in buttonArray {
		buttonText := Trim(item)

Console.WriteLine("buttonArray item: " buttonText) 

		switch buttonText {
			case "AlignLeft":
				rowLayout := buttonText
				continue
			case "AlignCenter":
				rowLayout := buttonText
				continue
			case "AlignRight":
				rowLayout := buttonText
				continue
			default:
				rowLayout := "AlignCenter"			
		}

Console.WriteLine("rowLayout: " rowLayout) 

		opt := "w75 yp"

		if (buttonText != "Default") AND InStr(buttonText, "Default") OR (buttonArray.Length = 1) {
			buttonText := StrReplace(buttonText, "Default", "")
			buttonText := Trim(buttonText)
			opt := opt . " " . "Default"
		}
		cmbGui.AddButton(opt, buttonText).OnEvent("Click", Button_Click)
		rowArray.Push(cmbGui[buttonText])

Console.WriteLine("buttonText Final: " buttonText) 
Console.WriteLine("opt: " opt) 

	}

	cmbMenu := Menu()
	cmbMenu.Add('Copy to Clipboard', MenuHandler)
	cmbMenu.SetIcon('Copy to Clipboard', 'shell32.dll' , 135)
	cmbGui.OnEvent('ContextMenu', Gui_ContextMenu)

	if (gW+gH+gX+gY = 0) 
		;cmbGui.Show("AutoSize Center")
		cmbGui.Show()
	else
		cmbGui.Show("w" gW " h" gH " x" gX " y" gY)

    ChangeWindowIconEx(IconFile, IconNumber, "ahk_id" cmbGui.Hwnd)

Console.WriteLine("rowLayout FINAL: " rowLayout) 

	; rowLayout := cmbText.Text = '' ? "AlignCenter" : rowLayout
	; rowLayout := "AlignCenter"

	_GuiLayout.Row(cmbGui, rowArray, rowLayout)

	SoundMap := Map("Error", "*16", "Stop", "*16", "Asterisk", "*64", "Exclamation", "*64", "Info", "*64")

	if (SoundOpt != "") {
		if SoundMap.Has(SoundOpt)
			SoundPlay SoundMap[SoundOpt]
		else if FileExist(SoundOpt)
			SoundPlay SoundOpt
		else if SoundOpt := "Beep"
			SoundBeep
	}

	WinWaitClose(cmbGui)
	cmbGui.Destroy()
	return buttonPressed

	Button_Click(Ctrl, Info) {
		buttonPressed := Ctrl.Text
		PostMessage(WM_CLOSE:=0x10, 0, 0, cmbGui.Hwnd)
		;Send('!{F4}') ; close the gui, destroy, return buttonPressed
	}

	Gui_ContextMenu(GuiObj, GuiCtrlObj, Item, IsRightClick, X, Y) {
		cmbMenu.Show(X, Y)
	}

	MenuHandler(Item, *) {
		if (Item == 'Copy to Clipboard')
			A_Clipboard := cmbText.Text
 	}
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

;Escape::ExitApp()
;Hotkey("Escape", "Off")


If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    CustomMsgBox_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
CustomMsgBox_Test() {

    #Warn Unreachable

    ; comment out to run tests
    ;SoundBeep(), ExitApp()

	;Hotkey("Escape", "On")

	global LongMessage := ''
	Loop 50
		LongMessage .= "1234567890123456789012345678901234567890123456789012345678901"

    ; comment out tests to skip:
	CustomMsgBox_Test_Standard()
	CustomMsgBox_Test_Defaults()
    ;CustomMsgBox_Test_Alias()
	;CustomMsgBox_Test_ShortName()
	;CustomMsgBox_Test_FullName()
	;CustomMsgBox_Test_Layouts()
	;CustomMsgBox_Test_All()
}

CustomMsgBox_Test_Standard() {
	;MsgBox()
	MsgBox(LongMessage, "MsgBox")
	;MsgBox("This is a Standard MsgBox with OK", "MsgBox")
	;MsgBox("This is a Standard MsgBox with OKCancel", "MsgBox", "OKCancel")
}

CustomMsgBox_Test_Defaults() {

; DEBUG one button align right
;r := CustomMsgBox("DEBUG one button align right.", "Custom MsgBox", "Default &OK, AlignRight")
;(r = "&Cancel") ? ExitApp() : nop:=true

	; First example has no parameters, all defaults:
	r := CustomMsgBox()
	;r := CustomMsgBox("text", "title")

	; Next example is similar to standard MsgBox:
	r := CustomMsgBox("This is similar to the standard MsgBox`n`nNote the buttons are centered.", "Custom MsgBox", "Default &OK, &Cancel, AlignCenter",,,,"Border")
	(r = "&Cancel") ? ExitApp() : nop:=true

}
CustomMsgBox_Test_Alias() {
	r := MsgBoxEx("Test: MsgBoxEx Defaults.", "Style: MsgBoxEx")	
}

CustomMsgBox_Test_ShortName() {
	r := MsgBoxB("Test: BSOD Style Defaults.", "Style: MsgBoxB")
	r := MsgBoxC("Test: Cmd Style Defaults.", "Style: MsgBoxC")
	r := MsgBoxM("Test: Matrix Style Defaults.", "Style: MsgBoxM")
	r := MsgBoxT("Test: Terminal Style Defaults.", "Style: MsgBoxT")	
}

CustomMsgBox_Test_FullName() {
	r := MsgBoxBsod("Test: BSOD Style Defaults.", "Style: MsgBoxBSOD")
	r := MsgBoxCmd("Test: Cmd Style Defaults.", "Style: MsgBoxCmd")
	r := MsgBoxMatrix("Test: Matrix Style Defaults.", "Style: MsgBoxMatrix")
	r := MsgBoxTerminal("Test: Terminal Style Defaults.", "Style: MsgBoxTerminal")	
}

CustomMsgBox_Test_Layouts() {

	; test Align Left, Center, Right
	r := CustomMsgBox("Layout: AlignLeft.", "Custom MsgBox", "Default &OK, &Cancel, AlignLeft")
	(r = "&Cancel") ? ExitApp() : nop:=true

	r := CustomMsgBox("Layout: AlignCenter", "Custom MsgBox", "Default &OK, &Cancel, AlignCenter")
	(r = "&Cancel") ? ExitApp() : nop:=true

	r := CustomMsgBox("Layout: AlignRight.", "Custom MsgBox", "Default &OK, &Cancel, AlignRight")
	(r = "&Cancel") ? ExitApp() : nop:=true

}

CustomMsgBox_Test_All() {

	; Finally, all options:
	MyText := ""
	loop 10 {
		MyText .= A_Index ": text, text, text, text, text, text, text, text, text, text, text, text, text, text`r`n"
	}

	; these are NOT required, tailor to your needs
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
	TextOpt	:= "Border -Wrap" 				; Also: Background, Border, Color, Wrap, E0x200=WS_EX_CLIENTEDGE, etc.
	IconOpt := IconExclamation				; [IconFileName, IconNumber]
	SoundOpt:= "Info" 						; Windows MsgBox sounds, or external audio sounds. See SoundMap() in the code above.

	; use all the parameters defined above
	r := CustomMsgBox(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)
	; change the Text and Button fonts, the Icon, and the Sound
	CustomMsgBox("You clicked: " r, Title,,,,["s20", "Segoe Print", "s20", "Impact"],,IconInfo, "Beep")
	(r = "&Cancel") ? ExitApp() : ''

	; other examples with various combinations
	r := CustomMsgBox(Text, Title " - Cmd Style", Buttons, GuiSize, ["","Black"], FontOpt, TextOpt " cWhite", IconCmd, SoundFile1)
	(r = "&Cancel") ? ExitApp() : nop:=true
	r := CustomMsgBox(Text, Title " - Matrix Style", Buttons, GuiSize, ["","Black"], FontOpt, TextOpt " c0x00FF41", IconQuestion, SoundFile2)
	(r = "&Cancel") ? ExitApp() : nop:=true
	r := CustomMsgBox(Text, Title " - Terminal Style", Buttons, GuiSize, ["","Blue"], FontOpt, TextOpt " cWhite", IconError, SoundFile3)
	(r = "&Cancel") ? ExitApp() : nop:=true
	r := CustomMsgBox(Text, Title, Buttons, GuiSize, ["","White"], FontOpt, TextOpt " cRed", IconInfo, SoundFile4)

	ExitApp
}

