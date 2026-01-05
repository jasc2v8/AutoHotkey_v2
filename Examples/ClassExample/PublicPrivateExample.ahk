; ABOUT:    MySCript v1.0
; From:     https://www.autohotkey.com/boards/viewtopic.php?t=47811
; License:
/*
    TODO: 
*/
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
esc::exitapp

#SingleInstance force


class MyClass extends PrivateObject {
    myvar := 0
    getVar() {
        return this.myvar
    }
    setVar(value) {
        if (value & 1)
            throw Exception("Odd value", -1, value)
        return this.myvar := value
    }
}

obj := new MyClass()
MsgBox obj.getVar()  ; 0
obj.setVar(42)
MsgBox obj.getVar()  ; 42
MsgBox obj.myvar  ; Error

; ====================================================

class PrivateObject {
    __new() {
        return PublicHandle(this)
    }
}

PublicHandle(this) {
    return {(PrivateObject): this, base: PublicHandleBase(this.base)}
}

class PublicHandle {
    __get(m:="") {
        if m != "base"
            throw Exception("Unknown property", -1, m)
    }
    __set(m:="") {
        throw Exception("Unknown property", -1, m)
    }
    __call(m:="") {
        if !ObjHasKey(this.base, m)
            throw Exception("Unknown method", -1, m)
    }
}

PublicHandleBase(cls) {
    static pbs := {}
    if pb := pbs[cls]
        return pb
    if cls = PrivateObject
        return PublicHandle
    pb := ObjClone(PublicHandleBase(cls.base))
    enm := ObjNewEnum(cls)
    while enm.Next(k, v) {
        if type(v) = "Func" && (SubStr(k,1,1) != "_" || k = "_NewEnum") && !pb.HasKey(k)
            ObjRawSet(pb, k, ((f, t, p*) => f.call(t[PrivateObject], p*)).Bind(v))
    }
    pb.base := cls  ; For type identity.
    pbs[cls] := pb  ; One per class.
    return pb
}