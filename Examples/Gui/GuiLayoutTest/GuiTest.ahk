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
    Client x,y = 450, 350

    Width           450
    Height          350
    WindowBorder    5       14 CL x - 9 margin = 5
    Magin           9       52 CL width - 38 TL with = 14 - 5 window border = 9
    Left            14      WindowBorder + Magin
    Right           403     450 client width - (9 margin - 38 button width=47)=403
    Top             0       Always 0
    Bottom          307     350 client height - (9 margin + 34 button height=43)=307

*/

; #region Example

myGui := Gui("+Resize")
myGui.SetFont("s12 cBlue w400", "Consolas")
myGui.BackColor:="Silver"
myGui.Show("w450 h350")

DemoDelay:=250

bw:= 120
bh:= 34
x :=450/2-bw/2   ; 208 = client width / 2 - button width / 2
y :=350/2-bh/2   ; 158 = client height / 2 - button height / 2
;x :=450/2
; y :=350/2
;returns a string with the .OnEvent: ButtonOK := myGui.AddButton("w" bw " h" bh, "ok").OnEvent("Click", Button_Click)

ButtonClick := myGui.AddButton("w" bw " h" bh " Default", "Click Me")
ButtonClick.OnEvent("Click", Button_Click)
ButtonClick.Move(x,y)

AddControls() {

    ; First, I added all the buttons a their default x,y
    ; Then I used those x,y to move them to their default pos
    x:=14   ; 5 window border + 9 margin
    y:=9
    ButtonTL := myGui.AddButton("", "TL")
    ButtonTL.Move(x,y)

    Sleep(DemoDelay)

    x:=5+9+38+9 ; 61: 5 window border + 9 margin + 38 button width + 9 margin
    y:= 0
    h:=43
    ButtonCT := myGui.AddButton("yp", "CT") ; Client Top
    ButtonCT.Move(x, y, , h)

    Sleep(DemoDelay)

    x:= 0
    y:= 9+34+9  ; 52: 9 margin + 34 button height + 9 margin
    w:= 52      ; 61: 5 window border + 9 margin + 38 button width
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

    X:= 403         ; 450 client width - 9 margin - 38 button width
    y:= 307         ; 9 margin + 34 button height + 9 margin
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

Button_Click(Ctrl, Info) {

    if (Ctrl.Text = "Click Again") {
        Reload
        ExitApp()
    }

    ;ToolTip "Click", 208, Y
    ButtonClick.Visible:=false

    AddControls()

    ButtonClick.Text:="Click Again"
    ButtonClick.Visible:=true
    ;Sleep(1000)
    ;ToolTip

}
