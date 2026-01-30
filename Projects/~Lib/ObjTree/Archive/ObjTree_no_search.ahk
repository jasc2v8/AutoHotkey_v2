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

; ObjTree v2.0.13
; Added "Copy Value Only" to Context Menu

ObjTree(Obj, Title := "Object TreeView", IsModal := true) {
    myGui := Gui("+Resize +MinSize300x200", Title)
    myGui.SetFont("s9", "Segoe UI")
    
    TV := myGui.Add("TreeView", "r20 w400")
    TV.OnEvent("DoubleClick", ObjTree_Copy)
    TV.OnEvent("ContextMenu", (GuiCtrl, ItemID, IsRightClick, X, Y) => ObjTree_Menu(GuiCtrl, ItemID, IsRightClick, X, Y, Obj))
    
    btnOk := myGui.Add("Button", "Default w80", "OK")
    btnOk.OnEvent("Click", (*) => myGui.Destroy())
    
    Visited := Map()
    ObjTree_Add(TV, 0, Obj, Visited)
    
    myGui.OnEvent("Size", (guiObj, minMax, width, height) => ObjTree_Size(guiObj, minMax, width, height, TV, btnOk))
    
    myGui.Show()
    
    if (IsModal)
        WinWaitClose(myGui)
}

ObjTree_Add(TV, ParentID, Obj, Visited) {
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
        displayKey := (item.k = "" ? "''" : item.k)
        val := item.v
        
        if IsObject(val) {
            typeStr := (val is Map ? "Map" : (val is Array ? "Array" : "Object"))
            nodeID := TV.Add(displayKey " [" typeStr "]", ParentID, "Expand")
            ObjTree_Add(TV, nodeID, val, Visited)
        } else {
            displayVal := (val = "" ? "''" : val)
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

ObjTree_Size(GuiObj, MinMax, Width, Height, TV, btnOk) {
    if (MinMax = -1)
        return
    
    TV.Move(10, 10, Width - 20, Height - 50)
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
    m.Add("Reload & Sort", (*) => ObjTree_Reload(GuiCtrl, OriginalObj))
    m.Show(X, Y)
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
}

ObjTree_Copy(GuiCtrl, ItemID, ValueOnly := false) {
    if (ItemID = 0)
        return
        
    txt := GuiCtrl.GetText(ItemID)
    
    if (ValueOnly) {
        ; Find the first colon for values or the first bracket for objects
        pos := InStr(txt, ": ")
        if (pos) {
            txt := SubStr(txt, pos + 2)
        } else {
            ; If it's a branch, return the part before the type marker [Map]
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