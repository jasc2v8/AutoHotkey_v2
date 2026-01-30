; TITLE  :  AhkIconViewer v1.0.0.2
; SOURCE :  Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  View and extract icons from Windows resources.
; USAGE  :
; NOTES  :

/*
    TODO:
*/
#Requires AutoHotkey v2+
#SingleInstance Force

TraySetIcon("C:\WINDOWS\System32\shell32.dll", 37)

; --- Global Initializations (Separate Lines) ---
global IL_Large := 0
global IL_Small := 0

; --- Configuration ---
global MaxToTry := 400 
global CurrentIconSize := 32
global CurrentFilePath := A_WinDir "\System32\imageres.dll"
global LastExportDir := ""
global TotalIconsInFile := 0

global GuiTitle := "Icon Viewer v1.0.0.2"

; Expanded list of icon-rich system files
CommonLibs := [
    "imageres.dll", "shell32.dll", "ddores.dll", "mstsc.exe", 
    "dsuiext.dll",  "user32.dll",  "comres.dll", "pifmgr.dll",
    "wmploc.dll",   "compstui.dll", "setupapi.dll", "netcenter.dll",
    "moricons.dll", "mmcbase.dll", "netshell.dll", "accessibilitycpl.dll"
]

; --- GUI Setup ---
MyGui := Gui("+Resize", GuiTitle)
MyGui.SetFont("s10", "Segoe UI")
MyGui.BackColor := "7DA7CA" ; Steel Blue +2.5 Glaucous

; --- Menu Setup ---
ContextMnu := Menu()
ContextMnu.Add("Copy Path & Index", CopyResourceInfo)
ContextMnu.Add("Save This Icon...", (*) => SaveSelectedIcon())
ContextMnu.Add()
ContextMnu.Add("Select All", (*) => (LV.Focus(), LV.Modify(0, "Select")))

; --- Top Controls ---
MyGui.Add("Button", "x10 y11 w100", "Custom File...").OnEvent("Click", SelectNewFile)
MyGui.Add("Text", "x120 y15", "Zoom:")
ZoomSld := MyGui.Add("Slider", "x165 y11 w60 Range16-128 TickInterval16", CurrentIconSize)
ZoomSld.OnEvent("Change", ChangeZoom)

MyGui.Add("Text", "x235 y15", "Search:")
SearchEdit := MyGui.Add("Edit", "x285 y12 w50")
SearchEdit.OnEvent("Change", (*) => FilterIcons(SearchEdit.Value))

BtnView := MyGui.Add("Button", "x345 y11 w80", "List View")
BtnView.OnEvent("Click", ToggleView)

BtnSelectAll := MyGui.Add("Button", "x430 y11 w80", "Select All")
BtnSelectAll.OnEvent("Click", (*) => (LV.Focus(), LV.Modify(0, "Select")))

BtnBatch := MyGui.Add("Button", "x515 y11 w100", "Batch Export")
BtnBatch.OnEvent("Click", BatchExportIcons)

BtnOpen := MyGui.Add("Button", "x620 y11 w100 Hidden", "Open Folder")
BtnOpen.OnEvent("Click", (*) => Run(LastExportDir))

ProgBar := MyGui.Add("Progress", "x140 y48 w600 h15 Hidden cGreen Range0-100")

