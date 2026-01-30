; Version: 4.6.0
#Requires AutoHotkey v2.0+
#SingleInstance Force

global IL_Large := 0
global IL_Small := 0

; Ensure ExitApp is called on script exit
OnExit(*) => ExitApp()

MyGui := Gui("+Resize", "HKCU Software Manager Pro")
MyGui.SetFont("s9", "Segoe UI")

; Explicitly ExitApp when the GUI window is closed
MyGui.OnEvent("Close", (*) => ExitApp())

; Correct way to set Minimum Window Size in v2
MyGui.Opt("+MinSize600x400")

; Initialize ImageLists for Icons
; PrivateExtractIcons and DLL names are case sensitive
IL_Small := IL_Create(10, 10, 0)
DllCall("user32.dll\PrivateExtractIcons", "Str", "shell32.dll", "Int", 3, "Int", 16, "Int", 16, "Ptr*", &IconKey := 0, "Ptr*", 0, "UInt", 1, "UInt", 0)
DllCall("user32.dll\PrivateExtractIcons", "Str", "shell32.dll", "Int", 69, "Int", 16, "Int", 16, "Ptr*", &IconDoc := 0, "Ptr*", 0, "UInt", 1, "UInt", 0)
IL_Add(IL_Small, "HICON:" . IconKey)
IL_Add(IL_Small, "HICON:" . IconDoc)

; Add Search Bar
MyGui.Add("Text", "vSearchLabel w50", "Search:")
SearchBox := MyGui.Add("Edit", "vSearchInput w240 x+5")
SearchBox.OnEvent("Change", (*) => FilterTree(SearchBox, TV))

; Setup Controls
TV := MyGui.Add("TreeView", "r20 w300 xm ImageList" . IL_Small)
LV := MyGui.Add("ListView", "r20 w500 x+10 ImageList" . IL_Small, ["Value Name", "Type", "Data"])

; Add Status Bar
SB := MyGui.Add("StatusBar")
SB.SetText("HKCU\Software")

; --- EVENTS ---
MyGui.OnEvent("Size", Gui_Size)
TV.OnEvent("ItemSelect", UpdateView)
TV.OnEvent("ItemExpand", OnItemExpand)
TV.OnEvent("ContextMenu", ShowKeyMenu)
LV.OnEvent("ContextMenu", ShowValueMenu)
LV.OnEvent("DoubleClick", (*) => EditValue())

; --- HOTKEYS ---
#HotIf WinActive("ahk_id " MyGui.Hwnd)
Esc::CollapseSelectedKey()
#HotIf

; --- MENUS ---
KeyMenu := Menu()
KeyMenu.Add("Copy Key Path", CopyKeyPath)
KeyMenu.Add()
KeyMenu.Add("New Subkey", CreateKey)
KeyMenu.Add("Rename Key", RenameKey)
KeyMenu.Add("Delete Key", DeleteSelectedKey)
KeyMenu.Add()
KeyMenu.Add("Refresh Tree", (*) => ReloadTree(TV))

ValMenu := Menu()
ValMenu.Add("Copy", CopyValueData)
ValMenu.Add()
ValMenu.Add("Edit Data", (*) => EditValue())
ValMenu.Add("Delete Value", DeleteSelectedValue)
ValMenu.Add("Rename Value", RenameValue)
ValMenu.Add()
ValMenu.Add("New Binary Value", (*) => CreateValue("REG_BINARY"))
ValMenu.Add("New DWORD Value", (*) => CreateValue("REG_DWORD"))
ValMenu.Add("New String Value", (*) => CreateValue("REG_SZ"))
ValMenu.Add()
ValMenu.Add("Refresh Values", (*) => RefreshValues())

; Initial Load
BaseKey := "HKCU\Software"
global RootID := 0
ReloadTree(TV)

MyGui.Show()

; --- LAZY LOADING LOGIC ---

OnItemExpand(TreeObj, ItemID, Expanded)
{
    if (!Expanded)
    return

    FirstChild := TreeObj.GetChild(ItemID)
    if (FirstChild != 0 && TreeObj.GetText(FirstChild) == "...")
    {
        TreeObj.Delete(FirstChild)
        ParentPath := GetFullPath(TreeObj, ItemID)
        AddSubKeys(ParentPath, ItemID, TreeObj, false)
    }
}

