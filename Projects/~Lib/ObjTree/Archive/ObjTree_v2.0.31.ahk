; TITLE  :  ObjTree v2.0.0.1
; SOURCE :  jasc2v8, Gemini, and https://github.com/HotKeyIt/ObjTree/tree/v2
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  A utility to visualize object structures in a TreeView
; USAGE  :  ObjTree(Obj, Title := "Object TreeView")
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

; ObjTree v2.0.31
; Filter box widened by 10px, X button remains at right edge

ObjTree(Obj, Title := "Object TreeView", IsModal := true) {
    myGui := Gui("+Resize +MinSize300x200", Title)
    myGui.SetFont("s9", "Segoe UI")
    
    ; Filter Controls
    myGui.Add("Text", "w40", "Filter:")
    ; Width increased by 10px (from 298 to 308)
    filterEdit := myGui.Add("Edit", "x+5 vFilter w308")
    btnClear := myGui.Add("Button", "x+20 w25 h22", "X")
    
    TV := myGui.Add("TreeView", "xm r20 w400")
    TV.OnEvent("DoubleClick", ObjTree_Copy)
    TV.OnEvent("ContextMenu", (GuiCtrl, ItemID, IsRightClick, X, Y) => ObjTree_Menu(GuiCtrl, ItemID, IsRightClick, X, Y, Obj))
    
    ; Events for filtering
    filterEdit.OnEvent("Change", (ed, *) => ObjTree_Filter(ed, TV, Obj))
    btnClear.OnEvent("Click", (*) => ObjTree_HandleClear(filterEdit, TV, Obj))
    
    ; Handle Esc to clear filter
    myGui.OnEvent("Escape", (guiObj) => ObjTree_HandleEsc(guiObj, filterEdit, TV, Obj))
    
    btnOk := myGui.Add("Button", "Default w80", "OK")
    btnOk.OnEvent("Click", (*) => myGui.Destroy())
    
    ; Initial load and expand
    ObjTree_Reload(TV, Obj)
    ObjTree_ExpandCollapse(TV, "Expand")
    
    myGui.OnEvent("Size", (guiObj, minMax, width, height) => ObjTree_Size(guiObj, minMax, width, height, TV, btnOk, filterEdit, btnClear))
    
    ; Focus the filter box so user can type immediately
    filterEdit.Focus()
    myGui.Show()
    
    if (IsModal)
        WinWaitClose(myGui)
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
    
    ; Always expand results when filtering or clearing filter
    ObjTree_ExpandCollapse(TV, "Expand")
    TV.Opt("+Redraw")
}

ObjTree_Add(TV, ParentID, Obj, Visited, Filter := "") {
    if (!IsObject(Obj)) {
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

ObjTree_Size(GuiObj, MinMax, Width, Height, TV, btnOk, filterEdit, btnClear) {
    if (MinMax = -1)
        return
    
    ; Widened edit box (Width - 100 instead of Width - 110)
    filterEdit.Move(,, Width - 100)
    
    ; X button remains flush with the right edge
    btnClear.Move(Width - 35)
    
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

; Test Case for Circular Reference:
;  a := {name: "A"}
;  b := {name: "B"}
;  a.child := b
;  b.parent := a
;  ObjTree(a)