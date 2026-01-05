0x8CC00000;AHK v2
;slightly-improved dialogs by jeeswg: sample scripts
;written for AutoHotkey v2 alpha (v2.0-a096)
;[first released: 2018-06-08]
;[updated: 2018-06-09]

;==================================================

;INTRODUCTION

;slightly-improved dialogs by jeeswg:
;1 MsgBox [big font]
;2 InputBox (+ InputBox multi) [big font/multiple fields]
;3 Progress [i.e. SplashText] [no additional features]
;4 SplashImage [option to use IE control]
;5 ToolTip [big font]
;6 Borders [show coloured borders around a rectangle]

;see also:
;7 Find dialog [custom Find dialog with whole word/RegEx options]
;Find dialog with whole word and RegEx support - AutoHotkey Community
;https://autohotkey.com/boards/viewtopic.php?f=6&t=50262

;other:
;(TrayTip) (unchanged)
;(FileSelect) (unchanged)
;(DirSelect) (unchanged)

;==================================================

;NOTES

;NOTES - GENERAL
;there are examples for:
;MsgBox/InputBox, Progress/SplashImage, ToolTip, Borders
;and finally an InputBox example demonstrating problems relating to
;Critical and Thread-Priority
;note: some MsgBox/ToolTip settings can be set in Control Panel e.g. Control Panel\Appearance and Personalization\Personalization

;NOTES - MSGBOX
;considerations: font name/size
;to do+: doesn't handle modal
;note: specify AX_MsgBoxOpt.CustomButtonCount, as 1/2/3 to use custom button names
;note: MsgBox in 'O' mode cannot distinguish between OK and X (close button)
;queries: exact specifications of system MsgBox (the XYWH window/control values appear to be very very unpredictable)

;NOTES - INPUTBOX
;considerations: font name/size, multiple input fields
;to do+: prevent InputBox getting lost under controls (currently it reactivates window, need logic for a general way to do this)
;to do+: enable timed countdown (5, 4, 3, 2, 1, need the user of SetTimer and a custom function that receives a GUI object)
;queries: do nothing until the GUI is dismissed (an alternative to WinWaitClose?)
;queries: how to get default margin values? (note: MarginX and MarginY start off as -1 until set by the user)
;queries: what is the default font? I tested on Windows 7 and it was 'Segoe UI, size 10'
;queries: window/control styles (are -0xFFFFFFFF -E0xFFFFFFFF always necessary?)
;queries: maybe a general solution re. editing dialogs is to allow a mode where you can edit the control before it's visible (could the default MsgBox/InputBox/ToolTip functions have a mode where they are hidden, so that you can edit them before they appear, possibly by temporarily blocking a show window dll function, perhaps this is more difficult with MsgBox which uses the Winapi's MessageBox function)
;queries: what is the exact size of a button (width/height)? something like text dimensions from DrawTextEx plus some arbitrary margin value perhaps
;queries: perhaps an InputBox minus an Edit control (plus extra button options) could provide an alternative to MsgBox
;note: InputBox button arrangement appears to be: MgnX[gap]OK[double gap]Cancel[gap]MgnX

;NOTES - PROGRESS/SPLASHIMAGE
;considerations: handle more image types (anigif, jxr/wdp, svg)
;to do+: font appearances don't quite match
;to do+: 'T': window is owned
;note: progress bars: if a colour is specified for the progress bar, the theme becomes old style
;note: progress bars: PBM_SETSTATE can change some colours
;note: SplashImage: this custom function uses a Static control, the built-in command uses BitBlt to draw an image
;note: source code location (Progress/SplashImage): 'Splash(' in script2.cpp
;note: additional source code location (SplashImage): 'case WM_ERASEBKGND' in script2.cpp
;note: 'FM'/'FS' refer to font size main/sub text
;note: the use of WS_THICKFRAME forces window of a minimum width

;built-in command functionality:
;options (stand-alone): A, B/B1/B2/M/M1/M2, T, Hide
;options (+ numbers): C, CB/CT/CW, FM/FS/WM/WS, P, X/Y/W/H, ZX/ZY/ZW/ZH
;options (+ range): R

;the use of Off/Show/Hide:
;Off/Show: Arg1 (Progress/SplashImage)
;Hide: Arg1 (Progress), Arg2 (SplashImage)

