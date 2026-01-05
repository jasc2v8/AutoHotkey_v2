; TITLE:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0

class MyStaticClass {

    static myProperty := "Default Value"

    static getProperty() {
        MsgBox "The current value of myProperty is: " this.myProperty
    }

    static setProperty(newValue) {
        this.myProperty := newValue
        MsgBox "myProperty has been updated to: " this.myProperty
    }
}

; If included, skip the following block of code.
; If run directly, execute the following block of code
If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    MyFunction__Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

MyFunction__Tests() {

    ; comment out to run tests
    ;SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    Test2()
    Test3()

    ; test methods
    Test1() {

        ; Access and display the property
        MyStaticClass.getProperty()

        ; Modify the property of the first instance
        MyStaticClass.setProperty("New Value")

        ; Display the modified property
        MyStaticClass.getProperty()

    }
    Test2() {
    }
    Test3() {
    }
}
