; TITLE: Beta v0.1.0.0
;SOURCE: V1 https://www.autohotkey.com/boards/viewtopic.php?f=6&t=9043

/**
 * TODO:
 *  change Opt to GuiOpt, Size to GuiSize()
 *      Size := "w,h,x,y" to "x,y,w,h" ; x,y default is center, w,h default?
 */

/*
	M(Text, Title, Buttons, Size, Opt,  BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
	Text := "`n`nPress OK or Abort, or Cancel to Break this Loop."
	Title := "🡸 Note the Icon for this Theme"
	Buttons := "Default &Continue, &Cancel, "

*/

#Requires AutoHotkey v2.0+
;------------------------------------------------------------------------
;  Text            := "My Text"
;  Title           := "My Title"
;  Buttons         := "Default &OK, &Abort, &Cancel, AlignCenter"
;  Size            := "w,h,x,y" "300,100,,"
;  Opt             := "+MinSize640x480 +MaxSize1280x960"
;  BackColor       := "Silver"
;  TextOpt         := "Center"
;  TextFontOpt     := "s14, Consolas"
;  ButtonFontOpt   := "s10, Segoe UI"
;  Icon            := "Icon?" or "C:\Windows\System32\imageres.dll, Icon264"
;  Sound           := "Icon?" or "C:\Windows\Media\Windows Default.wav"
;------------------------------------------------------------------------
Msg(Text:="",Title:="",Buttons:="", Size:="", Opt:="",BackColor:="",
 	    TextOpt:="",TextFontOpt:="",ButtonFontOpt:="",Icon:="",Sound:="") {
	return MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
}

MsgCmd(Text:="",Title:="",Buttons:="", Size:="", Opt:="",BackColor:="",
 	 			TextOpt:="",TextFontOpt:="",ButtonFontOpt:="",Icon:="",Sound:="") {
    BackColor := "0x0C0C0C"
    TextFontOpt := "s11  c0xCDD0B1, Consolas"
    Icon := "C:\Windows\System32\imageres.dll, Icon264" ; cmd prompt  265=with user 
	return MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
}
MsgMatrix(Text:="",Title:="",Buttons:="", Size:="", Opt:="",BackColor:="",
 	    TextOpt:="",TextFontOpt:="",ButtonFontOpt:="",Icon:="", Sound:="") {
    BackColor := "0x0C0C0C" ;"Black"
    TextFontOpt := "s11 c03A062, Consolas"
    Icon := "C:\Windows\System32\imageres.dll, Icon145" ; Terminal with green graph   
	return MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
}

MsgTerminal(Text:="",Title:="",Buttons:="", Size:="", Opt:="",BackColor:="",
 	    TextOpt:="",TextFontOpt:="",ButtonFontOpt:="",Icon:="", Sound:="") {
    BackColor := "0x012456" ; "0x0000FF" ; Vivid Blue, Noble Blue in the original PowerShell console: 0x012456
    TextFontOpt := "s11 c0xF5E5CB, Consolas" ; cCDD0B1
    Icon  := "C:\Windows\System32\imageres.dll, Icon105" ; Terminal with blue backcolor ;Icon313" ; PS prompt with user
	return MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
}

MsgC(Text:="",Title:="",Buttons:="", Size:="", Opt:="",BackColor:="",
 	 			TextOpt:="",TextFontOpt:="",ButtonFontOpt:="",Icon:="", Sound:="") {
    BackColor := "0x0C0C0C"
    TextFontOpt := "s11  c0xCDD0B1, Consolas"
    Icon := "C:\Windows\System32\imageres.dll, Icon264" ; cmd prompt  265=with user 
	return MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
}

MsgM(Text:="",Title:="",Buttons:="", Size:="", Opt:="",BackColor:="",
 	    TextOpt:="",TextFontOpt:="",ButtonFontOpt:="",Icon:="", Sound:="") {
    BackColor := "0x0C0C0C" ;"Black"
    TextFontOpt := "s11 c03A062, Consolas"
    Icon := "C:\Windows\System32\imageres.dll, Icon145" ; Terminal with green graph   
	return MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
}

