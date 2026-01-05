#Requires AutoHotkey v2.0+

; DEBUG
#SingleInstance Force
#NoTrayIcon
; Escape::ExitApp()

#Include MsgBoxEx.ahk
MsgBoxEx_Example()

; #Region Usage Examples

MsgBoxEx_Example() {

    ; comment out to run tests
    ;SoundBeep(), ExitApp()

    #Warn Unreachable, Off

	; Set an Alias for easier typing
	;obj := MsgBoxEx()
	global MB := ObjBindMethod(MsgBoxEx(), 'Show')

   ; TestButtons:="Default &OK, &Abort, &Cancel, AlignRight"

   global longMessage := unset
   Loop 30
    longMessage .= Format("{:02}", A_Index) ": The quick brown fox jumps over the lazy dog.`n"

   ; MsgBoxEx(longMessage, "TEST", TestButtons)

   ; #Region Test Selection

    ; comment out tests to skip:
	;MsgBoxEx_Example_All()
	; MsgBoxEx_Example_Debug()
	; MsgBoxEx_Example_Standard()
	; MsgBoxEx_Example_Defaults()
	; MsgBoxEx_Example_Fonts()
	; MsgBoxEx_Example_GuiOpt()
	 MsgBoxEx_Example_GuiPos()
	; MsgBoxEx_Example_ShortName()
	; MsgBoxEx_Example_FullName()
	; MsgBoxEx_Example_Layouts()
	; MsgBoxEx_Example_Icons()
	; MsgBoxEx_Example_Sounds()
}
MsgBoxEx_Example_All() {
    ;MsgBoxEx_Example_Debug()
    MsgBoxEx_Example_Standard()
    MsgBoxEx_Example_Defaults()
    MsgBoxEx_Example_Fonts()
    MsgBoxEx_Example_GuiOpt()
	MsgBoxEx_Example_GuiPos()
    MsgBoxEx_Example_ShortName()
    MsgBoxEx_Example_FullName()
    MsgBoxEx_Example_Layouts()
    MsgBoxEx_Example_Icons()
    MsgBoxEx_Example_Sounds()
}

