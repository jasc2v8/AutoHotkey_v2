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

; Universal List GUI Class
; Version 1.0.5

#Requires AutoHotkey v2.0

; --- Input Examples ---
DataArray := ["Apple", "Banana", "Cherry"]
DataMap   := Map("Key1", "Value1", "Key2", "Value2")
DataCSV   := "Red,Green,Blue,Yellow"
DataLines := "Line One`nLine Two`nLine Three"
DataText  := "Single Item"

; Example usage (Modal):
MyDisplay := ListManager(DataArray, "DataArray")
MyDisplay.Show()
MyDisplay := ListManager(DataMap, "DataMap")
MyDisplay.Show()
MyDisplay := ListManager(DataCSV, "DataCSV")
MyDisplay.Show()
MyDisplay := ListManager(DataLines, "DataLines", false)
MyDisplay.Show()
MyDisplay := ListManager(DataText, "DataText")
MyDisplay.Show()
MsgBox("The script was paused until you clicked Continue or closed the GUI.")

class ListManager {
    __New(InputData, Title := "List Manager", IsModal := true) {
        this.IsModal := IsModal
        this.MyGui := Gui("+Resize", Title)
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
        if (this.IsModal) {
            this.MyGui.Show()
            ; Pauses script execution until the Gui object is destroyed/hidden
            WinWaitClose("ahk_id " this.MyGui.Hwnd)
        } else {
            this.MyGui.Show()
        }
    }

    Close() {
        this.MyGui.Hide()
        ; If modal, the WinWaitClose in Show() will now resolve
    }

    ClearList() {
        if (this.LV.GetCount() = 0)
        return
        
        this.LV.Delete()
    }
}
