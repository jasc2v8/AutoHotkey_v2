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

; ObjTree v2.0.3
; Added OK button and Modal state to pause script execution

ObjTree(Obj, Title := "Object TreeView") {
    myGui := Gui("+Resize +MinSize300x200", Title)
    myGui.SetFont("s9", "Segoe UI")
    
    TV := myGui.Add("TreeView", "r20 w400")
    
    ; Add OK Button to close/continue
    btnOk := myGui.Add("Button", "Default w80", "OK")
    btnOk.OnEvent("Click", (*) => myGui.Destroy())
    
    ; Start recursion
    ObjTree_Add(TV, 0, Obj)
    
    myGui.OnEvent("Size", (guiObj, minMax, width, height) => ObjTree_Size(guiObj, minMax, width, height, TV, btnOk))
    
    ; Show as Modal to pause execution of the calling thread
    myGui.Show() ; ("Modal")
    
    ; Wait for the Gui to be destroyed before returning
    ;WinWaitClose(myGui)
}

ObjTree_Add(TV, ParentID, Obj) {
    if (!IsObject(Obj)) {
        return
    }

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

    for item in items {
        displayKey := (item.k = "" ? "''" : item.k)
        val := item.v
        
        if IsObject(val) {
            typeStr := (val is Map ? "Map" : (val is Array ? "Array" : "Object"))
            nodeID := TV.Add(displayKey " [" typeStr "]", ParentID, "Expand")
            ObjTree_Add(TV, nodeID, val)
        } else {
            displayVal := (val = "" ? "''" : val)
            TV.Add(displayKey ": " displayVal, ParentID)
        }
    }
}

ObjTree_Size(GuiObj, MinMax, Width, Height, TV, btnOk) {
    if (MinMax = -1)
        return
    
    ; Resize TreeView to leave room for button at bottom
    TV.Move(10, 10, Width - 20, Height - 50)
    
    ; Position OK button at bottom right
    btnOk.Move(Width - 90, Height - 35)
}

; Usage example that demonstrates the pause:
; MyMap := Map("Key1", "Value1", "Key2", "Value2")
; ObjTree(MyMap)
; MsgBox("This will only show AFTER you click OK or close the TreeView.")