AddSubKeys(ParentPath, ParentID, TreeObj, DeepLoad := false)
{
    Loop Reg, ParentPath, "K"
    {
        NewID := TreeObj.Add(A_LoopRegName, ParentID, "Sort Icon1")
        
        if (DeepLoad)
        {
            AddSubKeys(ParentPath . "\" . A_LoopRegName, NewID, TreeObj, true)
        }
        else
        {
            TreeObj.Add("...", NewID) 
        }
    }
}

ReloadTree(TreeViewObj)
{
    TreeViewObj.Delete()
    global RootID := TreeViewObj.Add("Software", 0, "Expand Sort Icon1")
    AddSubKeys("HKCU\Software", RootID, TreeViewObj, false)
}

; --- FUNCTIONS ---

CopyValueData(*)
{
    Row := LV.GetNext()
    if (Row = 0)
    return
    
    VName := LV.GetText(Row, 1)
    VType := LV.GetText(Row, 2)
    VData := LV.GetText(Row, 3)
    
    A_Clipboard := VName . "," . VType . "," . VData
    
    ToolTip("Copied (CSV): " . A_Clipboard)
    SetTimer(() => ToolTip(), -2000)
}

CopyKeyPath(*)
{
    SelectedID := TV.GetSelection()
    if (SelectedID = 0)
    return
    
    Path := GetFullPath(TV, SelectedID)
    A_Clipboard := Path
    ToolTip("Path Copied: " . Path)
    SetTimer(() => ToolTip(), -2000)
}

UpdateView(Source, ItemID)
{
    if (ItemID = 0)
    return

    FullPath := GetFullPath(Source, ItemID)
    SB.SetText(FullPath)
    ShowValues(Source, ItemID, LV)
}

Gui_Size(GuiObj, WindowMinMax, Width, Height)
{
    if (WindowMinMax = -1)
    return

    Margin := 10
    SearchH := 30
    
    TVWidth := Floor((Width - (Margin * 3)) * 0.35)
    LVWidth := Width - TVWidth - (Margin * 3)
    CtrlHeight := Height - (Margin * 4) - SearchH

    SearchBox.Move(60, Margin, TVWidth - 50)
    TV.Move(Margin, Margin + SearchH, TVWidth, CtrlHeight)
    LV.Move(TVWidth + (Margin * 2), Margin + SearchH, LVWidth, CtrlHeight)
}

CreateValue(Type)
{
    SelectedID := TV.GetSelection()
    if (SelectedID = 0)
    return
    
    CurrentPath := GetFullPath(TV, SelectedID)
    IB := InputBox("Enter Name for the new " . Type . " value:", "New Value")
    
    if (IB.Result = "Cancel")
    return
    
    Prompt := (Type = "REG_BINARY") ? "Enter Hex Data (e.g., DEADBEEF):" : "Enter Data:"
    VDataIB := InputBox(Prompt, "Value Data")
    
    if (VDataIB.Result = "Cancel")
    return
    
    try {
        RegWrite(VDataIB.Value, Type, CurrentPath, IB.Value)
        ShowValues(TV, SelectedID, LV)
    }
}

EditValue()
{
    Row := LV.GetNext()
    if (Row = 0)
    return
    
    VName := LV.GetText(Row, 1)
    VType := LV.GetText(Row, 2)
    VData := LV.GetText(Row, 3)
    
    IB := InputBox("Edit value for '" VName "':", "Edit " VType,, VData)
    
    if (IB.Result = "Cancel")
    return
    
    if (IB.Value = VData)
    return

    SelectedID := TV.GetSelection()
    CurrentPath := GetFullPath(TV, SelectedID)
    
    try {
        RegWrite(IB.Value, VType, CurrentPath, VName)
        ShowValues(TV, SelectedID, LV)
    }
}

GetFullPath(TreeViewObj, ItemID)
{
    CurrentID := ItemID
    Path := ""
    while (CurrentID != 0)
    {
        Txt := TreeViewObj.GetText(CurrentID)
        if (Txt = "Software")
        Path := "HKCU\Software" . (Path = "" ? "" : "\" . Path)
        else
        Path := Txt . (Path = "" ? "" : "\" . Path)
        CurrentID := TreeViewObj.GetParent(CurrentID)
    }
    return Path
}

ShowValues(TreeViewObj, ItemID, ListViewObj)
{
    ListViewObj.Delete()
    FullPath := GetFullPath(TreeViewObj, ItemID)
    
    Loop Reg, FullPath, "V"
    {
        try {
            ValData := RegRead()
            ListViewObj.Add("Icon2", A_LoopRegName, A_LoopRegType, ValData)
        }
    }
    ListViewObj.ModifyCol(1, "AutoHdr")
    ListViewObj.ModifyCol(2, "AutoHdr")
    ListViewObj.ModifyCol(3, "AutoHdr")

    if (ListViewObj.GetCount() = 0)
    return
}

CollapseSelectedKey()
{
    SelectedID := TV.GetSelection()
    if (SelectedID = 0)
    return

    if (TV.Get(SelectedID, "Expand"))
    {
        TV.Modify(SelectedID, "-Expand")
    }
    else
    {
        ParentID := TV.GetParent(SelectedID)
        if (ParentID != 0)
        {
            TV.Modify(ParentID, "Select -Expand")
        }
    }
}

FilterTree(EditCtrl, TreeObj)
{
    SearchTerm := EditCtrl.Value
    if (SearchTerm = "")
    return

    ItemID := 0
    Loop
    {
        ItemID := TreeObj.GetNext(ItemID, "Full")
        if (ItemID = 0)
        break
        
        ItemText := TreeObj.GetText(ItemID)
        if (InStr(ItemText, SearchTerm))
        {
            TreeObj.Modify(ItemID, "Select Vis")
            break
        }
    }
}

RefreshValues()
{
    SelectedID := TV.GetSelection()
    if (SelectedID = 0)
    return
    
    ShowValues(TV, SelectedID, LV)
}

ShowKeyMenu(GuiCtrlObj, ItemID, IsRightClick, X, Y)
{
    if (ItemID = 0)
    return
    
    KeyMenu.Show(X, Y)
}

ShowValueMenu(GuiCtrlObj, ItemIndex, IsRightClick, X, Y)
{
    ValMenu.Show(X, Y)
}

DeleteSelectedValue(*)
{
    Row := LV.GetNext()
    if (Row = 0)
    return
    
    VName := LV.GetText(Row, 1)
    SelectedID := TV.GetSelection()
    CurrentPath := GetFullPath(TV, SelectedID)
    
    if (MsgBox("Delete value '" VName "'?", "Confirm", "YesNo") = "No")
    return
    
    RegDelete(CurrentPath, VName)
    ShowValues(TV, SelectedID, LV)
}

RenameValue(*)
{
    Row := LV.GetNext()
    if (Row = 0)
    return
    
    OldName := LV.GetText(Row, 1)
    Type := LV.GetText(Row, 2)
    Data := LV.GetText(Row, 3)
    
    IB := InputBox("Enter new name:", "Rename Value",, OldName)
    
    if (IB.Result = "Cancel" || IB.Value = OldName)
    return
    
    SelectedID := TV.GetSelection()
    CurrentPath := GetFullPath(TV, SelectedID)
    
    RegWrite(Data, Type, CurrentPath, IB.Value)
    RegDelete(CurrentPath, OldName)
    ShowValues(TV, SelectedID, LV)
}

RenameKey(*)
{
    SelectedID := TV.GetSelection()
    if (SelectedID = RootID)
    return
    
    OldName := TV.GetText(SelectedID)
    IB := InputBox("Enter new name for key:", "Rename Key",, OldName)
    
    if (IB.Result = "Cancel" || IB.Value = OldName)
    return
    
    MsgBox("Key rename logic restricted for safety.")
}

CreateKey(*)
{
    SelectedID := TV.GetSelection()
    ParentPath := GetFullPath(TV, SelectedID)
    IB := InputBox("Enter name for new subkey:", "New Key")
    
    if (IB.Result = "Cancel")
    return
    
    RegWrite("", "REG_SZ", ParentPath . "\" . IB.Value)
    TV.Add(IB.Value, SelectedID, "Sort Icon1")
}

DeleteSelectedKey(*)
{
    SelectedID := TV.GetSelection()
    if (SelectedID = RootID)
    return
    
    TargetPath := GetFullPath(TV, SelectedID)
    if (MsgBox("Delete key?", "Confirm", "YesNo") = "No")
    return
    
    try {
        RegDeleteKey(TargetPath)
        TV.Delete(SelectedID)
    }
}