; ABOUT: Beta-1
 /**
  * TODO:
  * 
  */
#Requires AutoHotkey v2.0
;#NoTrayIcon

;DEBUG
#SingleInstance Force
Escape::ExitApp()

;---------------------------------------------------------------------------------------------------
;     Text 	        := "Text Message"				        ; Text Control text
;     Title 	    := "Custom MsgBox"				        ; Gui title
;     Buttons	    := "Default &Yes, &No, &All, &Cancel"   ; Default =Default button, &Y=Alt+Y shortcut
;     Size          := "400, 223, 10, 10" 			        ; w, h, x, y
;     Opt	        := "+AlwaysOnTop"                       ; this.gui.Opt("+AlwaysOnTop")
;     BackColor     := "Blue"                               ; this.gui.Backcolor:="Blue"
;     TextOpt       := "Border -Wrap" 				        ; this.gui.AddText(Options, Text)
;     TextFontOpt   := "s11 w700 cWhite, Consolas"          ; this.gui.SetFont(Options, FontName)
;     ButtonFontOpt := "s11, Segoe UI"                      ; this.gui.SetFont(Options, FontName)
;     Icon          := "Icon?"                              ; MsgBox Icon (IconX, Icon!, Icon?, Iconi)
;                   := "C:\Dir\file.ext, Icon1"             ; Icon from binary file (dll, exe, ico), icon number
;     Sound         := "Icon?"                              ; Sound to match MsgBox icon
;                   := "C:\Dir\sound.wav"                   ; Sound file

;---------------------------------------------------------------------------------------------------
; Purpose: Custom MsgBox with options, icons, sounds, and context menu.
; Returns: A String with the text from the button pressed.
; Context: Right-click to copy the text to the clipboard.
; License: The Unlicense: https://unlicense.org/
; Params :(Text,Title,Buttons,Size,Opt,BackColor,TextOpt,TextFontOpt,ButtonFontOpt,Icon,Sound)
;---------------------------------------------------------------------------------------------------

class MBox extends CustomMBox {
    __New(Text:="", Title:="", Buttons:="", Size:="", Opt:="",  BackColor:="",  
            TextOpt:="", TextFontOpt:="", ButtonFontOpt:="", Icon:="", Sound:="") {
        super.__New(Text,Title,Buttons,Size,Opt,BackColor,TextOpt,TextFontOpt,ButtonFontOpt,Icon,Sound)
    }
}

class MBoxPowerShell extends CustomMBox {
      __New(Text:="", Title:="", Buttons:="", Size:="", Opt:="",  BackColor:="",  
            TextOpt:="", TextFontOpt:="", ButtonFontOpt:="", Icon:="", Sound:="") {
        Theme := "Blue Screen of Death"
        BackColor := "Blue"
        TextFontOpt := "s11 cWhite, Consolas"
        Icon  := "C:\Windows\System32\imageres.dll, Icon313" ; PS prompt with user
        super.__New(Text,Title,Buttons,Size,Opt,BackColor,TextOpt,TextFontOpt,ButtonFontOpt,Icon,Sound)
    }
}

class MBoxP extends CustomMBox {
      __New(Text:="", Title:="", Buttons:="", Size:="", Opt:="",  BackColor:="",  
            TextOpt:="", TextFontOpt:="", ButtonFontOpt:="", Icon:="", Sound:="") {
        BackColor := "Blue"
        TextFontOpt := "s11 cWhite, Consolas"
        super.__New(Text,Title,Buttons,Size,Opt,BackColor,TextOpt,TextFontOpt,ButtonFontOpt,Icon,Sound)
    }
}

