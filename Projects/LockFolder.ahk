
#Requires AutoHotkey v2.0
#SingleInstance force
#NoTrayIcon
TraySetIcon('ieframe.dll', 65) ; 65 gold padlock, 86 yellow unlocked, 89 green locked

; optional #Include <RunCMD>

LPAD := ""

; Create a new Gui object
myGui := Gui()
myGui.Title := "Lock Folder"

MyGui.BackColor := "4682B4" ; Steel Blue
MyEdit := myGui.AddEdit("xm y+5 w400", "")
myGui.AddButton("x+5 yp w80", "Browse").OnEvent("Click", SelectFile)
ButtonLock   := myGui.AddButton("xm y+10 w80 Default", "Lock").OnEvent("Click", LockFolder)
ButtonUnLock := myGui.AddButton("yp w80", "UnLock").OnEvent("Click", UnLockFolder)
ButtonExplore := myGui.AddButton("yp w80", "Explore").OnEvent("Click", ExploreFolder)
myGui.AddButton("yp w140 +Hidden", "")
myGui.AddButton("yp w80", "Cancel").OnEvent("Click", ButtonCancel_Click)
SB := MyGui.AddStatusBar("yp")

MyEdit.Text := "D:\archived-projects"

; Show the GUI
myGui.Show()

ControlFocus("UnLock", MyGui)

ShowLockStatus()

; #region Functions

ShowLockStatus() {
    if IsLocked(MyEdit.Text) {
        SB.SetIcon('imageres.dll', 102) ; 217 locked, 218 unlocked
        SB.Text := LPAD "Folder is Locked."
    }
    else {
        SB.SetIcon('imageres.dll', 103) ; 217 locked, 218 unlocked
        SB.Text := LPAD "Folder is UnLocked."      
    }
}

IsLocked(path) {

    tempFile := A_Temp "\" A_TickCount . Random(100000, 999999) ".tmp"
    ;tempFile := A_Temp "\" A_TickCount ".tmp"

    ;OutputDebug('tempFile: ' tempFile)

    r := RunCMD("icacls.exe", MyEdit.Text, ">", tempFile)

    buff := FileRead(tempFile)

    FileDelete(tempFile)

    if InStr(buff, 'Everyone:(N)')
        return True
    else
        return False

}

RunCMD(Parts*) {

    DQ := '"'
    SQ := "'"
    SP := A_Space
    cmd := A_ComSpec " /c" 
    for index, value in Parts {
        if InStr(value, '\')
            cmd .= SP DQ value DQ
        else
            cmd .= SP value
    }
    return RunWait(cmd,,'Hide')
}

LockFolder(Ctrl, Info) {
    global MyEdit

    ;cmd := A_ComSpec " /c icacls.exe " '"' MyEdit.Text '"' " /deny everyone:f"
    ;r := RunWait(cmd,,'Hide')

    r := RunCMD("icacls.exe", MyEdit.Text, "/deny everyone:f")

    ShowLockStatus()

}

UnLockFolder(Ctrl, Info) {

    ; cmd := A_ComSpec " /c icacls.exe " '"' MyEdit.Text '"' " /remove everyone"
    ; r := RunWait(cmd,,'Hide')

    r := RunCMD("icacls.exe", MyEdit.Text, "/remove everyone")

    ShowLockStatus()
}

Timer_CallBack() {
    SetTimer , 0
    SB.Text := LPAD "Ready."
}

SelectFile(Ctrl, Info) {
    global MyEdit
    selectedFile := FileSelect("D", MyEdit.Text)
    if (selectedFile != "") {
        MyEdit.Text := selectedFile
        ShowLockStatus()
    }
}

ExploreFolder(Ctrl, Info) {
    if IsLocked(MyEdit.Text)
        SoundBeep
    else
        Run("explorer " MyEdit.Text)
}

ButtonCancel_Click(Ctrl, Info) {
    ExitApp
}