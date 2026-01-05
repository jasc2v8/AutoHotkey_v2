#Requires AutoHotkey v2.0+
#SingleInstance Force

Escape::ExitApp

; #Region Define Variables

MyGui := Gui()

DefaultSoundFile := "C:\Windows\Media\tada.wav"

SoundTada := "C:\Windows\Media\tada.wav"
SoundBlip := "C:\Windows\Media\Windows Default.wav"
SoundChord := "C:\Windows\Media\chord.wav"
SoundCriticalStop := "C:\Windows\Media\Windows Critical Stop.wav"
SoundChimes := "C:\Windows\Media\chimes.wav" 
SoundNotifySystemGeneric := "C:\Windows\Media\Windows Notify System Generic.wav"
SoundNotify := "C:\Windows\Media\Windows Notify.wav"
SoundExclamation := "C:\Windows\Media\Windows Exclamation.wav"
SoundError := "C:\Windows\Media\Windows Error.wav"
SoundBackground := "C:\Windows\Media\Windows Background.wav"
SoundForeground := "C:\Windows\Media\Windows Foreground.wav"

ButtonTextMsgBoxHand        := "Iconx" ; Hand/Stop/Error
ButtonTextMsgBoxQuestion    := "Icon?" ; Question
ButtonTextMsgBoxExclamation := "Icon!" ; Exclamation
ButtonTextMsgBoxInfo        := "Iconi" ; Asterisk/Info

; ButtonTextHandStopError := "Iconx:"
; ButtonTextQuestion := "Icon?"
; ButtonTextExclamation := "Icon!"
; ButtonTextAsteriskInfo := "Iconi"

SoundPlayBeep := "*-1"
SoundPlayHand := "*16"
SoundPlayQuestion := "*32"
SoundPlayExclamation := "*48"
SoundPlayAsteriskInfo := "*64"

ButtonTextSoundBeep := "SoundBeep"
ButtonTextSoundPlay := "SoundPlay"

ButtonTextAltBeep := "Alt. Beep"
ButtonTextAltBeep2 := "Alt. Blip"
ButtonTextAltError := "Alt. Error X"
ButtonTextAltError2 := "Alt. Error 2"
ButtonTextAltExclamation := "Alt. Exclamation !"
ButtonTextAltExclamation2 := "Alt. Exclamation 2"
ButtonTextAltInfo := "Alt. Info i"
ButtonTextAltInfo2 := "Alt. Info 2"
ButtonTextAltQuestion := "Alt. Question ?"
ButtonTextAltQuestion2 := "Alt. Question 2"

ButtonTada := "Tada"
ButtonChord := "Chord"
ButtonCriticalStop := "Critical"
ButtonChimes := "Chimes"

; Method A: Store the returned object
;MyLabel1 := MyGui.AddText('w200',"Windows Defaults:").SetFont("Bold")

; #Region Gui Create

MyEdit := MyGui.AddEdit("w530", DefaultSoundFile)
MyGui.AddButton("yp w75 h30 Default", "Select").OnEvent('Click', ButtonSelect_Click)
MyGui.AddButton("yp w75 h30        ", "Play").OnEvent('Click', ButtonPlay_Click)

MyGui.AddButton("xm w100", ButtonTextMsgBoxHand).OnEvent('Click', Button_Click)
MyGui.AddButton("yp w100", ButtonTextMsgBoxQuestion).OnEvent('Click', Button_Click)
MyGui.AddButton("yp w100", ButtonTextMsgBoxExclamation).OnEvent('Click', Button_Click)
MyGui.AddButton("yp w100", ButtonTextMsgBoxInfo).OnEvent('Click', Button_Click)

MyGui.AddButton("yp w100", ButtonTextSoundBeep).OnEvent('Click', Button_Click)

;MyLabel2 := MyGui.AddText('xm y+25 w200',"Alternates:").SetFont("Bold")

MyGui.AddButton("xm w100", ButtonTextAltError).OnEvent('Click', Button_Click)
MyGui.AddButton("yp w100", ButtonTextAltQuestion).OnEvent('Click', Button_Click)
MyGui.AddButton("yp w100", ButtonTextAltExclamation).OnEvent('Click', Button_Click)
MyGui.AddButton("yp w100", ButtonTextAltInfo).OnEvent('Click', Button_Click)
MyGui.AddButton("yp w100", ButtonTextAltBeep).OnEvent('Click', Button_Click)
;Button := MyGui.AddButton("xm w100 vBeepNew", ButtonTextAltBeep).OnEvent('Click', Button_Click)

