; ABOUT:    FontCompare v0.1
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  None

/*
    TODO:

*/
#Requires AutoHotkey v2.0

; --- 1. Custom Class Definition ---
class MyCustomText extends Gui.Text
{
    ; A custom property to store the last color set
    LastColor := "Black"

    ; Constructor: Must call the parent's constructor!
    __New(Options, Text)
    {
        ; Pass Options and Text to the MyGui.Text constructor
        super.__New(Options, Text)
    }

    ; Custom Method: Change the text color and store it
    ChangeColor(Color)
    {
        this.LastColor := Color
        this.Opt("c" Color) ; Apply the new color option
        this.Text := this.Text . " - (Color: " . Color . ")"
    }

    ; Custom Method: Reset the text and color
    Reset()
    {
        this.Text := "Original Text"
        this.Opt("cBlack")
        this.LastColor := "Black"
    }
}
; ------------------------------------


; --- 2. MyGui Creation and Usage ---
MyGui := Gui()
MyGui.SetFont("s12")

; Use the custom class to add a control!
CustomText := MyGui.Add(MyCustomText, "w250 h20", "Click a button!")

MyGui.Add("Button", "w80 gChangeRed", "Red")
MyGui.Add("Button", "w80 gChangeBlue", "Blue")
MyGui.Add("Button", "w80 gReset", "Reset")

MyGui.Show()
return

ChangeRed(*)
{
    ; Call the custom method on the control object
    CustomText.ChangeColor("Red")
}

ChangeBlue(*)
{
    ; Call the custom method on the control object
    CustomText.ChangeColor("Blue")
}

Reset(*)
{
    ; Call the custom method on the control object
    CustomText.Reset()

    ; You can still access and use built-in properties too
    MsgBox "Last saved color was: " . CustomText.LastColor
}