;possibilities for Arg1:
;Arg1: Off
;Arg1: Show
;Arg1: 3:Off [refer to nth window e.g. 3rd window][10 windows in total]
;[SplashImage (2 params): ImageFile, Options]
;Arg1: C:\MyDir\MyFile.png [bmp/(static) gif/jpg(/png/tif/ico)]
;Arg1: MyFile.png [in A_WorkingDir]
;Arg1: (blank) [image unchanged, change text]
;Arg1: HBITMAP:
;Arg1: HICON:
;[Progress (1 param): ProgressParam1 combines Arg1/Options]
;Arg1: bar position

;custom changes:
;supports 'A0' for always-on-top off
;supports 'B0' for borderless
;supports 'HFONT:' for FontName parameter
;supports 'Hide' for SplashImage's first parameter
;supports 'IE' for Internet Explorer_Server control (for more image types)
;supports 'IE###' for Internet Explorer_Server control (for more image types) (and zoom %)
;note: for 'IE': image dimensions and zoom must be specified explicitly, and the image will maintain its proportions

;NOTES - TOOLTIP
;considerations: font name/size, colours
;not using SetWindowTheme, gives an appearance like the ToolTip command: faded colours and rounded corners
;to do+: AHK has special handling when the cursor is near the edge of the screen
;queries: the built-in ToolTip at (X,Y) doesn't always work as expected (at least in Window/Client modes) (the 'OLD' ToolTips should overlap the 'XXX' ToolTips)
;queries: make it exactly central (e.g. by using precise title bar/border dimensions, versus something like creating the window hidden initially and retrieving the size)
;queries: what size margins does the ToolTip command use (otherwise what are the defaults)
;note: source code location (ToolTip): 'ToolTip(' in script2.cpp

;NOTES - BORDERS
;(none)

;NOTES - GENERAL LIMITATIONS IN BUILT-IN FUNCTIONALITY
;- cannot specify no icon
;- cannot specify class
;- problems re. Critical and Thread-Priority in custom GUI functions that built-in functions don't have
;- prefer '0xABCDEF' (or dec) to 'ABCDEF' (consistency, and the avoidance of double quotes)

;==================================================

;SETTINGS

;for Progress/SplashImage:
;include a valid path to an AHK v1 exe
;otherwise certain AHK v1 examples are skipped
vGblPathAhk1 := A_Desktop "\AutoHotkey_1.1.28.02\AutoHotkeyU32.exe"

;for SplashImage:
;include a valid path to an animated gif
;otherwise certain anigif examples are skipped
;e.g. animated gif
;https://autohotkey.com/boards/download/file.php?avatar=198_1381214069.gif
vPathAniGif := A_ScriptDir "\198 [hoppfrosch].gif"

;==================================================

#Requires AutoHotkey 2.0+
#SingleInstance force
#Persistent



SubQuickDemos:
MsgBoxNew()
AX_MsgBoxOpt.FontSize := 18
MsgBoxNew()
InputBoxNew(,,, "default")
AX_InputBoxOpt.FontSize := 18
InputBoxNew(,,, "default")
ProgressNew("", "hello", "hello"), Sleep(1500), ProgressNew("Off")
SplashImageNew(A_AhkPath), Sleep(1500), SplashImageNew("Off")
ToolTipNew("hello"), Sleep(3000), ToolTipNew()
AX_ToolTipOpt.FontSize := 18
ToolTipNew("hello"), Sleep(3000), ToolTipNew()
Borders(100, 100, 200, 200)
return

vListSub := "QMIPSTBX" ;GUI subs to execute
;vListSub := "X"

vDoInputBoxCriticalTest := 1
vDoInputBoxThreadPriorityTest := 1

if InStr(vListSub, "Q")
	Gosub SubQuickDemos
if InStr(vListSub, "M")
	Gosub SubMsgBox
if InStr(vListSub, "I")
	Gosub SubInputBox
if InStr(vListSub, "P")
	Gosub SubProgress
if InStr(vListSub, "S")
	Gosub SubSplashImage
if InStr(vListSub, "T")
	Gosub SubToolTip
if InStr(vListSub, "B")
	Gosub SubBorders
if InStr(vListSub, "X")
	Gosub SubCriticalThreadPriority
return

;==================================================

