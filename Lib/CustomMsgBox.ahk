;Inspiration: https://www.autohotkey.com/board/topic/9327-a-handy-dialogue-technique-and-colorful-msgboxs

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

	cmbDummy :=cmbGui.AddText("xm w0 h0 +Hidden vDUMMY") ; dummy control to start new row
	cmbDummy.Focus() ; If using Edit control, this will shift focus to enable the Default Button

	cmbGui.SetFont(bfOpt, bfName) ; Button Control Font

	; Common Button Names: "OK, Retry, Ignore, Yes, No, Abort, Try Again, Continue, Cancel"
	
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

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    CustomMsgBox_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
CustomMsgBox_Test() {

    #Warn Unreachable

    ; set true to run tests, else false
    Run_Tests := false

    if !Run_Tests
        SoundBeep(), ExitApp()

    ; comment out tests to skip:
    CustomMsgBox_Test1()
    ;Test2()
    ;Test3()
}

CustomMsgBox_Test1() {

	;standard icons and sounds
	; MsgBox("text", "title", "OK IconX") ; Stop/Error
	; MsgBox("text", "title", "OK Icon?") ; No Sound
	; MsgBox("text", "title", "OK Icon!") ; Asterisk/Exclamation/Info
	; MsgBox("text", "title", "OK IconI") ; Same as Icon!

	; First example has no parameters, all defaults:
	r := CustomMsgBox()

	; Next example is similar to standard MsgBox:
	r := CustomMsgBox("This is similar to the standard MsgBox.", "Custom MsgBox", "*&OK, &Cancel")

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
	r := CustomMsgBox(Text, Title, Buttons, GuiSize, ["","Black"], FontOpt, TextOpt " cWhite", IconCmd, SoundFile1)
	(r = "Cancel") ? ExitApp() : ''
	r := CustomMsgBox(Text, Title, Buttons, GuiSize, ["","Black"], FontOpt, TextOpt " cGreen", IconQuestion, SoundFile2)
	(r = "Cancel") ? ExitApp() : ''
	r := CustomMsgBox(Text, Title, Buttons, GuiSize, ["","Blue"], FontOpt, TextOpt " cWhite", IconError, SoundFile3)
	(r = "Cancel") ? ExitApp() : ''
	r := CustomMsgBox(Text, Title, Buttons, GuiSize, ["","White"], FontOpt, TextOpt " cRed", IconInfo, SoundFile4)

	ExitApp
}

