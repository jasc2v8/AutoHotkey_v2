; TITLE  :  Listen v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

; ok #Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <CRC>
#Include <Messenger>
#Include <ListObj>
#Include <JSON>

TargetScriptTitle := "Listen.ahk" ; Change this to your listener's script name

DetectHiddenWindows True

if !WinExist(TargetScriptTitle) {
    Run TargetScriptTitle
    WinWait(TargetScriptTitle)
}

; Other options:
;   TargetScriptTitle:= "Listen.ahk ahk_class AutoHotkey"
;   TargetScriptTitle:= "ahk_id hwnd"

; Establich an inter-process communication channel with a unique passkey
ipc:= Messenger(CRC.Get64(TargetScriptTitle))
; ok ipc:= Messenger("ahk_id " TargetHWND, CRC.Get64(TargetScriptTitle))

; Listen for incoming messages
ipc.Listen(OnMessageReceived)

ArrayObj:= ["item1", "item2", "item3"]
ListObj("ArrayObj", ArrayObj)

MapObj:= Map("Key1", "Value1", "Key2", "Value2", "Key3", "Value3")
ListObj("MapObj", MapObj)

ArrayJSON:= JSON.Stringify(ArrayObj)
MapJSON := JSON.Stringify(MapObj)

;FileAppend ArrayJSON, "ArrayJSON.txt"
;FileAppend MapJSON, "MapJSON.txt"

; Send a message to the listener
success := ipc.Send(TargetScriptTitle, ArrayJSON)

success := ipc.Send(TargetScriptTitle, MapJSON)

; Check success
; if (!success) {
;     MsgBox "Message Refused or Timeout!", "Sender"
;     ExitApp()
; }

; Send an exit message to the listener
ipc.Send(TargetScriptTitle, "IPC_EXIT", 0)

ExitApp()

; Handle incoming messages
OnMessageReceived(Text, SenderHWND) {
    MsgBox("From Listener:`n`n" Text)
}
