; TITLE:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; -------- Configuration --------
global NSSM_PATH := "C:\Tools\nssm\nssm.exe" ; <-- Set to your nssm.exe
global SC_PATH   := A_WinDir "\System32\sc.exe"

; -------- State --------
global Services := [] ; array of service objects {Name, DisplayName, Status, IsNSSM}
global CurrentSvc := "" ; selected service name

; -------- grui --------
grui := Gui("+Resize", "NSSM Service Manager")
grui.SetFont("s10", "Segoe UI")

; Left: ListView of services
lv := grui.Add("ListView", "x10 y10 w520 h360 AltSubmit -Multi", ["Name", "Display name", "Status", "NSSM"])
lv.OnEvent("ItemSelect", LV_OnSelect)
lv.OnEvent("DoubleClick", LV_OnDoubleClick)

; Right: Controls
btnRefresh := grui.Add("Button", "x540 y10 w140 h28", "Refresh")
btnRefresh.OnEvent("Click", (*) => RefreshServices())

btnStart   := grui.Add("Button", "x540 y50 w140 h28", "Start")
btnStop    := grui.Add("Button", "x540 y85 w140 h28", "Stop")
btnRestart := grui.Add("Button", "x540 y120 w140 h28", "Restart")
btnStart.OnEvent("Click", (*) => ControlSvc("start"))
btnStop.OnEvent("Click", (*) => ControlSvc("stop"))
btnRestart.OnEvent("Click", (*) => ControlSvc("restart"))

grui.Add("Text", "x540 y170 w140", "App path:")
tbAppPath := grui.Add("Edit", "x540 y190 w340")
grui.Add("Text", "x540 y225 w140", "App args:")
tbAppArgs := grui.Add("Edit", "x540 y245 w340")
grui.Add("Text", "x540 y280 w140", "App dir:")
tbAppDir  := grui.Add("Edit", "x540 y300 w340")

btnLoad   := grui.Add("Button", "x540 y340 w140 h28", "Load params")
btnSave   := grui.Add("Button", "x690 y340 w190 h28", "Save params")
btnLoad.OnEvent("Click", (*) => LoadParams())
btnSave.OnEvent("Click", (*) => SaveParams())

grui.Add("GroupBox", "x10 y380 w870 h120", "Install / Uninstall")
grui.Add("Text", "x20 y405 w80", "Name:")
tbNewName := grui.Add("Edit", "x105 y402 w200")
grui.Add("Text", "x310 y405 w90", "App path:")
tbNewPath := grui.Add("Edit", "x400 y402 w250")
grui.Add("Text", "x660 y405 w70", "Args:")
tbNewArgs := grui.Add("Edit", "x730 y402 w140")

btnInstall := grui.Add("Button", "x20 y440 w140 h28", "Install service")
btnUninstall := grui.Add("Button", "x170 y440 w140 h28", "Uninstall selected")
btnInstall.OnEvent("Click", (*) => InstallService())
btnUninstall.OnEvent("Click", (*) => UninstallService())

sb := grui.Add("StatusBar")
grui.OnEvent("Size", grui_OnSize)

; Init
VerifyTools()
RefreshServices()
grui.Show("w900 h520")
return

; -------- Events --------

grui_OnSize(grui, minMax, w, h) {
    lv.Move(, , w-380, h-160)
    btnRefresh.Move(w-340, 10)
    btnStart.Move(w-340, 50)
    btnStop.Move(w-340, 85)
    btnRestart.Move(w-340, 120)
    tbAppPath.Move(w-340, 190, 330)
    tbAppArgs.Move(w-340, 245, 330)
    tbAppDir.Move(w-340, 300, 330)
    btnLoad.Move(w-340, 340)
    btnSave.Move(w-190, 340, 180)
}

LV_OnSelect(lvCtrl, row) {
    if row = 0
        return
    name := lvCtrl.GetText(row, 1)
    CurrentSvc := name
    UpdateStatusBar("Selected: " name)
}

LV_OnDoubleClick(lvCtrl, row) {
    if row = 0
        return
    name := lvCtrl.GetText(row, 1)
    CurrentSvc := name
    LoadParams()
}

; -------- Core --------

VerifyTools() {
    if !FileExist(NSSM_PATH) {
        MsgBox("nssm.exe not found at:`n" NSSM_PATH "`nSet NSSM_PATH at the top.", "Missing NSSM", 0x10)
    }
}

RefreshServices() {
    Services := []
    lv.Opt("-Redraw")
    lv.Delete()
    for svc in EnumServicesReg() {
        svc.Status := GetServiceStatus(svc.Name)
        svc.IsNSSM := IsNSSMService(svc.Name)
        Services.Push(svc)
        lv.Add(, svc.Name, svc.DisplayName, svc.Status, svc.IsNSSM ? "Yes" : "")
    }
    lv.Opt("+Redraw")
    UpdateStatusBar("Services refreshed: " Services.Length)
}

ControlSvc(action) {
    if !CurrentSvc {
        MsgBox("Select a service first.", "No selection", 0x30)
        return
    }
    switch action {
        case "start":
            RunWait(SC_PATH ' start "' CurrentSvc '"', , "Hide")
        case "stop":
            RunWait(SC_PATH ' stop "' CurrentSvc '"', , "Hide")
        case "restart":
            RunWait(SC_PATH ' stop "' CurrentSvc '"', , "Hide")
            Sleep(700)
            RunWait(SC_PATH ' start "' CurrentSvc '"', , "Hide")
    }
    ; Refresh row status only
    for idx, svc in Services {
        if svc.Name = CurrentSvc {
            svc.Status := GetServiceStatus(svc.Name)
            lv.Modify(idx, , svc.Name, svc.DisplayName, svc.Status, svc.IsNSSM ? "Yes" : "")
            break
        }
    }
}

