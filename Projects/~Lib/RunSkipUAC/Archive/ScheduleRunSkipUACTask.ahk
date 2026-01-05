; TITLE:    MyScript v0.0
; SOURCE:   AHKv2 https://www.autohotkey.com/boards/viewtopic.php?f=13&t=31695&p=212511&hilit=schtasks#p212511
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <FileHelper>
#Include <RunAsAdmin>
#Include <RunHelper>

; requires Admin if runLevel = 'highest'

global TaskName:=''
global TaskExe:=''


;    exe       := "C:\ProgramData\AutoHotkey\AhkRunSkipUAC\AhkRunSkipUAC.exe"
g:=Gui()
g.Title:= "Schedule Task"
g.AddEdit("w400 vMyEdit", "")
g.AddButton("yp w75", "Select").OnEvent("Click", SelectFile)
g.AddButton("xm Default w75", "OK").OnEvent("Click", StartTask)
g.AddButton("yp w75", "Scheduler").OnEvent("Click", OpenTaskScheduler)
g.AddButton("yp w75", "Cancel").OnEvent("Click", (*) => ExitApp())
g.Show()

OpenTaskScheduler(*) {
    Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Task Scheduler.lnk"
}

SelectFile(*) {
    selection:= FileHelper.Select()
    if (selection != "") {
        g['MyEdit'].Text:= selection
    }
}

StartTask(*) {
    
    selection:= g['MyEdit'].Text
    TaskName:= FileHelper.SplitPath(selection).NameNoExt
    TaskExe:= selection

    r:= MsgBox("TaskName: " TaskName "`n`nTaskExe: " TaskExe, "Schedule Task", "YesNo Icon?")

    if (r!="Yes")
        return

    taskName  := TaskName
    app       := 'schtasks.exe'
    exe       := TaskExe
    schedule  := 'once'         ; on-demand
    startDate := '01/01/1910'   ; far in the past so it will never run as scheduled
    startTime := '00:00'        ; arbitrary
    runLevel  := 'highest'      ; 'limited' or 'highest' ; highest requires Admin
    runUser   := 'Users'        ; default is current user

    ;SCHTASKS /create /tn "AhkOnDemand" /tr "D:\Software\DEV\Work\AHK2\Projects\ScheduleTask\LogArgs.exe" /sc ONCE /sd 01/01/1910 /st 00:00

    output := RunHelper([app, "/create /tn", taskName, "/tr", exe, "/sc", schedule, "/st", startTime, "/rl", runLevel])

    MsgBox 'Output:`n`n' output, 'Status', 'Iconi'
}

