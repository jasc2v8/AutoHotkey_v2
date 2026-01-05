; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
#Warn Unreachable, Off
Esc::ExitApp

/*
    ---------------------------
    GuiAndClientdimExample.ahk
    ---------------------------
    GUI: 416x339
    Client: 400x300
    controlMaxWidth: 384
    controlMaxHeight: 292
    controlMinX: 8
    controlMinY: 0
    borderW: 8
    borderH: 8
    ---------------------------
    OK   
    ---------------------------

    The Gui is the window frame.
    Inside the Gui is the Client area for the Gui Controls.
    Gui("w400 h300") creates a Gui 416x339 with Client 400x300
    Gui Construction:
    ---------------------------------------
            Gui Top                   Width
    ---------------------------------------
    Top Window Border (t, b, l, r)                      =    8
    Title Bar (caption area)                            =   23  client.TitleBarHeight or gui.TitleBarHeight
    Controls                                            =  292  client.Top, Bottom, Left, Right, client.Width, client.Height
    Bottom Window border                                =    8
    ---------------------------------------
            Gui Bottom
    --------------------------------------        
    Gui Height                         339 (8+23+8+292+8)
    Client Height                      300 (292 + border 8)
    --------------------------------------
    Lborder Client Width    Rborder
        8   400                8    =  416 Width
    --------------------------------------
    Gui Width                          416 (Lborder 8 + 400 Rborder 8)
    Client Width                       400 
    --------------------------------------

    XTotal= 8 + 400 + 8 = 416 (match gui above)
    Gui W =
    Gui H = 8+23+8+292+8 = 339 (matches gui above)
    Client W = GuiW - border8 - border8 = 400
    Client H = GuiH339 - border8 - titleBar23 - border8 = 300

    Client TopY     = TopBorder8 + TitleBar23 + border8 = 39
    Client BottomY  = GuiH339 - border8 = 331


*/

GetGuiAndClientPos(aGui) {

    WinGetPos(,, &GuiWidth, &GuiHeight, aGui.Hwnd)

    aGui.GetClientPos(,, &ClientWidth, &ClientHeight)

    BorderX := (GuiWidth - ClientWidth) // 2    ; 8
    BorderY := BorderX
    BorderW := BorderX
    BorderH := BorderX

    ClientTop       :=0 ; always
    ClientLeft      :=0 ; always
    ClientBottom    := ClientHeight - BorderH
    ClientRight     := borderW + ClientWidth    ; both are the same = 458 (PREFERED)
    clientRightAlt  := GuiWidth - BorderX       ; both are the same = 458

    clientMaxW := ClientWidth - borderW - borderW
    clientMaxH := ClientHeight - borderH

    nop:=true

    return { 
        GuiWidth: GuiWidth,
        GuiHeight: GuiHeight,

        ClientWidth: ClientWidth,
        ClientHeight: ClientHeight,

        ClientMaxW: clientMaxW,
        ClientMaxH: clientMaxH,

        ClientTop: ClientTop,
        ClientLeft: ClientLeft,
        ClientBottom: ClientBottom,
        ClientRight: ClientRight,
        clientRightAlt: clientRightAlt,



        BorderX: BorderX,
        BorderY: BorderY,
        BorderW: BorderW,
        BorderH: BorderH,
    }
}


