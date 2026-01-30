;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2+
#SingleInstance Force
#NoTrayIcon

; Universal List GUI Class
; Version 1.0.9

#Requires AutoHotkey v2.0

; --- Input Examples ---
DataArray := ["Apple", "Banana", "Cherry"]
DataMap   := Map("Key1", "Value1", "Key2", "Value2")
DataCSV   := "Red,Green,Blue,Yellow"
DataLines := "Line One`nLine Two`nLine Three"
DataText  := "Single Item"

; Example usage:
ObjList(DataArray, "DataArray")
ObjList(DataMap, "DataMap")
ObjList(DataCSV, "DataCSV")
ObjList(DataLines, "DataLines")
ObjList(DataText, "DataText")


class ObjList {
    __New(InputData, Title := "List Manager", IsModal := true) {
        this.IsModal := IsModal
        
        ; Determine Type String for the Title
        TypeStr := ""
        if (InputData is Map) {
            TypeStr := "(Map)"
        }
        else if (InputData is Array) {
            TypeStr := "(Array)"
        }
        else if (InputData is String) {
            if (InStr(InputData, "`n")) {
                TypeStr := "(String list ``n)"
            }
            else if (InStr(InputData, ",")) {
                TypeStr := "(String CSV)"
            }
            else {
                TypeStr := "(String)"
            }
        }

        this.MyGui := Gui("+Resize", Title . A_Space . TypeStr)
        this.MyGui.SetFont("s10", "Segoe UI")
        
        ; Create ListView
        this.LV := this.MyGui.Add("ListView", "r10 w400", ["Index/Key", "Content"])
        
        ; Add Continue Button
        this.BtnContinue := this.MyGui.Add("Button", "Default w80", "Continue")
        this.BtnContinue.OnEvent("Click", (*) => this.Close())
        
        ; Close event for the 'X' button
        this.MyGui.OnEvent("Close", (*) => this.Close())

        ; Load the data
        this.Load(InputData)

        ; Show automatically upon creation
        this.Show()
    }

    Load(InputData) {
        this.LV.Delete()
        
        if (InputData is String) {
            if (InputData = "")
            return

            Delimiter := InStr(InputData, "`n") ? "`n" : (InStr(InputData, ",") ? "," : "")
            
            if (Delimiter = "") {
                this.LV.Add(, 1, InputData)
            } else {
                Loop Parse, InputData, Delimiter, "`r " {
                    if (A_LoopField = "")
                    continue
                    this.LV.Add(, A_Index, A_LoopField)
                }
            }
        }
        else if (InputData is Map) {
            for key, value in InputData {
                this.LV.Add(, key, value)
            }
        }
        else if (InputData is Array) {
            for index, value in InputData {
                DisplayValue := IsObject(value) ? "[Object]" : value
                this.LV.Add(, index, DisplayValue)
            }
        }
        
        this.LV.ModifyCol(1, "AutoHdr")
        this.LV.ModifyCol(2, "AutoHdr")
    }

    Show() {
        this.MyGui.Show()
        
        if (this.IsModal) {
            if (WinExist("ahk_id " this.MyGui.Hwnd))
            WinWaitClose("ahk_id " this.MyGui.Hwnd)
        }
    }

    Close() {
        this.MyGui.Hide()
    }

    ClearList() {
        if (this.LV.GetCount() = 0)
        return
        
        this.LV.Delete()
    }
}
