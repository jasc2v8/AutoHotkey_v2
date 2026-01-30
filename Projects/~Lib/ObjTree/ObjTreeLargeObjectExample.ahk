; TITLE  :  ObjTree v2.0.0.1
; SOURCE :  jasc2v8, Gemini, and https://github.com/HotKeyIt/ObjTree/tree/v2
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  A utility to visualize object structures in a TreeView
; USAGE  :  ObjTree(Obj, Title := "Object TreeView")
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

#Include ObjTree.ahk

;Esc::ExitApp()

; A simulated complex object for ObjTree
SystemData := Map(
    "User_8821", Map(
        "Settings", Map("Theme", "Dark", "FontSize", 12, "Locale", "en-US"),
        "Permissions", ["Read", "Write", "Execute", "Admin"],
        "Paths", Map("AppData", "C:\Users\Admin\AppData", "Temp", "C:\Temp")
    ),
    "Network", Map(
        "Adapters", [
            Map("Name", "Ethernet", "IP", "192.168.1.5", "Status", "Connected"),
            Map("Name", "Wi-Fi", "IP", "0.0.0.0", "Status", "Disconnected")
        ],
        "DNS", ["8.8.8.8", "8.8.4.4"]
    ),
    "Processes", Map(
        "AutoHotkey.exe", Map("PID", 4512, "ThreadCount", 4, "WorkingSet", "12MB"),
        "Chrome.exe", Map("PID", 9820, "ThreadCount", 32, "WorkingSet", "450MB"),
        "Code.exe", Map("PID", 1120, "ThreadCount", 12, "WorkingSet", "210MB")
    )
)

ObjTree(SystemData, "Large Object Example")
