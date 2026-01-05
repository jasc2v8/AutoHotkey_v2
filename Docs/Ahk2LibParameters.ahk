; ABOUT Initial version
; Function: A standalone block of code defined independently, not as part of an object or class
; Method: A function that is associated with an object or a class.

#Requires AutoHotkey v2.0

; #region Functions or Methods (Classes)

/**
 * Add character(s) to left side of the input string.
 * Example: LPad("Hello", 3, '*')
 * @b THIS IS A TEST
 * @abstract Output:  ***Hello
 * @argument Str
 * @attention
 * @jimdreher
 * @class
 * @example
 * @description
 * @function
 * @implements
 * @method
 * @name
 * @note
 * @param
 * @prop
 * @property
 * @returns {String}
 * @requires
 * @see
 * @summary
 * @template
 * @throws
 * @tutorial
 * @version
 * @warning
 * @yields
 *@fileoverview
 * @param Str Text you want to pad on the left side.
 * @param Count How many times do you want to repeat adding to the left side.
 * @param PadChar Character you want to repeat adding to the left side.
 * @returns {String}
 */
MyFunction(arg, Title) {
    MsgBox(arg, Title)
}

; #region Tests

 ;@todo something

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    __DoTests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
__DoTests() {

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
