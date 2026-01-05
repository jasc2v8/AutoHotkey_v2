; TITLE: WIP extract icon from exe
; source AHKV1: Google Gemini

#Include SaveHICONtoFile.ahk 

; Define the path to the executable file
;exePath := "C:\Path\To\Your\Executable.exe"
exePath := "NOTEPAD.exe"

; Initialize variables for the icon index and handle
iconIndex := 0  ; Usually 0 for the first icon
hIcon := 0

; Call ExtractAssociatedIcon to get the icon handle
hIcon := DllCall("Shell32\ExtractAssociatedIcon", "Ptr", 0, "Str", exePath, "ShortP", iconIndex, "Ptr")

; Check if the icon was successfully extracted
if (hIcon != 0)
{
    ; You now have the HICON (handle to the icon).
    ; To save it as an .ico file, you would typically need to use
    ; further DllCalls to functions like GetIconInfo and SaveIcon.
    ; This process is more complex and involves creating an icon structure.

    ; For simpler display or use within AHK, you can use the HICON directly,
    ; for example, with a GUI control or a custom menu.
    ;MsgBox("Icon handle obtained: " hIcon)


    ;TODO SAVE FOR SHOW IN PICTURE BOX?
    ;TODO Conver to AHKv2:
    SaveHICONtoFile( hIcon, "SaveHICONtoFile.ico" )


    ; Remember to destroy the icon handle when no longer needed to prevent memory leaks
    DllCall("DestroyIcon", "Ptr", hIcon)
}
else
{
    MsgBox("Failed to extract icon from: " exePath)
}