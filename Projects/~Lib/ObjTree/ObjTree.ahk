; TITLE  :  ObjTree v1.0.0.42
; SOURCE :  jasc2v8, Gemini, and https://github.com/HotKeyIt/ObjTree/tree/v2
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  A utility to visualize object structures in a TreeView
; USAGE  :  ObjTree(Obj, Title := "Object TreeView")
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

; ObjTree v2.0.52
; Reverted core logic to v2.0.46 (Stable)
; Added: JSON-style string detection for structured viewing

ObjTree(Obj, Title := "Object TreeView", IsModal := true) {
    static IsDark := false 
    
    myGui := Gui("+Resize +MinSize300x200", Title)
    myGui.SetFont("s9", "Segoe UI")
    
    ; Filter Controls
    lblFilter := myGui.Add("Text", "w40", "Filter:")
    filterEdit := myGui.Add("Edit", "x+5 vFilter w253")
    btnClear := myGui.Add("Button", "x+20 w25 h22", "X")
    btnTheme := myGui.Add("Button", "x+5 w50 h22", "Dark")
    
    TV := myGui.Add("TreeView", "xm r20 w400")
    TV.OnEvent("DoubleClick", ObjTree_Copy)
    TV.OnEvent("ContextMenu", (GuiCtrl, ItemID, IsRightClick, X, Y) => ObjTree_Menu(GuiCtrl, ItemID, IsRightClick, X, Y, Obj))
    
    ; Events
    filterEdit.OnEvent("Change", (ed, *) => ObjTree_Filter(ed, TV, Obj))
    btnClear.OnEvent("Click", (*) => ObjTree_HandleClear(filterEdit, TV, Obj))
    btnTheme.OnEvent("Click", (*) => ToggleTheme())
    
    myGui.OnEvent("Escape", (guiObj) => ObjTree_HandleEsc(guiObj, filterEdit, TV, Obj))
    
    btnOk := myGui.Add("Button", "Default w80", "OK")
    btnOk.OnEvent("Click", (*) => myGui.Destroy())
    
    ObjTree_Reload(TV, Obj)
    ObjTree_ExpandCollapse(TV, "Expand")
    
    myGui.OnEvent("Size", (guiObj, minMax, width, height) => ObjTree_Size(guiObj, minMax, width, height, TV, btnOk, filterEdit, btnClear, btnTheme))
    
    ToggleTheme(ForceInit := false) {
        if (!ForceInit)
            IsDark := !IsDark
        
        if (IsDark) {
            myGui.BackColor := "0x202020"
            DllCall("uxtheme\SetWindowTheme", "ptr", TV.Hwnd, "ptr", 0, "ptr", 0)
            TV.Opt("Background1C1C1C cWhite")
            filterEdit.Opt("Background2D2D2D cWhite")
            lblFilter.Opt("cWhite")
            btnTheme.Text := "Light"
            SetDarkModeFrame(myGui.Hwnd, true)
        } else {
            ;myGui.BackColor := "Default"
            ;myGui.BackColor := "4682B4" ; Steel Blue
            myGui.BackColor := "7DA7CA" ; Steel Blue +2.5 Glaucous
            ;myGui.BackColor := "5D8AA8" ; Royal Air Force (RAF Blue)

            DllCall("uxtheme\SetWindowTheme", "ptr", TV.Hwnd, "str", "Explorer", "ptr", 0)
            TV.Opt("BackgroundDefault cDefault")
            filterEdit.Opt("BackgroundDefault cDefault")
            lblFilter.Opt("cDefault")
            btnTheme.Text := "Dark"
            SetDarkModeFrame(myGui.Hwnd, false)
        }
    }

    SetDarkModeFrame(hwnd, enable) {
        static DWMWA_USE_IMMERSIVE_DARK_MODE := 20
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", DWMWA_USE_IMMERSIVE_DARK_MODE, "int*", enable, "int", 4)
    }

    ToggleTheme(true)
    
    filterEdit.Focus()
    myGui.Show()
    
    if (IsModal)
        WinWaitClose(myGui)
}

