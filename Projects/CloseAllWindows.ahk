; ABOUT: CloseAllWindows v1

;-------------------------------------------------------------------------------
; Purpose : Closes all Open Windows, except exclusions (e.g. Program Manager).
; 1st Pass: WinClose() so user can save work from notepad etc.
; 2nd Pass: Force close remaining windows, except exclusions.
; Include : <CustomMsgBox>
; License: The Unlicense: https://unlicense.org/
;-------------------------------------------------------------------------------

#Requires AutoHotkey >=2.0
#SingleInstance Force
#NoTrayIcon

#Include <CustomMsgBox>

TraySetIcon('imageres.dll', 237)

Title 	:= "Close All Windows"
Text 	:= "Press Start to close all open windows..."
Buttons	:= "*&Yes, &No, &All, &Cancel"
GuiSize := "400, 223, 10, 10"
GuiOpt	:= ["+AlwaysOnTop", "4682B4"]
FontOpt := ["s12", "Cascadia Mono", "s8", "Segoe UI"]
TextOpt	:= "Border -Wrap BackgroundWhite"
IconQ   := ["C:\Windows\System32\user32.dll", "Icon3"]
IconI	:= ["C:\Windows\System32\user32.dll", "Icon5"]
IconOpt := ""
SoundOpt:= ""

r := CustomMsgBox(Text, Title, "*&Start, &Cancel", GuiSize, GuiOpt, FontOpt, TextOpt, IconQ, SoundOpt)

if (r = "&Start") {

    count := CloseAllOpenWindows()

    if (count = 0) {
        SoundBeep
        msg := "No Open Windows to Close."
    } else {
        ConfirmWindowsClosed()
        SoundPlay "C:\Windows\Media\tada.wav"
        msg := "Done!`n`nPress OK to close this window."
    }

    CustomMsgBox(msg, Title, "&OK", GuiSize, GuiOpt, FontOpt, TextOpt, IconI, SoundOpt)
    ExitApp()

}

; #region Functions

CloseAllOpenWindows()
{
    count := 0

    ; Get a list of the HWNDs of all windows (excluding hidden ones by default).
    for hWnd in WinGetList()
    {    
        if IsExcluded(hWnd)
            continue
        
        ; WinClose sends a WM_CLOSE message, which allows the program to
        ;   prompt for saving unsaved data (e.g., in Notepad).
        WinClose(hWnd)

        count++
    }
    return count
}

IsExcluded(hWnd) {
    if !WinExist(hWnd)
        return true
    Title := WinGetTitle("ahk_id" hWnd)
    Class := WinGetClass("ahk_id" hWnd)
    if (Title ~= "i)Program Manager|Close All Windows")
        return true
    if (Class ~= "i)Shell_")
        return true
    return false
}

ConfirmWindowsClosed() {

    ids := WinGetList(,, "Program Manager")
    
    for this_id in ids
    {
        if IsExcluded(this_id)
            continue

        WinActivate this_id
        try {
            this_class := WinGetClass(this_id)
            this_title := WinGetTitle(this_id)
            this_pid   := WinGetPID(this_id)
        } catch Error as e {

        }

        Text := 
            "Title: " this_title   "`n" .
            "Class: " this_class   "`n" .
            "id   : " this_id      "`n" .
            "pid  : " this_pid      "`n`n" .
            "Forceably Close this Window?"
        
        r := CustomMsgBox(Text, Title, Buttons, GuiSize, GuiOpt, FontOpt, TextOpt, IconQ, SoundOpt)
    
OutputDebug(r)

        switch r {
            case "&Yes":
                ForceClose(this_id)
                continue
                
            case "&No":
                continue
                
            case "&All":
                ForceCloseAll()
                break
                
            case "&Cancel" :
                break
                
        }
    }
}

ForceCloseAll() {

    ids := WinGetList(,, "Program Manager")
    
    for this_id in ids
    {
        if IsExcluded(this_id)
            continue
        
        ForceClose(this_id)
    }
}

ForceClose(ahk_id) {
    
    ; Try to close the window using its unique ID (hWnd)      
    WinClose(ahk_id,,.250)

    ; If still open, then Kill
    if WinExist(ahk_id)
        WinKill(ahk_id,,.250)

    ; If still open, terminate Pid
    if WinExist(ahk_id)
        ProcessClose(WinGetPID(ahk_id))

    ; If still open, notify
    Sleep(250)
    if WinExist(ahk_id)
        MsgBox("Still open: " WinGetTitle(ahk_id) ", " ahk_id)
}
