#Requires AutoHotkey v2+
#SingleInstance

;#Include <Debug>
#Include <ListObj>

DetectHiddenWindows(true)

g:= Gui(, "My Gui") 
g.Show("w400 h200")
   
list:= GetAllScriptGuis()

ListObj('Gui List', list)

;Debug.ListVar(list, 'Gui List')

ExitApp()

GetAllScriptGuis()
{
    ScriptPID := WinGetPID("ahk_id " A_ScriptHwnd)
    GuiList := []
    
    ; Get all windows belonging to this process
    for hwnd in WinGetList("ahk_pid " ScriptPID)
    {
        ; Filter for actual AHK GUIs (excluding the hidden main window)
        if (WinGetClass(hwnd) = "AutoHotkeyGUI")
        {
            GuiList.Push(hwnd)
        }
    }
    
    return GuiList
}