; Version 1.0.0.5
#Requires AutoHotkey v2+

TraySetIcon("C:\WINDOWS\System32\imageres.dll", 318)

MainGui := Gui("+Resize", "Windows Media Player")
MainGui.SetFont("s10", "Segoe UI")

; Updated label with r2 height and newline
MainGui.Add("Text", "r2", "Select a sound file`n(Double-click to play, Right-click to copy path):")
SoundList := MainGui.Add("ListBox", "r15 w300")

; Play button and Cancel button
PlayBtn := MainGui.Add("Button", "Default w80", "Play")
CancelBtn := MainGui.Add("Button", "x+10 w80", "Cancel")

; Context Menu for Right-Click
ListMenu := Menu()
ListMenu.Add("Copy Path \ Filename", CopyPath)

; Populate the ListBox with files from C:\Windows\Media
MediaDir := "C:\Windows\Media"
Loop Files, MediaDir "\*.*"
{
    if (A_LoopFileExt = "wav" or A_LoopFileExt = "mp3" or A_LoopFileExt = "mid")
    {
        SoundList.Add([A_LoopFileName])
    }
}

; Define Actions
PlayBtn.OnEvent("Click", PlaySound)
SoundList.OnEvent("DoubleClick", PlaySound)
SoundList.OnEvent("ContextMenu", ShowContextMenu)
CancelBtn.OnEvent("Click", (*) => ExitApp())
MainGui.OnEvent("Close", (*) => ExitApp())

MainGui.Show()

PlaySound(*)
{
    SelectedFile := SoundList.Text
    if (SelectedFile = "")
    {
        return
    }
    
    SoundPlay MediaDir "\" SelectedFile
}

ShowContextMenu(*)
{
    ListMenu.Show()
}

CopyPath(*)
{
    SelectedFile := SoundList.Text
    if (SelectedFile = "")
    {
        return
    }
    
    A_Clipboard := MediaDir "\" SelectedFile
    ToolTip("Path copied!")
    SetTimer(() => ToolTip(), -2000)
}