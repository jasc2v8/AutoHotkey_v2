; TITLE:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    Demo3 = L.MoveFill()

    change the standard move to L.Move? (it adds Redraw only)

    returns a string with the .OnEvent: ButtonOK := myGui.AddButton("w" bw " h" bh, "ok").OnEvent("Click", Button_Click)

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
global bw:= 30
global bh:= 25

Demo1()

;----------------------------------------------------

Button_Click(Ctrl, Info) {

    if (Ctrl.Text = "OK")
        Demo2()

    if (Ctrl.Text = "Demo #3")
        Demo3()

    if (Ctrl.Text = "Restart")
        Reload
}

Demo1() {
    myGui := Gui("-Resize", "Demo #1 - Using Default Border and Margin")
    myGui.SetFont("s12 cBlue w400", "Consolas")
    myGui.BackColor:="Silver"
    myGui.Show("w450 h350")
    myGui.SetFont()
    myGui.AddButton(" w" bW " h" bh,       "B1")
    myGui.AddButton(" w" bW " h" bh " yp ","yp")
    myGui.AddButton(" w" bW " h" bh " xs ","xs")

    L := GuiLayout(myGui)
    x:= L.Pos().CenterX - bW//2
    y:= L.Pos().CenterY - bH//2 

    myGui.AddButton("w" bW " h" bH " Default vOK", "OK")
    myGui["OK"].OnEvent("Click", Button_Click)
    
    myGui.SetFont("cBlue", "Consolas")

    myGui["OK"].Move(x,y)
        text :=
        "B1 = Added at default x,y`r`n" .
        "yp = Added at default x,y`r`n" .
        "xs = Added at default x,y`r`n" . "`r`n" .
        "Border       : " L.Pos().Border . "`r`n" .
        "Margin       : " L.Pos().Margin . "`r`n" . "`r`n" .
        "Button Width : " bW . "`r`n" .
        "Button Height: " bH . "`r`n" .
        ""
    x:= x-55, y:= 0+10, w:=250, h:=300
    myText := myGui.AddText(" x" x " y" y " w" w " h" h " BackgroundSilver", text)

}

Demo2() {
    global bw, bh

    myGui := Gui("-Resize", "Demo #2 - Using GuiLayout")
    myGui.SetFont("s12 cBlue w400", "Consolas")
    myGui.BackColor:="Silver"
    myGui.Show("w450 h350")
    myGui.SetFont()

    L := GuiLayout(myGui)

;MsgBox L.Pos().Border ", " L.Pos().Margin


    DemoDelay:= 0

    w:= 75
    h:= bh
    x:= L.Pos().CenterX - w//2
    y:= L.Pos().CenterY - h//2 

    ButtonClick := myGui.AddButton("w" w " h" h " Default", "Demo #3")
    ButtonClick.OnEvent("Click", Button_Click)
    ButtonClick.Move(x,y)

    myGui.SetFont("cBlue", "Consolas")

    text :=
        "TL = Top Left`r`n" .
        "TR = Top Right`r`n" . "`r`n" .
        "BR = Bottom Right`r`n" .
        "BL = Bottom Left`r`n" . "`r`n" .
        "RT = Client RectTop    (No Border)`r`n" .
        "RR = Client RectRight  (No Border)`r`n" .
        "RB = Client RectBottom (No Border)`r`n" .
        "RL = Client RectLeft   (No Border)`r`n" .
        ""
    x:= x-55, y:= 0+10, w:=250, h:=300
    myText := myGui.AddText(" x" x " y" y " w" w " h" h " BackgroundSilver", text)

    global bw, bh
    
    ; I added all the buttons at their default x,y
    ; Then I moved the buttons to their these default x,y pos
    ; This verified L.Pos().Left and L.Pos().Top are equal to these default x,y pos

    x:= L.Pos().Left
    y:= L.Pos().Top
    ButtonTL := myGui.AddButton(" w" bW " h" bH, "TL")
    ButtonTL.Move(x,y)

    Sleep(DemoDelay)

    x:= L.Pos().Left + bW + L.Margin
    y:= L.Pos().RectTop
    h := bH + L.Border
    ButtonRT := myGui.AddButton(" w" bW, "RT") ; Client RectTop =  = Top No Border
    ButtonRT.Move(x, y, , h)

    Sleep(DemoDelay)

    x:= L.Pos().RectLeft
    y:= L.Margin + bH + L.Margin
    w:= L.Pos().RectLeft + bW + L.Border
    ButtonRL := myGui.AddButton(" h" bH, "RL")   ; Client RectLeft = Left No Border
    ButtonRL.Move(x,y,w)

    Sleep(DemoDelay)

    x:= L.Pos().RectRight -9-1 - bw
    y:= L.Pos().Top
    ButtonTR := myGui.AddButton(" w" bW " h" bH,  "TR") ; Client Top Right
    ButtonTR.Move(x,y)

    Sleep(DemoDelay)

    X:= L.Pos().RectRight - bW - L.Border
    y:= L.Pos().Top  + bh + L.Margin
    w:= bW + L.Border
    ButtonRR := myGui.AddButton(" w" bW, "RR") ; Client RectRight = Right No Border
    ButtonRR.Move(x, y, w)

    Sleep(DemoDelay)

    X:= L.Pos().Width  - bW
    y:= L.Pos().Bottom - bH
    ButtonBR := myGui.AddButton(" w" bW " h" bH,  "BR")
    ButtonBR.Move(x,y)

    Sleep(DemoDelay)

    h := bH + L.Border
    X := L.Pos().Right - bW - L.Margin - bW
    y := L.Pos().RectBottom - L.Border - bH 
    ButtonRB := myGui.AddButton(" w" bW, "RB") ; Client RectBottom = Bottom No Border
    ButtonRB.Move(x, y, , h)

    Sleep(DemoDelay)

    X := L.Pos().Left
    y := L.Pos().Bottom - bH
    h := bH + L.Margin
    ButtonBL := myGui.AddButton(" w" bW " h" bH,  "BL") ; Client Bottom Left
    ButtonBL.Move(x,y)
}