; --- Middle Section (+Sort added to ListBox) ---
LB := MyGui.Add("ListBox", "x10 y75 w120 r10 +Sort", CommonLibs)
LB.OnEvent("Change", (Ctrl, *) => LoadIcons(A_WinDir "\System32\" . Ctrl.Text))

LV := MyGui.Add("ListView", "x140 y75 w600 r10 +Icon +VScroll", ["Index", "Name"])
LV.OnEvent("ContextMenu", (GuiCtrl, Item, IsRightClick, X, Y) => (Item > 0) ? ContextMnu.Show(X, Y) : "")
LV.OnEvent("ItemSelect", (*) => UpdateStatus()) 

; --- Bottom Status Bar ---
SB := MyGui.AddStatusBar()
SB.SetParts(400, 120) 

; Hotkey for Escape
#HotIf WinActive("ahk_id " MyGui.Hwnd)
Esc:: {
    if (SearchEdit.Value != "") {
        SearchEdit.Value := ""
        FilterIcons("")
    }
}
#HotIf

MyGui.OnEvent("Size", Gui_Size)
LoadIcons(CurrentFilePath)
MyGui.Show()

; --- Status & Title Functions ---

UpdateStatus() {
    global CurrentFilePath, TotalIconsInFile
    SelCount := LV.GetCount("Selected")
    SB.SetText(CurrentFilePath, 1)
    SB.SetText("Total: " . TotalIconsInFile, 2)
    SB.SetText("Selected: " . SelCount, 3)
}

; --- Core Functions ---

FilterIcons(SearchVal) {
    LV.Opt("-Redraw")
    LV.Delete()
    VisibleCount := 0
    Loop MaxToTry {
        try {
            if (SearchVal = "" || InStr(String(A_Index), SearchVal)) {
                idx := IL_Add(IL_Large, CurrentFilePath, A_Index)
                if (idx > 0) {
                    IL_Add(IL_Small, CurrentFilePath, A_Index)
                    LV.Add("Icon" . idx, A_Index, "Index " . A_Index)
                    VisibleCount++
                }
            }
        }
    }
    UpdateStatus()
    LV.Opt("+Redraw")
}

LoadIcons(FilePath) {
    global IL_Large, IL_Small, CurrentFilePath, CurrentIconSize, MaxToTry, TotalIconsInFile
    CurrentFilePath := FilePath
    if !FileExist(FilePath)
        return
    
    LV.Opt("-Redraw")
    LV.Delete()
    BtnOpen.Visible := false 
    
    if (IL_Large)
        IL_Destroy(IL_Large)
    if (IL_Small)
        IL_Destroy(IL_Small)
    
    IL_Large := DllCall("Comctl32.dll\ImageList_Create", "int", CurrentIconSize, "int", CurrentIconSize, "uint", 0x21, "int", MaxToTry, "int", 10, "ptr")
    IL_Small := IL_Create(MaxToTry, 10, 0) 
    LV.SetImageList(IL_Large, 0) 
    LV.SetImageList(IL_Small, 1) 
    
    TotalIconsInFile := 0
    Loop MaxToTry {
        hIcon := 0
        if DllCall("PrivateExtractIcons", "str", FilePath, "int", A_Index-1, "int", 16, "int", 16, "ptr*", &hIcon, "ptr*", 0, "uint", 1, "uint", 0) > 0 {
            TotalIconsInFile++
            DllCall("DestroyIcon", "ptr", hIcon)
        }
    }
    
    FilterIcons(SearchEdit.Value)
}

ToggleView(Btn, *) {
    static IsIconView := true
    LV.Opt("-Redraw")
    if IsIconView {
        LV.Opt("-Icon +Report"), LV.SetImageList(IL_Small, 1)
        Btn.Text := "Icon View"
    } else {
        LV.Opt("-Report +Icon"), LV.SetImageList(IL_Large, 0)
        Btn.Text := "List View"
    }
    IsIconView := !IsIconView
    try LV.ModifyCol(1, "AutoHdr")
    LV.Opt("+Redraw")
}

BatchExportIcons(*) {
    global LastExportDir
    TargetIndices := []
    Row := 0
    Loop {
        Row := LV.GetNext(Row)
        if !Row
            break
        TargetIndices.Push(LV.GetText(Row, 1))
    }
    if (TargetIndices.Length = 0) {
        if MsgBox("No icons selected. Export all visible icons?", "Export All?", "YesNo Icon?") = "No"
            return
        Loop LV.GetCount()
            TargetIndices.Push(LV.GetText(A_Index, 1))
    }
    SelectedFolder := DirSelect(, 3, "Select Folder to Export")
    if (SelectedFolder = "")
        return
    SplitPath(CurrentFilePath, &FileName)
    ExportDir := SelectedFolder "\" RegExReplace(FileName, "\.", "_") "_Export"
    if !DirExist(ExportDir)
        DirCreate(ExportDir)
    LastExportDir := ExportDir 
    si := Buffer(24, 0), NumPut("UInt", 1, si)
    pToken := 0
    DllCall("gdiplus\GdiplusStartup", "ptr*", &pToken, "ptr", si, "ptr", 0)
    ProgBar.Visible := true
    ProgBar.Value := 0
    Count := 0
    for idx in TargetIndices {
        OutPath := ExportDir "\Icon_" idx ".png"
        if ExportIconToPNG_Simple(CurrentFilePath, idx, CurrentIconSize, OutPath)
            Count++
        ProgBar.Value := (A_Index / TargetIndices.Length) * 100
    }
    Sleep(150)
    try DllCall("gdiplus\GdiplusShutdown", "ptr", pToken)
    ProgBar.Visible := false
    BtnOpen.Visible := true 
    MsgBox("Exported " Count " icons.", "Success", "Iconi")
}

ExportIconToPNG_Simple(File, Index, Size, Dest) {
    static PngClsid := 0
    if !PngClsid {
        PngClsid := Buffer(16)
        DllCall("ole32\CLSIDFromString", "wstr", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "ptr", PngClsid)
    }
    hIcon := 0
    DllCall("PrivateExtractIcons", "str", File, "int", Index-1, "int", Size, "int", Size, "ptr*", &hIcon, "ptr*", 0, "uint", 1, "uint", 0)
    if !hIcon
        return false
    pBitmap := 0
    DllCall("gdiplus\GdipCreateBitmapFromHICON", "ptr", hIcon, "ptr*", &pBitmap)
    result := DllCall("gdiplus\GdipSaveImageToFile", "ptr", pBitmap, "wstr", Dest, "ptr", PngClsid, "ptr", 0)
    DllCall("gdiplus\GdiplusDisposeImage", "ptr", pBitmap)
    DllCall("DestroyIcon", "ptr", hIcon)
    return (result == 0)
}

CopyResourceInfo(*) {
    global CurrentFilePath
    if (Row := LV.GetNext()) {
        IconIdx := LV.GetText(Row, 1)
        A_Clipboard := '"' . CurrentFilePath . '", ' . IconIdx
        ToolTip("Copied: " . A_Clipboard)
        SetTimer(() => ToolTip(), -2500)
    }
}

SaveSelectedIcon(*) {
    Row := LV.GetNext()
    if !Row {
        MsgBox("Please select an icon first!")
        return
    }
    IconIdx := LV.GetText(Row, 1)
    DefaultName := "Icon_" . IconIdx . "_" . CurrentIconSize . "px.png"
    SelectedSavePath := FileSelect("S16", DefaultName, "Save Icon as PNG", "PNG Images (*.png)")
    if (SelectedSavePath != "") {
        if !RegExMatch(SelectedSavePath, "i)\.png$")
            SelectedSavePath .= ".png"
        si := Buffer(24, 0), NumPut("UInt", 1, si)
        pToken := 0
        DllCall("gdiplus\GdiplusStartup", "ptr*", &pToken, "ptr", si, "ptr", 0)
        if ExportIconToPNG_Simple(CurrentFilePath, IconIdx, CurrentIconSize, SelectedSavePath)
            ToolTip("Saved!")
        Sleep(50)
        try DllCall("gdiplus\GdiplusShutdown", "ptr", pToken)
        SetTimer(() => ToolTip(), -2500)
    }
}

ChangeZoom(Ctrl, *) {
    global CurrentIconSize := Ctrl.Value
    LoadIcons(CurrentFilePath)
}

Gui_Size(GuiObj, MinMax, Width, Height) {
    if (MinMax = -1)
        return
    LB.Move(,,, Height - 120)
    LV.Move(,, Width - 160, Height - 120)
    ProgBar.Move(,, Width - 160)
    try LV.ModifyCol(1, "AutoHdr")
}

SelectNewFile(*) {
    SelectedFile := FileSelect(3, A_WinDir "\System32", "Select Icon Resource", "Icons (*.dll; *.exe; *.icl; *.ocx)")
    if (SelectedFile != "")
        LoadIcons(SelectedFile)
}