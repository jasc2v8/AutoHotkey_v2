; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

class MyClass {
    ; --- Properties (Instance Variables) ---
    static ClassVersion := "1.0.0" ; Shared across all instances
    InstanceID := 0
    IsRunning  := false

    ; --- Constructor ---
    __New(initialID := 1) {
        this.InstanceID := initialID
        this._Initialize()
    }

    ; --- Public Methods ---
    
    /**
     * Perform an action
     * @param {String} inputVal - A description of the input
     * @returns {Integer} - Status code
     */
    DoSomething(inputVal) {
        if (inputVal == "") {
            throw Error("Input cannot be empty", -1)
        }
        
        MsgBox("Action performed with: " . inputVal, "Class Message")
        return 1
    }

    ; --- Private/Internal Methods ---
    _Initialize() {
        this.IsRunning := true
    }

    ; --- Cleanup ---
    __Delete() {
        ; Code here runs when the object is destroyed
        this.IsRunning := false
    }
}