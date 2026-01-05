;SOURCE: Copilot

#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon


GetWindowFrameMetrics(hwnd) {
    ; RECT for full window
    fullRect := Buffer(16, 0)
    DllCall("GetWindowRect", "ptr", g.hwnd, "ptr", fullRect.Ptr)

    fullleft   := NumGet(fullRect, 0, "int")
    fulltop    := NumGet(fullRect, 4, "int")
    fullright  := NumGet(fullRect, 8, "int")
    fullbottom := NumGet(fullRect, 12, "int")

    fullW := fullright - fullleft
    fullH := fullbottom - fulltop

    ; RECT for client area
    clientRect := Buffer(16, 0)
    DllCall("GetClientRect", "ptr", g.hwnd, "ptr", clientRect.Ptr)

    clientleft   := NumGet(clientRect, 0, "int")
    clienttop    := NumGet(clientRect, 4, "int")
    clientright  := NumGet(clientRect, 8, "int")
    clientbottom := NumGet(clientRect, 12, "int")

    clientW := clientright - clientleft
    clientH := clientbottom - clienttop

    ; Get border metrics
    borderX := DllCall("GetSystemMetrics", "int", 32, "int") ; SM_CXFRAME
    borderY := DllCall("GetSystemMetrics", "int", 33, "int") ; SM_CYFRAME
    captionH := DllCall("GetSystemMetrics", "int", 4, "int")  ; SM_CYCAPTION

    borderWidth := (fullW - clientW) // 2
    borderHeight := (fullH - clientH - captionH) // 2

    ; Calculate actual differences
    borderWidth := (fullW - clientW) // 2
    borderHeight := (fullH - clientH - captionH) // 2

    return {
        fullWidth: fullW,
        fullHeight: fullH,
        clientWidth: clientW,
        clientHeight: clientH,
        borderWidth: borderWidth,
        borderHeight: borderHeight,
        captionHeight: captionH,
		totalNonClientHeight: fullH - clientH
    }
}

esc::exitapp

g := Gui()
g.Setfont("s12", "Consolas")
myText :=g.AddText("w600 h400 BackgroundSilver vText")
g.Show("w600 h400")
;g.Show("AutoSize")



dim := GetWindowFrameMetrics(g.hwnd)

text := "guiWidth            : " dim.fullWidth "`n" .
        "guiHeight           : " dim.fullHeight "`n" .
        "clientWidth          : " dim.clientWidth "`n" .
        "clientHeight         : " dim.clientHeight "`n" .
        "borderWidth          : " dim.borderWidth "`n" .
        "borderHeight         : " dim.borderHeight "`n" .
        "captionHeight        : " dim.captionHeight "`n" .
		"totalNonClientHeight : " dim.fullHeight - dim.clientHeight

;MsgBox text, "Window Frame Metrics"
myText.Text := text

g.GetPos(&X, &Y, &Width, &Height)
text .=  "`r`n`r`n" . "Gui   : x: " X ", y: " y ", w: " Width ", h: " Height
myText.Text := text

g.GetClientPos(&X, &Y, &Width, &Height)
text .=  "`r`n`r`n" . "Client: x: " X ", y: " y ", w: " Width ", h: " Height
myText.Text := text

MsgBox()
MsgBox(text) ; for user to copy/paste


; fullRect := Buffer(16, 0)
; DllCall("GetWindowRect", "ptr", g.hwnd, "ptr", fullRect.Ptr)

; left   := NumGet(fullRect, 0, "int")
; top    := NumGet(fullRect, 4, "int")
; right  := NumGet(fullRect, 8, "int")
; bottom := NumGet(fullRect, 12, "int")

; fullW := right - left
; fullH := bottom - top

; MsgBox fullW ", " fullH

; clientRect := Buffer(16, 0)
; DllCall("GetClientRect", "ptr", g.hwnd, "ptr", clientRect.Ptr)

; left   := NumGet(clientRect, 0, "int")
; top    := NumGet(clientRect, 4, "int")
; right  := NumGet(clientRect, 8, "int")
; bottom := NumGet(clientRect, 12, "int")

; clientW := right - left
; clientH := bottom - top

; MsgBox clientW ", " clientH

; borderX := DllCall("GetSystemMetrics", "int", 32, "int") ; SM_CXFRAME
; borderY := DllCall("GetSystemMetrics", "int", 33, "int") ; SM_CYFRAME
; captionH := DllCall("GetSystemMetrics", "int", 4, "int")  ; SM_CYCAPTION

; MsgBox borderX ", " borderY ", " captionH

; borderWidth := (fullW - clientW) // 2
; borderHeight := (fullH - clientH - captionH) // 2
; MsgBox borderWidth ", " borderHeight

