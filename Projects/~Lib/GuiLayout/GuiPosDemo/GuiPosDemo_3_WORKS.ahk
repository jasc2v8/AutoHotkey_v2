; TITLE:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    is Bottom 2 pixels shortY?
    
    fix right margins
    make sure other scripts aren't running.

    
    x:= L.Pos().Left+L.Margin+bH+L.Margin => L.Move(b1, L.().Left)

    X := L.Pos().Right  - bW         =>   L.Move(myGuiCtrl, L.().Right)

    Y := L.Pos().Border + L.Margin   =>   no, that's OK, focus only on Client!

    X := L.Pos().Width-b1W-b2W-L.Margin    => L.Pos().Right-b1W-b2W =>   L.Move(b2, L.(b1).Right)

    2 pixels ~line 233

        ;returns a string with the .OnEvent: ButtonOK := myGui.AddButton("w" bw " h" bh, "ok").OnEvent("Click", Button_Click)

*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
#Warn Unreachable, Off
Esc::ExitApp

#Include ..\..\..\Projects\GuiLayout\GuiLayoutClass.ahk

/*
    Client x,y = 450, 350

    Width           434		450 width - 9 margin left + 1pix - 9 margin right + 1pix
    Height          334		350 height - 9 margin left + 1pix - 9 margin right + 1pix
    WindowBorder      5     14 CL x - 9 margin = 5
    Margin            9     52 CL width - 38 TL with = 14 - 5 window border = 9
    Left             14     WindowBorder + Margin
    Right			441     (450 client width - 9 margin=441) - 38 button width=403 button Y
    Top               9     client top - margin
    Bottom          341     (350 client height - 9 margin=341) - 34 button height=307 button Y

*/

; #region Example
global testExit := false
global bw:= 30
global bh:= 25

Demo1()

;----------------------------------------------------

Button_Click(Ctrl, Info) {
global testExit

    if testExit
        ExitApp()

    if (Ctrl.Text = "Demo #2") {
        Ctrl.Gui.Move(200)
        Demo2()
    }

    if (Ctrl.Text = "Demo #1") {
        Reload
    }

    testExit:=false

    ;ToolTip "Click", 208, Y
    ;ButtonClick.Visible:=false

    ;AddControls()

    ;Ctrl.Text:="Click Again"
    ;ButtonClick.Visible:=true
    ;Sleep(1000)
    ;ToolTip

}

Demo1() {
    global bw, bh

    myGui := Gui("+Resize", "Demo #1 - Calculated Positions")
    myGui.SetFont("s9 cBlue w400", "Consolas")
    myGui.BackColor:="Silver"
    myGui.Show("w450 h350")

    DemoDelay:=0

    w:= 75
    x :=450/2-w/2
    y :=350/2-bh/2 + 25

    ;returns a string with the .OnEvent: ButtonOK := myGui.AddButton("w" bw " h" bh, "ok").OnEvent("Click", Button_Click)

    ButtonClick := myGui.AddButton("w" w " h" bh " Default", "Demo #2")
    ButtonClick.OnEvent("Click", Button_Click)
    ButtonClick.Move(x,y)

    w:=250
    h:=300
    x:= x-40
    y:= 0 + 10
    text :=
        "TL = Top Left`r`n" .
        "TR = Top Right`r`n" . "`r`n" .
        "BR = Bottom Right`r`n" .
        "BL = Bottom Left`r`n" . "`r`n" .
        "CT = Client Top (No Margin)`r`n" .
        "CR = Client Right (No Margin)`r`n" .
        "CB = Client Bottom (No Margin)`r`n" .
        "CL = Client Left (No Margin)`r`n" .
        ""


    myText := myGui.AddText(" x" x " y" y " w" w " h" h " BackgroundSilver", text)

    AddControls()

    AddControls() {

        ; First, I added all the buttons a their default x,y
        ; Then I used those x,y to move them to their default pos
        x:= 10   ; 9 margin + 1 pixel
        y:= 9    ; 9 margin = Client Top
        ButtonTL := myGui.AddButton("", "TL")
        ButtonTL.Move(x,y)

        Sleep(DemoDelay)

        x:= 10+9+30 ; 49: 10 window border + 9 margin + 30 button width
        y:= 0
        h:= 35
        ButtonCT := myGui.AddButton("yp", "CT") ; Client Top
        ButtonCT.Move(x, y, , h)

        Sleep(DemoDelay)

        x:= 0
        y:= 43  ; 48: 9 margin + 25 button height + 9 margin
        w:= 52  ; 61: 5 window border + 9 margin + 38 button width
        ;h:=
        ButtonCL := myGui.AddButton("", "CL")   ; Client Left
        ButtonCL.Move(x,y,w)

        Sleep(DemoDelay)

        x:= 450-9-38    ; 450 client width - 9 margin - 38 button width
        y:= 9           ; 9 margin
        ButtonTR := myGui.AddButton("", "TR")
        ButtonTR.Move(x,y)

        Sleep(DemoDelay)

        X:= 403         ; 450 client width - 9 margin - 38 button width
        y:=  52         ; 9 margin + 34 button height + 9 margin
        w:= 38+9        ; 38 button width + 9 margin
        ButtonCR := myGui.AddButton("w4", "CR") ; Client Right
        ButtonCR.Move(x, y, w)

        Sleep(DemoDelay)

        clientBottom:=341   ; 350 client height - 9 margin
        X:= 403             ; 450 client width - 9 margin - 38 button width
        y:= 307             ; 341 client bottom - 34 button height=307
        ButtonBR := myGui.AddButton("", "BR")
        ButtonBR.Move(x,y)

        Sleep(DemoDelay)

        X := 356        ; (450 client width - 9 margin - 38 button width)=403 - 9 margin - 38 button width
        y := 307        ; 9 margin + 34 button height + 9 margin
        h :=  43        ; 34 button height + 9 margin
        ButtonCR := myGui.AddButton("w4", "CB") ; Client Bottom
        ButtonCR.Move(x, y, , h)

        Sleep(DemoDelay)

        X := 14         ; 5 window border + 9 margin
        y := 307        ; 9 margin + 34 button height + 9 margin
        h := 34+9       ;  34 button height + 9 margin
        ButtonBL := myGui.AddButton("", "BL")
        ButtonBL.Move(x,y)

    }
}

