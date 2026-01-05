;SOURCE: Gemini

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

    ; Another instance method to modify the property
    setProperty(newValue) {
        this.myProperty := newValue
        MsgBox "myProperty has been updated to: " this.myProperty
    }
}

; Create an instance of MyClass
; This calls the __New method
myObject := MyClass()

; Access and display the property
myObject.getProperty()

; Create another instance with an initial value
anotherObject := MyClass("Custom Initial Value")

; Modify the property of the first instance
myObject.setProperty("New Value for myObject")

; Display the modified property
myObject.getProperty()

; Display the property of the second instance (it remains unchanged)
anotherObject.getProperty()