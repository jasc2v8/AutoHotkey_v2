;ABOUT: Added GuiLayout

;Inspiration: https://www.autohotkey.com/board/topic/9327-a-handy-dialogue-technique-and-colorful-msgboxs

/** 
 * TODO
 * 	Now that we have alias e.g. MsgBoxCmd(), remove the GuiOpt := "Cmd" logic
 *
*/

Class GuiLayout {

    static guiX:=gY:=gW:=gH:=guiMarginX:=guiMarginY:=0
    static clientW:=clientH:=clientX:=clientY:=0
    static controlX:=controlY:=controlW:=controlH:=0

    static _GetDimensions(MyGui, MyControl:=MyGui) {
            WinGetPos &OutX, &OutY, &OutWidth, &OutHeight, MyGui
                this.guiX := OutX
                this.gY := OutY
                this.gW := OutWidth
                this.gH := OutHeight
                this.guiMarginX := MyGui.MarginX
                this.guiMarginY := MyGui.MarginY
            WinGetClientPos &OutClientX, &OutClientY, &OutClientWidth, &OutClientHeight, MyGui
                this.clientW := OutClientWidth
                this.clientH := OutClientHeight
                this.clientX := OutClientX
                this.clientY := OutClientY
            MyControl.GetPos(&X, &Y, &W, &H)
                this.controlX := X
                this.controlY := Y
                this.controlW := W
                this.controlH := H
    }

    static Row(MyGui, Controls, Layout) {
        Layout := Layout = '' ? "LeftRight" : Layout
        if (Layout = "LeftRight") {
            for control in Controls
            {
                this._GetDimensions(MyGui,control)
                if (A_Index = 1)
                    control.Move(0+this.guiMarginX, this.clientH - (this.controlH+this.guiMarginY))
                else
                    control.Move(0+this.guiMarginX+(this.controlW+this.guiMarginY)*(A_Index-1), this.clientH - (this.controlH+this.guiMarginY))
            }
            WinRedraw(MyGui)
            return
        }
        if (Layout = "RightLeft") {
            count := 1
            index := Controls.Length
            Loop
            {
                control := Controls[index]
                this._GetDimensions(MyGui,control)
                control.Move(this.gW-this.guiMarginX-count*(this.controlW+this.guiMarginX), this.clientH - (this.controlH+this.guiMarginY) )
                count++
                index--
                if (index = 0)
                    break
            }
            WinRedraw(MyGui)
            return
        }
        if (Layout = "Center") {
            for control in Controls
            {
                this._GetDimensions(MyGui,control)
                newX := this.gW / 2 - (this.controlW * Controls.Length - this.controlW/2)
                control.Move(newX + ((this.guiMarginX + this.controlW) * A_Index-1), this.clientH - (this.controlH+this.guiMarginY))
            }
            WinRedraw(MyGui)
            return
        }
    }   
}

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
; Buttons: A button name starting with an asterisk "*OK" is the default button.
; Context: Right-click to copy the text to the clipboard.
; License: The Unlicense: https://unlicense.org/
;-------------------------------------------------------------------------------
CustomMsgBox(Text:="Press OK to continue...", Title:=A_ScriptName, Buttons:="OK", 
	GuiSize:="", GuiOpt:="", FontOpt:="", TextOpt:="", IconOpt:="", SoundOpt:="")
{
	buttonPressed := ""

	if (GuiSize = "") {
		gW := gH := gX := gY := 0
		tW := 300
		tH := 160
	} else {
		split := StrSplit(GuiSize, ",")
		gW := split[1] != '' ? split[1] : 0
		gH := split[2] != '' ? split[2] : 0
		gX := split[3] != '' ? split[3] : 0
		gY := split[4] != '' ? split[4] : 0
		tW := gW >= 20 ? gW-20 : 0
		tH := gH >= 45 ? gH-45 : 0
	}

	if (GuiOpt = "") {
		GuiOpt:=["",""] ; old:		gOpt := gColor := ""

	} else if (GuiOpt = "BSOD") { ;StrCompare(GuiOpt, "BSOD") {
		GuiOpt:=["","Blue"]
		FontOpt := (FontOpt = '') ? ["s11","Consolas"] : FontOpt
		TextOpt := (TextOpt = '') ? " cWhite" : TextOpt
		IconOpt := ["C:\Windows\System32\imagres.dll", "Icon313"] ; PS prompt with user
	} else if (GuiOpt = "Cmd") {
		GuiOpt:=["","Black"], opt:=" c0x010401"
		FontOpt := (FontOpt = '') ? ["s11","Consolas"] : FontOpt
		TextOpt := (TextOpt = '') ? " cWhite" : TextOpt
		IconOpt := (IconOpt = '') ? ["C:\Windows\System32\imagres.dll", "Icon265"] : IconOpt ; cmd prompt with user
	} else if (GuiOpt = "Matrix") {
		GuiOpt:=["","Black"], opt:=" c0x010401"
		FontOpt := (FontOpt = '') ? ["s11","Consolas"] : FontOpt
		TextOpt := (TextOpt = '') ? " c0x00FF41" : TextOpt
		IconOpt := (IconOpt = '') ? ["C:\Windows\System32\imagres.dll", "Icon187"] : IconOpt ; Terminal with matrix of color or 125 green grap
	} else if (GuiOpt = "Terminal") {
		GuiOpt:=["","Black"], opt:=" c0x010401"
		FontOpt := (FontOpt = '') ? ["s11","Consolas"] : FontOpt
		TextOpt := (TextOpt = '') ? " cWhite" : TextOpt
		IconOpt := (IconOpt = '') ? ["C:\Windows\System32\imagres.dll", "Icon265"] : IconOpt ; cmd prompt with user
	}

	gOpt   := GuiOpt.Length >= 1 ? GuiOpt[1] : ''
	gColor := GuiOpt.Length >= 2 ? GuiOpt[2] : ''

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

	cmbDummy :=cmbGui.AddText("xm w0 h0 +Hidden vDUMMY") ; dummy control to start new row
	cmbDummy.Focus() ; If using Edit control, this will shift focus to enable the Default Button

	cmbGui.SetFont(bfOpt, bfName) ; Button Control Font

	; Common Button Names: "OK, Retry, Ignore, Yes, No, Abort, Try Again, Continue, Cancel"
	
	number := 1
	buttonArray := StrSplit(Buttons, ",", "`t")
	for item in buttonArray {
		button := Trim(item)
		opt := "w75 yp"
		if (buttonArray.Length = 1) OR (SubStr(button,1,1) = "*")
			opt := opt . " " . "Default"
		cmbGui.AddButton(opt, StrReplace(button,'*','')).OnEvent("Click", Button_Click)
	}
	
	cmbMenu := Menu()
	cmbMenu.Add('Copy to Clipboard', MenuHandler)
	cmbMenu.SetIcon('Copy to Clipboard', 'shell32.dll' , 135)
	cmbGui.OnEvent('ContextMenu', Gui_ContextMenu)

	if (gW+gH+gX+gY = 0) 
		cmbGui.Show("AutoSize Center")
	else
		cmbGui.Show("w" gW " h" gH " x" gX " y" gY)

    ChangeWindowIcon(IconFile, IconNumber, "ahk_id" cmbGui.Hwnd)

	rowArray := []
	for button in buttonArray {
		buttonIndex := RegExReplace(button, "[ *&]")
		rowArray.Push(cmbGui[buttonIndex])
	}
	GuiLayout.Row(cmbGui, rowArray, "Center")

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

ChangeWindowIcon(IconFile, IconNumber:="Icon1", WinTitle := "A") {

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

Escape::ExitApp()
Hotkey("Escape", "Off")


If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    CustomMsgBox_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
CustomMsgBox_Test() {

    #Warn Unreachable

    ; set true to run tests, else false
    Run_Tests := true

    if !Run_Tests
        SoundBeep(), ExitApp()

	Hotkey("Escape", "On")

    ; comment out tests to skip:
    CustomMsgBox_Test_Alias()
	CustomMsgBox_Test_ShortName()
	CustomMsgBox_Test_FullName()
	CustomMsgBox_Test_Defaults()
	CustomMsgBox_Test_All()
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

CustomMsgBox_Test_Defaults() {

	; First example has no parameters, all defaults:
	r := CustomMsgBox()

	; Next example is similar to standard MsgBox:
	r := CustomMsgBox("This is similar to the standard MsgBox.", "Custom MsgBox", "*&OK, &Cancel")
	(r = "&Cancel") ? ExitApp() : nop:=true

	; test styles with all other defaults
	r := CustomMsgBox("Test: Cmd Style Defaults.", "Style: Cmd",,,"cmd")
	(r = "&Cancel") ? ExitApp() : nop:=true
	r := CustomMsgBox("Test: BSOD Style Defaults.", "Style: BSOD",,,"BSOD")
	(r = "&Cancel") ? ExitApp() : nop:=true
	r := CustomMsgBox("Test: Matrix Style Defaults.", "Style: Matrix",,,"matrix")
	(r = "&Cancel") ? ExitApp() : nop:=true
	r := CustomMsgBox("Test: Terminal Style Defaults.", "Style: Terminal",,,"terminal")
	(r = "&Cancel") ? ExitApp() : nop:=true

	; can still change fonts
	r := CustomMsgBox("Test: BSOD Style with User Fonts.", "Style: BSOD",,,"BSOD", ["s24 Bold","Courier"], " cRed")
	(r = "&Cancel") ? ExitApp() : nop:=true

	;standard icons and sounds
	; MsgBox("text", "title", "OK IconX") ; Stop/Error
	; MsgBox("text", "title", "OK Icon?") ; No Sound
	; MsgBox("text", "title", "OK Icon!") ; Asterisk/Exclamation/Info
	; MsgBox("text", "title", "OK IconI") ; Same as Icon!

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
	Buttons	:= "*&Yes, &No, &All, &Cancel"	; *&Yes:  *=Default button, &=Alt+Y shortcut
	GuiSize := "400, 223, 10, 10" 			; w, h, x, y
	GuiOpt	:= ["+AlwaysOnTop", "White"]  ; [Gui Opt, Gui.Background]
	FontOpt := ["s8", "Cascadia Mono", "s8", "Segoe UI"] ; [TextFontSize, TextFontName, ButtonFontSize, ButtonFontName]
	TextOpt	:= "Border -Wrap" 				; Also: Background, Border, Color, Wrap, E0x200=WS_EX_CLIENTEDGE, etc.
	IconOpt := IconExclamation				; [IconFileName, IconNumber]
	SoundOpt:= "Info" 						; Windows MsgBox sounds, or external audio sounds. See SoundMap() in the code above.

	; use all the parameters defined above
	r := CustomMsgBox(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconOpt, SoundOpt)
	(r = "&Cancel") ? ExitApp() : ''

	; change the Text and Button fonts, the Icon, and the Sound
	CustomMsgBox("You clicked: " r, Title,,,,["s20", "Segoe Print", "s20", "Impact"],,IconInfo, "Beep")

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

