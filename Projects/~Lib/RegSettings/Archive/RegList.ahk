; Version: 1.4.0
global IL_Large := 0
global IL_Small := 0

; Create the Window
MyGui := Gui("+Resize", "Registry Settings Viewer")
MyGui.SetFont("s9", "Segoe UI")

; Add a ListView with three columns
LV := MyGui.Add("ListView", "r20 w600 vMyListView", ["Name", "Type", "Data"])

; Add a refresh button
BtnRefresh := MyGui.Add("Button", "Default w80", "Refresh")
BtnRefresh.OnEvent("Click", (*) => LoadRegistryEntries(LV))

; Initial load
LoadRegistryEntries(LV)

MyGui.Show()

LoadRegistryEntries(LVControl)
{
    LVControl.Delete() ; Clear existing list
    
    ; We are looking at the Environment variables as an example
    TargetKey := "HKCU\Environment"
    
    Loop Reg, TargetKey, "V"
    {
        try {
            ValData := RegRead()
        }
        catch {
            ValData := "<Error Reading Data>"
        }
        
        ; Add the data to the ListView
        LVControl.Add(, A_LoopRegName, A_LoopRegType, ValData)
    }
    
    ; Auto-size columns to fit the content
    LVControl.ModifyCol(1, "AutoHdr")
    LVControl.ModifyCol(2, "AutoHdr")
    LVControl.ModifyCol(3, "AutoHdr")
    
    ; Formatting requirement: check if empty and return
    if (LVControl.GetCount() = 0)
    return
}