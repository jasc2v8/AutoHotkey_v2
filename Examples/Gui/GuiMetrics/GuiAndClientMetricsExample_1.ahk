; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

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

GetGuiAndClientdim(gui) {
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

esc::ExitApp


myGui := Gui()
myGui.SetFont("s12 cBlue w400", "Consolas")
myGui.Show("w450 h350")
;Sleep 100 ; ensure window is fully rendered

; get dimensions of GUI and Client area
dim := GetGuiAndClientdim(myGui)

text:=  "GUI                    : " dim.guiWidth "x" dim.guiHeight "`n" .
        "Client                 : " dim.clientWidth "x" dim.clientHeight "`n" .
        "--------------------------------`n" .
        "Top Border             : " dim.borderY "`n" .
        "Title Bar              : " dim.titleBarHeight "`n" .       
        ;"Title+Border           : " dim.titleBarWithBorderHeight "`n" .
        "Client Top Border      : " dim.borderY "`n" .
        "Client                 : " dim.clientHeight "`n" .
        "Client Bottom Border   : " dim.borderH "`n" .
        "--------------------------------`n" .
        "Gui Height Total       : " dim.borderY+dim.titleBarHeight+dim.borderY+dim.clientHeight+dim.borderY "`n`n" .

        "clientLeftX            : " dim.clientLeft "`n" .
        "clientRightX           : " dim.clientRight "`n" .
        "clientTopY             : " dim.clientTop "`n" .
        "clientBottomY          : " dim.clientBottom "`n" .
        
line := ""
loop parse text "`n", "`r`n"
    line .= A_LoopField "`n"

; "w" dim.clientWidth

myText := myGui.AddText("w" dim.clientWidth/2 " h" dim.clientHeight . 
             " x" dim.controlMinX " y" dim.controlMinY . 
             " BackgroundSilver", line)

bW := 75
bH := 25

myGui.SetFont()

bX := dim.clientWidth - bW+ dim.borderW
bY := dim.controlMinY
;myButtonYes:= myGui.AddButton("x" bX " y" bY  " w" bW " h" bH "", "Yes").OnEvent("Click", Button_Click)
myButtonOpen := myGui.AddButton("x" bX " y" bY  " w" bW " h" bH "", "Open").OnEvent("Click", Button_Click)

;TODO fix tab order

; postion the first button at the bottom right of the gui
; both work:
bX := dim.clientWidth - bW + dim.borderW
;bX := dim.guiWidth - (dim.guiWidth -dim.clientWidth) - dim.borderW - bW

;bY := dim.clientHeight - dim.borderH - bH
bY := dim.clientBottom - dim.borderH - bH

myButtonCancel := myGui.AddButton("x" bX " y" bY  " w" bW " h" bH, "Cancel").OnEvent("Click", (*) => ExitApp())

; positiong the second button to the left of the first button
bX := bX - bW - dim.borderW
myButtonOK:= myGui.AddButton("x" bX " y" bY  " w" bW " h" bH " Default", "OK").OnEvent("Click", Button_Click)

; Expand the text to the top of the buttons
;txtH := bY - dim.borderH
;myText.Move(, , , txtH)

; Expand the text to the top of the buttons and to the Open button

myGui["Open"].GetPos(&X, &Y, &W, &H)

txtW := dim.clientWidth - dim.borderW - W

;txtH := bY - dim.borderH
;myText.Move(, , txtW, txtH)

txtW := dim.clientWidth ;- dim.borderW ; - W

myText.Move(, , txtW,)

ControlFocus("OK", MyGui)

count := 0

; MyText.GetPos(&X, &Y, &Width, &Height)
; MsgBox X ", " Y ; 8,0

; border := DllCall("GetSystemMetrics", "int", 33)  ; SM_CYFRAME
; MsgBox border
; caption := DllCall("GetSystemMetrics", "int", 4)  ; SM_CYCAPTION
; MsgBox caption

; #region Functions

Button_Click(Ctrl, Info) {
    global count, myBox, myBox

    myGui.SetFont("s12 cMaroon", "Consolas")
    txtCount        :=  "`n`n`n`n`n" . 
                        "GUI          : " dim.guiWidth "x" dim.guiHeight "`n" .
                        "Client       : " dim.clientWidth "x" dim.clientHeight "`n`n" .
    txtCount        :=  "Count        : "
    txtClientArea   :=  "Client Area  : "
    txtClientTop    :=  "Client Top   : "  
    txtClientLeft   :=  "Client Left  : "
    txtClientRight  :=  "Client Right : "
    txtClientBottom :=  "Client Bottom: "

    count += 1

    switch count {

        case 1:
            myText.Text := txtCount count "`r`n" txtClientTop dim.clientTop "`r`n" txtClientLeft dim.clientLeft

            cW := 50
            cH := 50
            cX := dim.clientLeft
            cY := dim.clientTop
            myBox := myGui.AddText("x" cX " y" 0  " w" cW " h" cH " Border BackgroundRed", "")
            WinRedraw(MyGui)
            
        case 2:
            myText.Text := txtCount count "`r`n" txtClientTop dim.ClientTop "`r`n" txtClientRight dim.clientRight

            ; TODO fix this
            guiBorder:=10

            cW := 50
            cH := 50
            cX := dim.clientRight - guiBorder - cW - dim.borderW
            cY := dim.clientTop
            myBox.Move(cX, cY, cW, cH)
            WinRedraw(MyGui)
            
        case 3:
            myText.Text := txtCount count "`r`n" txtClientBottom dim.ClientBottom "`r`n" txtClientRight dim.clientRight

            guiBorder:=10

            cW := 50
            cH := 50
            cX := dim.clientRight - guiBorder - cW - dim.borderW
            cY := dim.clientBottom - dim.borderY - bh - dim.borderY
            myBox.Move(cX, cY, cW, cH)
            WinRedraw(MyGui)
            
        case 4:
            myText.Text := txtCount count "`r`n" txtClientBottom dim.ClientBottom "`r`n" txtClientLeft dim.clientLeft
  
            guiBorder:=10

            cW := 50
            cH := 50
            cX := dim.clientLeft
            cY := dim.clientBottom - dim.borderY - bh - dim.borderY
            myBox.Move(cX, cY, cW, cH)
            WinRedraw(MyGui)
            
        default:
            ; SoundBeep
            ; myText.Text := "`r`n`r`nEnd of Test.`r`n`r`nPress OK to Continue or ESCAPE to exit."
            ; ;ControlFocus("OK", MyGui)
            count := 0
            myBox.Visible := false
            myText.Value := "Press OK to Continue or Escape to Exit."
    }
    ControlFocus("OK", MyGui)
    WinRedraw(MyGui)

}


