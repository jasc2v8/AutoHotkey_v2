#Requires AutoHotkey v2.0
#SingleInstance Force

ShowStatus(msg) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -3000)
}