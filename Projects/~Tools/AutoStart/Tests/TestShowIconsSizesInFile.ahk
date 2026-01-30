; Version 1.2.3

global IL_Large := 0
global IL_Small := 0

ShowIconSizesAutofit()
{
    SelectedFile := FileSelect(3, , "Select an Icon File", "Icons (*.ico)")
    
    if (SelectedFile = "")
    return

    MyGui := Gui(, "Autofit Icon Preview")
    LV := MyGui.Add("ListView", "w400 r10", ["Image", "Size (px)", "Source Resource Index"])
    
    global IL_Large := IL_Create(7, 5, 1)
    global IL_Small := IL_Create(7, 5, 0)
    
    LV.SetImageList(IL_Small, 1)
    
    Sizes := [16, 24, 32, 48, 64, 128, 256]
    
    for Index, Size in Sizes
    {
        hIcon := 0
        ; PrivateExtractIcons is case sensitive
        DllCall("PrivateExtractIcons"
            , "Str", SelectedFile
            , "Int", 0
            , "Int", Size
            , "Int", Size
            , "Ptr*", &hIcon
            , "Ptr*", 0
            , "UInt", 1
            , "UInt", 0
            , "UInt")
            
        if (hIcon = 0)
        continue
        
        ImgIndex := IL_Add(IL_Small, "HICON:" . hIcon)
        LV.Add("Icon" . ImgIndex, "", Size . " pixels wide", "Index 0")
    }

    ; Autofit all columns
    ; Loop through the number of columns and apply "AutoHdr"
    Loop LV.GetCount("Col")
    {
        LV.ModifyCol(A_Index, "AutoHdr")
    }

    MyGui.Show()
}

ShowIconSizesAutofit()
