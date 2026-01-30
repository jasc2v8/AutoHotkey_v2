#Requires AutoHotkey v2.0
; Version 1.0.4

; --- Initialize Variables ---
Username := "Admin"
LoginTime := A_Hour . ":" . A_Min
AccessLevel := 5
IsActive := True
LastStatus := "Processing..."

; Define the list of variables you want to inspect
VarsToTrack := ["Username", "LoginTime", "AccessLevel", "IsActive", "LastStatus"]

ShowCurrentValues(VarsToTrack)

ShowCurrentValues(VarList) {
    if (VarList.Length = 0)
    return

    ; Create GUI
    MyGui := Gui("+Resize", "Current Value Inspector")
    MyGui.SetFont("s10", "Segoe UI")
    LV := MyGui.Add("ListView", "r10 w400", ["Variable Name", "Current Value"])
    
    ; Loop through the list of names provided
    for Name in VarList {
        try {
            ; Dynamic reference: %Name% gets the value of the variable named in the string
            CurrentValue := %Name%
            LV.Add(, Name, CurrentValue)
        } catch {
            LV.Add(, Name, "ERROR: Variable not found")
        }
    }

    LV.ModifyCol(1, "AutoHdr")
    LV.ModifyCol(2, "AutoHdr")
    MyGui.Show()
}