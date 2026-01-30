#Requires AutoHotkey v2.0
AddNumbers(a, b) {
    return a + b
}
SubtractNumbers(a, b) {
    return a - b
}

ToUpper(txt) {
    return StrUpper(txt)
}
ToLower(txt) {
    return StrLower(txt)
}

#SingleInstance Force
ShowStatus(msg) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -3000)
}

Global AppName := "My Toolbox"
Global Version := "1.0.0.4"
text := "hellow world"
ShowStatus("Test Started.")
MsgBox  AddNumbers(10, 20) "`n`n" SubtractNumbers(10, 20) "`n`n"  .
        ToUpper(text)  "`n`n" ToLower(text), "Combine Scripts Test"
ShowStatus("Test Finished.")

