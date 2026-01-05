; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
#Requires AutoHotkey v2.0

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


    Gui("w400 h300") creates a Gui 416x339 Client 400x300
    Inside the Gui is the Client area for the Gui Controls 400x300
    Gui Construction:
                 Gui Top                =    0
        Lborder Topborder       Rborder =    8 Topborder=8, L+Rborder=8
            |   title bar          |    =   23
            |   border             |    =    8
            |   client top         |    =    0
            |   client area        |    =  292
            |   client bottom      |    =    0
            |   border             |    =    8
        Lborder Gui Bottom      bottom  =    0
        --------------------------------------
        YTotal                             339
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

    ; Calculate border and title bar thickness
    ; assumes symmetrical borders
    borderX := (guiW - clientW) // 2    ; 8
    borderY := guiH - clientH - borderX ; 31

    ; assumes symmetrical borders
    borderW := borderX ; 8
    borderH := borderX ; 8

    titleBarH := BorderY - borderX ; 23

    ; add a contorl set to maximum client size less margins
    ctrlX := borderW
    ctrlY := 0

    ; In AutoHotkey v2, the default margins that apply when adding controls to a 
    ; Gui object are 10 pixels for both horizontal and vertical spacing.
    ; However, this example calculates 8 pix.

    clientMaxW := clientW - borderW - borderW   ; 384 left and right borders
    clientMaxH := clientH - borderH             ; 292

    ;myGui.AddText("w" clientMaxW " h" clientMaxH " x" ctrlX " y" ctrlY " Border BackgroundSilver")
 
    return { 
        guiWidth: guiW,
        guiHeight: guiH,
        clientWidth: clientW,
        clientHeight: clientH,
        controlMaxWidth: clientMaxW,
        controlMaxHeight: clientMaxH,
        controlMinX: borderW,
        controlMinY: ctrlY,
        borderW: borderX,
        borderH: borderH
    }
}

; #region Example

esc::ExitApp


myGui := Gui()
myGui.SetFont("s18 cBlue w400", "Consolas")
myGui.Show("w400 h300")
;Sleep 100 ; ensure window is fully rendered

; get dimensions of GUI and Client area
dim := GetGuiAndClientdim(myGui)

text:=  "GUI             : " dim.guiWidth "x" dim.guiHeight "`n" .
        "Client          : " dim.clientWidth "x" dim.clientHeight "`n" .
        "controlMaxWidth : " dim.controlMaxWidth "`n" .
        "controlMaxHeight: " dim.controlMaxHeight "`n" .
        "controlMinX     : " dim.controlMinX "`n" .
        "controlMinY     : " dim.controlMinY "`n" .
        "borderW         : " dim.borderW "`n" .
        "borderH         : " dim.borderH
        
line := ""
loop parse text "`n", "`r`n"
    line .= A_LoopField "`n"

myEdit :=myGui.AddEdit("w" dim.controlMaxWidth " h" dim.controlMaxHeight . 
             " x" dim.controlMinX " y" dim.controlMinY . 
             " r10 -vScroll BackgroundSilver ", line)

bW := 75
bH := 25

; postion the first button at the bottom right of the gui
; both work:
bX := dim.controlMaxWidth - bW + dim.borderW
;bX := dim.guiWidth - (dim.guiWidth -dim.clientWidth) - dim.borderW - bW

bY := dim.controlMaxHeight - dim.borderH - bH

myGui.SetFont()
myButtonCancel := myGui.AddButton("x" bX " y" bY  " w" bW " h" bH, "Cancel").OnEvent("Click", (*) => ExitApp())

; positiong the second button to the left of the first button
bX := bX - bW - dim.borderW
myButtonOK:= myGui.AddButton("x" bX " y" bY  " w" bW " h" bH, "OK").OnEvent("Click", (*) => SoundBeep())

; Expand the text to the top of the buttons
txtH := bY - dim.borderH
myEdit.Move(, , , txtH)

;myEdit.Redraw()


