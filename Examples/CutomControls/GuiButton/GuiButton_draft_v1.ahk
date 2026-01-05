
#Requires AutoHotkey v2.0.2+

; --- Main Script ---

MyGui := Gui(, "Icon Button Example")

; 1. Add the Button and get its HWND
; Use the 'Hwnd' option to capture the control's handle.
; Increase the button height (h) to make room for a standard 32x32 icon.
MyButton := MyGui.AddButton('w120 h40', 'Run Script')

; 2. Call the function to set the icon
; File: shell32.dll (a system file containing many icons)
; Index: 23 (a common 'info' or 'run' icon)
; Options: s32 (sets the icon size to 32x32 pixels)
if !GuiButtonIcon(MyButton.Hwnd, 'shell32.dll', 23, 's32') {
    MsgBox("Error: Could not load icon. Make sure AHK v2.0.2+ is used.")
}

; 3. Define the button's action
MyButton.OnEvent('Click', ButtonClick)

MyGui.Show('w200 h100')
return

ButtonClick(GuiCtrlObj, Info) {
    MsgBox("The icon button was clicked!", "Action Performed", 64)
}

; --- GuiButtonIcon Function (Required for Icon on Button) ---
; Source: AutoHotkey Community (FanaticGuru, iPhilip)

/**
 * Assigns an icon to a Gui Button control using Windows API calls.
 * * @param {Ptr} Handle HWND handle of the Gui button control.
 * @param {String} File File containing the icon/image (e.g., shell32.dll, a.ico).
 * @param {Number} Index The zero-based index of the icon within the file (default: 0).
 * @param {String} Options Options string for icon size and alignment (e.g., 's32', 'w16 h16').
 * @returns {Integer} The icon list handle on success, 0 on failure.
 */
GuiButtonIcon(Handle, File, Index := 0, Options := '') {
    ; Constant: BCM_SETIMAGELIST message to set an image list on a button
    static BCM_SETIMAGELIST := 0x1602 + 0x2
    
    ; Default size is 16x16.
    W := H := 16.0 

    Options := 's32'
    MsgBox RegExMatch(Options, 'i)s\K\d+', &S)
    MsgBox S[0]
    

    MsgBox &S

    ; Parse Options for size (s, w, h)
    RegExMatch(Options, 'i)s\K\d+', &S) ? W := H := S.Value.0 : ''
    RegExMatch(Options, 'i)w\K\d+', &W) ? W := W.Value.0 : ''
    RegExMatch(Options, 'i)h\K\d+', &H) ? H := H.Value.0 : ''
    
    ; Parse Options for margins (l, t, r, b)
    RegExMatch(Options, 'i)l\K\d+', &L) ? L := L.Value.0 : L := 0
    RegExMatch(Options, 'i)t\K\d+', &T) ? T := T.Value.0 : T := 0
    RegExMatch(Options, 'i)r\K\d+', &R) ? R := R.Value.0 : R := 0
    RegExMatch(Options, 'i)b\K\d+', &B) ? B := B.Value.0 : B := 0
    
    ; Adjust for screen DPI scaling
    W *= A_ScreenDPI / 96, H *= A_ScreenDPI / 96

    ; Allocate memory for the BUTTON_IMAGELIST structure
    button_il := Buffer(20 + A_PtrSize)
    
    ; 1. Create a new image list (ILC_COLOR32 = 0x21)
    normal_il := DllCall('ImageList_Create', 'Int', W, 'Int', H, 'UInt', 0x21, 'Int', 1, 'Int', 1)
    
    ; Check if ImageList was successfully created
    if (normal_il = 0)
        return 0

    ; 2. Add the icon to the image list
    IL_Add_Result := DllCall('ImageList_AddIcon', 'Ptr', normal_il, 'Ptr', DllCall('LoadIcon', 'Ptr', 0, 'Ptr', DllCall('ExtractIcon', 'Ptr', A_ScriptHwnd, 'Str', File, 'Int', Index)))
    
    ; Check if icon was successfully added
    if (IL_Add_Result = -1) {
        DllCall('ImageList_Destroy', 'Ptr', normal_il)
        return 0
    }
    
    ; 3. Populate the BUTTON_IMAGELIST structure (Size: 20 bytes + PtrSize)
    
    ; Ptr: normal_il (HIMAGELIST)
    NumPut('Ptr', normal_il, button_il, 0)
    
    ; RECT (Margins)
    NumPut('Int', L, button_il, 0 + A_PtrSize)  ; Left Margin
    NumPut('Int', T, button_il, 4 + A_PtrSize)  ; Top Margin
    NumPut('Int', R, button_il, 8 + A_PtrSize)  ; Right Margin
    NumPut('Int', B, button_il, 12 + A_PtrSize) ; Bottom Margin
    
    ; Alignment (e.g., 0x0004 = BUTTON_IMAGELIST_ALIGN_LEFT)
    NumPut('UInt', 0x0004, button_il, 16 + A_PtrSize)
    
    ; 4. Send the BCM_SETIMAGELIST message to the button control
    SendMessage(BCM_SETIMAGELIST, 0, button_il, Handle)
    
    return normal_il ; Return the image list handle
}