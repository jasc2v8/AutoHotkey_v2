; Version: 4.8.13
; Description: Registry Utility with Multi-Select Delete and Path Restoration
#Requires AutoHotkey v2.0+
#SingleInstance Force

; Ensure ExitApp is called on script exit
OnExit(*) => ExitApp()

; Global variables separated as requested
global IL_Large := 0
global IL_Small := 0
global RootID := 0
global SettingsFile := "RegEditSettings.ini"

MyGui := Gui("+Resize", "Registry Edit HKCU v4.8.13")
MyGui.SetFont("s9", "Segoe UI")

; Explicitly ExitApp when the GUI window is closed
MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.Opt("+MinSize600x400")

; Initialize ImageLists for Icons
IL_Small := IL_Create(10, 10, 0)
DllCall("user32.dll\PrivateExtractIcons", "Str", "shell32.dll", "Int", 3, "Int", 16, "Int", 16, "Ptr*", &IconKey := 0, "Ptr*", 0, "UInt", 1, "UInt", 0)
DllCall("user32.dll\PrivateExtractIcons", "Str", "shell32.dll", "Int", 69, "Int", 16, "Int", 16, "Ptr*", &IconDoc := 0, "Ptr*", 0, "UInt", 1, "UInt", 0)
IL_Add(IL_Small, "HICON:" . IconKey)
IL_Add(IL_Small, "HICON:" . IconDoc)

; Setup Controls
MyGui.Add("Text", "vSearchLabel w50", "Search:")
SearchBox := MyGui.Add("Edit", "vSearchInput w240 x+5")
SearchBox.OnEvent("Change", (*) => FilterTree(SearchBox, TV))

TV := MyGui.Add("TreeView", "r20 w300 xm ImageList" . IL_Small)
; LV Multi-select enabled via "Multi" option
LV := MyGui.Add("ListView", "r20 w500 x+10 ImageList" . IL_Small . " Multi", ["Value Name", "Type", "Data"])

SB := MyGui.Add("StatusBar")
SB.SetText("HKEY_CURRENT_USER")

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
F5::GlobalRefresh()
Del::DeleteSelectedValues()
#HotIf

; --- MENUS ---
KeyMenu := Menu()
KeyMenu.Add("Copy Key Path", CopyKeyPath)
KeyMenu.Add()
KeyMenu.Add("New Subkey", CreateKey)
KeyMenu.Add("Delete Key", DeleteSelectedKey)
KeyMenu.Add()
KeyMenu.Add("Refresh Tree", (*) => ReloadTree(TV))

ValMenu := Menu()
ValMenu.Add("Edit Data", (*) => EditValue())
ValMenu.Add("Delete Selected", DeleteSelectedValues)
ValMenu.Add()
ValMenu.Add("New String Value", (*) => CreateValue("REG_SZ"))
ValMenu.Add("New DWORD Value", (*) => CreateValue("REG_DWORD"))
ValMenu.Add("New Float (Binary)", (*) => CreateFloatValue())
ValMenu.Add()
ValMenu.Add("Refresh Values", (*) => RefreshValues())

; Initial Load
ReloadTree(TV)
RestoreLastKey(TV)
MyGui.Show()

; --- MULTI-DELETE LOGIC ---

DeleteSelectedValues(*)
{
    ; Only trigger if ListView is focused
    if (MyGui.FocusedCtrl != LV)
        return

    SelectedCount := LV.GetCount("Selected")
    if (SelectedCount = 0)
        return

    SelectedID := TV.GetSelection()
    if (SelectedID = 0)
        return
        
    CurrentPath := GetFullPath(TV, SelectedID)
    
    ConfirmMsg := (SelectedCount = 1) 
        ? "Are you sure you want to delete the selected value?" 
        : "Are you sure you want to delete " . SelectedCount . " selected values?"
        
    if (MsgBox(ConfirmMsg, "Confirm Deletion", "YesNo Icon!") = "No")
        return

    ; Collect names first to avoid index shifting during deletion
    ItemsToDelete := []
    RowNumber := 0
    Loop
    {
        RowNumber := LV.GetNext(RowNumber)
        if (RowNumber = 0)
            break
        ItemsToDelete.Push(LV.GetText(RowNumber, 1))
    }

    for ValueName in ItemsToDelete
    {
        try {
            RegDelete(CurrentPath, ValueName)
        }
    }

    ShowValues(TV, SelectedID, LV)
    SB.SetText("Deleted " . SelectedCount . " items.")
}

; --- NAVIGATION & PERSISTENCE ---

