; Version 1.2.4

global IL_Large := 0
global IL_Small := 0

ShowIconsInPictureBox()
{
    SelectedFile := FileSelect(3, , "Select an Icon File", "Icons (*.ico)")
    
    if (SelectedFile = "")
    return

    MyGui := Gui("+MaxSize600x800", "Icon PictureBox Gallery")
    MyGui.SetFont("s10", "Segoe UI")
    
    ; Common sizes to attempt extraction
    Sizes := [16, 24, 32, 48, 64, 128, 256]
    
    for Index, Size in Sizes
    {
        hIcon := 0
        ; PrivateExtractIcons is case sensitive
        ; We use Index 0 for the first icon resource in the .ico
        Result := DllCall("PrivateExtractIcons"
            , "Str", SelectedFile
            , "Int", 0
            , "Int", Size
            , "Int", Size
            , "Ptr*", &hIcon
            , "Ptr*", 0
            , "UInt", 1
            , "UInt", 0
            , "UInt")
            
        if (hIcon = 0 || hIcon = -1)
        continue
        
        ; Add a text label for the size
        MyGui.Add("Text", "xm", Size "x" Size ":")
        
        ; Add the Picture control (PictureBox)
        ; Passing the HICON handle directly using the HICON: prefix
        MyGui.Add("Picture", "w" Size " h" Size, "HICON:" . hIcon)
    }

    MyGui.Show()
}

ShowIconsInPictureBox()
