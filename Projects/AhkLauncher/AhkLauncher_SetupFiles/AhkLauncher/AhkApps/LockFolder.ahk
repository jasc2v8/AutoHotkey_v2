;ABOUT: Lock Folder added ClearRecentFiles

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

    ;hide folder
    r := RunCMD("attrib.exe", MyEdit.Text, "+h +s +r")

    ;lock folder
    r := RunCMD("icacls.exe", MyEdit.Text, "/deny everyone:f")

    ClearRecentFiles()

    ShowLockStatus()

}

UnLockFolder(Ctrl, Info) {

    ; cmd := A_ComSpec " /c icacls.exe " '"' MyEdit.Text '"' " /remove everyone"
    ; r := RunWait(cmd,,'Hide')

    ;Unlock folder
    r := RunCMD("icacls.exe", MyEdit.Text, "/remove everyone")

    ;Unhide folder
    r := RunCMD("attrib.exe", MyEdit.Text, "-h -s -r")

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

ClearRecentFiles() {
   ; Define the path to the Recent Items folder.
    RecentPath := A_AppData "\Microsoft\Windows\Recent\*"

    ; Delete all shortcuts (*.lnk) in the folder.
    ; The '0' indicates to not recurse into subdirectories.
    FileDelete RecentPath

    ; Also clear the "AutomaticDestinations" and "CustomDestinations" folders
    ; which manage the jump list items for applications.
    DirDelete A_AppData "\Microsoft\Windows\Recent\AutomaticDestinations", 1
    DirDelete A_AppData "\Microsoft\Windows\Recent\CustomDestinations", 1
    
    ; Restart the Explorer shell to refresh the Recent Files and jump lists.
    ; This will kill and restart explorer.exe.
    Run "cmd.exe /c taskkill /f /im explorer.exe && start explorer.exe"

    ; Show a confirmation message.
    ;MsgBox "Windows recent files and jump lists have been cleared.", "Success!", 0
    SB.Text := LPAD "Windows recent files and jump lists have been cleared."
    Sleep(2000)

}

ButtonCancel_Click(Ctrl, Info) {
    ExitApp
}