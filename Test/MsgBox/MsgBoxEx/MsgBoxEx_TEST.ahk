#Requires AutoHotkey v2.0+

#SingleInstance Force
#NoTrayIcon
Escape::ExitApp()

#Include MsgBoxEx.ahk

; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)

; class MBM {

;     static Buttons := "Default &OK, AlignCenter"
;     static BackColor := "Blue"
;     static TextFontOpt := "s11 cWhite, Consolas"
;     static Icon  := "C:\Windows\System32\imageres.dll, Icon313" ; PS prompt with user

; 	;static Show(Text:="",Title:=""){
;  	static Show(Text:="",Title:="",Buttons:=this.Buttons,Size:="", Opt:="",BackColor:=this.BackColor,
;  	 			TextOpt:="",TextFontOpt:=this.TextFontOpt,ButtonFontOpt:="",Icon:=this.Icon,Sound:=""){

; 		MsgBoxEx.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
; 	}
; }
;MsgBoxPowerShell
;MsgBoxPS
;MBPS
MsgBoxCustom
;MBMatrix
;MBM
;MBPowerShell
;MBP
;MBTerminal
;MBT
Msg
;Msg()
;MsgM
;MsgP
;MsgT

;MBox()
;MBoxM()
;MBoxP()
;MBoxT()

DefineProp

MBCustom("Hello World!", "MBCustom",,Size)
MBC("Hello World!", "MBC",,Size)

;MBMatrix("Hello World!", "MBMatrix",,Size)
MBM("Hello World!", "MBMatrix",,Size)

;MBM("Hello World!", "MBM",,Size)

MsgBox("Hello World!", "Standard MsgBox")

MsgBoxCustom.Show("Hello World!", "MsgBoxEx Base",,Size)
MBC("Hello World!", "MBC = Custom",,Size)
MBM.Show("Hello World!", "MBM = Matrix",,Size)
MBP.Show("Hello World!", "MBP = PowerShell",,Size)
MBT.Show("Hello World!", "MBT = Terminal",,Size)

MsgBoxCustom_Test()

; #Region Usage Examples

MsgBoxCustom_Test() {

    ; comment out to run tests
    ;SoundBeep(), ExitApp()

    #Warn Unreachable, Off

	; Set an Alias for easier typing
	;obj := MsgBoxCustom()
	;global MB := ObjBindMethod(obj, 'Show')

   ; TestButtons:="Default &OK, &Abort, &Cancel, AlignRight"

   global longMessage := unset
   Loop 30
    longMessage .= Format("{:02}", A_Index) ": The quick brown fox jumps over the lazy dog.`n"

   ; MsgBoxCustom(longMessage, "TEST", TestButtons)

   ; #Region Test Selection

    ; comment out tests to skip:
	;MsgBoxCustom_Test_All()
	; MsgBoxCustom_Test_Debug()
	; MsgBoxCustom_Test_Standard()
	; MsgBoxCustom_Test_Defaults()
	; MsgBoxCustom_Test_Fonts()
	; MsgBoxCustom_Test_GuiOpt()
	; MsgBoxCustom_Test_GuiPos()
	; MsgBoxCustom_Test_ShortName()
	; MsgBoxCustom_Test_FullName()
	; MsgBoxCustom_Test_Layouts()
	; MsgBoxCustom_Test_Icons()
	; MsgBoxCustom_Test_Sounds()
}
MsgBoxCustom_Test_All() {
    ;MsgBoxCustom_Test_Debug()
    MsgBoxCustom_Test_Standard()
    MsgBoxCustom_Test_Defaults()
    MsgBoxCustom_Test_Fonts()
    MsgBoxCustom_Test_GuiOpt()
	MsgBoxCustom_Test_GuiPos()
    MsgBoxCustom_Test_ShortName()
    MsgBoxCustom_Test_FullName()
    MsgBoxCustom_Test_Layouts()
    MsgBoxCustom_Test_Icons()
    MsgBoxCustom_Test_Sounds()
}

MsgBoxCustom_Test_Defaults() {

    ; First example has no parameters, all defaults:
	r := MBC()

	; Next example is similar to standard MsgBox:
    Text := "This is similar to the standard MsgBox.Note the buttons are centered."
    Title := "Custom MsgBox"
    r := MBC(Text, Title,"Default &OK, &Cancel, AlignCenter")

    Text := "This is similar to the standard MsgBox. Note the border around the text." "`n`n" .
			"Press any button to see the result:"
    Title := "Custom MsgBox with Border"
    r := MBC(Text, Title,"Default &OK, &Abort, &Cancel, AlignCenter",,,,"Border")

    MBC("You pressed: " r)

}
MsgBoxCustom_Test_Fonts() {

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
;		r := MBC(TextLine, Title, Buttons)
		r := MBC(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break

		TextFont := "s14, Courier New"
		ButtonFont := "s14, Gabriola"
		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
		r := MBC(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break

		TextFont := "s14, Consolas"
		ButtonFont := "Default"
		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
		r := MBC(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break

		TextFont := "s11, Times New Roman" ;Cascadia Code
		ButtonFont := "s11, Impact"
		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
		r := MBC(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
		if (r = "&Abort") OR (r = "&Cancel")
			Break
	}
}

MsgBoxCustom_Test_Standard() {
	MsgBox()
	MsgBox("This is a Standard MsgBox with OK", "Standard MsgBox")
	MsgBox("This is a Standard MsgBox with OKCancel", "Standard MsgBox", "OKCancel")
	MsgBox(LongMessage, "Standard MsgBox")
}
MsgBoxCustom_Test_FullName() {

	;TODO MsgBoxMatrix, MsgBoxPowershell, MsgBoxTerminal (MBM, MBP, MBT?)
	
	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
	Text := "`n`nPress Continue or Cancel to Break this Loop."
	Title := "🡸 Note the Icon for this style"
	Buttons := "Default &Continue, &Cancel, "

    Loop {

		r := MBC(longMessage . Text, Title, Buttons . "AlignLeft",,,,,,,"IconX")
        if (r = "&Cancel")
            Break

        r := MBC(longMessage . Text, Title, Buttons . "AlignCenter",,,,,,,"Icon?")
        if (r = "&Cancel")
            Break

        r := MBC(longMessage . Text, Title, Buttons . "AlignRight",,,,,,,"Icon!")
        if (r = "&Cancel")
            Break

        r := MBC(longMessage . Text, Title, Buttons . "AlignCenter",,,,,,,"Iconi")
        if (r = "&Cancel")
            Break
    }
}

MsgBoxCustom_Test_ShortName() {

	;TODO MB, MBM, MBP, MBT
	
	Text := "`n`nPress Continue or Cancel to Break this Loop."
	Title := "🡸 Note the Icon for this style"
	Buttons := "Default &Continue, &Cancel, "

	Loop {

		MBC()

		r := MBC(longMessage, "Custom Title", Buttons . "AlignLeft")
		if (r = "&Cancel")
		Break

		r := MBC(longMessage, "Custom Title", Buttons . "AlignCenter")
		if (r = "&Cancel")
		Break

		r := MBC(longMessage, "Custom Title", Buttons . "AlignRight")
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
		r := MBC(Text, Title "(No Icon)", Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break

		; Show standard MsgBox Icons
		Icon := "Icon!"
		r := MBC(Text, Title "Icon!",Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break

		; Show custom icon from icon file, number
		Icon := "C:\Windows\System32\user32.dll, Icon7"
		r := MBC(Text, Title "From File:  " icon,Buttons,Size,,,,TextFont,,Icon)
		if (r = "&Cancel")
			Break
	}
}

MsgBoxCustom_Test_Layouts() {

	;DEBUG
	;r:=MB_TEST.Show("TEST")

	LorenIpsum := "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam laoreet nisl sed convallis consectetur."
	msg := LorenIpsum "`n`nPress Abort or Cancel to Break this Loop." ;

	; test Align Left, Center, Right
    Buttons := "Default &OK, &Abort, &Cancel, "
    
	Loop {
		align := "AlignLeft"
		r := MBC(msg, "Test Layout:  " align, Buttons . align)
        if (r = "&Abort") OR (r = "&Cancel")
            Break

		align := "AlignCenter"
		r := MBC(msg, "Test Layout:  " align, Buttons . align)
        if (r = "&Abort") OR (r = "&Cancel")
			Break

		align := "AlignRight"
		r := MBC(msg, "Test Layout:  " align, Buttons . align)
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
            r := MBC(TextLine, Title, Buttons, Size,,,,TextFont,,Icon, Sound)
            if (r = "&Cancel")
                Break 2
        }
    }

    Text  := "Sound: Tada"
	Size  := "300,60"
    Icon  := "C:\Windows\System32\imageres.dll, Icon229" ; 229=Green Check Circle
    Sound := "C:\Windows\Media\tada.wav"
    MBC(Text, Title,, Size,,,,TextFont,,Icon, Sound)
}

MsgBoxCustom_Test_GuiOpt() {
	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
 	; just examples, not actually used together
	; Reize does not redraw the gui, just for demo here
    Opt := "+AlwaysOnTop +MinimizeBox +Resize +OwnDialogs +OwnDialogs"
    Text := "GuiOpt: " Opt "`n`nCick on a different Window and note that this Message Box remains on top."
    Title := "Test GuiOpt AlwaysOnTop"
    Buttons := "Default &OK, &Cancel, AlignCenter"
	Size := "" ; "400,200"
	TextFont := "s11, Consolas"
    r := MBC(Text, Title, Buttons, Size, Opt,,,TextFont)
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
					",," sw-500 "," sh-250] ; "300,100"
    TextFont := "s12, Consolas" ; w700
    Icons := ",IconX, Icon!, Icon?, Iconi"

    Loop {
		for size in SizeArray {
            i := Trim(A_LoopField)
            Icon := "Iconi"
            Sound := Icon
            r := MBC(Text, Title, Buttons, size,,,,TextFont,,Icon, Sound)
            if (r = "&Cancel")
                Break 2
        }
    }
}
MsgBoxCustom_Test_Debug() {

    ;MsgBox "test"

    Buttons := "Default &OK, &Cancel"
    r := MBC("Starting Test_Debug...", "Test: Debug", Buttons,,"+AlwaysOnTop")
	(r = "&OK") ? nop:=true : ExitApp()

    r := MBC("Test Opt(+AlwaysOnTop)...", "Test: AlwaysOnTop", Buttons,,"+AlwaysOnTop")
	(r = "&OK") ? nop:=true : ExitApp()

    
    #Warn Unreachable, Off
    return

}