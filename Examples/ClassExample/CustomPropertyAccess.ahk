; ABOUT: MySCript v1.0
; From:
; License:
/*
    TODO: 
*/
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

class MyClass {

    __New(name) {
        ;this.name := name
    }

    __Get(key) {
        MsgBox "Attempted to get: " key
        return "default"
    }

    __Set(key, value) {
        MsgBox "Attempted to set: " key " to " value
    }

    __Call(method, args*) {
        MsgBox "Unknown method: " method
    }
}

obj := MyClass("Jim")
;value := obj.undefinedProp()        ; triggers __Get
; no ;obj.newProp := "Hello"            ; triggers __Set
;obj.unknownMethod(1, 2)           ; triggers __Call
obj.GetSomething()
obj.SetSomething()
obj.Parameter := "Hello"