class MBoxMatrix extends CustomMBox {
      __New(Text:="", Title:="", Buttons:="", Size:="", Opt:="",  BackColor:="",  
            TextOpt:="", TextFontOpt:="", ButtonFontOpt:="", Icon:="", Sound:="") {
        BackColor := "Black"
        TextFontOpt := "s11 cGreen, Consolas"
        Icon := "C:\Windows\System32\imageres.dll, Icon145" ; Terminal with green graph        
        super.__New(Text,Title,Buttons,Size,Opt,BackColor,TextOpt,TextFontOpt,ButtonFontOpt,Icon,Sound)
    }
}

class MBoxM extends CustomMBox {
      __New(Text:="", Title:="", Buttons:="", Size:="", Opt:="",  BackColor:="",  
            TextOpt:="", TextFontOpt:="", ButtonFontOpt:="", Icon:="", Sound:="") {
        BackColor := "Black"
        TextFontOpt := "s11 cGreen, Consolas"        
        super.__New(Text,Title,Buttons,Size,Opt,BackColor,TextOpt,TextFontOpt,ButtonFontOpt,Icon,Sound)
    }
}

class MBoxTerminal extends CustomMBox {
      __New(Text:="", Title:="", Buttons:="", Size:="", Opt:="",  BackColor:="",  
            TextOpt:="", TextFontOpt:="", ButtonFontOpt:="", Icon:="", Sound:="") {
        BackColor := "Black"
        TextFontOpt := "s11 cWhite, Consolas"
        Icon := "C:\Windows\System32\imageres.dll, Icon265" ; cmd prompt with user       
        super.__New(Text,Title,Buttons,Size,Opt,BackColor,TextOpt,TextFontOpt,ButtonFontOpt,Icon,Sound)
    }
}

class MBoxT extends CustomMBox {
      __New(Text:="", Title:="", Buttons:="", Size:="", Opt:="",  BackColor:="",  
            TextOpt:="", TextFontOpt:="", ButtonFontOpt:="", Icon:="", Sound:="") {
        BackColor := "Black"
        TextFontOpt := "s11 cWhite, Consolas"        
        super.__New(Text,Title,Buttons,Size,Opt,BackColor,TextOpt,TextFontOpt,ButtonFontOpt,Icon,Sound)
    }
}

class CustomMBox {
    
    Text            := "Press OK to continue."
    Title           := ""
    Buttons         := "Default &OK"
    Size            := ""
    Opt             := ""
    BackColor       := ""
    TextOpt         := ""
    TextFontOpt     := ""
    ButtonFontOpt   := ""
    ButtonFontName  := ""
    Icon            := ""
    Sound           := ""

    gui             := ""
    Result          := ""
    IconMap         := ""
    SoundMap        := ""

    __New(Text:="", Title:="", Buttons:="", Size:="", Opt:="",  BackColor:="",  
            TextOpt:="", TextFontOpt:="", ButtonFontOpt:="", Icon:="", Sound:="") {

        this.Text := (Text  = "") ? this.Text : Text
        this.Title := Title
        this.Buttons := (Buttons = "") ? this.Buttons : Buttons
        this.Size := Size
        this.Opt := Opt
        this.BackColor := BackColor
        this.TextOpt := TextOpt
        this.TextFontOpt := TextFontOpt
        this.ButtonFontOpt := (ButtonFontOpt="") ? "s9 Segoe UI" : ButtonFontOpt
        this.Icon := Icon
        this.Sound := Sound

        this.ButtonCount := 0
        this.ButtonAlignment := "AlignCenter"

    }

