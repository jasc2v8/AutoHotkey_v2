#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
Escape::ExitApp()

#Include MsgBoxCustom.ahk

; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)

LorenIpsum := "Lorem ipsum dolor sit amet, consectetur adipiscing elit.`n`nEtiam laoreet nisl sed convallis consectetur."
LorenIpsum := "Lorem ipsum dolor sit amet, consectetur adipiscing elit."

global longMessage := unset
Loop 30
	longMessage .= Format("{:02}", A_Index) ": The quick brown fox jumps over the lazy dog.`n"

global shortMessage := unset
Loop 1
	shortMessage .= Format("{:02}", A_Index) ": The quick brown fox jumps over the lazy dog.`n"

MsgBoxCustom_Test()

return

; #Region Usage Examples

MsgBoxCustom_Test() {

    ; comment out to run tests
    ;SoundBeep(), ExitApp()

    #Warn Unreachable, Off

	global longMessage := unset
	Loop 30
	longMessage .= Format("{:02}", A_Index) ": The quick brown fox jumps over the lazy dog.`n"
	longMessage := SubStr(longMessage, 1, StrLen(longMessage)-1)

   ; #Region Test Selection
    ; comment out tests to skip:
	MsgBoxCustom_Test_All()
	; MsgBoxCustom_Test_Debug()
	; MsgBoxCustom_Test_Standard()
	; MsgBoxCustom_Test_Defaults()
	; MsgBoxCustom_Test_Alignment()
	; MsgBoxCustom_Test_Fonts()
	; MsgBoxCustom_Test_TextOpt()
	; MsgBoxCustom_Test_GuiOpt()
	; MsgBoxCustom_Test_GuiPos()
	; MsgBoxCustom_Test_Icons()
	; MsgBoxCustom_Test_Theme()
	; MsgBoxCustom_Test_Theme_ShortName()
	; MsgBoxCustom_Test_Buttons()
	; MsgBoxCustom_Test_Sounds()
}

MsgBoxCustom_Test_All() {
    ;MsgBoxCustom_Test_Debug()
    MsgBoxCustom_Test_Standard()
    MsgBoxCustom_Test_Defaults()
    MsgBoxCustom_Test_Alignment()
    MsgBoxCustom_Test_Fonts()
	MsgBoxCustom_Test_TextOpt()
    MsgBoxCustom_Test_GuiOpt()
	MsgBoxCustom_Test_GuiPos()
    MsgBoxCustom_Test_Icons()
    MsgBoxCustom_Test_Theme()
	;MsgBoxCustom_Test_Theme_ShortName()
    MsgBoxCustom_Test_Buttons()
    MsgBoxCustom_Test_Sounds()
}

