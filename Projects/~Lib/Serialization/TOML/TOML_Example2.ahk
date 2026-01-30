;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include TOML.ahk
#Include <ObjView>
#Include <ObjTree>
#Include <ObjList>

; Sample TOML data
tomlData := '
(
[settings]
servers = ["192.168.1.1", "192.168.1.2"]
retry_codes = [404, 500, 503]
)'

; Parse the string
config := TOML.Parse(tomlData)

ObjView(,config)
ObjTree(config)
ObjList(config)

; 1. Accessing by index (Note: AHK v2 arrays are 1-based)
primaryServer := config["settings"]["servers"][1] 
MsgBox("Primary Server: " . primaryServer)

; 2. Iterating through an array
allPorts := ""
for index, code in config["settings"]["retry_codes"] {
    allPorts .= "Code " . index . ": " . code . "`n"
}
MsgBox("Retry Codes:`n" . allPorts)

; 3. Modifying and Stringifying back to TOML
config["settings"]["servers"].Push("192.168.1.3")
newToml := TOML.Stringify(config)

MsgBox("Updated TOML:`n" . newToml)
