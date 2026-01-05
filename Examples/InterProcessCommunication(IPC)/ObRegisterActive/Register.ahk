; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    If object is registred as Admin, User cannot access it.

*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

;#Include <RunAsAdmin>

GUID:="{5833F089-D9BF-423F-A570-F828BA1FF246}"

sharedObj := {key:"value"}

ObjRegisterActive(sharedObj, GUID)

x := ComObjActive(GUID)

MsgBox "Shared object key: " x.key, "REGISTERED"

ObjRegisterActive(sharedObj, "")

MsgBox "Shared object key: " x.key, "UNREGISTERED"

MsgBox "Exit to destroy the Shared object", "DESTROY"

ExitApp()

;Persistent()

ObjRegisterActive(sharedObj, "")

/*
    ObjRegisterActive(Object, CLSID, Flags:=0)
    
        Registers an object as the active object for a given class ID.
    
    Object:
            Any AutoHotkey object.
    CLSID:
            A GUID or ProgID of your own making.
            Pass an empty string to revoke (unregister) the object.
    Flags:
            One of the following values:
              0 (ACTIVEOBJECT_STRONG)
              1 (ACTIVEOBJECT_WEAK)
            Defaults to 0.
    
    Related:
        http://goo.gl/KJS4Dp - RegisterActiveObject
        http://goo.gl/no6XAS - ProgID
        http://goo.gl/obfmDc - CreateGUID()

    Author: lexikos (https://www.autohotkey.com/boards/viewtopic.php?f=6&t=6148)
*/
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