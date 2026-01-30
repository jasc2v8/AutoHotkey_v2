; Gemini

#Requires AutoHotkey v2.0

; Global variables separated on two lines as requested
global IL_Large := 0
global IL_Small := 0

FileOpsGui := Gui("+AlwaysOnTop", "File & Data Operations")
FileOpsGui.SetFont("s11", "Segoe UI")

; --- File Management Group ---
FileOpsGui.Add("GroupBox", "w280 h110", "File Management")
BtnOpenF := FileOpsGui.Add("Button", "xp+10 yp+25 w125 h30", Chr(0x1F412) " Open File")
BtnOpenD := FileOpsGui.Add("Button", "x+10 w125 h30", Chr(0x1F411) " Open Folder")

BtnSave  := FileOpsGui.Add("Button", "xm+10 y+10 w125 h30", Chr(0x1F4BE) " Save")
BtnSaveA := FileOpsGui.Add("Button", "x+10 w125 h30", Chr(0x1F4BE) " + Save As")

; --- Data Exchange Group ---
FileOpsGui.Add("GroupBox", "xm w280 h70", "Data Exchange")
BtnExport := FileOpsGui.Add("Button", "xp+10 yp+25 w125 h30", Chr(0x1F4E4) " Export")
BtnImport := FileOpsGui.Add("Button", "x+10 w125 h30", Chr(0x1F4E5) " Import")

; --- Status Bar ---
FileOpsGui.SetFont("s9 italic", "Segoe UI")
StatusText := FileOpsGui.Add("Text", "xm w280 Center cGray", "Ready for operations...")

; --- Event Handlers ---
BtnOpenF.OnEvent("Click", (*) => UpdateStatus("Opening File..."))
BtnOpenD.OnEvent("Click", (*) => UpdateStatus("Opening Folder..."))
BtnSave.OnEvent("Click",  (*) => UpdateStatus("Saving..."))
BtnSaveA.OnEvent("Click", (*) => UpdateStatus("Opening 'Save As' Dialog..."))
BtnExport.OnEvent("Click",(*) => UpdateStatus("Exporting data..."))
BtnImport.OnEvent("Click",(*) => UpdateStatus("Importing data..."))

UpdateStatus(msg) {
    StatusText.Value := msg
    SetTimer(() => StatusText.Value := "Ready", -2000)
}

FileOpsGui.Show()