GetGuiAndClientDim(gui) {
    hwnd := gui.Hwnd

    ; Get full GUI dimensions
    myGui.GetPos(&guiX, &guiY, &guiW, &guiH) ; 752, 346, 416, 339

    ; Get client area dimensions
    ;   GetClientRect does not populate left and top because it always returns a rectangle with 
    ;   the top-left corner at (0, 0) relative to the client area.
    rc := Buffer(16, 0) ; RECT struct: left, top, right, bottom
    DllCall("GetClientRect", "ptr", hwnd, "ptr", rc)
    clientLeft  := NumGet(rc, 0, "int")  ; always   0
    clientTop   := NumGet(rc, 4, "int")  ; always   0
    clientW     := NumGet(rc, 8, "int")  ; rightX   400
    clientH     := NumGet(rc, 12, "int") ; bottomY  300

    ; Calculate borders height (assumes symmetrical borders)
    borderX := (guiW - clientW) // 2    ; 8
    borderY := borderX ; 8
    borderW := borderX ; 8
    borderH := borderX ; 8

    ; Calculate title bar height
    titleBarWithBorderH := guiH - clientH - borderX ; 31
    titleBarH           := titleBarWithBorderH - borderY ; 23

    ; add a contorl set to maximum client size less margins
    ctrlX := borderW
    ctrlY := 0

    ; In AutoHotkey v2, the default margins that apply when adding controls to a 
    ; Gui object are 10 pixels for both horizontal and vertical spacing.
    ; However, this example calculates 8 pix.

    clientMaxW := clientW - borderW - borderW   ; 384 left and right borders
    clientMaxH := clientH - borderH             ; 292

    clientBottom := clientH - borderH
    ;clientRight := borderW + clientW
    clientRight := guiW - borderX
    ;myGui.AddText("w" clientMaxW " h" clientMaxH " x" ctrlX " y" ctrlY " Border BackgroundSilver")
 
    nop:=true

    return { 
        guiWidth: guiW,
        guiHeight: guiH,
        clientLeft: borderW,
        clientWidth: clientW,
        clientHeight: clientH,
        clientWidth: clientMaxW,
        clientHeight: clientMaxH,
        controlMinX: borderW,
        controlMinY: ctrlY,
        borderX: borderX,
        borderY: borderY,
        borderW: borderX,
        borderH: borderH,
        titleBarHeight: titleBarH,
        titleBarWithBorderHeight: titleBarWithBorderH,
        controlLeft: clientLeft,
        clientRight: clientRight,
        clientTop: clientTop,
        clientBottom:clientBottom,
    }
}

; #region Example



myGui := Gui()
myGui.SetFont("s12 cBlue w400", "Consolas")
myGui.Show("w450 h350")
;Sleep 100 ; ensure window is fully rendered

dllpos := GetGuiAndClientDim(myGui)

dim := GetGuiAndClientPos(myGui)

guiBorder:=10

;***************** Get Border widths *****************


;MsgBox dim.clientRightAlt " : " dim.clientRightAlt

myGui.AddText("w50 h25 Border BackgroundBlue vTestLeftMargin")
myGui["TestLeftMargin"].GetPos(&X, &Y, &W, &H)
cX := X
gX := dim.ClientLeft
LeftMargin := cX - gX
;MsgBox LeftMargin ; 15 = the default X margin when a control is added without an X parameter

cW := dim.ClientWidth
gW := dim.GuiWidth
RightBorder := gW - cW ; 16 = the difference betweed the gui and client width

guiY := dim.GuiHeight
clientY := dim.ClientBottom
BottomBorder := guiY - clientY ; 47 ; actually 39 plus Border 8

;                 16 : 47              ,               389: 350
;MsgBox RightBorder " : " BottomBorder ", " dim.GuiHeight ": " dim.ClientHeight

; #region Border

controlMinX:= dim.BorderW
controlMinY:= dim.ClientTop

myText := myGui.AddText("w" dim.clientMaxW " h" dim.clientMaxH . 
             " x" controlMinX " y" controlMinY . 
             " BackgroundTrans Border", "")

cW := 50
cH := dim.ClientHeight ; dim.ClientMaxH
cX := dim.ClientWidth // 6
cY := dim.ClientTop
ClientHeightBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundYellow Center", "#1 w" cW " h" cH)

cW := 50
cH := dim.ClientMaxH ; dim.ClientHeight - 8
cX := dim.ClientWidth - 125
cY := dim.ClientTop
;ClientHeightBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundYellow Center", "#2 w" cW " h" cH)


;MsgBox

; #region Top Left

myGui.SetFont("s11 cWhite", "Consolas")

cW := 50
cH := 50
cX := dim.clientLeft
cY := dim.clientTop
TopLeftBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundRed Center", "x" cX " y" cY)

; #region Top Right

;myText.Text := txtCount count "`r`n" txtClientBottom dim.ClientBottom "`r`n" txtClientRight dim.clientRight


cW := 50
cH := 50
cX := dim.clientRight - guiBorder - cW - dim.borderW
cY := dim.clientTop
TopRightBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundRed Center", "x" cX " y" cY)

