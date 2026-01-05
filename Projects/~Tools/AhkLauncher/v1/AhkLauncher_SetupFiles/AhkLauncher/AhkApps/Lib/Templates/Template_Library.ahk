; TITLE:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0

;#Include <MyLib>

MyFunction(arg, Title) {
    MsgBox(arg, Title)
}

MyMethod(arg, Title) {
    MsgBox(arg, Title)
    return arg " modified."
}

; #region Tests

; If the file containing this line of code is the same file that was originally launched,
; then execute the following block of code.

; If included, skip the following block of code.
; If run directly, execute the following block of code
If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    MyFunction__Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

MyFunction__Tests() {

    ; comment out to run tests
    SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    Test2()
    Test3()

    ; test methods
    Test1() {
        MyFunction("MyFunction", "Test1")
    }
    Test2() {
    }
    Test3() {
    }
}