MsgBoxCustom_Test_Defaults() {

    ; First example has no parameters, all defaults:
	r := Msg("The next test will be a Custom MsgBox with all Defaults.", "Testing Defaults")

	r := Msg()

	; Next example is similar to standard MsgBox:
    Text := "This is similar to the standard MsgBox.Note the buttons are centered."
    Title := "Custom MsgBox"
    r := Msg(Text, Title,"Default &OK, &Cancel, AlignCenter")

    Text := "This is similar to the standard MsgBox. Note the border around the text." "`n`n" .
			"Press any button to see the result:"
    Title := "Custom MsgBox with Border"
    r := Msg(Text, Title,"Default &OK, &Abort, &Cancel, AlignCenter",,,,"Border")

    Msg("Finished Testing Defaults`n`nYou pressed: " r)

}
MsgBoxCustom_Test_Fonts() {

	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
	Text := "`n`nPress OK or Abort, or Cancel to Break this Loop."
	Title := "🡸 Note the Icon for this Theme"
	Buttons := "Default &Continue, &Cancel, "

    Loop {

		Title := "Testing: Fonts"
		Buttons := "Default &OK, &Abort, &Cancel, AlignCenter"
		Size := "" ; ""300,100,,"
		
		TextFont := "Default"
		ButtonFont := "Default"
		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
;		r := Msg(TextLine, Title, Buttons)
		r := Msg(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break

		TextFont := "s14, Courier New"
		ButtonFont := "s14, Gabriola"
		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
		r := Msg(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break

		TextFont := "s14, Consolas"
		ButtonFont := "Default"
		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
		r := Msg(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break

		TextFont := "s11, Times New Roman" ;Cascadia Code
		ButtonFont := "s11, Impact"
		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
		r := Msg(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break
	}
}
MsgBoxCustom_Test_TextOpt() {
	TextLine := "TextOpt: Center`n`nNote this text is Centered."
	Title := "Testing: TextOpt"
	Buttons := "Default &OK, &Abort, &Cancel, AlignCenter"
	Size := "" ; ""300,100,,"
	TextFont := "s14, Consolas"
	TextOpt := "Center"
	ButtonFont := "Default"
	;TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
	r := Msg(TextLine, Title,Buttons,Size,,,TextOpt,TextFont,ButtonFont)
	; if (r = "&Abort") OR (r = "&Cancel")
	; 	Break

	TextOpt := "Border Center"
	TextLine := "TextOpt: Border Center`n`nNote this text is Centered with a Border."
	r := Msg(TextLine, Title,Buttons,Size,,,TextOpt,TextFont,ButtonFont)

	TextOpt := "Right"
	TextLine := "TextOpt: " TextOpt "`n`nNote this text is Right justified."
	r := Msg(TextLine, Title,Buttons,Size,,,TextOpt,TextFont,ButtonFont)

	TextOpt := "Left"
	TextLine := "TextOpt: " TextOpt "`n`nNote this text is Left justified."
	r := Msg(TextLine, Title,Buttons,Size,,,TextOpt,TextFont,ButtonFont)


}

MsgBoxCustom_Test_Standard() {
	MsgBox("The next Gui will be a Standard MsgBox with Defaults", "Test: Standard MsgBox")
	MsgBox()
	MsgBox("This is a Standard MsgBox with OKCancel", "Test: Standard MsgBox", "OKCancel")
	MsgBox(LongMessage, "Standard MsgBox")
}
MsgBoxCustom_Test_Buttons() {

	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)

	;MsgBox("text", "title", "YesNoCancel")

	Title := "Test Buttons"

	ButtonAlign := "AlignLeft"
	count := 1

    Loop {

		switch count {
			case 1:
				ButtonAlign := "AlignLeft"
			case 2:
				ButtonAlign := "AlignCenter"	
			case 3:
				ButtonAlign := "AlignRight"
				
		}

		;MsgBox() ; compare with standard
		ButtonsMax := 20
		Icon := "C:\Windows\System32\shell32.dll, Icon315" ; large cog

		Text := "Button # 1 of " ButtonsMax "`n`nPress OK to continue."
		Buttons := "Default &OK,"  ButtonAlign
		r := Msg(Text, Title, Buttons,,,,,,,Icon)

		Text := "Button # 2 of " ButtonsMax "`n`nPress Cancel to Break this Loop."
		Buttons := "Default &OK, Cancel, " ButtonAlign
		r := Msg(Text, Title, Buttons,,,,,,,Icon)
      	if (r = "Cancel")
           	Break 1

		Loop ButtonsMax-2 {
			Text :=  "`n" "Button # " A_Index+2 " of " ButtonsMax "`n`nPress Cancel to Break this Loop."
			Buttons .= ", Btn" A_Index + 2
			r := Msg(Text, Title, Buttons,,,,,,,Icon)
        	if (r = "Cancel")
            	Break 2
		}
		count++
		count := (count > 3) ? 1 : count
	
    }
}

MsgBoxCustom_Test_Theme() {

	;TODO MB, MBM, MBP, MBT
	
	Text := "`n`nPress Continue or Cancel to Break this Loop."
	Title := "🡸 Note the Icon for this Theme"
	Buttons := "Default &Continue, &Cancel, "

	Loop {

		Msg(, "Theme: Standard")

		r := Msg(longMessage, "Custom Theme: Standard Window", Buttons . "AlignCenter")
		if (r = "&Cancel")
		Break

		r := MsgCmd(longMessage, "Custom Theme: Command Window", Buttons . "AlignLeft")
		if (r = "&Cancel")
		Break

		r := MsgMatrix(longMessage, "Custom Theme: Matrix", Buttons . "AlignCenter")
		if (r = "&Cancel")
		Break

		r := MsgTerminal(longMessage, "Custom Theme: Terminal", Buttons . "AlignRight")
		if (r = "&Cancel")
		Break

	}
}

MsgBoxCustom_Test_Theme_ShortName() {
	Text := "`n`nPress Continue or Cancel to Break this Loop."
	Title := "🡸 Note the Icon for this Theme (Short Name)"
	Buttons := "Default &Continue, &Cancel, "

	Loop {

		Msg(, "Theme: Standard")

		r := MsgC(longMessage, Title, Buttons . "AlignLeft")
		if (r = "&Cancel")
		Break

		r := MsgM(longMessage, Title, Buttons . "AlignCenter")
		if (r = "&Cancel")
		Break

		r := MsgT(longMessage, Title, Buttons . "AlignRight")
		if (r = "&Cancel")
		Break

	}

}
MsgBoxCustom_Test_Icons() {

	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)

	Text := "Press Continue or Cancel to Break this Loop."
    Title := "🡸  "
	Size := "" ;"300,100,,"
	Buttons := "Default &Continue, &Cancel"
    TextFont := "s11, Consolas" ; w700

	Loop {

		Icon := ""
		r := Msg(Text, Title "Testing Icons: No Icon", Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break

		; Show standard MsgBox Icons
		Icon := "IconX"
		r := Msg(Text, Title "Testing Icons: " Icon,Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break

		; Show standard MsgBox Icons
		Icon := "Icon?"
		r := Msg(Text, Title "Testing Icons: " Icon,Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break
				; Show standard MsgBox Icons

		Icon := "Icon!"
		r := Msg(Text, Title "Testing Icons: " Icon,Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break

		Icon := "Iconi"
		r := Msg(Text, Title "Testing Icons: " Icon,Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break

		; Show custom icon from icon file, number
		Icon := "C:\Windows\System32\user32.dll, Icon7"
		r := Msg(Text, Title "From File:  " icon,Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break
	}
}
MsgBoxCustom_Test_Alignment() {

	LorenIpsum := "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam laoreet nisl sed convallis consectetur."
	TextLine := LorenIpsum "`n`nPress Abort or Cancel to Break this Loop." ;

	; test Align Left, Center, Right
    Buttons := "Default &OK, &Abort, &Cancel, "
    
	Loop {
		align := "AlignLeft"
		r := Msg(TextLine, "Test Layout:  " align, Buttons . align)
        if (r = "&Abort") OR (r = "&Cancel")
            Break

		align := "AlignCenter"
		r := Msg(TextLine, "Test Layout:  " align, Buttons . align)
        if (r = "&Abort") OR (r = "&Cancel")
			Break

		align := "AlignRight"
		r := Msg(TextLine, "Test Layout:  " align, Buttons . align)
        if (r = "&Abort") OR (r = "&Cancel")
            Break
	}
}

MsgBoxCustom_Test_Sounds() {

	Text := "Press Continue or Cancel to Break this Loop."
    Title := "Test Sounds"
    TextFont := "s12, Consolas" ; w700
    Buttons := "Default &OK, &Cancel, AlignCenter"
    Icons := ",IconX, Icon!, Icon?, Iconi"
	Size := "" ; "300,100"

    Loop {
        Loop Parse Icons, "," {
            i := Trim(A_LoopField)
            s := (i = "") ? "Default (No Sound)" : i
            TextLine := "Sound: " s "`n`n" Text
            Icon := i
            Sound := Icon
            r := Msg(TextLine, Title, Buttons, Size,,,,TextFont,,Icon, Sound)
            if (r = "&Cancel")
                Break 2
        }
    }

    Text  := "Sound: Tada!"
	Size  := "300,60"
    Icon  := "C:\Windows\System32\imageres.dll, Icon229" ; 229=Green Check Circle
    Sound := "C:\Windows\Media\tada.wav"
	BackColor := "26ff00"
	TextOpt := "cRed"
	TextFont := "s14, Impact"
    Msg(Text, Title,, Size,,BackColor,TextOpt,TextFont,,Icon, Sound)
}

MsgBoxCustom_Test_GuiOpt() {
	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
 	; just examples, not actually used together. Reize doesn't redraw the gui, just for demo here
    Opt := "+AlwaysOnTop +MinimizeBox +Resize +Owner +OwnDialogs"
    Text := "GuiOpt: " Opt .
		"`n`nResize is just for demo, it won't actually resize the Gui." .
		"`n`nCick on a different Window and note that this Message Box remains on top."
    Title := "Test GuiOpt AlwaysOnTop"
    Buttons := "Default &OK, &Cancel, AlignCenter"
	Size := "" ; "400,200"
	TextFont := "s11, Consolas"
    r := Msg(Text, Title, Buttons, Size, Opt,,,TextFont)
	(r = "&OK") ? nop:=true : Exit
}
MsgBoxCustom_Test_GuiPos() {

	sw := A_ScreenWidth
	sh := A_ScreenHeight
	
	Text := "Press Continue or Cancel to Break this Loop."
    Title := "Test Position"
    Buttons := "Default &Continue, &Cancel, AlignCenter"
	SizeArray := [	"",",,20,20", 
					",," sw-500 ",20",
					",,20, " sh-250 ,
					",," sw-500 "," sh-250]
    TextFont := "s12, Consolas"
    Icons := ",IconX, Icon!, Icon?, Iconi"

    Loop {
		for size in SizeArray {
            i := Trim(A_LoopField)
            Icon := "Iconi"
            Sound := (A_Index = 1) ? Icon : ""
            r := Msg(Text, Title, Buttons, size,,,,TextFont,,Icon, Sound)
            if (r = "&Cancel")
                Break 2
        }
    }
}
MsgBoxCustom_Test_Debug() {


	Buttons := "Default &OK, Cancel"
	r := Msg("Press OK.", "Debug", Buttons)
	r := MsgC("Press OK.", "Debug", Buttons)
	r := MsgM("Press OK.", "Debug", Buttons)
	r := MsgT("Press OK.", "Debug", Buttons)
	r := Msg("Press OK.", "Debug", Buttons,,,"Yellow",,,,"Icon?")

	;r := Msg(, A_ScriptName,,,,,"Border")
	ButtonAlignment := "AlignLeft"
	;ButtonAlignment := "AlignCenter"
	;ButtonAlignment := "AlignRight"
	
	Buttons := "Default &OK, Cancel, " ButtonAlignment
	;Buttons := "Default &OK, Cancel, AlignLeft"
	;Buttons := "Default &OK, Cancel, AlignCenter"
	;Buttons := "Default &OK, Cancel, AlignRight"
	ButtonsContinue := "Default &Continue, Abort, " ButtonAlignment
	ButtonsExit := "Default &Exit, " ButtonAlignment

	r := Msg("Press OK.", "Debug", Buttons)

	r := Msg("Return value: " r, "Debug", ButtonsContinue)
	(r != "&Continue") ? ExitApp() : nop:=true

	r := Msg("Press Cancel.", "Debug", Buttons)

	r := Msg("Return value: " r, "Debug", ButtonsContinue)
	(r != "&Continue") ? ExitApp() : nop:=true

	r := Msg("Press Escape.", "Debug", Buttons)

	r := Msg("Return value: " r, "Debug", ButtonsContinue)
	(r != "&Continue") ? ExitApp() : nop:=true

	r := Msg("Press Close Button [X].", "Debug", " ")

	r := Msg("Return value: " r, "Debug", ButtonsContinue)
	(r != "&Continue") ? ExitApp() : nop:=true

	r := Msg("End of Demo.", "Debug", ButtonsExit)

	return

	Title 	        := "Close All Windows"
	Text 	        := "Press Start to close all open windows...`ntwo`nthree"
	Buttons	        := "Default &Start, &Cancel"
	Size            := "300, 168, 10, 10"
	Opt	            := "+AlwaysOnTop"
	BackColor       := "4682B4"
	TextOpt	        := "Background cWhite -Wrap Border"
	TextFontOpt     := "s11", "Cascadia Mono"
	ButtonFontOpt   := "s8", "Segoe UI"
	IconQ           := "C:\Windows\System32\user32.dll, Icon3"
	IconI       	:= "C:\Windows\System32\user32.dll, Icon5"
	Icon            := IconQ
	Sound           := ""

	r := MsgT(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)

	;return
    ;MsgBox "test"

    Buttons := "Default &OK, &Cancel, &Abort, AlignCenter"
    r := Msg("Starting Test_Debug...", "Test: Debug", Buttons,,"+AlwaysOnTop")
	(r = "&OK") ? nop:=true : ExitApp()

    r := Msg("Test Opt(+AlwaysOnTop)...", "Test: AlwaysOnTop", Buttons,,"+AlwaysOnTop")
	(r = "&OK") ? nop:=true : ExitApp()

    #Warn Unreachable, Off

	MsgBox(shortMessage, "Standard MsgBox")
	Msg(shortMessage, "Msg")
	MsgM(shortMessage, "MsgM")
	MsgT(shortMessage, "MsgT")
	MsgC(shortMessage, "MsgC")

	MsgBox(longMessage, "Standard MsgBox")
	r := Msg(longMessage, "Theme: Custom MsgBox")
	r := MsgM(longMessage "`nYou typed: " r, "Theme: Matrix", Buttons)
	r := MsgT(longMessage "`nYou typed: " r, "Theme: PowerShell", Buttons)
	r := MsgC(longMessage "`nYou typed: " r, "Theme: Terminal", Buttons)
}