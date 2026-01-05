#Requires AutoHotkey v2.0
class A {
    B() => MsgBox(A_ThisFunc)
}
class C extends A {
    static Base := this.Prototype
    B() {
        super.B()  ; This calls the version of B defined by A.
        MsgBox(A_ThisFunc)
    }
}
C.B()