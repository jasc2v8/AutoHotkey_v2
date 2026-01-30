; Version 1.1.9

ShowIconRange(40, 60)

ShowIconRange(StartIcon, EndIcon)
{
    IconFile := "shell32.dll"
    
    MyGui := Gui(, "Icon Range Preview")
    LV := MyGui.Add("ListView", "w400 r15", ["Icon", "1-Based Index", "0-Based (DLL)"])
    
    ; Initialize ImageLists on separate lines
    global IL_Large := IL_Create(EndIcon - StartIcon + 1, 5, 1)
    global IL_Small := IL_Create(EndIcon - StartIcon + 1, 5, 0)
    
    ; Assign both for visibility in Report mode
    LV.SetImageList(IL_Large, 0)
    LV.SetImageList(IL_Small, 1)
    
    Loop (EndIcon - StartIcon + 1)
    {
        CurrentIndex := StartIcon + A_Index - 1
        
        ; Extract handle using case-sensitive DllCall and Index - 1
        hIcon := GetIconHandle(IconFile, CurrentIndex, 32)
        
        if (hIcon = 0)
        continue
        
        ; Add to ImageList
        ImgIndex := IL_Add(IL_Small, "HICON:" . hIcon)
        
        ; Add to ListView
        LV.Add("Icon" . ImgIndex, "", CurrentIndex, CurrentIndex - 1)
    }
    
    MyGui.Show()
}

GetIconHandle(File, Index, Size)
{
    hIcon := 0
    ; PrivateExtractIcons is case sensitive
    Result := DllCall("PrivateExtractIcons"
        , "Str", File
        , "Int", Index - 1
        , "Int", Size
        , "Int", Size
        , "Ptr*", &hIcon
        , "Ptr*", 0
        , "UInt", 1
        , "UInt", 0
        , "UInt")
        
    if (Result = 0 || Result = 0xFFFFFFFF)
    return 0
    
    return hIcon
}

