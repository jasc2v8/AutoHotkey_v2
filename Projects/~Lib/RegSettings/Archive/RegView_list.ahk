; Version: 1.6.0
global IL_Large := 0
global IL_Small := 0

; Create the Window
RegGui := Gui("+Resize", "HKCU\Software Explorer")
RegGui.SetFont("s9", "Segoe UI")

RegGui.Add("Text",, "Application Keys in HKEY_CURRENT_USER\Software:")
LV := RegGui.Add("ListView", "r20 w400 vRegList", ["Key Name", "Type"])

LoadSoftwareKeys(LV)
RegGui.Show()

LoadSoftwareKeys(LVControl)
{
    LVControl.Delete()
    RootKey := "HKCU\Software"
    
    ; Mode "K" only retrieves subkey names
    Loop Reg, RootKey, "K"
    {
        ; We use A_LoopRegType which will simply be "KEY" in this mode
        LVControl.Add(, A_LoopRegName, A_LoopRegType)
    }
    
    LVControl.ModifyCol(1, "AutoHdr")
    LVControl.ModifyCol(2, "AutoHdr")
    
    ; Required formatting: separate lines for if and return
    if (LVControl.GetCount() = 0)
    return
}