; #region Bottom Right

;myText.Text := txtCount count "`r`n" txtClientBottom dim.ClientBottom "`r`n" txtClientRight dim.clientRight

guiBorder:=10

cW := 50
cH := 50
cX := dim.clientRight - guiBorder - cW - dim.borderW
cY := dim.clientBottom - dim.borderY - 10 - dim.borderY
BottomRightBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundRed Center", "x" cX " y" cY)

; #region Bottom Left

;myText.Text := txtCount count "`r`n" txtClientBottom dim.ClientBottom "`r`n" txtClientLeft dim.clientLeft

guiBorder:=10

cW := 50
cH := 50
cX := dim.clientLeft
cY := dim.clientBottom - dim.borderY - 10 - dim.borderY
BottomLeftBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundRed Center", "x" cX " y" cY)

; #region Client Width

cW := dim.clientMaxW ; dim.ClientWidth - RightBorder ; 16 ;dim.BorderX*2
cH := 25
cX := 8 ; dim.clientLeft
cY := dim.ClientHeight //2
ClientWidthBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundRed Center", "#1 x" cX " y" cY  " w" cW  " h" cH )

cW := dim.ClientMaxW ; dim.ClientMaxW ; dim.ClientWidth
cH := 25
cX := dim.clientLeft + dim.BorderW
cY := dim.ClientHeight - 124
;ClientWidthBox2 := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundRed Center", "#1 x" cX " y" cY  " w" cW  " h" cH )
ClientWidthBox2 := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundRed Center", "#2 x" cX " y" cY  " w" cW  " h" cH )

; default controlMargin

bw := 50
;cX := dim.ClientLeft  + dim.BorderW*2 ; dim.ClientMaxW - bW ; dim.clientLeft + dim.BorderW
cY := dim.ClientHeight - 100
cW := 50 ;dim.ClientMaxW ; dim.ClientMaxW ; dim.ClientWidth
cH := 25
bM := 8
myGui.AddButton(" w" cW " h" cH " ", "Ok") ; adds the button at the left side with no buttonMargin

;*** Left Buttons
; bw := 50
; cX := dim.ClientLeft  + dim.BorderW*2 ; dim.ClientMaxW - bW ; dim.clientLeft + dim.BorderW
; cY := dim.ClientHeight - 100
; cW := 50 ;dim.ClientMaxW ; dim.ClientMaxW ; dim.ClientWidth
; cH := 25
; bM := 8
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "Ok")
; cx += bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "Yes")
; cx += bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "No")
; cx += bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "No")

; bw := 50
; cX := dim.ClientLeft  + dim.BorderW*2 ; dim.ClientMaxW - bW ; dim.clientLeft + dim.BorderW
; cY := dim.ClientHeight - 130
; cW := 50 ;dim.ClientMaxW ; dim.ClientMaxW ; dim.ClientWidth
; cH := 25
; bM := dim.BorderW
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "Ok")
; cx += bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "Yes")
; cx += bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "No")
; cx += bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "No")


;*** Right Buttons
; bw := 50
; cX := dim.ClientMaxW - bW ; dim.clientLeft + dim.BorderW
; cY := dim.ClientHeight - 100
; cW := 50 ;dim.ClientMaxW ; dim.ClientMaxW ; dim.ClientWidth
; cH := 25
; bM := 10
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "Ok")
; cx -= bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "Yes")
; cx -= bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "No")
; cx -= bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "No")

; cX := dim.ClientMaxW - bW ; dim.clientLeft + dim.BorderW
; cY := dim.ClientHeight - 130
; bM := dim.BorderX
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "No")
; cx -= bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "No")
; cx -= bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "No")
; cx -= bw + bM
; myGui.AddButton("x" cX " y" cY  " w" cW " h" cH " ", "No")


; #region Gui Dim

text:=  "myGui.Show : (w450 h350)" "`n" . 
        "GUI    : " dim.guiWidth "x" dim.guiHeight "`n" .
        "Client : " dim.clientWidth "x" dim.clientHeight "`n" 

