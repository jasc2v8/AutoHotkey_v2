#Requires AutoHotkey v2.0

;CLSID := "{2F6D1410-B14D-4F71-A2A2-B67D3D22467D}"
CLSID := "{01234567-89AB-CDEF-0123-456789ABCDEF}"

try {
    ; Test 1: Can we see the CLSID at all?

    _clsid := Buffer(16, 0)
    
    if (hr := DllCall("ole32\CLSIDFromString", "wstr", CLSID, "ptr", _clsid)) < 0
        throw Error("Invalid CLSID", -1, CLSID)

    ;hr := DllCall("oleaut32\GetActiveObject", "Ptr", _clsid, "Str", CLSID, "Ptr", _clsid.Ptr, "Ptr", 0, "PtrP", &pUnk := 0)
    punk := 0
    hr := DllCall("oleaut32\GetActiveObject", "ptr", _clsid, "ptr", 0, "ptr*", punk, "uint")
    
    if (hr != 0) {
        MsgBox("The object is NOT in the ROT.`nError Code: " . Format("0x{:X}", hr))
        ; 0x800401E3 = Operation unavailable (Object not registered)
    } else {
        MsgBox("The object IS in the ROT, but access might be blocked.")
        pUnk:=""
        
        ; Test 2: Attempt standard AHK connection
        RemoteObj := ComObjActive(CLSID)
        MsgBox("Success! Connection established.")


    }
} catch Any as e {
    MsgBox("Connection Error: " e.Message "`nCode: " e.Extra)
}