LoadParams() {
    if !CurrentSvc {
        MsgBox("Select a service first.", "No selection", 0x30)
        return
    }
    if !IsNSSMService(CurrentSvc) {
        MsgBox("Selected service is not managed by NSSM.", "Unsupported", 0x30)
        return
    }
    tbAppPath.Value := NssmGet(CurrentSvc, "AppPath")
    tbAppArgs.Value := NssmGet(CurrentSvc, "AppParameters")
    tbAppDir.Value  := NssmGet(CurrentSvc, "AppDirectory")
    UpdateStatusBar("Params loaded for " CurrentSvc)
}

SaveParams() {
    if !CurrentSvc {
        MsgBox("Select a service first.", "No selection", 0x30)
        return
    }
    if !IsNSSMService(CurrentSvc) {
        MsgBox("Selected service is not managed by NSSM.", "Unsupported", 0x30)
        return
    }
    if tbAppPath.Value
        NssmSet(CurrentSvc, "AppPath", tbAppPath.Value)
    NssmSet(CurrentSvc, "AppParameters", tbAppArgs.Value)
    if tbAppDir.Value
        NssmSet(CurrentSvc, "AppDirectory", tbAppDir.Value)
    UpdateStatusBar("Params saved for " CurrentSvc)
}

InstallService() {
    name := tbNewName.Value
    app  := tbNewPath.Value
    args := tbNewArgs.Value
    if !name || !app {
        MsgBox("Name and App path are required.", "Missing data", 0x30)
        return
    }
    cmd := '"' NSSM_PATH '" install "' name '" "' app '"'
    if args
        cmd .= " " args
    RunWait(cmd, , "Hide")
    ; Optional: set AppDirectory to app's folder
    try {
        SplitPath(app, , &dir)
        if dir
            NssmSet(name, "AppDirectory", dir)
    }
    RefreshServices()
    ; Select newly installed
    for idx, svc in Services {
        if svc.Name = name {
            lv.ModifySelect(idx)
            CurrentSvc := name
            break
        }
    }
}

UninstallService() {
    if !CurrentSvc {
        MsgBox("Select a service first.", "No selection", 0x30)
        return
    }
    if MsgBox("Uninstall service '" CurrentSvc "'?", "Confirm", 0x23) != "Yes"
        return
    ; Stop service if running
    RunWait(SC_PATH ' stop "' CurrentSvc '"', , "Hide")
    Sleep(500)
    RunWait('"' NSSM_PATH '" remove "' CurrentSvc '" confirm', , "Hide")
    RefreshServices()
    CurrentSvc := ""
}

; -------- Helpers --------

EnumServicesReg() {
    list := []
    root := "HKLM\SYSTEM\CurrentControlSet\Services"
    for keyName in RegEnumKeys(root) {
        keyPath := root "\" keyName
        try {
            display := RegRead(keyPath, "DisplayName", "")
        }
        try {
            image := RegRead(keyPath, "ImagePath", "")
        }
        svc := { Name: keyName, DisplayName: display ? display : keyName, ImagePath: image }
        list.Push(svc)
    }
    return list
}

RegEnumKeys(keyPath) {
    arr := []
    loop Reg, keyPath
        arr.Push(A_LoopRegName)
    return arr
}

GetServiceStatus(name) {
    ; Parse sc.exe query output for STATE line
    sh := ComObject("WScript.Shell")
    exec := sh.Exec(SC_PATH ' query "' name '"')
    out := exec.StdOut.ReadAll()
    ; Look for "STATE" line and status word after colon
    for line in StrSplit(out, "`n", "`r") {
        if InStr(line, "STATE") {
            ; e.g. "STATE              : 4  RUNNING"
            parts := StrSplit(Trim(line), " ")
            ; last token typically is status word
            return parts[parts.Length]
        }
    }
    return ""
}

IsNSSMService(name) {
    key := "HKLM\SYSTEM\CurrentControlSet\Services\" name
    image := ""
    try image := RegRead(key, "ImagePath", "")
    if image && InStr(StrLower(image), "nssm.exe")
        return true
    ; NSSM usually creates a Parameters subkey
    if RegKeyExists(key "\Parameters")
        return true
    return false
}

RegKeyExists(keyPath) {
    try {
        loop Reg, keyPath
            return true
    }
    return false
}

NssmGet(name, setting) {
    cmd := '"' NSSM_PATH '" get "' name '" "' setting '"'
    sh := ComObject("WScript.Shell")
    exec := sh.Exec(cmd)
    out := exec.StdOut.ReadAll()
    ; NSSM prints the value or nothing if unset
    return Trim(out)
}

NssmSet(name, setting, value) {
    ; Quote value carefully; NSSM accepts raw string, but quoting helps spaces.
    cmd := '"' NSSM_PATH '" set "' name '" "' setting '" "' value '"'
    RunWait(cmd, , "Hide")
}

UpdateStatusBar(text) {
    sb.SetText(text)
}