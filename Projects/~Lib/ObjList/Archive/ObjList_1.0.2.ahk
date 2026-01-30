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

; GUI Object List Display
; Version 1.0.2

#Requires AutoHotkey v2.0

; 1. Define your Object List
FilesList := [
    {FileName: "Shell32.dll", Path: "C:\Windows\System32\shell32.dll", Index: 1},
    {FileName: "User32.dll", Path: "C:\Windows\System32\user32.dll", Index: 5},
    {FileName: "Explorer.exe", Path: "C:\Windows\explorer.exe", Index: 0}
]

FilesList := ["item1", "item2", "item3"]

; 2. Create the GUI
MyGui := Gui("+Resize", "Object List Manager")
MyGui.SetFont("s10", "Segoe UI")

; Create ListView with 3 columns
LV := MyGui.Add("ListView", "r10 w400 vMyListView", ["Name", "Index", "Full Path"])

; 3. Populate the ListView from the Object List
for index, obj in FilesList {
    LV.Add(, obj.FileName, obj.Index, obj.Path)
}

LV.ModifyCol(1, "AutoHdr")
LV.ModifyCol(2, "Integer")

MyGui.Show()

; --- Event Handlers ---

; Example of your specific 'if' formatting for an event
OnSelect(GuiCtrlObj, ItemIndex) {
    if (ItemIndex = 0)
    return
    
    SelectedName := LV.GetText(ItemIndex, 1)
    MsgBox("You selected: " . SelectedName)
}

; Demonstrating the conditional requirement for ScriptContent
ValidateInput(ScriptContent) {
    if (ScriptContent = "")
    return
    
    ; Process content if not empty
}
