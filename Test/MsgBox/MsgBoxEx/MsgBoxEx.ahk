; ABOUT: Custom MsgBox as a Static Class

/**
 * TODO:
 *  - Align the text in the Text control Vertically.
 *  - Get actual colors for Black and Blue Backgrounds: AhkSpy
 * 
 *  MsgBoxCustom.ahk
 *      MBC()
 *      MBM()
 *      MBP()
 *      MBT()
 */

#Requires AutoHotkey v2.0+

MBCustom(Text:="",Title:="",Buttons:="", Size:="", Opt:="",BackColor:=BackColor:="",
 	 			TextOpt:="",TextFontOpt:=TextFontOpt:="",ButtonFontOpt:="",Icon:="", Sound:="") {
	    return MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
}
MBC(Text:="",Title:="",Buttons:="", Size:="", Opt:="",BackColor:=BackColor:="",
 	 			TextOpt:="",TextFontOpt:=TextFontOpt:="",ButtonFontOpt:="",Icon:="", Sound:="") {
	    return MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
}

MBM(Text:="",Title:="",Buttons:="", Size:="", Opt:="",BackColor:=BackColor:="",
 	 			TextOpt:="",TextFontOpt:=TextFontOpt:="",ButtonFontOpt:="",Icon:="", Sound:="") {
	    return MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
}
class MBC_old {
    ; Custom
 	static Show(Text:="",Title:="",Buttons:="", Size:="", Opt:="",BackColor:=BackColor:="",
 	 			TextOpt:="",TextFontOpt:=TextFontOpt:="",ButtonFontOpt:="",Icon:="", Sound:=""){
	    MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
	}
}
class MBM_OLD {
    ; Matrix Theme
    static Buttons := "Default &OK, AlignCenter"
    static BackColor := "0x0C0C0C" ;"Black"
    static TextFontOpt := "s11 cGreen, Consolas"
    static Icon := "C:\Windows\System32\imageres.dll, Icon145" ; Terminal with green graph   
 	static Show(Text:="",Title:="",Buttons:=this.Buttons,Size:="", Opt:="",BackColor:=this.BackColor,
 	 			TextOpt:="",TextFontOpt:=this.TextFontOpt,ButtonFontOpt:="",Icon:=this.Icon,Sound:=""){
	    MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
	}
}

class MBP {
    ; Powershell Theme
    static Buttons := "Default &OK, AlignCenter"
    static BackColor := "0x457AD5" ; "Blue"
    static TextFontOpt := "s11 cWhite, Consolas"
    static Icon  := "C:\Windows\System32\imageres.dll, Icon313" ; PS prompt with user
 	static Show(Text:="",Title:="",Buttons:=this.Buttons,Size:="", Opt:="",BackColor:=this.BackColor,
 	 			TextOpt:="",TextFontOpt:=this.TextFontOpt,ButtonFontOpt:="",Icon:=this.Icon,Sound:=""){
	    MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
	}
}
class MBT {
    ; Terminal Theme
    static Buttons := "Default &OK, AlignCenter"
    static BackColor := "Black"
    static TextFontOpt := "s11 cWhite, Consolas"
    static Icon := "C:\Windows\System32\imageres.dll, Icon265" ; cmd prompt with user 
 	static Show(Text:="",Title:="",Buttons:=this.Buttons,Size:="", Opt:="",BackColor:=this.BackColor,
 	 			TextOpt:="",TextFontOpt:=this.TextFontOpt,ButtonFontOpt:="",Icon:=this.Icon,Sound:=""){
	    MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
	}
}

; return
;---------------------------------------------------------------------------------------------------
; Purpose: Custom MsgBox with options, icons, sounds, and context menu.
;---------------------------------------------------------------------------------------------------
 class MsgBoxCustom
{
	Result := ""

