; TITLE:    MyScript v0.0
; SOURCE:   AHKv2 https://www.autohotkey.com/boards/viewtopic.php?f=13&t=31695&p=212511&hilit=schtasks#p212511
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <_Run>

; Does NOT require Admin

; COPY TO CLIPBOARD "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe, TEST WITH SPACES"

app       := 'schtasks.exe'
switches  := "/run /tn"
taskName  := 'AhkBackupSkipUAC-Jim'

command := _Run.ConvertToArray(app, switches, taskName)

;command := "schtasks.exe /run /tn AhkBackupSkipUAC-Jim"

output := _Run(command)

MsgBox 'Output: ' output, 'Status', 'Iconi'