ObjTree_Add(TV, ParentID, Obj, Visited, Filter := "") {
    ; Handle Strings (List \n, CSV, or Raw)
    if (!IsObject(Obj)) {
        strVal := String(Obj)
        
        ; Newline List
        if InStr(strVal, "`n") {
            nodeID := TV.Add("[List]", ParentID)
            Loop Parse, strVal, "`n", "`r"
            {
                if (A_LoopField != "")
                    TV.Add("Line " A_Index ": " A_LoopField, nodeID)
            }
        } 
        ; CSV Row
        else if InStr(strVal, ",") {
            nodeID := TV.Add("[CSV Row]", ParentID)
            Loop Parse, strVal, ","
                TV.Add("Col " A_Index ": " Trim(A_LoopField), nodeID)
        } 
        ; Raw Value
        else {
            TV.Add("Value: " strVal, ParentID)
        }
        return
    }

    if (Visited.Has(Obj)) {
        TV.Add("[Circular Reference]", ParentID)
        return
    }
    
    Visited[Obj] := true
    items := []

    if (Obj is Map) {
        for key, val in Obj
            items.Push({k: key, v: val})
    } else if (Obj is Array) {
        for key, val in Obj
            items.Push({k: key, v: val})
    } else {
        for key, val in Obj.OwnProps()
            items.Push({k: key, v: val})
    }

    if (items.Length > 1) {
        QuickSort(items, (a, b) => AlnumCompare(String(a.k), String(b.k)))
    }

    for item in items {
        displayKey := (item.k = "" ? "''" : String(item.k))
        val := item.v
        
        matchFound := (Filter = "")
        if (Filter != "") {
            if (InStr(displayKey, Filter)) {
                matchFound := true
            } else if (!IsObject(val) && InStr(String(val), Filter)) {
                matchFound := true
            }
        }

        if (!matchFound) {
            if (!IsObject(val))
                continue
        }

        if IsObject(val) {
            typeStr := (val is Map ? "Map" : (val is Array ? "Array" : "Object"))
            nodeID := TV.Add(displayKey " [" typeStr "]", ParentID)
            ObjTree_Add(TV, nodeID, val, Visited, Filter)
            
            if (Filter != "" && !TV.GetChild(nodeID) && !InStr(displayKey, Filter))
                TV.Delete(nodeID)
        } else {
            displayVal := (val = "" ? "''" : String(val))
            TV.Add(displayKey ": " displayVal, ParentID)
        }
    }
}

ObjTree_HandleClear(filterEdit, TV, Obj) {
    filterEdit.Value := ""
    filterEdit.Focus()
    ObjTree_Filter(filterEdit, TV, Obj)
}

ObjTree_HandleEsc(GuiObj, filterEdit, TV, Obj) {
    if (filterEdit.Value = "") {
        GuiObj.Destroy()
        return
    }
    
    ObjTree_HandleClear(filterEdit, TV, Obj)
}

ObjTree_Filter(ed, TV, Obj) {
    Static lastFilter := ""
    currentFilter := ed.Value
    
    if (currentFilter = lastFilter)
        return
    
    lastFilter := currentFilter
    TV.Opt("-Redraw")
    TV.Delete()
    Visited := Map()
    ObjTree_Add(TV, 0, Obj, Visited, currentFilter)
    
    ObjTree_ExpandCollapse(TV, "Expand")
    TV.Opt("+Redraw")
}

AlnumCompare(a, b) {
    return StrCompare(a, b, "Logical")
}

