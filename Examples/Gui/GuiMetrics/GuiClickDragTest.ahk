#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
#Warn Unreachable, Off
Esc::ExitApp

#Requires AutoHotkey v2.0

; Create a simple GUI with a button we can drag
grui := Gui()
grui.Title:="My Window Title"
btn := grui.Add("Button", "x50 y50 w100 h30 vbtn", "Drag Me")
sb := grui.AddStatusBar("")
grui.Show("w400 h300")
#Requires AutoHotkey v2.0

; Replace "My Control Name" with the ClassNN or text of your control, 
; and "My Window Title" with the title of the window.
MyControl := btn ;"Control Name or ClassNN"
MyWinTitle := "My Window Title"

; Hotkey to start the drag (e.g., press the left mouse button)
~$LButton::
{
    sb.SetText("    Click")

    ; 1. Get the window and control under the cursor.
    MouseGetPos(&x, &y, &TargetWin, &TargetControl)

    ; Check if the click was on the desired window and control
    if (TargetWin != "" && TargetWin == MyWinTitle && TargetControl == MyControl)
    {
        ; Use SendMode "Event" or "Play" for better dragging reliability
        SendMode "Event" 
        
        ; 2. Send the control a Mouse Down event
        ; This simulates pressing the mouse button specifically on the control.
        ; Convert screen coordinates to client/control coordinates if needed.
        ; ControlClick/SendEvent can handle the coordinates relative to the control/window.
        
        ; Using a simplified approach by sending a {Click Down} event.
        ; For dragging an actual control, you may need to use ControlSend or
        ; a custom function that sends WM_LBUTTONDOWN/WM_MOUSEMOVE messages 
        ; if a simple Send doesn't work.
        
        Send ("{LButton Down}") 

        ; 3. Loop while the mouse button is physically held down
        Loop
        {
            ; Exit the loop if the left mouse button is released
            if (!GetKeyState("LButton", "P"))
                break

            ; Get the current mouse position (screen or client coordinates)
            MouseGetPos(&CurrentX, &CurrentY)

            ; 4. Move the mouse to the new position *within* the control's context
            ; For simple *visual* dragging that is captured by the application, 
            ; you just need MouseMove, which updates the mouse cursor position. 
            ; If the app needs to *think* the mouse is moving *over* the control 
            ; without moving the *physical* cursor, you'll need the advanced 
            ; ControlMouseMove function or DLL calls (like the search results suggest).
            
    sb.SetText("    Drag")
            ; This simple MouseMove moves the physical cursor:
            MouseMove(CurrentX, CurrentY)
            
            Sleep 10 ; Pause to limit CPU usage and control speed
        }

        ; 5. Send the control a Mouse Up event
        Send ("{LButton Up}") 

    sb.SetText("")

    }
}

; The ControlClick function is often used for simple clicks *on* a control 
; without the need for physical mouse movement, but for dragging 
; (which requires continuous movement), a loop with MouseMove is needed.