RestoreLastKey(TreeObj)
{
    LastPath := IniRead(SettingsFile, "Settings", "LastKey", "")
    if (LastPath = "" || LastPath = "HKEY_CURRENT_USER")
        return

    PathToFollow := StrReplace(LastPath, "HKEY_CURRENT_USER\", "",, &Count)
    if (Count = 0 && LastPath != "HKEY_CURRENT_USER")
        PathToFollow := LastPath
    
    Parts := StrSplit(PathToFollow, "\")
    CurrentID := RootID
    
    for PartName in Parts
    {
        FirstChild := TreeObj.GetChild(CurrentID)
        if (FirstChild != 0 && TreeObj.GetText(FirstChild) == "...")
        {
            TreeObj.Delete(FirstChild)
            AddSubKeys(GetFullPath(TreeObj, CurrentID), CurrentID, TreeObj, false)
        }
        
        ChildID := TreeObj.GetChild(CurrentID)
        FoundID := 0
        while (ChildID != 0)
        {
            if (TreeObj.GetText(ChildID) = PartName)
            {
                FoundID := ChildID
                break
            }
            ChildID := TreeObj.GetNext(ChildID)
        }
        
        if (FoundID = 0)
            break
            
        CurrentID := FoundID
        TreeObj.Modify(CurrentID, "Expand")
    }
    
    if (CurrentID != RootID)
        TreeObj.Modify(CurrentID, "Select Vis")
}

GetFullPath(TreeViewObj, ItemID)
{
    CurrentID := ItemID
    Path := ""
    while (CurrentID != 0)
    {
        Txt := TreeViewObj.GetText(CurrentID)
        Path := Txt . (Path = "" ? "" : "\" . Path)
        CurrentID := TreeViewObj.GetParent(CurrentID)
    }
    return Path
}

; --- REFRESH & LOADING ---

GlobalRefresh()
{
    ReloadTree(TV)
    RefreshValues()
    ToolTip("Refreshed")
    SetTimer(() => ToolTip(), -1000)
}

ReloadTree(TreeViewObj)
{
    TreeViewObj.Delete()
    global RootID := TreeViewObj.Add("HKEY_CURRENT_USER", 0, "Expand Icon1")
    AddSubKeys("HKEY_CURRENT_USER", RootID, TreeViewObj, false)
}

AddSubKeys(ParentPath, ParentID, TreeObj, DeepLoad := false)
{
    Loop Reg, ParentPath, "K"
    {
        NewID := TreeObj.Add(A_LoopRegName, ParentID, "Sort Icon1")
        if (!DeepLoad)
            TreeObj.Add("...", NewID)
    }
}

OnItemExpand(TreeObj, ItemID, Expanded)
{
    if (!Expanded)
        return

    FirstChild := TreeObj.GetChild(ItemID)
    if (FirstChild != 0 && TreeObj.GetText(FirstChild) == "...")
    {
        TreeObj.Delete(FirstChild)
        AddSubKeys(GetFullPath(TreeObj, ItemID), ItemID, TreeObj, false)
    }
}

; --- UI HELPERS ---

UpdateView(Source, ItemID)
{
    if (ItemID = 0)
        return

    FullPath := GetFullPath(Source, ItemID)
    SB.SetText(FullPath)
    IniWrite(FullPath, SettingsFile, "Settings", "LastKey")
    ShowValues(Source, ItemID, LV)
}

ShowValues(TreeViewObj, ItemID, ListViewObj)
{
    ListViewObj.Delete()
    FullPath := GetFullPath(TreeViewObj, ItemID)
    Loop Reg, FullPath, "V"
    {
        try {
            ValData := RegRead(FullPath, A_LoopRegName)
            ListViewObj.Add("Icon2", A_LoopRegName, A_LoopRegType, ValData)
        }
    }
    ListViewObj.ModifyCol(1, "AutoHdr")
}

Gui_Size(GuiObj, WindowMinMax, Width, Height)
{
    if (WindowMinMax = -1)
        return
    TV.Move(,, Floor(Width * 0.35), Height - 60)
    LV.Move(Floor(Width * 0.35) + 20,, Width - Floor(Width * 0.35) - 30, Height - 60)
}

RefreshValues()
{
    if (Sel := TV.GetSelection())
        ShowValues(TV, Sel, LV)
}

; --- STUBS ---
EditValue() => MsgBox("Edit Dialog")
CreateKey() => MsgBox("Create Key")
DeleteSelectedKey() => MsgBox("Delete Key")
CopyKeyPath() => (A_Clipboard := SB.GetText())
CollapseSelectedKey() => (Sel := TV.GetSelection(), Sel ? TV.Modify(Sel, "-Expand") : 0)
FilterTree(E, T) => 0
ShowKeyMenu(S, I, R, X, Y) => KeyMenu.Show(X, Y)
ShowValueMenu(S, I, R, X, Y) => ValMenu.Show(X, Y)
CreateValue(T) => MsgBox("Create " . T)
CreateFloatValue() => MsgBox("Create Float")