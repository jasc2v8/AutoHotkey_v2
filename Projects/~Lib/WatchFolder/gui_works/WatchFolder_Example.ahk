#Requires AutoHotKey v2.0
#Warn
#Include WatchFolder.ahk
; ----------------------------------------------------------------------------------------------------------------------------------
MainGui := Gui( , "Watch Folder")
MainGui.OnEvent("Close", GuiClose)
MainGui.MarginX := 20
MainGui.MarginY := 20
MainGui.AddText( , "Watch Folder:")
EdtFolder := MainGui.AddEdit("xm y+3 w730 cGray +ReadOnly", "Select a folder ...")
BtnSelect := MainGui.AddButton("x+m yp w50 hp +Default", "...")
BtnSelect.OnEvent("Click", SelectFolder)
MainGui.AddText("xm y+5", "Watch Changes:")
CBSubTree := MainGui.AddCheckbox("xm y+3", "In Sub-Tree")
CBFiles := MainGui.AddCheckbox("x+5 yp Checked", "Files")
CBFolders :=MainGui.AddCheckbox("x+5 yp Checked", "Folders")
CBAttr :=MainGui.AddCheckbox("x+5 yp", "Attributes")
CBSize := MainGui.AddCheckbox("x+5 yp", "Size")
CBWrite :=MainGui.AddCheckbox("x+5 yp", "Last Write")
CBAccess := MainGui.AddCheckbox("x+5 yp", "Last Access")
CBCreation := MainGui.AddCheckbox("x+5 yp", "Creation")
CBSecurity := MainGui.AddCheckbox("x+5 yp", "Security")
LV := MainGui.AddListView("xm w800 r15", ["TickCount", "Folder", "Action", "Name", "IsDir", "OldName", " "])
BtnAction := MainGui.AddButton("xm w100 +Disabled", "Start")
BtnAction.OnEvent("Click", StartStop)
BtnPause := MainGui.AddButton("x+m yp wp +Disabled", "Pause")
BtnPause.OnEvent("Click", PauseResume)
BtnClear := MainGui.AddButton("x+m yp wp", "Clear")
BtnClear.OnEvent("Click", Clear)
MainGui.Show()
BtnSelect.Focus
Return
; ----------------------------------------------------------------------------------------------------------------------------------
GuiClose(*) {
   ExitApp
}
; ----------------------------------------------------------------------------------------------------------------------------------
Clear(Ctrl, *) {
   LV.Delete()
}
; ----------------------------------------------------------------------------------------------------------------------------------
PauseResume(Ctrl, *) {
   If (Ctrl.Text = "Pause") {
      WatchFolder("**PAUSE", True)
      BtnAction.Opt("+Disabled")
      Ctrl.Text := "Resume"
   }
   Else {
      WatchFolder("**PAUSE", False)
      BtnAction.Opt("-Disabled")
      Ctrl.Text := "Pause"
   }
}
; ----------------------------------------------------------------------------------------------------------------------------------
StartStop(Ctrl, *) {
   MainGui.Opt("+OwnDialogs")
   WatchedFolder := EdtFolder.Text
   If !InStr(FileExist(WatchedFolder), "D") {
      MsgBox(WatchedFolder . " isn't a valid folder name!", "Error")
      Return
   }
   If (Ctrl.Text = "Start") {
      Watch := 0
      Watch |= CBFiles.Value ? 1 : 0
      Watch |= CBFolders.Value ? 2 : 0
      Watch |= CBAttr.Value ? 4 : 0
      Watch |= CBSize.Value ? 8 : 0
      Watch |= CBWrite.Value ? 16 : 0
      Watch |= CBAccess.Value ? 32 : 0
      Watch |= CBCreation.Value ? 64 : 0
      Watch |= CBSecurity.Value ? 256 : 0
      If (Watch = 0) {
         CBFiles.Value := 1
         CBFolders.Value := 1
         Watch := 3
      }
      If !WatchFolder(WatchedFolder, MyUserFunc, CBSubTree.Value, Watch) {
         MsgBox("Call of WatchFolder() failed!", "Error")
         Return
      }
      BtnAction.Text := "Stop"
      BtnSelect.Opt("+Disabled")
      BtnPause.Opt("-Disabled")
   }
   Else {
      WatchFolder(WatchedFolder, "**DEL")
      BtnAction.Text := "Start"
      BtnSelect.Opt("-Disabled")
      BtnPause.Opt("+Disabled")
   }
}
; ----------------------------------------------------------------------------------------------------------------------------------
SelectFolder(Ctrl, *) {
   WatchedFolder := DirSelect()
   If (WatchedFolder != "") {
      EdtFolder.Opt("+cDefault")
      EdtFolder.Text := WatchedFolder
      BtnAction.Opt("-Disabled")
   }
}
; ----------------------------------------------------------------------------------------------------------------------------------
MyUserFunc(Folder, Changes) {
   Static Actions := ["1 (added)", "2 (removed)", "3 (modified)", "4 (renamed)"]
   TickCount := A_TickCount
   LV.Opt("-Redraw")
   For Each, Change In Changes
      LV.Modify(LV.Add("", TickCount, Folder, Actions[Change.Action], Change.Name, Change.IsDir, Change.OldName, ""), "Vis")
   Loop LV.GetCount("Columns")
      LV.ModifyCol(A_Index, "AutoHdr")
   LV.Opt("+Redraw")
}