
; TITLE  :  DebugTests v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :  

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

#Include Debug.ahk

ESC::ExitApp()

Debug__Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

Debug__Tests() {

    ; comment out to run tests
    ;SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test0()
    ;Test1()
    ;Test2()
    ;Test3()

    ; test methods

    Test0(){

        GetArray() {
            
        }
        varTest := "this is a test"

        name := [NameOf(&varTest), varTest]

        MsgBox("NAME: " name[1] ", VALUE: " name[2])

        NameOf(&v) => StrGet(NumGet(ObjPtr(&v) + 8 + 6 * A_PtrSize, 'ptr'), 'utf-16')

        GetName(var) {
            return var
        }

        test:="THIS IS A TEST"
        junk1:="THIS IS A JUNK1"
        junk2:="THIS IS A JUNK2"

        var := "test"
        ;MsgBox("Name: " . "'var'" . "`n`nValue: " . var)

        ;MsgBox("Name: " . NameOf(&var) . "`n`nValue: " . var)
        
        ;MsgBox(NameOf(&var) ": " var)

        msg := NameOf(&test) ": " test "`n`n" NameOf(&junk1) ": " junk1 "`n`n" NameOf(&junk2) ": " junk2 "`n`n"

        msg := GetName(NameOf(&test)) ; "`n`n" GetName(&junk1) "`n`n" GetName(&junk2)

        MsgBox(msg)

    }
    Test1() {

        MyArray := ["item1", "item2", "item3"]
        MyLine := "The quick brown fox.`r`n"
        MyCSV := "apple, banana, cherry"
        MyMap := Map("Key1", "Value1", "Key2", "Value2")
        MyObj := {KeyA: "ValueA", KeyB: "ValueB", KeyC: "ValueC"}
        MyString := "The quick brown fox jumps over the dog."

        r := Debug.ListVar(MyArray, "Array", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true

        r := Debug.ListVar(MyLine, "Line of Text", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true

        r := Debug.ListVar(MyCSV, "CSV", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true

        r := Debug.ListVar(MyMap, "Map", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true

        r := Debug.ListVar(MyObj, "Object", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true

        r := Debug.ListVar(MyString, "String", "OKCancel")
        (r="Cancel") ? ExitApp() : nop := true
    }
    Test2() {

        test:="TEST"
        MsgBox Debug.VarName(test) ": " test, "Debug"

        junk:="THIS IS JUNK1"
        MsgBox Debug.VarName(junk) ": " junk, "Debug"

        junk:="THIS IS JUNK2"
        MsgBox Debug.VarName(junk) ": " junk, "Debug"
    }

    Test3() {
            
        ; ListVars(Title:="", Options:="", Labels:="", Vars*)

        a:=Format("0x{:X}", 0xFCFCFC)
        b:=2.25
        c:=Format("{:.2f}", 3.1415927)
        d:=2
        e:=4
        f:=8

        ; equal number of vars
        Debug.ListVars("Test", "Enclose[], Spacing2", "a, b, c", a, b, c)

        ; vars > labels
        Debug.ListVars("Test", "Enclose(), Spacing3, OKCancel", "a, b, c", a, b, c, d, e, f)

        ; vars < labels
        Debug.ListVars("Test", "Enclose<>, Spacing4, YesNoCancel", "a, b, c", a, b)

    }

}