SubQuickDemos:
MsgBoxNew()
AX_MsgBoxOpt.FontSize := 18
MsgBoxNew()
InputBoxNew(,,, "default")
AX_InputBoxOpt.FontSize := 18
InputBoxNew(,,, "default")
ProgressNew("", "hello", "hello"), Sleep(1500), ProgressNew("Off")
SplashImageNew(A_AhkPath), Sleep(1500), SplashImageNew("Off")
ToolTipNew("hello"), Sleep(3000), ToolTipNew()
AX_ToolTipOpt.FontSize := 18
ToolTipNew("hello"), Sleep(3000), ToolTipNew()
Borders(100, 100, 200, 200)
return

;==================================================

SubMsgBox:
AX_MsgBoxOpt.FontSize := 18
vDoButtons := 1
vDoIcons := 1

;test buttons: 7 types: 0 to 6
vList := "O,OC,ARI,YNC,YN,RC,CTC"
if vDoButtons
	Loop Parse, vList, ","
	{
		MsgBoxNew(A_LoopField,, A_LoopField)
		MsgBox(A_LoopField,, A_LoopField)
	}
;note: ARI/YN - Close blocked
;note: result if press Esc (or alt+space, c): OK/Cancel/-/Cancel/-/Cancel/Cancel

;test icons: 4 types
vList := "x?!i"
if vDoIcons
	Loop Parse, vList
	{
		MsgBoxNew("text", "title", "Icon" A_LoopField)
		MsgBox("text", "title", "Icon" A_LoopField)
	}

;test timeout
vRet := MsgBoxNew("test timeout", "title", "T2000")
MsgBoxNew("result: " vRet)

;test return value
vRet := MsgBoxNew("the next MsgBox will state:`r`n" "return value/ErrorLevel/AX_MsgBoxResult", "title", "YNC")
MsgBoxNew("return value: " vRet "`r`n" "ErrorLevel: " ErrorLevel "`r`n" "AX_MsgBoxResult: " AX_MsgBoxResult)

;text short/long strings
;test blanks
MsgBoxNew("the next MsgBoxes will display short/long strings")
MsgBoxNew()
MsgBox()
MsgBoxNew(,, "")
MsgBox(,, "")

vText := "abcdefghijklmnopqrstuvwxyz"
vText2 := ""
Loop 100
	vText2 .= "a`n"
oArray := []
oArray.Push("")
oArray.Push("text")
oArray.Push("text`ntext`ntext")
oArray.Push("text`ntext`ntext`ntext`ntext")
oArray.Push(vText vText vText vText vText)
oArray.Push(vText vText vText vText vText vText vText vText vText vText)
oArray.Push(vText)
oArray.Push(vText "`n" vText "`n" vText)
oArray.Push(vText "`n" vText "`n" vText "`n" vText "`n" vText)
oArray.Push(vText2)
for vKey, vValue in oArray
{
	MsgBoxNew(vValue, "title")
	MsgBox(vValue, "title")
}

MsgBoxNew("the next MsgBoxes will display text with/without icons")
MsgBox(vText vText vText vText vText)
MsgBox(vText vText vText vText vText,, "Icon?")
MsgBoxNew(vText vText vText vText vText)
MsgBoxNew(vText vText vText vText vText,, "Icon?")
MsgBox(vText "`n" vText "`n" vText "`n" vText "`n" vText)
MsgBox(vText "`n" vText "`n" vText "`n" vText "`n" vText,, "Icon?")
MsgBoxNew(vText "`n" vText "`n" vText "`n" vText "`n" vText)
MsgBoxNew(vText "`n" vText "`n" vText "`n" vText "`n" vText,, "Icon?")

;test custom buttons
MsgBoxNew("the next MsgBoxes will display custom buttons")
AX_MsgBoxOpt.CustomButtonCount := 1
MsgBoxNew("custom buttons: 1")
AX_MsgBoxOpt.CustomButtonCount := 2
MsgBoxNew("custom buttons: 2")
AX_MsgBoxOpt.CustomButtonCount := 3
vRet := MsgBoxNew("custom buttons: 3")
MsgBoxNew("return value: " vRet)
AX_MsgBoxOpt.CustomButtonCount := ""
MsgBoxNew("custom buttons: off")

