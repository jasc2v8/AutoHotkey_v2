#Requires AutoHotkey v2

hr := DllCall("ole32\CoInitialize", "ptr", 0, "uint")
MsgBox "CoInitialize hr=0x" Format("{:08X}", hr)

; --- Call #1: no '&' ---
pROT1 := 0
hr1 := DllCall("ole32\GetRunningObjectTable"
    , "uint", 0
    , "ptr*", pROT1
    , "uint")

; --- Call #2: WITH '&' ---
pROT2 := 0
hr2 := DllCall("ole32\GetRunningObjectTable"
    , "uint", 0
    , "ptr*", &pROT2
    , "uint")

MsgBox "Call #1 (no &):`n"
    . "  hr1 = 0x" Format("{:08X}", hr1) "`n"
    . "  pROT1 (dec) = " pROT1 "`n"
    . "  pROT1 (hex) = 0x" Format("{:016X}", pROT1) "`n`n"
    . "Call #2 (with &):`n"
    . "  hr2 = 0x" Format("{:08X}", hr2) "`n"
    . "  pROT2 (dec) = " pROT2 "`n"
    . "  pROT2 (hex) = 0x" Format("{:016X}", pROT2)

if (pROT1)
    ObjRelease(pROT1)
if (pROT2)
    ObjRelease(pROT2)

DllCall("ole32\CoUninitialize")
ExitApp