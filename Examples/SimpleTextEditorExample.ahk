
; Directives, keywords
#SingleInstance Force
#NoTrayIcon

; Create the MyGui window:
MyGui := Gui("+Resize", "Untitled")  ; Make the window resizable.

; Create the submenus for the menu bar:
FileMenu := Menu()
FileMenu.Add("&New", MenuFileNew)
FileMenu.Add("&Open", MenuFileOpen)
FileMenu.Add("&Save", MenuFileSave)
FileMenu.Add("Save &As", MenuFileSaveAs)
FileMenu.Add() ; Separator line.
FileMenu.Add("E&xit", MenuFileExit)
HelpMenu := Menu()
HelpMenu.Add("&About", MenuHelpAbout)

; Create the menu bar by attaching the submenus to it:
MyMenuBar := MenuBar()
MyMenuBar.Add("&File", FileMenu)
MyMenuBar.Add("&Help", HelpMenu)

; Attach the menu bar to the window:
MyGui.MenuBar := MyMenuBar

; Create the main Edit control:
MainEdit := MyGui.Add("Edit", "WantTab W600 R20")

; Apply events:
MyGui.OnEvent("DropFiles", Gui_DropFiles)
MyGui.OnEvent("Size", Gui_Size)

MenuFileNew()  ; Apply default settings.
MyGui.Show()  ; Display the window.

MenuFileNew(*)
{
    MainEdit.Value := ""  ; Clear the Edit control.
    FileMenu.Disable("3&")  ; Gray out &Save.
    MyGui.Title := "Untitled"
}

MenuFileOpen(*)
{
    MyGui.Opt("+OwnDialogs")  ; Force the user to dismiss the FileSelect dialog before returning to the main window.
    SelectedFileName := FileSelect(3,, "Open File", "Text Documents (*.txt)")
    if SelectedFileName = "" ; No file selected.
        return
    global CurrentFileName := readContent(SelectedFileName)
}

MenuFileSave(*)
{
    saveContent(CurrentFileName)
}

MenuFileSaveAs(*)
{
    MyGui.Opt("+OwnDialogs")  ; Force the user to dismiss the FileSelect dialog before returning to the main window.
    SelectedFileName := FileSelect("S16",, "Save File", "Text Documents (*.txt)")
    if SelectedFileName = "" ; No file selected.
        return
    global CurrentFileName := saveContent(SelectedFileName)
}

MenuFileExit(*)  ; User chose "Exit" from the File menu.
{
    WinClose()
}

MenuHelpAbout(*)
{
    About := Gui("+owner" MyGui.Hwnd)  ; Make the main window the owner of the "about box".
    MyGui.Opt("+Disabled")  ; Disable main window.
    About.Add("Text",, "Text for about box.")
    About.Add("Button", "Default", "OK").OnEvent("Click", About_Close)
    About.OnEvent("Close", About_Close)
    About.OnEvent("Escape", About_Close)
    About.Show()

    About_Close(*)
    {
        MyGui.Opt("-Disabled")  ; Re-enable the main window (must be done prior to the next step).
        About.Destroy()  ; Destroy the about box.
    }
}

readContent(FileName)
{
    try
        FileContent := FileRead(FileName)  ; Read the file's contents into the variable.
    catch
    {
        MsgBox("Could not open '" FileName "'.")
        return
    }
    MainEdit.Value := FileContent  ; Put the text into the control.
    FileMenu.Enable("3&")  ; Re-enable &Save.
    MyGui.Title := FileName  ; Show file name in title bar.
    return FileName
}

saveContent(FileName)
{
    try
    {
        if FileExist(FileName)
            FileDelete(FileName)
        FileAppend(MainEdit.Value, FileName)  ; Save the contents to the file.
    }
    catch
    {
        MsgBox("The attempt to overwrite '" FileName "' failed.")
        return
    }
    ; Upon success, Show file name in title bar (in case we were called by MenuFileSaveAs):
    MyGui.Title := FileName
    return FileName
}

Gui_DropFiles(thisGui, Ctrl, FileArray, *)  ; Support drag & drop.
{
    CurrentFileName := readContent(FileArray[1])  ; Read the first file only (in case there's more than one).
}

Gui_Size(thisGui, MinMax, Width, Height)
{
    if MinMax = -1  ; The window has been minimized. No action needed.
        return
    ; Otherwise, the window has been resized or maximized. Resize the Edit control to match.
    MainEdit.Move(,, Width-20, Height-20)
}