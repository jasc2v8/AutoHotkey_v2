;ABOUT: General functions to include or copy
;   TODO
;       return definition for (VarName)

#Requires AutoHotkey v2.0

DecToHex(num, width := 0, prefix := true) {
    fmt := "{:" (width ? "0" width : "") "X}"
    return (prefix ? "0x" : "") Format(fmt, num)
}

MsgBox DecToHex(1234)        ; "0x4D2"
MsgBox DecToHex(1234, 6)     ; "0x0004D2"
MsgBox DecToHex(1234, , false) ; "4D2"

dec := 4095
hex := "0x" Format("{:X}", dec)
MsgBox hex   ; "0xFFF"