MsgT(Text:="",Title:="",Buttons:="", Size:="", Opt:="",BackColor:="",
 	    TextOpt:="",TextFontOpt:="",ButtonFontOpt:="",Icon:="", Sound:="") {
    BackColor := "0x012456" ; "Blue"
    TextFontOpt := "s11 cCDD0B1, Consolas"
    Icon  := "C:\Windows\System32\imageres.dll, Icon105" ; Terminal with blue backcolor ;Icon313" ; PS prompt with user
	return MsgBoxCustom.Show(Text, Title, Buttons, Size, Opt, BackColor, TextOpt, TextFontOpt, ButtonFontOpt, Icon, Sound)
}

;---------------------------------------------------------------------------------------------------
; Purpose: Custom MsgBox with options, icons, sounds, and context menu.
;---------------------------------------------------------------------------------------------------
 class MsgBoxCustom
{
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
    	global Result := ""

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

        ; Loop backwards to safely delete "Align" items without skipping elements due to index shiftinMyGui.
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
                gW := split[1] != '' ? Round(split[1]) : 0
                gH := split[2] != '' ? Round(split[2]) : 0
                gX := 0
                gY := 0
            } else if (split.Length = 4) {
                gW := split[1] != '' ? Round(split[1]) : 0
                gH := split[2] != '' ? Round(split[2]) : 0
                gX := split[3] != '' ? Round(split[3]) : 0
                gY := split[4] != '' ? Round(split[4]) : 0
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

        ; #Region Gui Options

        ; Append any Opt
        if (Icon != "")
            Opt := ("-MinimizeBox -MaximizeBox " Opt)
        else
            Opt := ("+ToolWindow -MinimizeBox -MaximizeBox " Opt)

        ; Gui Margins
        LeftMargin   := 12            ; Left Gui margin
        RightMargin  := 8             ; Space between right side of button and right Gui edge

        ; WhiteBox Margins
        WBMargin   := 17 ; 26            ; Spacing above and below text in top area of the Gui
        WBMarginBottom  := LeftMargin                          ; Set the distance between the bottom of the white box and the top of the OK button

        ; Button Size
        ButtonWidth  := 75 ; 88            ; Width of OK button
        ButtonHeight := 23 ; 26            ; Height of OK button
        ButtonMargin := 7 ;4               ; Spacing between buttons
        ButtonOffset := 30            ; Offset between the right side of text and right edge of button
        BottomHeight := ButtonHeight+2*LeftMargin+3-4      ; Calculate the height of the bottom section of the Gui

        ; Button Controls
        ButtonWidth  := 75                 ; Standard MsgBox
        ButtonHeight := 23                 ; Standard MsgBox

        ; Gui Margins
        MinGuiWidth  := 138           ; Minimum width of Gui
        SS_WHITERECT := 0x0006        ; Gui option for white rectangle (http://ahkscript.org/boards/viewtopic.php?p=20053#p20053)

        ; #Region Create Gui

        global MyGui := Gui()
        MyGui.Opt(Opt)
        MyGui.Title := Title
        MyGui.BackColor := BackColor
        
        ; #Region Set Font Text Control

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

        MyGui.SetFont(FontSize, FontName)

        ; #Region Add WhiteBox

        ; Add a Text Control with white rectangle background, a "WhiteBox"
        ; Gui option for white rectangle (http://ahkscript.org/boards/viewtopic.php?p=20053#p20053)
        MyWhiteBox := MyGui.AddText("x0 y0 " SS_WHITERECT " vWhiteBox")   ; Add a white box at the top of the window

        ; #Region Add Text

        TextOptions := " BackgroundTrans " TextOpt
    
        MyText := MyGui.AddText(" x" LeftMargin " y" WBMargin TextOptions, Text)   ; Add the text to the Gui
  
        ; #Region Move WhiteBox

        ; Get the position of the text box
        ControlGetPos &SizeX, &SizeY, &SizeW, &SizeH, MyText.Hwnd

        ; Calculate the width of the buttons
        BottomWidth := ButtonOffset + (ButtonWidth + ButtonMargin) * ButtonCount
    
        ; Calculate the Gui width
        GuiWidth := LeftMargin+SizeW+ButtonOffset+RightMargin+1-9

        ; Choose the larger of the GuiWidth or BottomWidth
        GuiWidth := (GuiWidth > BottomWidth) ? GuiWidth : BottomWidth

        ; Make sure that it's not smaller than MinGuiWidth
        GuiWidth := GuiWidth < MinGuiWidth ? MinGuiWidth : GuiWidth

        ; Adjust the width and height of the white box
        WhiteBoxHeight := SizeY+SizeH+WBMargin 
        ControlMove(, , GuiWidth, WhiteBoxHeight, MyWhiteBox.Hwnd)

        ; Calculate the vertical position of the button
        ButtonY := WhiteBoxHeight+WBMarginBottom

        ; Calculate the overall height of the Gui
        GuiHeight := WhiteBoxHeight+BottomHeight

        ; If Gui BackColor option present then hide the WhiteBox, and adjust Button Y position
        if (BackColor != "" ) {
            MyWhiteBox.Visible := False        
            ButtonY := ButtonY - ButtonHeight/2
        }

        ; #Region Add Buttons

        ; Calculate the horizontal alignment of the buttons
        ButtonSpace := (ButtonWidth * buttonArray.Length) + (ButtonMargin * buttonArray.Length - 1)
        AlignLeft := LeftMargin
        AlignCenter := (GuiWidth / 2) - (ButtonSpace / 2)
        AlignRight := GuiWidth - ButtonSpace - RightMargin

        ; Select the Button Alignment
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

        MyGui.SetFont(FontSize, FontName)

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
            MyGui.AddButton(opt, buttonText).OnEvent("Click", _Button_Click)

            ;Calculate the horizontal position of the next button
            ButtonX += (ButtonMargin + ButtonWidth) 

        }

        ; #Region Event Handlers

        MyGui.OnEvent("Close", Gui_Close)
        MyGui.OnEvent("Escape", Gui_Escape)
        MyGui.OnEvent('ContextMenu', Gui_ContextMenu)

        ; #Region Context Menu

        MyMenu := Menu()
        MyMenu.Add('Copy to Clipboard', MenuHandler)
        MyMenu.SetIcon('Copy to Clipboard', 'shell32.dll' , 135)

        ; #Region MyGui.Show()

        ; Position the Gui on the primary monitor.
         xPos := (gX = 0) ? "" : xPos:=" x" gX
         yPos := (gY = 0) ? "" : yPos:=" y" gY

        MyGui.Show(xPos yPos "w" GuiWidth " h" GuiHeight) 

        ; Remove the ToolWindow option so that the Gui has rounded corners and no icon
        ; Trick from http://ahkscript.org/boards/viewtopic.php?p=11519#p11519
        MyGui.Opt("-ToolWindow")

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

            _ChangeWindowIcon(IconFile, IconNumber, "ahk_id" MyGui.Hwnd)
        }

        ; #Region Set Sound

        key := StrLower(Sound)

        ; If Sound then play it
        if (Sound != "") {
            if SoundMap.Has(key)
                SoundPlay soundFile := SoundMap[key]
            else if FileExist(Sound)
                SoundPlay Sound
        }

        ; #Region Wait on Gui Close
    
        WinWaitClose(MyGui.Hwnd)
        return Result

        ; #Region Handlers

        _Button_Click(Ctrl, Info) {
			Global
            MyGui.Hide()
            Result := Ctrl.Text
        }

       	Gui_ContextMenu(GuiObj, GuiCtrlObj, Item, IsRightClick, X, Y) {
		    MyMenu.Show(X, Y)
	    }

        MenuHandler(Item, *) {
		    if (Item == 'Copy to Clipboard')
			A_Clipboard := MyText.Text
        }

        Gui_Close(*){
            Result := "Close"
            MyGui.Destroy()
        }

        Gui_Escape(*) {
            MyGui.Destroy()
            Result := "Escape"
        }

        ; #Region Change Window Icon

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

