; TITLE:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0

class MyClass {

    myProperty := "Default Value"

    __New(initialValue := "") {

        if (initialValue != "") {
            this.myProperty := initialValue
        }
        MsgBox "MyClass instance created with property: " this.myProperty
    }

    getProperty() {
        MsgBox "The current value of myProperty is: " this.myProperty
    }

    setProperty(newValue) {
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
        ; Create an instance of MyClass
        ; This calls the __New method
        myObject := MyClass()

        ; Access and display the property
        myObject.getProperty()

        ; Create another instance with an initial value
        anotherObject := MyClass("Custom Initial Value")

        ; Modify the property of the first instance
        myObject.setProperty("New Value")

        ; Display the modified property
        myObject.getProperty()

        ; Display the property of the second instance with initial value
        anotherObject.getProperty()
    }
    Test2() {
    }
    Test3() {
    }
}