cW := dim.ClientWidth
cH := 60
cX := dim.clientLeft
cY := dim.ClientHeight // 4
ClientWidthBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundRed Center", text)

cW := 50
cH := dim.ClientHeight
cX := dim.ClientWidth // 2
cY := dim.ClientHeight
ClientHeightBox := myGui.AddText("x" cX " y" cY  " w" cW " h" cH " Border BackgroundYellow Center", "H ????")


MsgBox

; get dimensions of GUI and Client area
; dim := GetGuiAndClientdim(myGui)

; text:=  "GUI                    : " dim.guiWidth "x" dim.guiHeight "`n" .
;         "Client                 : " dim.clientWidth "x" dim.clientHeight "`n" .
;         "--------------------------------`n" .
;         "Top Border             : " dim.borderY "`n" .
;         "Title Bar              : " dim.titleBarHeight "`n" .       
;         ;"Title+Border           : " dim.titleBarWithBorderHeight "`n" .
;         "Client Top Border      : " dim.borderY "`n" .
;         "Client                 : " dim.clientHeight "`n" .
;         "Client Bottom Border   : " dim.borderH "`n" .
;         "--------------------------------`n" .
;         "Gui Height Total       : " dim.borderY+dim.titleBarHeight+dim.borderY+dim.clientHeight+dim.borderY "`n`n" .

;         "clientLeftX            : " dim.clientLeft "`n" .
;         "clientRightX           : " dim.clientRight "`n" .
;         "clientTopY             : " dim.clientTop "`n" .
;         "clientBottomY          : " dim.clientBottom "`n" .
        
; line := ""
; loop parse text "`n", "`r`n"
;     line .= A_LoopField "`n"

; ; "w" dim.clientWidth

; myText := myGui.AddText("w" dim.clientWidth/2 " h" dim.clientHeight . 
;              " x" dim.controlMinX " y" dim.controlMinY . 
;              " BackgroundSilver", line)

; bW := 75
; bH := 25

; myGui.SetFont()

; bX := dim.clientWidth - bW+ dim.borderW
; bY := dim.controlMinY
; ;myButtonYes:= myGui.AddButton("x" bX " y" bY  " w" bW " h" bH "", "Yes").OnEvent("Click", Button_Click)
; myButtonOpen := myGui.AddButton("x" bX " y" bY  " w" bW " h" bH "", "Open").OnEvent("Click", Button_Click)

; ;TODO fix tab order

; ; postion the first button at the bottom right of the gui
; ; both work:
; bX := dim.clientWidth - bW + dim.borderW
; ;bX := dim.guiWidth - (dim.guiWidth -dim.clientWidth) - dim.borderW - bW

; ;bY := dim.clientHeight - dim.borderH - bH
; bY := dim.clientBottom - dim.borderH - bH

; myButtonCancel := myGui.AddButton("x" bX " y" bY  " w" bW " h" bH, "Cancel").OnEvent("Click", (*) => ExitApp())

; ; positiong the second button to the left of the first button
; bX := bX - bW - dim.borderW
; myButtonOK:= myGui.AddButton("x" bX " y" bY  " w" bW " h" bH " Default", "OK").OnEvent("Click", Button_Click)

; ; Expand the text to the top of the buttons
; ;txtH := bY - dim.borderH
; ;myText.Move(, , , txtH)

; ; Expand the text to the top of the buttons and to the Open button

; myGui["Open"].GetPos(&X, &Y, &W, &H)

; txtW := dim.clientWidth - dim.borderW - W

; ;txtH := bY - dim.borderH
; ;myText.Move(, , txtW, txtH)

; txtW := dim.clientWidth ;- dim.borderW ; - W

; myText.Move(, , txtW,)

; ControlFocus("OK", MyGui)

; count := 0

; ; MyText.GetPos(&X, &Y, &Width, &Height)
; ; MsgBox X ", " Y ; 8,0

; ; border := DllCall("GetSystemMetrics", "int", 33)  ; SM_CYFRAME
; ; MsgBox border
; ; caption := DllCall("GetSystemMetrics", "int", 4)  ; SM_CYCAPTION
; ; MsgBox caption

; ; #region Functions


Button_Click(Ctrl, Info) {


}


