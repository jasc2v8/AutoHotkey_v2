; Version 1.2.0

; Run the function
;ShowAllIcons("shell32.dll")
;ShowAllIcons("C:\Users\Jim\Documents\AutoHotkey\Lib\Icons\cog.ico")
ShowIcoFileIcons()
; Version 1.2.1

global IL_Large := 0
global IL_Small := 0

ShowIcoFileIcons()
{
    ; Select a .ico file
    SelectedFile := FileSelect(3, , "Select an Icon File", "Icons (*.ico)")
    
    if (SelectedFile = "")
    return

    ; Get total icon count
    TotalIcons := DllCall("PrivateExtractIcons", "Str", SelectedFile, "Int", 0, "Int", 0, "Int", 0, "Ptr", 0, "Ptr", 0, "UInt", 0, "UInt", 0)
    
    if (TotalIcons = 0 || TotalIcons = 0xFFFFFFFF)
    return

    MyGui := Gui(, "Icon Viewer: " . SelectedFile)
    LV := MyGui.Add("ListView", "w400 r10", ["Image", "Index", "Description"])
    
    ; Initialize ImageLists on separate lines
    global IL_Large := IL_Create(TotalIcons, 5, 1)
    global IL_Small := IL_Create(TotalIcons, 5, 0)
    
    LV.SetImageList(IL_Large, 0)
    LV.SetImageList(IL_Small, 1)
    
    Loop TotalIcons
    {
        hIcon := 0
        ; PrivateExtractIcons is case sensitive
        ; Using Index - 1 logic
        DllCall("PrivateExtractIcons"
            , "Str", SelectedFile
            , "Int", A_Index - 1
            , "Int", 32
            , "Int", 32
            , "Ptr*", &hIcon
            , "Ptr*", 0
            , "UInt", 1
            , "UInt", 0
            , "UInt")
            
        if (hIcon = 0)
        continue
        
        ImgIndex := IL_Add(IL_Small, "HICON:" . hIcon)
        LV.Add("Icon" . ImgIndex, "", A_Index, "Icon from .ico file")
    }
    
    LV.ModifyCol(1, 50)
    MyGui.Show()
}

