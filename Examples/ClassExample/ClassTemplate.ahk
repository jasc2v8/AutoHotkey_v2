#Requires AutoHotkey v2.0

class MyExampleClass {
    ; Static property (shared across all instances)
    static MyStaticValue := "This is a static property"

    ; Instance property (each object has its own copy)
    __New(instanceName) {
        this.Name := instanceName
    }

    ; Static method (called directly on the class)
    static StaticMethod() {
        MsgBox("I am a static method, called from " . this.MyStaticValue)
        this.InstanceMethod()
    }

    ; Instance method (called on an object of the class)
    InstanceMethod() {
        MsgBox("I am an instance method, called from " . this.Name)

        this.StaticMethod()
    }


}

; Call a static method directly from the class
MyExampleClass.StaticMethod()

; Create an instance (object) of the class
myObject := MyExampleClass("MyFirstObject")

; Call an instance method on the object
myObject.InstanceMethod()

; Access an instance property
MsgBox("Object name: " . myObject.Name)
