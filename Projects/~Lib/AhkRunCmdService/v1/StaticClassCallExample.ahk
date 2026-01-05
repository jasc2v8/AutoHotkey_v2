#Requires AutoHotkey 2.0+
#SingleInstance Force

Esc::ExitApp()

class MyStaticClass {
    ; Static method that acts like a "call" operator
    static Call(param) {
        MsgBox "Called with: " param
        return "You passed: " param
    }
}

; Usage examples:
result := MyStaticClass("Hello World")   ; invokes MyStaticClass.Call()
MsgBox result

; You can also call explicitly:
result2 := MyStaticClass.Call(123)
MsgBox result2


