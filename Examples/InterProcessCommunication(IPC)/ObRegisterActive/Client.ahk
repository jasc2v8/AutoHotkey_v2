#Requires AutoHotkey v2

; --- COM init ---
hr := DllCall("ole32\CoInitialize", "ptr", 0, "uint")
if (hr != 0 && hr != 1)
{
    MsgBox "CoInitialize failed: 0x" Format("{:08X}", hr)
    ExitApp
}

; --- GetRunningObjectTable ---
pROT := 0
hr := DllCall("ole32\GetRunningObjectTable"
    , "uint", 0
    , "ptr*", pROT    ; v2: no &
    , "uint")
MsgBox "Client: GetRunningObjectTable hr=0x" Format("{:08X}", hr) "`n pROT=" pROT
if hr != 0
    goto Cleanup

; --- CreateItemMoniker "!:AHK.Shared.Dictionary" ---
pMoniker := 0
hr := DllCall("ole32\CreateItemMoniker"
    , "wstr", "!"
    , "wstr", "AHK.Shared.Dictionary"
    , "ptr*", pMoniker   ; v2: no &
    , "uint")
MsgBox "Client: CreateItemMoniker hr=0x" Format("{:08X}", hr) "`n pMoniker=" pMoniker
if hr != 0
    goto Cleanup

; --- IRunningObjectTable::GetObject ---
vtbl       := NumGet(pROT, 0, "ptr")
pGetObject := NumGet(vtbl, 6 * A_PtrSize, "ptr") ; index 6 = GetObject

punk := 0
hr := DllCall(pGetObject
    , "ptr",  pROT
    , "ptr",  pMoniker
    , "ptr*", punk      ; v2: no &
    , "uint")
MsgBox "Client: GetObject hr=0x" Format("{:08X}", hr) "`n punk=" punk
if hr != 0
    goto Cleanup

; --- Wrap and use dictionary ---
dict := ComObjFromPtr(punk)
ObjRelease(punk)  ; release raw pointer, keep AHK wrapper

msg := dict["msg"]
count := dict["count"]
MsgBox "Client: msg=" msg "`ncount=" count

Cleanup:
if pMoniker
    ObjRelease(pMoniker)
if pROT
    ObjRelease(pROT)
DllCall("ole32\CoUninitialize")
ExitApp
#Requires AutoHotkey v2
#Include RotCom.ahk

try {
    client := RotClient("AHK.Shared.Dictionary")
    dict := client.Object

    msg := dict["msg"]
    count := dict["count"]

    MsgBox "msg=" msg "`ncount=" count
}
catch any as e {
    MsgBox "Error:`n" e.Message
}