MsgBoxEx_Example_Defaults() {

    ; First example has no parameters, all defaults:
	r := MB()

	; Next example is similar to standard MsgBox:
    Text := "This is similar to the standard MsgBox.Note the buttons are centered."
    Title := "Custom MsgBox"
    r := MB(Text, Title,"Default &OK, &Cancel, AlignCenter")

    Text := "This is similar to the standard MsgBox. Note the border around the text." "`n`n" .
			"Press any button to see the result:"
    Title := "Custom MsgBox with Border"
    r := MB(Text, Title,"Default &OK, &Abort, &Cancel, AlignCenter",,,,"Border")

    MB("You pressed: " r)

}
MsgBoxEx_Example_Fonts() {

	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
	Text := "`n`nPress OK or Abort, or Cancel to Break this Loop."
	Title := "🡸 Note the Icon for this style"
	Buttons := "Default &Continue, &Cancel, "

    Loop {

		Title := "Testing: Fonts"
		Buttons := "Default &OK, &Abort, &Cancel, AlignCenter"
		Size := "" ; ""300,100,,"
		
		TextFont := "Default"
		ButtonFont := "Default"
		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
;		r := MB(TextLine, Title, Buttons)
		r := MB(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break

		TextFont := "s14, Courier New"
		ButtonFont := "s14, Gabriola"
		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
		r := MB(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break

		TextFont := "s14, Consolas"
		ButtonFont := "Default"
		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
		r := MB(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break

		TextFont := "s11, Times New Roman" ;Cascadia Code
		ButtonFont := "s11, Impact"
		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
		r := MB(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break
	}
}

MsgBoxEx_Example_Standard() {
	MsgBox()
	MsgBox("This is a Standard MsgBox with OK", "Standard MsgBox")
	MsgBox("This is a Standard MsgBox with OKCancel", "Standard MsgBox", "OKCancel")
	MsgBox(LongMessage, "Standard MsgBox")
}
MsgBoxEx_Example_FullName() {

	;TODO MsgBoxMatrix, MsgBoxPowershell, MsgBoxTerminal (MBM, MBP, MBT?)
	
	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
	Text := "`n`nPress Continue or Cancel to Break this Loop."
	Title := "🡸 Note the Icon for this style"
	Buttons := "Default &Continue, &Cancel, "

    Loop {

		r := MB(longMessage . Text, Title, Buttons . "AlignLeft",,,,,,,"IconX")
        if (r = "&Cancel")
            Break

        r := MB(longMessage . Text, Title, Buttons . "AlignCenter",,,,,,,"Icon?")
        if (r = "&Cancel")
            Break

        r := MB(longMessage . Text, Title, Buttons . "AlignRight",,,,,,,"Icon!")
        if (r = "&Cancel")
            Break

        r := MB(longMessage . Text, Title, Buttons . "AlignCenter",,,,,,,"Iconi")
        if (r = "&Cancel")
            Break
    }
}

MsgBoxEx_Example_ShortName() {

	;TODO MB, MBM, MBP, MBT
	
	Text := "`n`nPress Continue or Cancel to Break this Loop."
	Title := "🡸 Note the Icon for this style"
	Buttons := "Default &Continue, &Cancel, "

	Loop {

		MB()

		r := MB(longMessage, "Custom Title", Buttons . "AlignLeft")
		if (r = "&Cancel")
		Break

		r := MB(longMessage, "Custom Title", Buttons . "AlignCenter")
		if (r = "&Cancel")
		Break

		r := MB(longMessage, "Custom Title", Buttons . "AlignRight")
		if (r = "&Cancel")
		Break

	}
}

MsgBoxEx_Example_Icons() {

	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)

	Text := "Press Continue or Cancel to Break this Loop."
    Title := "🡸  "
	Size := "" ;"300,100,,"
	Buttons := "Default &Continue, &Cancel"
    TextFont := "s11, Consolas" ; w700

	Loop {

		Icon := ""
		r := MB(Text, Title "(No Icon)", Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break

		; Show standard MsgBox Icons
		Icon := "Icon!"
		r := MB(Text, Title "Icon!",Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break

		; Show custom icon from icon file, number
		Icon := "C:\Windows\System32\user32.dll, Icon7"
		r := MB(Text, Title "From File:  " icon,Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break
	}
}

MsgBoxEx_Example_Layouts() {

	;DEBUG
	;r:=Mx_Example.Show("TEST")

	LorenIpsum := "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam laoreet nisl sed convallis consectetur."
	msg := LorenIpsum "`n`nPress Abort or Cancel to Break this Loop." ;

	; test Align Left, Center, Right
    Buttons := "Default &OK, &Abort, &Cancel, "
    
	Loop {
		align := "AlignLeft"
		r := MB(msg, "Test Layout:  " align, Buttons . align)
        if (r = "&Abort") OR (r = "&Cancel")
            Break

		align := "AlignCenter"
		r := MB(msg, "Test Layout:  " align, Buttons . align)
        if (r = "&Abort") OR (r = "&Cancel")
			Break

		align := "AlignRight"
		r := MB(msg, "Test Layout:  " align, Buttons . align)
        if (r = "&Abort") OR (r = "&Cancel")
            Break
	}
}

MsgBoxEx_Example_Sounds() {

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
            r := MB(TextLine, Title, Buttons, Size,,,,TextFont,,Icon, Sound)
            if (r = "&Cancel")
                Break 2
        }
    }

    Text  := "Sound: Tada"
	Size  := "300,60"
    Icon  := "C:\Windows\System32\imageres.dll, Icon229" ; 229=Green Check Circle
    Sound := "C:\Windows\Media\tada.wav"
    MB(Text, Title,, Size,,,,TextFont,,Icon, Sound)
}

MsgBoxEx_Example_GuiOpt() {
	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
 	; just examples, not actually used together
	; Reize does not redraw the gui, just for demo here
    Opt := "+AlwaysOnTop +MinimizeBox +Resize +OwnDialogs +OwnDialogs"
    Text := "GuiOpt: " Opt "`n`nCick on a different Window and note that this Message Box remains on top."
    Title := "Test GuiOpt AlwaysOnTop"
    Buttons := "Default &OK, &Cancel, AlignCenter"
	Size := "" ; "400,200"
	TextFont := "s11, Consolas"
    r := MB(Text, Title, Buttons, Size, Opt,,,TextFont)
	(r = "&OK") ? nop:=true : Exit
}
MsgBoxEx_Example_GuiPos() {

	sw := A_ScreenWidth
	sh := A_ScreenHeight
	
	Text := "Press Continue or Cancel to Break this Loop."
    Title := "Test Position"
    Buttons := "Default &Continue, &Cancel, AlignCenter"
	SizeArray := [	"",",,20,20", 
					",," sw-500 ",20",
					",,20, " sh-250 ,
					",," sw-500 "," sh-250] ; "300,100"
    TextFont := "s12, Consolas" ; w700
    Icons := ",IconX, Icon!, Icon?, Iconi"

    Loop {
		for size in SizeArray {
            i := Trim(A_LoopField)
            Icon := "Iconi"
            Sound := Icon
            r := MB(Text, Title, Buttons, size,,,,TextFont,,Icon, Sound)
            if (r = "&Cancel")
                Break 2
        }
    }
}
MsgBoxEx_Example_Debug() {

    ;MsgBox "test"

    Buttons := "Default &OK, &Cancel"
    r := MB("Starting Test_Debug...", "Test: Debug", Buttons,,"+AlwaysOnTop")
	(r = "&OK") ? nop:=true : ExitApp()

    r := MB("Test Opt(+AlwaysOnTop)...", "Test: AlwaysOnTop", Buttons,,"+AlwaysOnTop")
	(r = "&OK") ? nop:=true : ExitApp()

    
    #Warn Unreachable, Off
    return

}