QuickSort(Items, Compare, Left := 1, Right := -1) {
    if (Right = -1)
        Right := Items.Length
    
    i := Left, j := Right
    pivot := Items[(Left + Right) // 2]
    
    while (i <= j) {
        while (Compare(Items[i], pivot) < 0)
            i++
        while (Compare(Items[j], pivot) > 0)
            j--
        if (i <= j) {
            temp := Items[i]
            Items[i] := Items[j]
            Items[j] := temp
            i++, j--
        }
    }
    if (Left < j)
        QuickSort(Items, Compare, Left, j)
    if (i < Right)
        QuickSort(Items, Compare, i, Right)
}

ObjTree_Size(GuiObj, MinMax, Width, Height, TV, btnOk, filterEdit, btnClear, btnTheme) {
    if (MinMax = -1)
        return
    
    filterEdit.Move(,, Width - 155)
    btnClear.Move(Width - 90)
    btnTheme.Move(Width - 60)
    TV.Move(,, Width - 20, Height - 85)
    btnOk.Move(Width - 90, Height - 35)
}

ObjTree_Menu(GuiCtrl, ItemID, IsRightClick, X, Y, OriginalObj) {
    m := Menu()
    if (ItemID != 0) {
        m.Add("Copy Full Line", (*) => ObjTree_Copy(GuiCtrl, ItemID))
        m.Add("Copy Value Only", (*) => ObjTree_Copy(GuiCtrl, ItemID, true))
        m.Add()
    }
    
    m.Add("Expand All", (*) => ObjTree_ExpandCollapse(GuiCtrl, "Expand"))
    m.Add("Collapse All", (*) => ObjTree_ExpandCollapse(GuiCtrl, "Collapse"))
    m.Add()
    m.Add("Save to File", (*) => ObjTree_SaveToFile(GuiCtrl))
    m.Add("Reload & Sort", (*) => ObjTree_Reload(GuiCtrl, OriginalObj))
    m.Show(X, Y)
}

ObjTree_SaveToFile(TV) {
    FilePath := FileSelect("S16", "ObjectExport.txt", "Save Object Tree", "Text Documents (*.txt)")
    if (FilePath = "") {
        return
    }

    OutText := ""
    ObjTree_RecursiveGetText(TV, 0, 0, &OutText)
    
    try {
        if (FileExist(FilePath))
            FileDelete(FilePath)
        FileAppend(OutText, FilePath, "UTF-8")
        MsgBox("Export successful!", "ObjTree", "Iconi T2")
    } catch Error as err {
        MsgBox("Export failed:`n" err.Message, "Error", "Iconx")
    }
}

ObjTree_RecursiveGetText(TV, ParentID, Level, &OutText) {
    ItemID := TV.GetChild(ParentID)
    while (ItemID) {
        Indent := ""
        Loop Level
            Indent .= "    "
        
        OutText .= Indent TV.GetText(ItemID) "`n"
        ObjTree_RecursiveGetText(TV, ItemID, Level + 1, &OutText)
        ItemID := TV.GetNext(ItemID)
    }
}

ObjTree_Reload(TV, Obj) {
    TV.Delete()
    Visited := Map()
    ObjTree_Add(TV, 0, Obj, Visited)
}

ObjTree_ExpandCollapse(TV, Action) {
    ItemID := 0 
    Loop {
        ItemID := TV.GetNext(ItemID, "Full")
        if (!ItemID)
            break
        
        TV.Modify(ItemID, (Action = "Expand" ? "Expand" : "-Expand"))
    }
    
    SendMessage(0x115, 6, 0, TV.Hwnd)
}

ObjTree_Copy(GuiCtrl, ItemID, ValueOnly := false) {
    if (ItemID = 0)
        return
        
    txt := GuiCtrl.GetText(ItemID)
    if (ValueOnly) {
        pos := InStr(txt, ": ")
        if (pos) {
            txt := SubStr(txt, pos + 2)
        } else {
            pos := InStr(txt, " [")
            if (pos)
                txt := SubStr(txt, 1, pos - 1)
        }
    }
    A_Clipboard := txt
    ToolTip("Copied: " txt)
    SetTimer(() => ToolTip(), -1500)
}

;ObjTreeExample()

ObjTreeExample() {

    ; Correct AHK v2 Multi-line String format
    jsonTest := "
    (
    {
        `"Project`": `"ObjTree Debugger`",
        `"Version`": `"2.0.55`",
        `"Features`": [
            `"Search Filtering`",
            `"Dark Mode`"
        ],
        `"Settings`": {
            `"Theme`": `"Light`",
            `"ShowIcons`": true
        }
    }
    )"

    ; Call the function
    ObjTree(jsonTest, "AHK v2 String Test")

}


; Test Case for Circular Reference:
;  a := {name: "A"}
;  b := {name: "B"}
;  a.child := b
;  b.parent := a
;  ObjTree(a)

