; ABOUT: MySCript v1.0
; From:
; License:
/*
    TODO: 
*/
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
class MetaLogger {
    static LogFile := A_ScriptDir "\meta_log.txt"

    __New(args*) {
        this.Log("__New", args)
    }

    __Delete() {
        this.Log("__Delete")
    }

    __Get(key, params*) {
        this.Log("__Get", [key, params])
        return "default"
    }

    __Set(key, value, params*) {
        this.Log("__Set", [key, value, params])
    }

    __Call(method, args*) {
        this.Log("__Call", [method, args])
    }

    __Enum(n) {
        this.Log("__Enum", [n])
        i := 0
        return (n = 1)
            ? (obj => (i < 3 ? (obj[1] := i, obj[2] := "val" i++, true) : false))
            : (obj => (i < 3 ? (obj[1] := "val" i++, true) : false))
    }

    Clone() {
        this.Log("Clone")
        return MetaLogger()
    }

    Log(tag, data := "") {
        FileAppend FormatTime() " [" tag "] " this.Format(data) "`n", MetaLogger.LogFile
    }

    Format(data) {
        if IsObject(data) {
            try return data.HasMethod("Join") ? data.Join(", ") : JSON.stringify(data)
            catch => return "Object"
        }
        return data
    }
}

FormatTime() {
    return Format("{:04}-{:02}-{:02} {:02}:{:02}:{:02}", A_Year, A_Mon, A_MDay, A_Hour, A_Min, A_Sec)
}

;Usage Example

obj := MetaLogger("init")
val := obj.someMissingProp
obj.someMissingProp := "new value"
obj.undefinedMethod(1, 2)

for k, v in obj {
    ; Iteration triggers __Enum
}

clone := obj.Clone()

