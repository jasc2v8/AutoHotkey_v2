; TITLE  :  RunPS v1.0
; SOURCE :  Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force

#Requires AutoHotkey v2.0

; Default PowerShell template
defaultPS := "
(
Write-Host 'System Diagnostics' -ForegroundColor Cyan
Write-Host '------------------'
Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object -First 5
Write-Host '`nProcess Count: ' (Get-Process).Count
)"

; Create GUI
MyGui := Gui("+Resize", "PowerShell Runner v3")
MyGui.SetFont("s10", "Consolas")

MyGui.Add("Text",, "PowerShell Script Editor:")
EditBox := MyGui.Add("Edit", "r20 w750 vPSContent", defaultPS)

; Action Buttons
LoadBtn := MyGui.Add("Button", "w100", "Open .ps1")
LoadBtn.OnEvent("Click", (*) => LoadFile(EditBox))

RunBtn := MyGui.Add("Button", "x+10 Default w100", "Run & Capture")
RunBtn.OnEvent("Click", (*) => RunPS(EditBox, false))

; Admin Run Button with Shield
AdminBtn := MyGui.Add("Button", "x+10 w130", "Run as Admin")
SendMessage(0x160C, 0, 1, AdminBtn.Hwnd) ; BCM_SETSHIELD
AdminBtn.OnEvent("Click", (*) => RunPS(EditBox, true))

ClearBtn := MyGui.Add("Button", "x+10 w100", "Clear Editor")
ClearBtn.OnEvent("Click", (*) => EditBox.Value := "")

; --- Functions ---

RunPS(Ctrl, asAdmin) {
    ScriptContent := Ctrl.Value
    ; Wrap PowerShell code to handle execution policy and output formatting
    psCommand := 'PowerShell -NoProfile -ExecutionPolicy Bypass -Command "' ScriptContent '"'
    
    try {
        if (asAdmin) {
            ; For Admin, we redirect to a temp file because of security context isolation
            OutFile := A_Temp "\ps_out.txt"
            if FileExist(OutFile)
                FileDelete(OutFile)
                
            ; Run hidden, redirecting output to file
            RunWait('*RunAs PowerShell -NoProfile -ExecutionPolicy Bypass -Command "' ScriptContent ' | Out-File -FilePath ' OutFile ' -Encoding utf8"',, "Hide")
            
            if FileExist(OutFile) {
                OutText := FileRead(OutFile)
                Ctrl.Value := ScriptContent "`r`n`r`n--- ADMIN OUTPUT ---`r`n" OutText
                FileDelete(OutFile)
            }
        } else {
            ; Normal execution via WScript.Shell for direct stream capture
            shell := ComObject("WScript.Shell")
            exec := shell.Exec(psCommand)
            OutText := exec.StdOut.ReadAll()
            Ctrl.Value := ScriptContent "`r`n`r`n--- OUTPUT ---`r`n" OutText
        }
    } catch Error as err {
        MsgBox("Error: " err.Message)
    }
}

LoadFile(Ctrl) {
    SelectedFile := FileSelect(3, , "Open PowerShell Script", "Scripts (*.ps1)")
    if SelectedFile {
        Ctrl.Value := FileRead(SelectedFile)
    }
}

MyGui.Show()
