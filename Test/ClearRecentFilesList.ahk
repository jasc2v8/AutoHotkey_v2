;ABOUT: clears the Windows "Recent Files" list (RecentDocs Registry Key)
;       and deletes all Jump List history from the Taskbar and Start Menu

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#Include <ConsoleWindowIcon>

Console := ConsoleWindowIcon()

; Requires AutoHotkey v2.0+

; Set a hotkey to trigger the script. In this case, Ctrl+Alt+C.
^!r::
{
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
    MsgBox "Windows recent files and jump lists have been cleared.", "Success!", 0
}
