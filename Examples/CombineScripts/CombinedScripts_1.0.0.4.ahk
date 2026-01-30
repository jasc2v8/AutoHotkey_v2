; Combined Script - Generated on 20260123124323
; Version: 1.0.0.4

; --- Start of: D:\Software\DEV\Work\AHK2\Examples\CombineScripts\Lib_Math.ahk ---
#Requires AutoHotkey v2.0
AddNumbers(a, b) {
    return a + b
}
SubtractNumbers(a, b) {
    return a - b
}

; --- End of: D:\Software\DEV\Work\AHK2\Examples\CombineScripts\Lib_Math.ahk ---

; --- Start of: D:\Software\DEV\Work\AHK2\Examples\CombineScripts\Lib_String.ahk ---
; [Duplicate Removed] #Requires AutoHotkey v2.0
ToUpper(txt) {
    return StrUpper(txt)
}
ToLower(txt) {
    return StrLower(txt)
}

; --- End of: D:\Software\DEV\Work\AHK2\Examples\CombineScripts\Lib_String.ahk ---

; --- Start of: D:\Software\DEV\Work\AHK2\Examples\CombineScripts\Lib_UI.ahk ---
; [Duplicate Removed] #Requires AutoHotkey v2.0
#SingleInstance Force
ShowStatus(msg) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -3000)
}

; --- End of: D:\Software\DEV\Work\AHK2\Examples\CombineScripts\Lib_UI.ahk ---

; --- Start of: D:\Software\DEV\Work\AHK2\Examples\CombineScripts\TestMain.ahk ---
; [Duplicate Removed] #Requires AutoHotkey v2.0
; [Duplicate Removed] #SingleInstance Force
Global AppName := "My Toolbox"
Global Version := "1.0.0.4"
; [Include Removed] #Include "Lib_Math.ahk"
; [Include Removed] #Include "Lib_String.ahk"
; [Include Removed] #Include "Lib_UI.ahk"
text := "hellow world"
ShowStatus("Test Started.")
MsgBox  AddNumbers(10, 20) "`n`n" SubtractNumbers(10, 20) "`n`n"  .
        ToUpper(text)  "`n`n" ToLower(text), "Combine Scripts Test"
ShowStatus("Test Finished.")

; --- End of: D:\Software\DEV\Work\AHK2\Examples\CombineScripts\TestMain.ahk ---

