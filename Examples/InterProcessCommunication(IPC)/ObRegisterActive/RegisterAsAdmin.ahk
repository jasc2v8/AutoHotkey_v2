#Requires AutoHotkey v2.0

#Include <RunAsAdmin>

; ============================================================
; Get current process token
; ============================================================

hToken := 0
ok := DllCall("advapi32\OpenProcessToken",
    "ptr", DllCall("kernel32\GetCurrentProcess", "ptr"),
    "uint", 8,          ; TOKEN_QUERY
    "ptr*", &hToken,
    "int")

if !ok {
    MsgBox "OpenProcessToken failed"
    return
}

; ============================================================
; Query TokenUser to get the user SID
; ============================================================

size:=0
; First call: get required size
DllCall("advapi32\GetTokenInformation",
    "ptr", hToken,
    "int", 1,           ; TokenUser
    "ptr", 0,
    "uint", 0,
    "uint*", &size)

buf := Buffer(size)

ok := DllCall("advapi32\GetTokenInformation",
    "ptr", hToken,
    "int", 1,
    "ptr", buf,
    "uint", size,
    "uint*", &size)

if !ok {
    MsgBox "GetTokenInformation failed"
    return
}

pUserSid := NumGet(buf, 0, "ptr")

; Convert SID → string
strSid := 0
DllCall("advapi32\ConvertSidToStringSidW",
    "ptr", pUserSid,
    "ptr*", &strSid)

ownerSid := StrGet(strSid, "UTF-16")
DllCall("kernel32\LocalFree", "ptr", strSid)

; ============================================================
; Build SDDL using current user as owner + group
; ============================================================

sddl := "O:" ownerSid "G:" ownerSid "D:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;WD)"

; ============================================================
; Convert SDDL → Security Descriptor
; ============================================================

pSD := 0
ok := DllCall("advapi32\ConvertStringSecurityDescriptorToSecurityDescriptorW",
    "str", sddl,
    "uint", 1,
    "ptr*", &pSD,
    "ptr", 0,
    "int")

if !ok {
    MsgBox "ConvertStringSecurityDescriptorToSecurityDescriptorW failed"
    return
}

; ============================================================
; Initialize COM security
; ============================================================

hr := DllCall("ole32\CoInitializeSecurity",
    "ptr", pSD,
    "int", -1,
    "ptr", 0,
    "ptr", 0,
    "uint", 0,
    "uint", 2,      ; IDENTIFY
    "ptr", 0,
    "uint", 0,
    "ptr", 0,
    "uint")

;MsgBox "CoInitializeSecurity hr=0x" Format("{:08X}", hr)

; ============================================================
; 2. Define a simple COM object (IDispatch)
; ============================================================

MyObject := {key:"value"}
;obj := ComObject("Dispatch", MyObject)
;obj := MyObject


; ============================================================
; 3. Register object in ROT
; ============================================================

CLSID := "{01234567-89AB-CDEF-0123-456789ABCDEF}"

ObjRegisterActive(MyObject, CLSID)

MsgBox "COM server running.`nPress OK to exit."

; guid := Buffer(16, 0)
; DllCall("ole32\CLSIDFromString", "wstr", CLSID, "ptr", guid)

; ;   hr := DllCall("oleaut32\RegisterActiveObject", "ptr", ObjPtr(obj), "ptr", _clsid, "uint", Flags, "uint*", &cookie:=0, "uint")

; dwReg := 0
; hr := DllCall("oleaut32\RegisterActiveObject"
;     , "ptr", ObjPtr(obj)
;     , "ptr", guid
;     , "uint", 1  ; ACTIVEOBJECT_STRONG
;     , "uint*", &dwReg)

; if hr != 0
;     MsgBox "RegisterActiveObject failed: 0x" Format("{:08X}", hr)

ObjRegisterActive(obj, CLSID, Flags:=0) {
    static cookieJar := Map()
    if (!CLSID) {
        if (cookie := cookieJar.Delete(obj)) != ""
            DllCall("oleaut32\RevokeActiveObject", "uint", cookie, "ptr", 0)
        return
    }
    if cookieJar.Has(obj)
        throw Error("Object is already registered", -1)
    _clsid := Buffer(16, 0)
    if (hr := DllCall("ole32\CLSIDFromString", "wstr", CLSID, "ptr", _clsid)) < 0
        throw Error("Invalid CLSID", -1, CLSID)
    hr := DllCall("oleaut32\RegisterActiveObject", "ptr", ObjPtr(obj), "ptr", _clsid, "uint", Flags, "uint*", &cookie:=0, "uint")
    if hr < 0
        throw Error(format("Error 0x{:x}", hr), -1)
    cookieJar[obj] := cookie
}