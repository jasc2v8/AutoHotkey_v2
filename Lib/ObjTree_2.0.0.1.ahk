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

; ObjTree v2.0.1
; A utility to visualize object structures in a TreeView

ObjTree(Obj, Title := "Object TreeView") {
    myGui := Gui("+Resize", Title)
    myGui.SetFont("s9", "Segoe UI")
    
    TV := myGui.Add("TreeView", "r20 w400")
    
    ; Start recursion
    ObjTree_Add(TV, 0, Obj)
    
    myGui.OnEvent("Size", (guiObj, minMax, width, height) => ObjTree_Size(guiObj, minMax, width, height, TV))
    myGui.Show()
    return myGui
}

ObjTree_Add(TV, ParentID, Obj) {
    if (!IsObject(Obj)) {
        return
    }

    for key, val in (Obj is Array ? Obj : Obj.OwnProps()) {
        displayKey := (key = "" ? "''" : key)
        
        if IsObject(val) {
            typeStr := (val is Array ? "Array" : "Object")
            nodeID := TV.Add(displayKey " [" typeStr "]", ParentID, "Expand")
            ObjTree_Add(TV, nodeID, val)
        } else {
            displayVal := (val = "" ? "''" : val)
            TV.Add(displayKey ": " displayVal, ParentID)
        }
    }
}

ObjTree_Size(GuiObj, MinMax, Width, Height, TV) {
    if (MinMax = -1)
        return
    
    TV.Move(,, Width - 20, Height - 20)
}

; Example usage:
;myData := {Name: "John", Roles: ["Admin", "User"], Meta: {ID: 123, Active: true}}
;ObjTree(myData)