	;---------------------------------------------------------------------------------------------------
	; Purpose: Custom MsgBox with options, icons, sounds, and context menu.
	; Returns: A String with the text from the button pressed.
	; Context: Right-click to copy the text to the clipboard.
	; License: The Unlicense: https://unlicense.org/
	; Params :(Text,Title,Buttons,Size,Opt,BackColor,TextOpt,TextFontOpt,ButtonFontOpt,Icon,Sound)
	;---------------------------------------------------------------------------------------------------
    static Show(Text:=""   , Title:=""      , Buttons:=""      , Size:="", Opt:=""   ,  BackColor:="",
				TextOpt:="", TextFontOpt:="", ButtonFontOpt:="", Icon:="", Sound:="")
    {
		; #Region Show
		
		; Parse Text and set default
		Text  := (Text  != "") ? Text : "Press OK to Continue."

		; Skip Parse Title to allow blank
		; Title := (Title != "") ? Title : A_ScriptName

        ; #Region Parse Buttons

		Buttons  := (Buttons  != "") ? Buttons : "Default &OK"

        ; Split the Buttons into an array
        buttonArray := StrSplit(Buttons, ",", "`t")
        ButtonCount := buttonArray.Length
        
        ; Get alignment parameter and remove from buttonArray
        ButtonAlignment := "AlignCenter" ; default

        ; Loop backwards to safely delete "Align" items without skipping elements due to index shifting.
        i := buttonArray.Length
        while (i >= 1) {
            buttonText := Trim(buttonArray[i])
            if (SubStr(buttonText, 1, 5) ="Align") {
                ButtonAlignment := buttonText
                buttonArray.RemoveAt(i)
                break
            }
            i--
        }

        ; #Region Parse Size

        if (Size = "") {
            gW := gH := gX := gY := 0
        } else {
            split := StrSplit(Size, ",")
            if (split.Length = 2) {
                gW := split[1] != '' ? split[1] : 0
                gH := split[2] != '' ? split[2] : 0
                gX := 0
                gY := 0
            } else if (split.Length = 4) {
                gW := split[1] != '' ? split[1] : 0
                gH := split[2] != '' ? split[2] : 0
                gX := split[3] != '' ? split[3] : 0
                gY := split[4] != '' ? split[4] : 0
            }
        }

        ; #Region Parse Opt

		; Set defaults and append any additional Opt
        if (Icon != "")
            Opt := ("-MinimizeBox -MaximizeBox " Opt)
        else
            Opt := ("+ToolWindow -MinimizeBox -MaximizeBox " Opt)

    	; #Region Parse Icons

        IconMap := Map()
        IconMap.Set("iconx", "C:\Windows\System32\user32.dll, Icon4")
        IconMap.Set("icon?", "C:\Windows\System32\user32.dll, Icon3")
        IconMap.Set("icon!", "C:\Windows\System32\user32.dll, Icon2")
        IconMap.Set("iconi", "C:\Windows\System32\user32.dll, Icon5")

        ; #Region Parse Sound

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
        SoundMap.Set("iconx", SoundIconError)
        SoundMap.Set("icon?", SoundIconQuestion)
        SoundMap.Set("icon!", SoundIconExclamation)
        SoundMap.Set("iconi", SoundIconInfo)
        SoundMap.Set("beep", SoundBlip)

        ; #Region Gui Create

        ; Append any Opt
        if (Icon != "")
            Opt := ("-MinimizeBox -MaximizeBox " Opt)
        else
            Opt := ("+ToolWindow -MinimizeBox -MaximizeBox " Opt)
       
		global g := Gui()
        g.Opt(Opt)
        g.Title := Title
        g.BackColor := BackColor

        ;TODO adjust based on font size? FontSize * (96/72)
        TopMargin    := 8                   ; Spacing above and below text in top area of the G. Convert Font Point to Pixels
        LeftMargin   := 12                  ; Left Gui margin
        RightMargin  := 8                   ; Space between right side of button and right Gui edge
        BottomMargin := 8
        
        ;TODO adjust based on font size?
        ButtonMargin := 4                   ; Spacing between buttons
        ButtonWidth  := 75                  ; Width of OK button
        ButtonHeight := 23                  ; Height of OK button
        ButtonPanel := ButtonHeight*2      ; Calculate the height of the bottom section of the Gui

        ; Minimum width of Gui
        MinGuiWidth  := buttonArray.Length * (ButtonWidth + ButtonMargin) + LeftMargin
        
        ; Set the font to be used in the Text box
        if (TextFontOpt = "") {
            FontSize := ""
            FontName := ""
        } else {
            split := StrSplit(TextFontOpt,",")
            if (split.Length = 2) {
                FontSize := (split[1] = '') ? '' : Trim(split[1])
                FontName := (split[2] = '') ? '' : Trim(split[2])
            } else {
                FontSize := ""
                FontName := ""
            }
        }

        g.SetFont(FontSize, FontName)

        ; #Region Add WhiteBox

        ; Add a Text Control with white rectangle background, a "WhiteBox"
        ; Gui option for white rectangle (http://ahkscript.org/boards/viewtopic.php?p=20053#p20053)
        MyWhiteBox := g.AddText("x0 y0 " SS_WHITERECT:=0x0006)

        ; Hide Whitebox if Gui BackColor option present
        if (BackColor != "" )
            MyWhiteBox.Visible := False        
        
        ; Make the Whitebox Transparent and appened the Text Options
        TextOptions := " BackgroundTrans " TextOpt

        ; Add the Text Control to the Gui
        MyText := g.AddText(" x" LeftMargin " y" TopMargin TextOptions, Text)

        ; Get the position of the text box
        ControlGetPos &TextX, &TextY, &TextW, &TextH, MyText.Hwnd

        ; Calculate the width of the Whitebox
        TextSpace   := LeftMargin + TextW + RightMargin
        ButtonSpace := LeftMargin + (buttonArray.Length * (ButtonWidth + ButtonMargin)) + RightMargin
        LargerWidth := TextSpace > ButtonSpace ? TextSpace : ButtonSpace
        WhiteBoxWidth := LargerWidth > gW ? LargerWidth : gW

        ; Calculate the height of the Whitebox
        WhiteBoxHeight := TextY + TextH + BottomMargin
        WhiteBoxHeight := WhiteBoxHeight > gh ? WhiteBoxHeight : gH            

        ; Adjust the width and height of the white box
         ControlMove(, , WhiteBoxWidth, WhiteBoxHeight, MyWhiteBox.Hwnd)
    
        ; Calculate the vertical position of the button row
        ButtonY := WhiteBoxHeight + ButtonHeight/2 ; BottomGap

        ; Calculate the horizontal alignment of the buttons
        ButtonSpace := (buttonWidth * buttonArray.Length) + (ButtonMargin * buttonArray.Length - 1)
        AlignLeft := LeftMargin
        AlignCenter := (WhiteBoxWidth / 2) - (ButtonSpace / 2)
        AlignRight := WhiteBoxWidth - ButtonSpace - RightMargin

        ; #Region Add Buttons

        ; Set Button Alignment
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

        ; Set the font to be used in the Buttons
        if (ButtonFontOpt = "") {
            FontSize := ""
            FontName := ""
        } else {
            split := StrSplit(ButtonFontOpt,",")
            if (split.Length = 2) {
                FontSize := (split[1] = '') ? '' : Trim(split[1])
                FontName := (split[2] = '') ? '' : Trim(split[2])
            } else {
                FontSize := ""
                FontName := ""
            }
        }

        g.SetFont(FontSize, FontName)

        ; Add buttons
        Loop buttonArray.Length {

            ; Get the index number
            index :=A_Index

            ; Get the button text from the array[index]
            buttonText := Trim(buttonArray[index])

            ; Preset options
            opt := "x" ButtonX " y" ButtonY " w" ButtonWidth " h" ButtonHeight

            ; If Default then add to the options
            if InStr(buttonText, "Default") OR (buttonArray.Length = 1) {
                buttonText := StrReplace(buttonText, "Default", "")
                buttonText := Trim(buttonText)
                opt := opt " Default"
            }

            ; Add the button with a common click handler
            g.AddButton(opt, buttonText).OnEvent("Click", _Button_Click)

            ;Calculate the horizontal position of the next button
            ButtonX += (ButtonMargin + ButtonWidth) 

        }

        ; #Region G.Show()

        GuiHeight := WhiteBoxHeight + ButtonPanel ; Calculate the overall height of the Gui

        g.OnEvent("Close", Gui_Escape)
        g.OnEvent("Escape", Gui_Escape)
        g.OnEvent('ContextMenu', Gui_ContextMenu)

        MyMenu := Menu()
        MyMenu.Add('Copy to Clipboard', MenuHandler)
        MyMenu.SetIcon('Copy to Clipboard', 'shell32.dll' , 135)

        ; Position the Gui on the primary monitor.
        xPos := (gX = 0) ? "" : xPos:=" x" gX
        yPos := (gY = 0) ? "" : yPos:=" y" gY

        ; Show the Gui
        g.Show("w" WhiteBoxWidth " h" GuiHeight xPos yPos) 

        ; Remove the ToolWindow option so that the Gui has rounded corners and no icon
        ; Trick from http://ahkscript.org/boards/viewtopic.php?p=11519#p11519
        g.Opt("-ToolWindow")

        ; #Region Set Icon
        
        ; If Icon then show icon, else no icon
        IconFile := IconNumber := ""

        if (Icon != "") {

            split := StrSplit(Icon, ",")
            
            key := StrLower(split[1])

            if (IconMap.Has(key)) {
                IconFileAndNumber := IconMap[key]
                split := StrSplit(IconFileAndNumber, ",")
                IconFile   := split[1] != '' ? split[1] : ''
                IconNumber := split[2] != '' ? split[2] : ''
            } else {
                IconFile   := (Icon != '') ? split[1] : ''
                IconNumber := (Icon != '') ? split[2] : ''
            }

            _ChangeWindowIcon(IconFile, IconNumber, "ahk_id" g.Hwnd)
        }

        ; #Region Set Sound Files

        key := StrLower(Sound)

        if (Sound != "") {
            if SoundMap.Has(key)
                SoundPlay soundFile := SoundMap[key]
            else if FileExist(Sound)
                SoundPlay Sound
        }

        ; #Region Show Gui
    
        g.Show()
        WinWaitClose(g.Hwnd)
        return Result

        ; #Region Handlers

        _Button_Click(Ctrl, Info) {
			Global
            Result := Ctrl.Text
            g.Hide()
        }

       	Gui_ContextMenu(GuiObj, GuiCtrlObj, Item, IsRightClick, X, Y) {
		    MyMenu.Show(X, Y)
	    }

        MenuHandler(Item, *) {
		    if (Item == 'Copy to Clipboard')
			A_Clipboard := MyText.Text
        }

        Gui_Close(*){
            g.Destroy()
        }

        Gui_Escape(*) {
            g.Destroy()
        }
	_ChangeWindowIcon(IconFile, IconNumber:="Icon1", WinTitle := "A") {

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
      }    
	}
}

; If (A_LineFile == A_ScriptFullPath)  ; Run Test when this Script is run directly, not included
;     MsgBoxCustom_Test()

; ; #Region Usage Examples

; MsgBoxCustom_Test() {

;     ; comment out to run tests
;     SoundBeep(), ExitApp()

;     #Warn Unreachable, Off

; 	; Set an Alias for easier typing
; 	obj := MsgBoxCustom()
; 	global MB := ObjBindMethod(obj, 'Show')

;    ; TestButtons:="Default &OK, &Abort, &Cancel, AlignRight"

;    global longMessage := unset
;    Loop 30
;     longMessage .= Format("{:02}", A_Index) ": The quick brown fox jumps over the lazy dog.`n"

;    ; MsgBoxCustom(longMessage, "TEST", TestButtons)

;    ; #Region Test Selection

;     ; comment out tests to skip:
; 	;MsgBoxCustom_Test_All()
; 	; MsgBoxCustom_Test_Debug()
; 	; MsgBoxCustom_Test_Standard()
; 	; MsgBoxCustom_Test_Defaults()
; 	; MsgBoxCustom_Test_Fonts()
; 	; MsgBoxCustom_Test_GuiOpt()
; 	; MsgBoxCustom_Test_GuiPos()
; 	; MsgBoxCustom_Test_ShortName()
; 	; MsgBoxCustom_Test_FullName()
; 	; MsgBoxCustom_Test_Layouts()
; 	; MsgBoxCustom_Test_Icons()
; 	; MsgBoxCustom_Test_Sounds()
; }
; MsgBoxCustom_Test_All() {
;     ;MsgBoxCustom_Test_Debug()
;     MsgBoxCustom_Test_Standard()
;     MsgBoxCustom_Test_Defaults()
;     MsgBoxCustom_Test_Fonts()
;     MsgBoxCustom_Test_GuiOpt()
; 	MsgBoxCustom_Test_GuiPos()
;     MsgBoxCustom_Test_ShortName()
;     MsgBoxCustom_Test_FullName()
;     MsgBoxCustom_Test_Layouts()
;     MsgBoxCustom_Test_Icons()
;     MsgBoxCustom_Test_Sounds()
; }

; MsgBoxCustom_Test_Defaults() {

;     ; First example has no parameters, all defaults:
; 	r := MB()

; 	; Next example is similar to standard MsgBox:
;     Text := "This is similar to the standard MsgBox.Note the buttons are centered."
;     Title := "Custom MsgBox"
;     r := MB(Text, Title,"Default &OK, &Cancel, AlignCenter")

;     Text := "This is similar to the standard MsgBox. Note the border around the text." "`n`n" .
; 			"Press any button to see the result:"
;     Title := "Custom MsgBox with Border"
;     r := MB(Text, Title,"Default &OK, &Abort, &Cancel, AlignCenter",,,,"Border")

;     MB("You pressed: " r)

; }
; MsgBoxCustom_Test_Fonts() {

; 	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
; 	Text := "`n`nPress OK or Abort, or Cancel to Break this Loop."
; 	Title := "🡸 Note the Icon for this style"
; 	Buttons := "Default &Continue, &Cancel, "

;     Loop {

; 		Title := "Testing: Fonts"
; 		Buttons := "Default &OK, &Abort, &Cancel, AlignCenter"
; 		Size := "" ; ""300,100,,"
		
; 		TextFont := "Default"
; 		ButtonFont := "Default"
; 		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
; ;		r := MB(TextLine, Title, Buttons)
; 		r := MB(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
; 		if (r = "&Abort") OR (r = "&Cancel")
; 			Break

; 		TextFont := "s14, Courier New"
; 		ButtonFont := "s14, Gabriola"
; 		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
; 		r := MB(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
; 		if (r = "&Abort") OR (r = "&Cancel")
; 			Break

; 		TextFont := "s14, Consolas"
; 		ButtonFont := "Default"
; 		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
; 		r := MB(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
; 		if (r = "&Abort") OR (r = "&Cancel")
; 			Break

; 		TextFont := "s11, Times New Roman" ;Cascadia Code
; 		ButtonFont := "s11, Impact"
; 		TextLine := "Text Font: " TextFont "`n`nButton Font: " ButtonFont . Text
; 		r := MB(TextLine, Title,Buttons,Size,,,,TextFont,ButtonFont)
; 		if (r = "&Abort") OR (r = "&Cancel")
; 			Break
; 	}
; }

; MsgBoxCustom_Test_Standard() {
; 	MsgBox()
; 	MsgBox("This is a Standard MsgBox with OK", "Standard MsgBox")
; 	MsgBox("This is a Standard MsgBox with OKCancel", "Standard MsgBox", "OKCancel")
; 	MsgBox(LongMessage, "Standard MsgBox")
; }
; MsgBoxCustom_Test_FullName() {

; 	;TODO MsgBoxMatrix, MsgBoxPowershell, MsgBoxTerminal (MBM, MBP, MBT?)
	
; 	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
; 	Text := "`n`nPress Continue or Cancel to Break this Loop."
; 	Title := "🡸 Note the Icon for this style"
; 	Buttons := "Default &Continue, &Cancel, "

;     Loop {

; 		r := MB(longMessage . Text, Title, Buttons . "AlignLeft",,,,,,,"IconX")
;         if (r = "&Cancel")
;             Break

;         r := MB(longMessage . Text, Title, Buttons . "AlignCenter",,,,,,,"Icon?")
;         if (r = "&Cancel")
;             Break

;         r := MB(longMessage . Text, Title, Buttons . "AlignRight",,,,,,,"Icon!")
;         if (r = "&Cancel")
;             Break

;         r := MB(longMessage . Text, Title, Buttons . "AlignCenter",,,,,,,"Iconi")
;         if (r = "&Cancel")
;             Break
;     }
; }

; MsgBoxCustom_Test_ShortName() {

; 	;TODO MB, MBM, MBP, MBT
	
; 	Text := "`n`nPress Continue or Cancel to Break this Loop."
; 	Title := "🡸 Note the Icon for this style"
; 	Buttons := "Default &Continue, &Cancel, "

; 	Loop {

; 		MB()

; 		r := MB(longMessage, "Custom Title", Buttons . "AlignLeft")
; 		if (r = "&Cancel")
; 		Break

; 		r := MB(longMessage, "Custom Title", Buttons . "AlignCenter")
; 		if (r = "&Cancel")
; 		Break

; 		r := MB(longMessage, "Custom Title", Buttons . "AlignRight")
; 		if (r = "&Cancel")
; 		Break

; 	}
; }

; MsgBoxCustom_Test_Icons() {

; 	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)

; 	Text := "Press Continue or Cancel to Break this Loop."
;     Title := "🡸  "
; 	Size := "" ;"300,100,,"
; 	Buttons := "Default &Continue, &Cancel"
;     TextFont := "s11, Consolas" ; w700

; 	Loop {

; 		Icon := ""
; 		r := MB(Text, Title "(No Icon)", Buttons,Size,,,,TextFont,,Icon)
; 		if (r = "&Cancel")
; 			Break

; 		; Show standard MsgBox Icons
; 		Icon := "Icon!"
; 		r := MB(Text, Title "Icon!",Buttons,Size,,,,TextFont,,Icon)
; 		if (r = "&Cancel")
; 			Break

; 		; Show custom icon from icon file, number
; 		Icon := "C:\Windows\System32\user32.dll, Icon7"
; 		r := MB(Text, Title "From File:  " icon,Buttons,Size,,,,TextFont,,Icon)
; 		if (r = "&Cancel")
; 			Break
; 	}
; }

; MsgBoxCustom_Test_Layouts() {

; 	;DEBUG
; 	;r:=MB_TEST.Show("TEST")

; 	LorenIpsum := "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam laoreet nisl sed convallis consectetur."
; 	msg := LorenIpsum "`n`nPress Abort or Cancel to Break this Loop." ;

; 	; test Align Left, Center, Right
;     Buttons := "Default &OK, &Abort, &Cancel, "
    
; 	Loop {
; 		align := "AlignLeft"
; 		r := MB(msg, "Test Layout:  " align, Buttons . align)
;         if (r = "&Abort") OR (r = "&Cancel")
;             Break

; 		align := "AlignCenter"
; 		r := MB(msg, "Test Layout:  " align, Buttons . align)
;         if (r = "&Abort") OR (r = "&Cancel")
; 			Break

; 		align := "AlignRight"
; 		r := MB(msg, "Test Layout:  " align, Buttons . align)
;         if (r = "&Abort") OR (r = "&Cancel")
;             Break
; 	}
; }

; MsgBoxCustom_Test_Sounds() {

; 	Text := "Press Continue or Cancel to Break this Loop."
;     Title := "Test Sounds"
;     TextFont := "s12, Consolas" ; w700
;     Buttons := "Default &OK, &Cancel, AlignCenter"
;     Icons := ",IconX, Icon!, Icon?, Iconi"
; 	Size := "" ; "300,100"

;     Loop {
;         Loop Parse Icons, "," {
;             i := Trim(A_LoopField)
;             s := (i = "") ? "Default (No Sound)" : i
;             TextLine := "Sound: " s "`n`n" Text
;             Icon := i
;             Sound := Icon
;             r := MB(TextLine, Title, Buttons, Size,,,,TextFont,,Icon, Sound)
;             if (r = "&Cancel")
;                 Break 2
;         }
;     }

;     Text  := "Sound: Tada"
; 	Size  := "300,60"
;     Icon  := "C:\Windows\System32\imageres.dll, Icon229" ; 229=Green Check Circle
;     Sound := "C:\Windows\Media\tada.wav"
;     MB(Text, Title,, Size,,,,TextFont,,Icon, Sound)
; }

; MsgBoxCustom_Test_GuiOpt() {
; 	; Show(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
;  	; just examples, not actually used together
; 	; Reize does not redraw the gui, just for demo here
;     Opt := "+AlwaysOnTop +MinimizeBox +Resize +OwnDialogs +OwnDialogs"
;     Text := "GuiOpt: " Opt "`n`nCick on a different Window and note that this Message Box remains on top."
;     Title := "Test GuiOpt AlwaysOnTop"
;     Buttons := "Default &OK, &Cancel, AlignCenter"
; 	Size := "" ; "400,200"
; 	TextFont := "s11, Consolas"
;     r := MB(Text, Title, Buttons, Size, Opt,,,TextFont)
; 	(r = "&OK") ? nop:=true : Exit
; }
; MsgBoxCustom_Test_GuiPos() {

; 	sw := A_ScreenWidth
; 	sh := A_ScreenHeight
	
; 	Text := "Press Continue or Cancel to Break this Loop."
;     Title := "Test Position"
;     Buttons := "Default &Continue, &Cancel, AlignCenter"
; 	SizeArray := [	"",",,20,20", 
; 					",," sw-500 ",20",
; 					",,20, " sh-250 ,
; 					",," sw-500 "," sh-250] ; "300,100"
;     TextFont := "s12, Consolas" ; w700
;     Icons := ",IconX, Icon!, Icon?, Iconi"

;     Loop {
; 		for size in SizeArray {
;             i := Trim(A_LoopField)
;             Icon := "Iconi"
;             Sound := Icon
;             r := MB(Text, Title, Buttons, size,,,,TextFont,,Icon, Sound)
;             if (r = "&Cancel")
;                 Break 2
;         }
;     }
; }
; MsgBoxCustom_Test_Debug() {

;     ;MsgBox "test"

;     Buttons := "Default &OK, &Cancel"
;     r := MB("Starting Test_Debug...", "Test: Debug", Buttons,,"+AlwaysOnTop")
; 	(r = "&OK") ? nop:=true : ExitApp()

;     r := MB("Test Opt(+AlwaysOnTop)...", "Test: AlwaysOnTop", Buttons,,"+AlwaysOnTop")
; 	(r = "&OK") ? nop:=true : ExitApp()

    
;     #Warn Unreachable, Off
;     return

; }