;test custom icon and sound
AX_MsgBoxOpt.HIconDefault := LoadPicture(A_AhkPath, "w32 h32", vType)
AX_MsgBoxOpt.SoundDefault := "C:\Windows\Media\tada.wav"
MsgBoxNew("custom icon and sound")
AX_MsgBoxOpt.HIconDefault := ""
AX_MsgBoxOpt.SoundDefault := "-"
return

;==================================================

SubInputBox:
AX_InputBoxOpt.FontSize := 18
;InputBoxNew("text", "title", "T1000", "default")
vRet := InputBoxNew("text", "title",, "default")
MsgBox(vRet)
;MsgBox(ErrorLevel "`r`n" AX_InputBoxResult)

;InputBoxMulti(["ITEM 1`naaa","ITEM 2`nbbb","ITEM 3`nccc"], vWinTitle:="", vOpt:="", ["AAA","BBB","CCC"])
oArray := InputBoxMulti(["aaa","bbb","ccc"], vWinTitle:="", vOpt:="", ["AAA","BBB","CCC"])
if IsObject(oArray)
	MsgBox(oArray.1 "`r`n" oArray.2 "`r`n" oArray.3 "`r`n" oArray.4)
else
	MsgBox("")
;MsgBox(ErrorLevel "`r`n" AX_InputBoxResult)

InputBox("text", "title",, "default")
InputBoxNew("text", "title",, "default")
InputBox("text", "title", "Password+", "default")
InputBoxNew("text", "title", "Password+", "default")
InputBox("text",,, "default")
InputBoxNew("text",,, "default")
return

SubCriticalThreadPriority:
;can't be used with Critical or Thread-Priority,
;which is an argument for good built-in functions
MsgBox("the next and final custom GUI will demonstrate an issue with custom GUIs and Critical/Thread-Priority, i.e. it can't be closed")
if 1
{
	if vDoInputBoxCriticalTest
		Critical()
	if vDoInputBoxThreadPriorityTest
		Thread("Priority", 1)
	vRet := InputBoxNew("text", "title",, "default")
	MsgBox(vRet)
}
return

;==================================================

SubProgress:
;vGblPathAhk1 := A_Desktop "\AutoHotkey_1.1.28.02\AutoHotkeyU32.exe"
vDelay := 3000
vGblDelayAhk1 := vDelay
;note: the 'vGbl' variables are for use with the diagnostic ProgressAhk1 function

;vTemp := "hello"
vTemp := "abcdefghijklmnopqrstuvwxyz"
vText := vTemp "`n" vTemp "`n" vTemp "`n" vTemp "`n" vTemp

vFormat := "zh0 b c0 fs18" ;no border + left
ProgressAhk1(vFormat, vText)
ProgressNew(vFormat, vText), Sleep(vDelay), ProgressNew("Off")
vFormat := "zh0 b1 fs18" ;border + centre
ProgressAhk1(vFormat, vText)
ProgressNew(vFormat, vText), Sleep(vDelay), ProgressNew("Off")
vFormat := "b2"
ProgressAhk1(vFormat, vText)
ProgressNew(vFormat, vText), Sleep(vDelay), ProgressNew("Off")
return

if 1
{
	ProgressAhk1("", vText)
	ProgressNew("", vText), Sleep(vDelay), ProgressNew("Off")
	ProgressAhk1("fs4", vText)
	ProgressNew("fs4", vText), Sleep(vDelay), ProgressNew("Off")
	ProgressAhk1("fs24", vText)
	ProgressNew("fs24", vText), Sleep(vDelay), ProgressNew("Off")
}

ProgressAhk1("P30", "SubText", "MainText", "WinTitle")
ProgressNew("P30", "SubText", "MainText", "WinTitle"), Sleep(vDelay), ProgressNew("Off")

ProgressAhk1("P30 CWFF0000 CBFFFF00 CT0000FF", "SubText", "MainText", "WinTitle")
ProgressNew("P30 CW0xFF0000 CB0xFFFF00 CT0x0000FF", "SubText", "MainText", "WinTitle"), Sleep(vDelay), ProgressNew("Off")

ProgressAhk1("P7500 R0-10000 CWFF0000 CBFFFF00 CT0000FF", "SubText", "MainText", "WinTitle")
ProgressNew("P7500 R0-10000 CW0xFF0000 CB0xFFFF00 CT0x0000FF", "SubText", "MainText", "WinTitle"), Sleep(vDelay)
ProgressNew(10000), Sleep(vDelay), ProgressNew("Off")
return

