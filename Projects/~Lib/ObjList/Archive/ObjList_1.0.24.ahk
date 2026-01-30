;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

; Universal List GUI Class
; Version 1.0.24

#Requires AutoHotkey v2.0

class ObjList {
    static RegPath := "HKEY_CURRENT_USER\Software\AHK_Scripts\ObjList"

    __New(InputData, Title := "List Manager", IsModal := true) {
        this.IsModal := IsModal
        this.Margin := 10
        
        ; Persistent Theme Check
        try {
            this.IsDarkMode := (RegRead(ObjList.RegPath, "Theme") = "Dark")
        } catch {
            this.IsDarkMode := false
        }
        
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

        ; Initialize GUI
        this.MyGui := Gui("+Resize +MinSize230x210 +MaxSize1280x720", Title . A_Space . TypeStr)
        this.MyGui.SetFont("s9", "Segoe UI")
        
        ; Create ListView
        this.LV := this.MyGui.Add("ListView", "vMyListView +Multi", ["Index/Key", "Content"])
        this.LV.OnEvent("ContextMenu", (GuiCtrl, Item, IsRightClick, X, Y) => this.ShowMenu(Item, X, Y))
        
        ; Mode Toggle Button
        this.BtnTheme := this.MyGui.Add("Button", "w100", this.IsDarkMode ? "Light Mode" : "Dark Mode")
        this.BtnTheme.OnEvent("Click", (*) => this.ToggleTheme())

        ; Action Button logic
        BtnText := this.IsModal ? "Continue" : "Close"
        this.BtnAction := this.MyGui.Add("Button", "Default w80", BtnText)
        this.BtnAction.OnEvent("Click", (*) => this.Close())
        
        ; Set up Events
        this.MyGui.OnEvent("Size", (GuiObj, MinMax, Width, Height) => this.OnSize(Width, Height))
        this.MyGui.OnEvent("Close", (*) => this.Close())
        this.MyGui.OnEvent("Escape", (*) => this.Close())

        ; Load data and apply theme
        this.Load(InputData)
        this.ApplyTheme()
        this.Show()
    }

    ClearSettings() {
        try {
            RegDeleteKey(ObjList.RegPath)
        }
        
        this.IsDarkMode := false
        this.ApplyTheme()
    }

    ToggleTheme() {
        this.IsDarkMode := !this.IsDarkMode
        try {
            RegWrite(this.IsDarkMode ? "Dark" : "Light", "REG_SZ", ObjList.RegPath, "Theme")
        }
        this.ApplyTheme()
    }

    ApplyTheme() {
        if (this.IsDarkMode) {
            this.MyGui.BackColor := "0x1A1A1A"
            this.MyGui.SetFont("cWhite")
            this.LV.Opt("+Background2D2D2D cWhite")
            this.BtnTheme.Text := "Light Mode"
        } else {
            this.MyGui.BackColor := "Default"
            this.MyGui.SetFont("cDefault")
            this.LV.Opt("+BackgroundDefault cDefault")
            this.BtnTheme.Text := "Dark Mode"
        }
    }

    OnSize(Width, Height) {
        if (Width = 0 or Height = 0)
        return

        this.LV.Move(this.Margin, this.Margin, Width - (this.Margin * 2), Height - 50)
        
        ; Position Buttons
        this.BtnAction.Move(Width - 80 - this.Margin, Height - 35)
        this.BtnTheme.Move(Width - 80 - this.Margin - 110, Height - 35)
        
        this.LV.ModifyCol(1, "AutoHdr")
        Col1W := SendMessage(0x101D, 0, 0, this.LV.Hwnd)
        RemainingW := Width - Col1W - (this.Margin * 2) - 25
        
        if (RemainingW > 50) {
            this.LV.ModifyCol(2, RemainingW)
        } else {
            this.LV.ModifyCol(2, "AutoHdr")
        }
    }

    ShowMenu(Item, X, Y) {
        Context := Menu()
        Context.Add("Select All (Ctrl+A)", (*) => this.SelectAll())
        Context.Add()
        
        if (this.LV.GetNext(0) = 0) {
            Context.Add("Copy Selected", (*) => "")
            Context.Disable("Copy Selected")
        } else {
            Context.Add("Copy Selected", (*) => this.CopySelected())
        }
        
        Context.Show(X, Y)
    }

    SelectAll() {
        this.LV.Modify(0, "Select")
    }

    CopySelected() {
        SelectedText := ""
        RowNumber := 0
        
        Loop {
            RowNumber := this.LV.GetNext(RowNumber)
            if (RowNumber = 0)
            break
            
            SelectedText .= this.LV.GetText(RowNumber, 1) . ": " . this.LV.GetText(RowNumber, 2) . "`r`n"
        }
        
        if (SelectedText != "")
        A_Clipboard := RTrim(SelectedText, "`r`n")
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
        this.MyGui.Show("w450 h300")
        
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