Demo2() {
    global bw, bh

    myGui := Gui("-Resize", "Demo #2 - Using GuiLayout")
    myGui.SetFont("s12 cBlue w400", "Consolas")
    myGui.BackColor:="Silver"
    myGui.Show("w450 h350")
    myGui.SetFont()

    L := GuiLayout(myGui)

    ;bottomBorder := guiBottom - clientRectBottom

    ; 710, 350, 366
    ;clientRectBottom - guiBorderWidth - border + bottomBorder
    ;MsgBox L.Pos().RectBottom ", " L.Pos().BottomBorderWidth ", " L.Pos().border ", " L.Pos().bottomBorder
    ;MsgBox L.Pos().BottomBorder ", " L.Pos().Test

    DemoDelay:=0

    ; bw:= 120
    ; bh:= 34
    ; x :=450/2-bw/2   ; 208 = client width / 2 - button width / 2
    ; y :=350/2-bh/2   ; 158 = client height / 2 - button height / 2
    ;x :=450/2
    ; y :=350/2
    ;returns a string with the .OnEvent: ButtonOK := myGui.AddButton("w" bw " h" bh, "ok").OnEvent("Click", Button_Click)

    w:= 75
    h:= bh
    x:= L.Pos().CenterX - w//2
    y:= L.Pos().CenterY - h//2 +25

    ButtonClick := myGui.AddButton("w" w " h" h " Default", "Demo #1")
    ButtonClick.OnEvent("Click", Button_Click)
    ButtonClick.Move(x,y)

    AddControls()

    AddControls() {
        global bw, bh
        
        ; First, I added all the buttons a their default x,y
        ; Then I used those x,y to move them to their default pos
        ; x:=14   ; 5 window border + 9 margin
        ; y:=9

        x:= L.Pos().Left
        y:= L.Pos().Top
        ButtonTL := myGui.AddButton(" w" bW " h" bH, "TL")
        ButtonTL.Move(x,y)

        Sleep(DemoDelay)

        x:= L.Pos().Left + bW + L.Margin
        y:= L.Pos().Top
        ;h:= L.Pos().Top + bH + L.Margin
        h := bH + L.Pos().Border
        ButtonCT := myGui.AddButton(" w" bW, "CT") ; Client Rect Top
        ButtonCT.Move(x, y, , h)

        Sleep(DemoDelay)

        x:= L.Pos().RectLeft
        y:= L.Margin + bH + L.Margin
        w:= L.Pos().RectLeft + bW + L.Pos().Border
        ButtonCL := myGui.AddButton(" h" bH, "CL")   ; Client Left
        ButtonCL.Move(x,y,w)

        Sleep(DemoDelay)

        ;x:= 450-9-38    ; 450 client width - 9 margin - 38 button width
        ;y:= 9           ; 9 margin
        ;x:= L.Pos().Width - 30 ; bW - L.Pos().Border -1
        x:= L.Pos().RectRight -9-1 - bw
        y:= L.Pos().Top
        ButtonTR := myGui.AddButton(" w" bW " h" bH,  "TR")
        ButtonTR.Move(x,y)

        Sleep(DemoDelay)

        X:= 403         ; 450 client width - 9 margin - 38 button width
        y:=  52         ; 9 margin + 34 button height + 9 margin
        _bw:= 38+2 ;9-7        ; 38 button width + 9 margin + 5 border

        X:= L.Pos().RectRight  - _bw
        y:= L.Pos().Top  + bh + L.Margin ;   + _bw
    ; check on 2 pixels
        ButtonCR := myGui.AddButton(" w" bW, "CR") ; Client Right No Border
        ButtonCR.Move(x, y, _bw)

        Sleep(DemoDelay)

        ; clientBottom:=341   ; 350 client height - 9 margin
        ; X:= 403             ; 450 client width - 9 margin - 38 button width
        ; y:= 307             ; 341 client bottom - 34 button height=307

        X:= L.Pos().Width  - bW
        y:= L.Pos().Bottom - bH
        ButtonBR := myGui.AddButton(" w" bW " h" bH,  "BR")
        ButtonBR.Move(x,y)

        Sleep(DemoDelay)

        ; X := 356        ; (450 client width - 9 margin - 38 button width)=403 - 9 margin - 38 button width
        ; y := 307        ; 9 margin + 34 button height + 9 margin
        ; h :=  43        ; 34 button height + 9 margin

        X := L.Pos().Width  - bW - bW - L.Margin
        y := L.Pos().Bottom - bH
        h := bH + L.Pos().Border
        ButtonCB := myGui.AddButton(" w" bW, "CB") ; Client Bottom
        ButtonCB.Move(x, y, , h)

        Sleep(DemoDelay)

        X := 14         ; 5 window border + 9 margin
        y := 307        ; 9 margin + 34 button height + 9 margin
        h := 34+9       ;  34 button height + 9 margin

        X := L.Pos().Border + L.Margin
        y := L.Pos().Bottom - bH
        h := bH + L.Margin
        ButtonBL := myGui.AddButton(" w" bW " h" bH,  "BL")
        ButtonBL.Move(x,y)
    }
}