;==================================================

SubSplashImage:
;vGblPathAhk1 := A_Desktop "\AutoHotkey_1.1.28.02\AutoHotkeyU32.exe"
vDelay := 1500
vGblDelayAhk1 := vDelay
;e.g. animated gif
;https://autohotkey.com/boards/download/file.php?avatar=198_1381214069.gif
;vPathAniGif := A_ScriptDir "\198 [hoppfrosch].gif"
;note: the 'vGbl' variables are for use with the diagnostic SplashImageAhk1 function
vPath := A_AhkPath

if 1
{
	SplashImageAhk1(vPath)
	SplashImageNew(vPath), Sleep(vDelay), SplashImageNew("Off")

	SplashImageAhk1(vPath, "M2 X0 Y0", "SubText", "MainText", "WinTitle")
	SplashImageNew(vPath, "M2 X0 Y0", "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageAhk1(vPath, "M1 X200 Y200", "SubText", "MainText", "WinTitle")
	SplashImageNew(vPath, "M1 X200 Y200", "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageAhk1(vPath, "M X400 Y400", "SubText", "MainText", "WinTitle")
	SplashImageNew(vPath, "M X400 Y400", "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageAhk1(vPath, "B X600 Y600", "SubText", "MainText", "WinTitle")
	SplashImageNew(vPath, "B X600 Y600", "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")

	SplashImageNew("1:" vPath, "M2 X0 Y0", "SubText", "MainText", "WinTitle")
	SplashImageNew("2:" vPath, "M1 X200 Y200", "SubText", "MainText", "WinTitle")
	SplashImageNew("3:" vPath, "M X400 Y400", "SubText", "MainText", "WinTitle")
	SplashImageNew("4:" vPath, "B X600 Y600", "SubText", "MainText", "WinTitle")
	Sleep(vDelay)
	SplashImageNew("1:Off")
	SplashImageNew("3:Off")
	Sleep(vDelay)
	SplashImageNew("2:Off")
	SplashImageNew("4:Off")
}

if 1
{
	hIcon := LoadPicture(vPath,, vImgType)
	;compare load hIcon v. load path
	;SplashImageAhk1("HICON:" hIcon,, "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageNew("HICON:" hIcon,, "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageAhk1(vPath,, "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageNew(vPath,, "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")

	hIcon := LoadPicture("shell32.dll", "icon35", vImgType)
	;SplashImageAhk1("HICON:" hIcon,, "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageNew("HICON:" hIcon,, "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
}

if FileExist(vPathAniGif)
if 1
{
	vImgW := 80, vImgH := 63
	vImgW += 20, vImgH += 30 ;add margins
	vImgPos := Format("ZW{} ZH{}", vImgW, vImgH)
	SplashImageNew(vPathAniGif, "IE " vImgPos, "SubText", "MainText", "WinTitle"), Sleep(vDelay*1.6), SplashImageNew("Off")
	vImgW *= 3, vImgH *= 3 ;zoom
	vImgPos := Format("ZW{} ZH{}", vImgW, vImgH)
	SplashImageNew(vPathAniGif, "IE300 " vImgPos, "SubText", "MainText", "WinTitle"), Sleep(vDelay*1.6), SplashImageNew("Off")

	SplashImageNew(vPathAniGif,, "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageNew(vPathAniGif, "ZW300", "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageNew(vPathAniGif, "ZH300", "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageNew(vPathAniGif, "ZW600 ZH300", "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageNew(vPathAniGif, "ZW300 ZH300", "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	SplashImageNew(vPathAniGif, "ZW300 ZH-1", "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
}

if 1
{
	SplashImageNew(vPath,, "SubText", "MainText", "WinTitle")
	Sleep(vDelay)
	SplashImageNew(, "Hide")
	Sleep(vDelay)
	SplashImageNew("Show")
	Sleep(vDelay)
	SplashImageNew("Off")
	Sleep(vDelay)

	hBitmap := LoadPicture(vPath, "W256 H256")
	SplashImageNew("HBITMAP:" hBitmap,, "", "", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	hIcon := LoadPicture(vPath, "W256 H256", vImgType)
	SplashImageNew("HICON:" hIcon,, "", "", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")

	hBitmap := LoadPicture(vPath, "W256 H256")
	SplashImageNew("HBITMAP:" hBitmap,, "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
	hIcon := LoadPicture(vPath, "W256 H256", vImgType)
	SplashImageNew("HICON:" hIcon,, "SubText", "MainText", "WinTitle"), Sleep(vDelay), SplashImageNew("Off")
}
return

;==================================================

SubToolTip:
;test standard ToolTips
if 0
{
	CoordMode("ToolTip", "Screen")
	ToolTip("Client ___ Window ___ SCREEN",,, 1)
	CoordMode("ToolTip", "Window")
	ToolTip("Client ___ WINDOW",,, 2)
	CoordMode("ToolTip", "Client")
	ToolTip("CLIENT",,, 3)
	Sleep(3000)

	CoordMode("ToolTip", "Screen")
	ToolTip("SCREEN", 300, 300, 1)
	CoordMode("ToolTip", "Window")
	ToolTip("WINDOW", 300, 300, 2)
	CoordMode("ToolTip", "Client")
	ToolTip("CLIENT", 300, 300, 3)
	Sleep(3000)

	ToolTip(,,, 1)
	ToolTip(,,, 2)
	ToolTip(,,, 3)
}

CoordMode("ToolTip", "Screen")
CoordMode("ToolTip", "Window")
CoordMode("ToolTip", "Client")
ToolTip("XXX 300 300", 300, 300, 4)
ToolTip("XXX",,, 5)

AX_ToolTipOpt.FontSize := 18
;vText := "   hello world   `r`nhello world`r`nhello world"
vText := "hello world`r`nhello world`r`nhello world"
vDelay := 1500

ToolTipNew(vText)
Sleep(vDelay)
ToolTipNew()

ToolTipNew(vText, "c", "c")
Sleep(vDelay)
ToolTipNew()

ToolTipNew(vText, "c", "c",, 0x0000FF, 0xFFFF00)
Sleep(vDelay)
ToolTipNew()

ToolTipNew(vText, "c", "c",, 0xFFFF00, 0x0000FF)
Sleep(vDelay)
ToolTipNew()

ToolTipNew(vText, 100, 100, 1)
ToolTipNew(vText, 200, 200, 2)
ToolTipNew(vText, 300, 300, 3)
Sleep(vDelay)
;Sleep(vDelay * 3)
ToolTipNew(,,, 1)
ToolTipNew(,,, 2)
ToolTipNew(,,, 3)

AX_ToolTipOpt.FontSize := 9
ToolTipNew(vText, "c", "c")
ToolTip(vText)
Sleep(vDelay)
ToolTipNew()
ToolTip()

;confirm they overlap at (X,Y)
ToolTipNew("NEW" A_Space A_Space A_CoordModeToolTip)
ToolTip("OLD")
Sleep(vDelay)
ToolTipNew()
ToolTip()

;confirm they overlap when (X,Y) not specified
ToolTipNew("NEW" A_Space A_Space A_CoordModeToolTip, 300, 300)
ToolTip("OLD", 300, 300)
Sleep(vDelay)
ToolTipNew()
ToolTip()

ToolTip(,,, 4)
ToolTip(,,, 5)
return

;w:: ;ToolTip - get margins
;ToolTip via AutoHotkey ToolTip command reports 0,0,0,0
VarSetCapacity(RECT, 16, 0)
SendMessage(0x41B,, &RECT,, "ahk_class tooltips_class32") ;TTM_GETMARGIN := 0x41B
vOutput := NumGet(&RECT, 0, "UInt")
vOutput .= "," NumGet(&RECT, 4, "UInt")
vOutput .= "," NumGet(&RECT, 8, "UInt")
vOutput .= "," NumGet(&RECT, 12, "UInt")
MsgBox(vOutput)
return

;==================================================

SubBorders:
;draw borders around the active window/control
hWnd := WinGetID("A")
vCtlClassNN := ControlGetFocus("ahk_id " hWnd)
hWnd := ControlGetHwnd(vCtlClassNN, "ahk_id " hWnd)
WinGetPos(vCtlX, vCtlY, vCtlW, vCtlH, "ahk_id " hWnd)
Borders(vCtlX, vCtlY, vCtlW, vCtlH)
return

;==================================================
