;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; Flexible GUI List Loader
; Version 1.0.3

#Requires AutoHotkey v2.0

; --- Input Examples (Uncomment one to test) ---
; Data := ["Apple", "Banana", "Cherry"]                                  ; Simple Array
; Data := Map("Key1", "Value1", "Key2", "Value2")                        ; Map
; Data := "Red,Green,Blue,Yellow"                                        ; CSV String
Data := "Line One`nLine Two`nLine Three"                                 ; Newline String
; Data := "Single Item"                                                  ; Single String


MyGui := Gui("+Resize", "Universal List Loader")
MyGui.SetFont("s10", "Segoe UI")
LV := MyGui.Add("ListView", "r10 w400", ["Index", "Data Content"])

; Load the data regardless of type
LoadDataIntoLV(LV, Data)

MyGui.Show()


LoadDataIntoLV(GuiCtrl, InputData) {
    GuiCtrl.Delete() ; Clear existing items
    
    ; 1. Handle Strings (CSV, Newline, or Single)
    if (InputData is String) {
        if (InputData = "")
        return

        ; Determine if it's CSV or Newline
        Delimiter := InStr(InputData, "`n") ? "`n" : ","
        Loop Parse, InputData, Delimiter, "`r " {
            if (A_LoopField = "")
            continue
            GuiCtrl.Add(, A_Index, A_LoopField)
        }
    }
    ; 2. Handle Maps
    else if (InputData is Map) {
        for key, value in InputData {
            GuiCtrl.Add(, key, value)
        }
    }
    ; 3. Handle Arrays (Object Lists)
    else if (InputData is Array) {
        for index, value in InputData {
            ; Check if the array element is an object or simple value
            DisplayValue := IsObject(value) ? "[Object]" : value
            GuiCtrl.Add(, index, DisplayValue)
        }
    }
    
    GuiCtrl.ModifyCol(1, "AutoHdr")
    GuiCtrl.ModifyCol(2, "AutoHdr")
}

; Function demonstrating your specific 'if' formatting requirements
ValidateList(ScriptContent) {
    if (ScriptContent = "")
    return
    
    MsgBox("List validated.")
}