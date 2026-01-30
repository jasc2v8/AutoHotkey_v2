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

; 1. Create a nested Map structure
appConfig := Map()
appConfig["title"] := "My Script"

net := Map()
net["ip"] := "127.0.0.1"
net["ports"] := [443, 80]

appConfig["network"] := net

; 2. Convert to TOML String
tomlOutput := TOML.Stringify(appConfig)
MsgBox(tomlOutput)

/* Output:
title = "My Script"

[network]
ip = "127.0.0.1"
ports = [443, 80]
*/

; 3. Parse it back
parsedMap := TOML.Parse(tomlOutput)
MsgBox(parsedMap["network"]["ip"]) ; Results in 127.0.0.1