Demo3() {

    myGui := Gui("-Resize", "Demo #3 - Client Rect")

    WinSetTransparent 150, myGui

    myGui.BackColor:="Silver"
    myGui.Show("w450 h350")

    L := GuiLayout(myGui)

    w:= 75
    x:= L.Pos().CenterX -w/2
    y:= L.Pos().CenterY -bh/2 + bh + L.Margin

    ;returns a string with the .OnEvent: ButtonOK := myGui.AddButton("w" bw " h" bh, "ok").OnEvent("Click", Button_Click)
    ButtonClick := myGui.AddButton("w" w " h" bh " Default", "Restart")
    ;ButtonClick := myGui.Add("Button","w" w " h" bh " Default", "Demo #2")
    ButtonClick.OnEvent("Click", Button_Click)
    ButtonClick.Move(x,y)

    myGui.SetFont("cBlue", "Consolas")
    text :=
        "The yellow border is the client Rect dimensions.`r`n`r`n" .
        "This is the Client area without borders" .
        ""
    x:= x-55, y:= y+35, w:=250, h:=300
    myText := myGui.AddText(" x" x " y" y " w" w " h" h " BackgroundSilver", text)

    ; Add Controls
    myGui.SetFont("s7 cGreen w700", "")

    tw:=tH:=L.Border ; 10
    
    x:= L.Pos().RectLeft
    y:= L.Pos().RectTop
    w:= L.Pos().RectWidth
    h:= tH 
    ButtonRT := myGui.AddText("BackgroundYellow Center", "Top") ; Rect Top
    ButtonRT.Move(x, y, w, h)

    x:= L.Pos().RectLeft
    y:= L.Pos().RectBottom - tH
    w:= L.Pos().RectWidth
    h:= tH
    ButtonRB := myGui.AddText("BackgroundYellow Center", "Bottom") ; Rect Bottom
    ButtonRB.Move(x, y, w, h)

    x:= L.Pos().RectLeft
    y:= L.Pos().RectTop
    w:= tW
    h:= L.Pos().RectHeight
    ButtonRT := myGui.AddText("BackgroundYellow", "L") ; Rect Left
    ButtonRT.Move(x, y, w, h)

    x:= L.Pos().RectRight - tw
    y:= L.Pos().RectTop
    w:=tW
    h:= L.Pos().RectHeight
    ButtonRR := myGui.AddText("BackgroundYellow", "R") ; Rect Right
    ButtonRR.Move(x, y, w, h)

}

