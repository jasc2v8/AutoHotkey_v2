; ABOUT: MySCript v1.0
; From:
; License:
/*
    TODO: 
*/
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

class MetaDemo {
    __New(args*) {
        MsgBox "__New called with args:`n" args.Length ? args.Join("`, ") : "none"
    }

    __Delete() {
        MsgBox "__Delete called"
    }

    __Get(key, params*) {
        MsgBox "__Get called for key: " key "`nParams: " (params.Length ? params.Join("`, ") : "none")
        return "default"
    }

    __Set(key, value, params*) {
        MsgBox "__Set called for key: " key "`nValue: " value "`nParams: " (params.Length ? params.Join("`, ") : "none")
    }

    __Call(method, args*) {
        MsgBox "__Call called for method: " method "`nArgs: " (args.Length ? args.Join("`, ") : "none")
    }

    __Enum(n) {
        MsgBox "__Enum called with mode: " n
        i := 0
        return (n = 1)
            ? (obj => (i < 3 ? (obj[1] := i, obj[2] := "val" i++, true) : false))
            : (obj => (i < 3 ? (obj[1] := "val" i++, true) : false))
    }

    Clone() {
        MsgBox "Clone called"
        new := MetaDemo()
        ; Copy properties manually if needed
        return new
    }
}

; Example sage

obj := MetaDemo("init")
val := obj.someMissingProp
obj.someMissingProp := "new value"
obj.undefinedMethod(1, 2)

for k, v in obj {
    MsgBox "Enum: " k " = " v
}

clone := obj.Clone()