MyGui.AddButton("xm w100", ButtonTextAltError2).OnEvent('Click', Button_Click)
MyGui.AddButton("yp w100", ButtonTextAltQuestion2).OnEvent('Click', Button_Click)
MyGui.AddButton("yp w100", ButtonTextAltExclamation2).OnEvent('Click', Button_Click)
MyGui.AddButton("yp w100", ButtonTextAltInfo2).OnEvent('Click', Button_Click)
MyGui.AddButton("yp w100", ButtonTextAltBeep2).OnEvent('Click', Button_Click)

MyGui.AddButton("yp w100", "Cancel").OnEvent('Click',(*)=>ExitApp())


SB := MyGui.AddStatusBar()

MyGui.Show()

PostMessage(EM_SETSEL:=0xB1, -1, 0, MyEdit.Hwnd) ; Deselect all text

return

Button_Click(GuiCtrl, Info)
{
    ;MsgBox GuiCtrl.Hwnd  ', ' MyGui["Beep"].Hwnd ', ' MyGui["BeepNew"].Hwnd

    switch GuiCtrl.Text {

        ; MsgBox Sounds
        case ButtonTextMsgBoxHand:
            ShowStatus("MsgBox Iconx: Windows Error Sound.") ; Iconx
            SoundPlay SoundPlayHand ; C:\Windows\Media\Windows User Account Control.wav

        case ButtonTextMsgBoxQuestion:
            ShowStatus("MsgBox Icon?: Windows Question (No Sound).")
            SoundPlay SoundPlayQuestion

        case ButtonTextMsgBoxExclamation:
            ShowStatus("MsgBox Icon!: Windows Exclamation.")
            SoundPlay SoundPlayExclamation

        case ButtonTextMsgBoxInfo:
            ShowStatus("MsgBoxi Iconi = Same as Icon!: Windows Exclamation.")
            SoundPlay SoundPlayAsteriskInfo

        ; beep sounds

        case ButtonTextSoundBeep:
            ShowStatus("Sound Beep:")
            SoundBeep

        ; Alternate sounds

        case ButtonTextAltBeep:
            ShowStatus("Alternate Beep.")
            SoundBeep(400, 150)

        case ButtonTextAltBeep2:
            ShowStatus("Alternate Blip.")
            SoundPlay SoundBlip

        case ButtonTextAltError:
            ShowStatus("Alternate Error.")
            SoundPlay SoundCriticalStop

        case ButtonTextAltInfo:
            ShowStatus("Alternate Info i.")
            SoundPlay SoundNotify

        case ButtonTextAltInfo2:
            ShowStatus("Alternate Info 2.")
            SoundPlay SoundError

        case ButtonTextAltQuestion:
            ShowStatus("Alternate Question.")
            SoundPlay "*16" 

        case ButtonTextAltQuestion2:
            ShowStatus("Alternate Question 2.")
            SoundPlay SoundNotifySystemGeneric

        case ButtonTextAltExclamation:
            ShowStatus("Alternate Exclamation.")
            SoundPlay SoundExclamation

        case ButtonTextAltExclamation2:
            ShowStatus("Alternate Exclamation 2.")
            SoundPlay SoundChimes
                 
        case ButtonTextAltError2:
            ShowStatus("Alternate Error 2.")
            SoundPlay SoundChord            
    }
}

ButtonSelect_Click(*) {
    file := FileSelect(, DefaultSoundFile, "Select Sound File", "Sound Files (*.wav;*.mp3;*.ogg;*.flac)")
    if (file !='') {
        MyEdit.Text := file
        ButtonPlay_Click()
    }
}

ButtonPlay_Click(*) {

    if FileExist(MyEdit.Text) {
        ShowStatus("Playing: " MyEdit.Text)
        SoundPlay MyEdit.Text
    }
}

ShowStatus(Text) {
    pad  := ""
    Loop 4
        pad .= A_Space
    SB.SetText(pad . Text)
}