    Show(Text:="", Title:="") {

        this.Text  := (Text  = "") ? this.Text : Text
        this.Title := (Title = "") ? this.Title : Title       

        ; #Region Parse Size

        if (this.Size = "") {
            gW := gH := gX := gY := 0
        } else {
            split := StrSplit(this.Size, ",")
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

        ; #Region Parse Buttons

        ; Split the Buttons into an array
        buttonArray := StrSplit(this.Buttons, ",", "`t")
        this.ButtonCount := buttonArray.Length
        
        ; Get alignment parameter and remove from buttonArray
        this.ButtonAlignment := "AlignCenter" ; default

        ; Loop backwards to safely delete "Align" items without skipping elements due to index shifting.
        i := buttonArray.Length
        while (i >= 1) {
            buttonText := Trim(buttonArray[i])
            if (SubStr(buttonText, 1, 5) ="Align") {
                this.ButtonAlignment := buttonText
                buttonArray.RemoveAt(i)
                break
            }
            i--
        }

        ; #Region Parse Icons

        this.IconMap := Map()
        this.IconMap.Set("iconx", "C:\Windows\System32\user32.dll, Icon4")
        this.IconMap.Set("icon?", "C:\Windows\System32\user32.dll, Icon3")
        this.IconMap.Set("icon!", "C:\Windows\System32\user32.dll, Icon2")
        this.IconMap.Set("iconi", "C:\Windows\System32\user32.dll, Icon5")

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

        this.SoundMap := Map()
        this.SoundMap.Set("iconx", SoundIconError)
        this.SoundMap.Set("icon?", SoundIconQuestion)
        this.SoundMap.Set("icon!", SoundIconExclamation)
        this.SoundMap.Set("iconi", SoundIconInfo)
        this.SoundMap.Set("beep", SoundBlip)

        ; #Region Gui Create

        ; Append any Opt
        if (this.Icon != "")
            this.Opt := ("-MinimizeBox -MaximizeBox " this.Opt)
        else
            this.Opt := ("+ToolWindow -MinimizeBox -MaximizeBox " this.Opt)
       
        this.gui := Gui()
        this.gui.Opt(this.Opt)
        this.gui.Title := this.Title
        this.gui.BackColor := this.BackColor

        ;TODO adjust based on font size? FontSize * (96/72)
        TopMargin    := 8                   ; Spacing above and below text in top area of the Gui. Convert Font Point to Pixels
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
        if (this.TextFontOpt = "") {
            FontSize := ""
            FontName := ""
        } else {
            split := StrSplit(this.TextFontOpt,",")
            if (split.Length = 2) {
                FontSize := (split[1] = '') ? '' : Trim(split[1])
                FontName := (split[2] = '') ? '' : Trim(split[2])
            } else {
                FontSize := ""
                FontName := ""
            }
        }

        this.gui.SetFont(FontSize, FontName)

        ; #Region Add WhiteBox

        ; Add a Text Control with white rectangle background, a "WhiteBox"
        ; Gui option for white rectangle (http://ahkscript.org/boards/viewtopic.php?p=20053#p20053)
        MyWhiteBox := this.gui.AddText("x0 y0 " SS_WHITERECT:=0x0006)

        ; Hide Whitebox if Gui BackColor option present
        if (this.BackColor != "" )
            MyWhiteBox.Visible := False        
        
        ; Make the Whitebox Transparent and appened the Text Options
        TextOptions := " BackgroundTrans " this.TextOpt

        ; Add the Text Control to the Gui
        MyText := this.gui.AddText(" x" LeftMargin " y" TopMargin TextOptions, this.Text)

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
        switch this.ButtonAlignment {
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
        if (this.ButtonFontOpt = "") {
            FontSize := ""
            FontName := ""
        } else {
            split := StrSplit(this.ButtonFontOpt,",")
            if (split.Length = 2) {
                FontSize := (split[1] = '') ? '' : Trim(split[1])
                FontName := (split[2] = '') ? '' : Trim(split[2])
            } else {
                FontSize := ""
                FontName := ""
            }
        }

        this.gui.SetFont(FontSize, FontName)

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
            this.gui.AddButton(opt, buttonText).OnEvent("Click", _Button_Click)

            ;Calculate the horizontal position of the next button
            ButtonX += (ButtonMargin + ButtonWidth) 

        }

        ; #Region Gui.Show()

        GuiHeight := WhiteBoxHeight + ButtonPanel ; Calculate the overall height of the Gui

        this.gui.OnEvent("Close", Gui_Escape)
        this.gui.OnEvent("Escape", Gui_Escape)
        this.gui.OnEvent('ContextMenu', Gui_ContextMenu)

        MyMenu := Menu()
        MyMenu.Add('Copy to Clipboard', MenuHandler)
        MyMenu.SetIcon('Copy to Clipboard', 'shell32.dll' , 135)

        ; Position the Gui on the primary monitor.
        xPos := (gX = 0) ? "" : xPos:=" x" gX
        yPos := (gY = 0) ? "" : yPos:=" y" gY

        ; Show the Gui
        this.gui.Show("w" WhiteBoxWidth " h" GuiHeight xPos yPos) 

        ; Remove the ToolWindow option so that the Gui has rounded corners and no icon
        ; Trick from http://ahkscript.org/boards/viewtopic.php?p=11519#p11519
        this.gui.Opt("-ToolWindow")

        ; #Region Set Icon
        
        ; If Icon then show icon, else no icon
        IconFile := IconNumber := ""

        if (this.Icon != "") {

            split := StrSplit(this.Icon, ",")
            
            key := StrLower(split[1])

            if (this.IconMap.Has(key)) {
                IconFileAndNumber := this.IconMap[key]
                split := StrSplit(IconFileAndNumber, ",")
                IconFile   := split[1] != '' ? split[1] : ''
                IconNumber := split[2] != '' ? split[2] : ''
            } else {
                IconFile   := (this.Icon != '') ? split[1] : ''
                IconNumber := (this.Icon != '') ? split[2] : ''
            }

            this._ChangeWindowIcon(IconFile, IconNumber, "ahk_id" this.gui.Hwnd)
        }

        ; #Region Set Sound Files

        key := StrLower(this.Sound)

        if (this.Sound != "") {
            if this.SoundMap.Has(key)
                SoundPlay soundFile := this.SoundMap[key]
            else if FileExist(this.Sound)
                SoundPlay this.Sound
        }

        ; #Region Show Gui
    
        this.gui.Show()
        WinWaitClose(this.gui.Hwnd)
        return this.Result

        ; #Region Handlers

        _Button_Click(Ctrl, Info) {
            this.Result := Ctrl.Text
            this.gui.Hide()
        }

       	Gui_ContextMenu(GuiObj, GuiCtrlObj, Item, IsRightClick, X, Y) {
		    MyMenu.Show(X, Y)
	    }

        MenuHandler(Item, *) {
		    if (Item == 'Copy to Clipboard')
			A_Clipboard := MyText.Text
        }

        Gui_Close(*){
            this.gui.Destroy()
        }

        Gui_Escape(*) {
            this.gui.Destroy()
        }
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

If (A_LineFile == A_ScriptFullPath)  ; when run directly, not included
    MBox_Test()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

; #region Usage Examples

MBox_Test() {

   global longMessage := unset

    #Warn Unreachable, Off

    ; comment out to run tests
    SoundBeep(), ExitApp()

   ; TestButtons:="Default &OK, &Abort, &Cancel, AlignRight"

   longMessage := unset
   Loop 30
    longMessage .= Format("{:02}", A_Index) ": The quick brown fox jumps over the lazy dog.`n"

   ; MsgBoxEx(longMessage, "TEST", TestButtons)

   ; #Region Test Selection

    ; comment out tests to skip:
	MBox_Test_All()
	;MBox_Test_Debug()
	;MBox_Test_Standard()
	;MBox_Test_Defaults()
	;MBox_Test_Fonts()
	;MBox_Test_GuiOpt()
	;MBox_Test_ShortName()
	;MBox_Test_FullName()
	;MBox_Test_Layouts()
	;MBox_Test_Icons()
    ;MBox_Test_Sounds()
}

MBox_Test_All() {
    ;MBox_Test_Debug()
    MBox_Test_Standard()
    MBox_Test_Defaults()
    MBox_Test_Fonts()
    MBox_Test_GuiOpt()
    MBox_Test_ShortName()
    MBox_Test_FullName()
    MBox_Test_Layouts()
    MBox_Test_Icons()
    MBox_Test_Sounds()
}
MBox_Test_Defaults() {

    ; First example has no parameters, all defaults:
    MB := MBox()
	r := MB.Show()

	; Next example is similar to standard MsgBox:
    ;Text := LongMessage
    Text := "This is similar to the standard MsgBox. Note the buttons are centered."
    Title := "Custom MsgBox"
    MB := MBox(Text, Title,"Default &OK, &Abort, &Cancel, AlignCenter")
    r := MB.Show(Text, Title)

    Text := "This is similar to the standard MsgBox. Note the border around the text."
    Title := "Custom MsgBox with Border"
    MB := MBox(Text, Title,"Default &OK, &Abort, &Cancel, AlignCenter",,,,"Border")
    r := MB.Show(Text, Title)
    MsgBox("You pressed: " r)

}
MBox_Test_Fonts() {

    Title := "Test Fonts"
    Buttons := "Default &OK, &Abort, &Cancel, AlignLeft"
    Size := "300,100,,"
    
    TextFont := "Default"
    ButtonFont := "Default"
    Text := "Text Font: " TextFont "`n`nButton Font: " ButtonFont
    MB := MBox(Text, Title, Buttons)
    MB.Show()

    TextFont := "s14, Courier New"
    ButtonFont := "s14, Gabriola"
    Text := "Text Font: " TextFont "`n`nButton Font: " ButtonFont
    MB := MBox(Text, Title, Buttons,,,,,TextFont,ButtonFont)
    MB.Show()

    TextFont := "s14, Consolas"
    ButtonFont := "Default"
    Text := "Text Font: " TextFont "`n`nButton Font: " ButtonFont
    MB := MBox(Text, Title, Buttons,"300,100,,",,,,TextFont,"")
    MB.Show()

    TextFont := "Default"
    ButtonFont := "s11, Impact"
    Text := "Text Font: " TextFont "`n`nButton Font: " ButtonFont
    MB := MBox(Text, Title,,Size,,,,"",ButtonFont)
    MB.Show()
}

MBox_Test_Standard() {
	MsgBox()
	MsgBox("This is a Standard MsgBox with OK", "Standard MsgBox")
	MsgBox("This is a Standard MsgBox with OKCancel", "Standard MsgBox", "OKCancel")
	MsgBox(LongMessage, "Standard MsgBox")
}
MBox_Test_FullName() {

    Loop {
        MB := MBoxPowerShell(,"🡸 Note the Icon for this style","Default &OK, Con&tinue, &Cancel, AlignLeft")
        r := MB.Show()
        if (r = "&Cancel")
            Break

        r :=MB.Show(longMessage, "Custom Title")
        if (r = "&Cancel")
            Break

        MB := MBoxMatrix(,"🡸 Note the Icon for this style","Default &OK, Con&tinue, &Cancel, AlignCenter")
        r := MB.Show()
        if (r = "&Cancel")
            Break

        r := MB.Show(longMessage, "Custom Title")
        if (r = "&Cancel")
            Break

        MB := MBoxTERMINAL(,"🡸 Note the Icon for this style","Default &OK, Con&tinue, &Cancel, AlignRight")
        r := MB.Show()
        if (r = "&Cancel")
            Break

        r := MB.Show(longMessage, "Custom Title")
        if (r = "&Cancel")
            Break
    }
}

MBox_Test_Icons() {

    Title := "Test Icons"
    TextFont := "s14 w700, Consolas"

    Text := "Icon: Default (No Icon)"
    Icon := ""
    MB := MBox(Text, Title,,"300,100,,",,,,TextFont,,Icon)
    MB.Show()

    ; Show standard Msb box Icons
    Text := "Icon: Icon!"
    Icon := "Icon!"
    MB := MBox(Text, Title,,"300,100,,",,,,TextFont,,Icon)
    MB.Show()

    ; Show custom icon from icon file, number
    Text := "Icon: From File"
    Icon := "C:\Windows\System32\user32.dll, Icon7"
    MB := MBox(Text, Title,,"300,100,,",,,,TextFont,,Icon)
    MB.Show()
}

MBox_Test_ShortName() {

    MB := MBoxP(,,"Default &OK, &Abort, &Cancel, AlignLeft",,,,,)
    MB.Show()
    MB.Show(longMessage, "Custom Title")

    MB := MBoxM(,,"Default &OK, &Abort, &Cancel, AlignLeft",,,,,)
    MB.Show()
    MB.Show(longMessage, "Custom Title")

    MB := MBoxT(,,"Default &OK, &Abort, &Cancel, AlignLeft",,,,,)
    MB.Show()
    MB.Show(longMessage, "Custom Title")
}

MBox_Test_Layouts() {

	; test Align Left, Center, Right
    MB := MBoxP(,,"Default &OK, &Abort, &Cancel, AlignLeft")
	r := MB.Show("This is a test of the Layout with the Parameter:`n`nAlignLeft.", "MsgBox - AlignLeft")
	(r = "&Cancel") ? ExitApp() : nop:=true

    MB := MBoxM(,, "Default &OK, &Cancel, AlignCenter")
	r := MB.Show("This is a test of the Layout with the Parameter:`n`nAlignCenter", "MsgBox - AlignCenter")
	(r = "&Cancel") ? ExitApp() : nop:=true

    MB := MBoxT(,, "Default &OK, &Cancel, AlignRight")
	r := MB.Show("This is a test of the Layout with the Parameter:`n`nAlignRight.", "MsgBox - AlignRight")
	(r = "&Cancel") ? ExitApp() : nop:=true

}

MBox_Test_Sounds() {

    Title := "Test Sounds"
    TextFont := "s14 w700, Consolas"
    Buttons := "Default &OK, &Cancel, AlignLeft"
    Icons := ",IconX, Icon!, Icon?, Iconi"
    Size := "300,100"

    Loop {
        Loop Parse Icons, "," {
            i := Trim(A_LoopField)
            t := (i = "") ? "Default (No Sound)" : i
            Text := "Sound: " t
            Icon := i
            Sound := Icon
            MB := MBox(Text, Title, Buttons, Size,,,,TextFont,,Icon, Sound)
            r := MB.Show()
            if (r = "&Cancel")
                Break 2
        }
    }

    Text  := "Sound: Tada"
    Icon  := "C:\Windows\System32\imageres.dll, Icon229" ; 229=Green Check Circle
    Sound := "C:\Windows\Media\tada.wav"
    MB := MBox(Text, Title,, Size,,,,TextFont,,Icon, Sound)
    MB.Show()
}
MBox_Test_GuiOpt() {
    Title := "Test GuiOpt AlwaysOnTop"
    Buttons := "Default &OK, &Cancel, AlignCenter"
    Opt := "+AlwaysOnTop +MinimizeBox +Resize +OwnDialogs +OwnDialogs" ; just examples, not actually used together
    Text := "GuiOpt: " Opt
    MB := MBoxT(Text, Title, Buttons, "400,200",Opt)
    r := MB.Show()
	(r = "&OK") ? nop:=true : Exit
}

MBox_Test_Debug() {

    Persistent

    ;MsgBox "test"

    Buttons := "Default &OK, &Cancel"
    MB := MBoxP("Starting Test_Debug...", "Test: Debug", Buttons,,"+AlwaysOnTop")
    r := MB.Show()
	(r = "&OK") ? nop:=true : ExitApp()

    MB := MBoxP("Test Opt(+AlwaysOnTop)...", "Test: AlwaysOnTop", Buttons,,"+AlwaysOnTop")
    r := MB.Show()  
	(r = "&OK") ? nop:=true : ExitApp()

    #Warn Unreachable, Off
    
    return
    ; vSize := 0
    ;     ;DEFAULT_GUI_FONT := 17
	; 	hFontDefault := DllCall("gdi32\GetStockObject", "Int",17)
	; 	vSize := DllCall("gdi32\GetObject", "Ptr",hFontDefault, "Int", vSize, "Ptr",0)
    ; MsgBox vSize    

        ;MBM := MBoxMatrix()
    ;MyTheme := MBM.Theme
    ;MyFont := MBM.FontName
    ;MBM.Show("This is my text in Theme: [" MyTheme "]", "Matrix Title")
    ;MBM.Show("Font: [" MyFont "]", "Matrix Title")
    ; MBM.Show(MBM.TestValue)
    ; ExitApp()
    ;MB := CustomMBox("Text", "Title", Buttons, Theme := "Matrix")
    ; MBM := CustomMBoxMatrix("mText", "mTitle")
    ;ExitApp()

    ;MB := MBoxEx()

    Size :=""
    ;Size          := "400, 223, 20, 20"

    ;MB := MBoxEx(,,,"Default &OK, &Abort, &Cancel, AlignRight",Size,,,"Border","s14, Consolas","s9, Segoe UI")
    ;MB := MBoxEx(,,,"Default &OK, &Abort, &Cancel, AlignRight",,,,,"s11, Consolas","s9, Segoe UI")
    MB := MBox(,,,"Default &OK, &Abort, &Cancel, AlignLeft",,,,,"s11, Consolas","s9, Segoe UI")
    MB.Show()
    MB.Show(longMessage, "Custom Title")
    ;MB.Show("This is my text.", "My Title")

    MB := MBoxP(,,,"Default &OK, &Abort, &Cancel, AlignLeft",,,,,)
    MB.Show()
    MB.Show(longMessage, "Custom Title")

    MB := MBoxM(,,,"Default &OK, &Abort, &Cancel, AlignLeft",,,,,)
    MB.Show()
    MB.Show(longMessage, "Custom Title")

    MB := MBoxT(,,,"Default &OK, &Abort, &Cancel, AlignLeft",,,,,)
    MB.Show()
    MB.Show(longMessage, "Custom Title")

    ExitApp()

    MB.TestValue := "Test Value 2"
    TestValue := MB.TestValue
    ;MB := CustomMBox(TestValue, "Test Value")

    ;if (MB.Result = "OK")
    ;    MsgBox "Button Clicked: " MB.Result

    ;Show Text, Title
    returnValue := MB.Show("Press OK to continue...", "New Title")

    MB.Show("returnValue: " returnValue, "Return Value")

    MB.Show("Press OK to close.", "End of Demo")

    ; if (MB.Result = "OK")
    ;     MB.Show("Button Clicked: " MB.Result)

    ;myGui2 := CustomMBox("Button Clicked: " this.gui.Result)

    ;WinWaitNotActive(this.gui.gui.Hwnd)

    ;MsgBox  Type(myGui)
    MB := MBM := unset

}

    ; MsgBoxNew:

	; static hIconHand := DllCall("user32\LoadIcon", Ptr,0, Ptr,32513, Ptr) ;IDI_HAND := 32513
	; static hIconQuestion := DllCall("user32\LoadIcon", Ptr,0, Ptr,32514, Ptr) ;IDI_QUESTION := 32514
	; static hIconExclamation := DllCall("user32\LoadIcon", Ptr,0, Ptr,32515, Ptr) ;IDI_EXCLAMATION := 32515
	; static hIconAsterisk := DllCall("user32\LoadIcon", Ptr,0, Ptr,32516, Ptr) ;IDI_ASTERISK := 32516

    ;62: 		;DEFAULT_GUI_FONT := 17
	;Line  863: 		hFontDefault := DllCall("gdi32\GetStockObject", Int,17, Ptr)
