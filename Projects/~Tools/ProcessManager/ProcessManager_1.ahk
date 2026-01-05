; TITLE  :  AhkProcessManager v1.0
; SOURCE :  Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0

DetectHiddenWindows(true)

; --- Saved Information Requirements ---
global IL_Large := 0
global IL_Small := 0

TraySetIcon("C:\WINDOWS\System32\shell32.dll", 335)

; --- Setup the GUI ---
AdminStatus := A_IsAdmin ? "[ADMIN]" : "[USER]"
MyGui := Gui("+Resize", "AHK Process Manager v1.0 " . AdminStatus)
MyGui.SetFont("s9", "Segoe UI")

; Row 1: Search + Radios + Actions
MyGui.Add("Text", "xm y12", "Search:")
EditSearch := MyGui.Add("Edit", "x+5 w150 vSearchTerm") 
EditSearch.OnEvent("Change", (*) => UpdateList())

RadAll := MyGui.Add("Radio", "vViewAll x+10 y12", "All")
RadAHK := MyGui.Add("Radio", "x+10 vViewAHK Checked y12", "AHK Only")
RadAll.OnEvent("Click", (*) => UpdateList())
RadAHK.OnEvent("Click", (*) => UpdateList())

BtnRefresh := MyGui.Add("Button", "x+10 w70 h26 y10", "🔄 Refresh")
BtnRefresh.OnEvent("Click", (*) => UpdateList())

if !A_IsAdmin {
    BtnAdmin := MyGui.Add("Button", "x+5 w120 h26 y10", "🛡️ Restart as Admin")
    BtnAdmin.OnEvent("Click", RestartAsAdmin)
}

BtnCancel := MyGui.Add("Button", "x+5 w70 h26 y10", "❌ Cancel")
BtnCancel.OnEvent("Click", (*) => ExitApp())

; 2. Create ListView
LV := MyGui.Add("ListView", "xm y+15 w652 h450", ["Window Title", "Process Name", "PID", "Class"])
IL_Small := IL_Create(10, 10, false)
LV.SetImageList(IL_Small)

; Register events
MyGui.OnEvent("Size", Gui_Size)
OnMessage(0x0100, WM_KEYDOWN) 

; 3. Setup Right-Click Menu
ProcessMenu := Menu()
ProcessMenu.Add("Open File Location", Menu_OpenDir)
ProcessMenu.Add("Properties", Menu_Properties)
ProcessMenu.Add() 
ProcessMenu.Add("Kill Process", Menu_KillProcess)
LV.OnEvent("ContextMenu", (GuiCtrl, Item, *) => (Item ? ProcessMenu.Show() : ""))
LV.OnEvent("DoubleClick", (*) => Menu_OpenDir())

UpdateList()

; Show with explicit width of 672
MyGui.Show("w672")
EditSearch.Focus()

; --- Core Functions ---

WM_KEYDOWN(wParam, lParam, msg, hwnd) {
    static VK_ESCAPE := 0x1B
    if (wParam = VK_ESCAPE) {
        if (GuiCtrl := GuiCtrlFromHwnd(hwnd)) {
            if (GuiCtrl.Name = "SearchTerm") {
                GuiCtrl.Value := ""
                UpdateList()
                return 0 
            }
        }
    }
}

Gui_Size(thisGui, MinMax, Width, Height) {
    if (MinMax = -1) 
        return
    margin := 10
    newW := Width - (margin * 2)
    newH := Height - 55 
    LV.Move(,, newW, newH)
}

UpdateList(*) {
    searchTerm := EditSearch.Value
    LV.Delete()
    IL_Destroy(IL_Small)
    global IL_Small := IL_Create(10, 10, false)
    LV.SetImageList(IL_Small)

    iconCache := Map()
    seenPIDs := Map() 

    for hwnd in WinGetList() {
        try {
            this_pid := WinGetPID(hwnd)
            if seenPIDs.Has(this_pid)
                continue
                
            this_class := WinGetClass(hwnd)
            full_title := WinGetTitle(hwnd)
            this_name  := WinGetProcessName(hwnd)

            if (StrCompare(this_name, "him.exe", 0) == 0)
                continue
            if (RadAHK.Value && !(this_class = "AutoHotkey" || this_class = "AutoHotkeyGUI"))
                continue

            if (full_title != "" || RadAHK.Value) {
                display_title := full_title
                if InStr(full_title, "\") {
                    SplitPath(full_title, &nameOnly)
                    display_title := nameOnly
                }

                if (searchTerm != "") {
                    searchContent := display_title . " " . this_name . " " . this_pid . " " . this_class
                    if !InStr(searchContent, searchTerm, false)
                        continue
                }

                iconIdx := 1
                try {
                    path := ProcessGetPath(this_pid)
                    iconIdx := iconCache.Has(path) ? iconCache[path] : IL_Add(IL_Small, path, 1)
                    iconCache[path] := iconIdx
                }
                
                LV.Add("Icon" . iconIdx, display_title, this_name, this_pid, this_class)
                seenPIDs[this_pid] := true 
            }
        }
    }
    
    LV.ModifyCol(1, "Sort")      
    LV.ModifyCol(1, "AutoHdr")   
    LV.ModifyCol(2, "AutoHdr")   
    LV.ModifyCol(3, "AutoHdr")   
    LV.ModifyCol(4, "AutoHdr")   
}

; --- Action Functions ---

RestartAsAdmin(*) {
    try {
        if A_IsCompiled
            Run('*RunAs "' A_ScriptFullPath '" /restart')
        else
            Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
        ExitApp()
    } catch {
        MsgBox("Admin elevation was refused or failed.")
    }
}

Menu_OpenDir(*) {
    if (Row := LV.GetNext()) {
        PID := LV.GetText(Row, 3)
        try {
            Path := ProcessGetPath(PID)
            Run('explorer.exe /select,"' . Path . '"')
        } catch {
            MsgBox("Access Denied or Path not found.")
        }
    }
}

Menu_Properties(*) {
    if (Row := LV.GetNext()) {
        PID := LV.GetText(Row, 3)
        try {
            Path := ProcessGetPath(PID)
            if (Path = "" || !FileExist(Path)) {
                MsgBox("Path not accessible: " . (Path = "" ? "Unknown" : Path))
                return
            }
            
            ; Clean COM approach (No PowerShell/DllCall strings needed)
            SplitPath(Path, &fName, &fDir)
            shellApp := ComObject("Shell.Application")
            objFolder := shellApp.Namespace(fDir)
            objFolderItem := objFolder.ParseName(fName)
            objFolderItem.InvokeVerb("Properties")
            
        } catch {
            MsgBox("Error accessing process properties. You may need to run as Admin.")
        }
    }
}

Menu_KillProcess(*) {
    if (Row := LV.GetNext()) {
        PTitle := LV.GetText(Row, 1), PName := LV.GetText(Row, 2), PID := LV.GetText(Row, 3)
        msg := "Kill " . (PTitle ? PTitle : PName) . " (PID: " . PID . ")?"
        if (MsgBox(msg, "Confirm", 4) == "Yes") {
            try {
                ProcessClose(PID)
                UpdateList()
            } catch {
                MsgBox("Failed to terminate process. Try running this script as Admin.")
            }
        }
    }
}