; TITLE Initial version
#Requires AutoHotkey v2.0

#Include <String> ; used in Tests below

DebugLine(Title1:='DEBUG: ', Args*) {
	msg:=''
   	Loop Args.length
		msg .= Args[A_Index] ""
	OutputDebug(Title1 msg)
}

DebugList(Title1:='DEBUG: ', Args*) {
	msg:=''
   	Loop Args.length
		msg .= Args[A_Index] ""
	OutputDebug(Title1 msg)
}

;-------------------------------------------------------------------------------
; FUNCTION: ListObj([Map or Array], EncloseInBrackets)
; Purpose: Lists the values of an AHK Map object in a message box.
; Returns: The keys and/or values as a string.
; Parameters: The Object or Array, EnclosedInBrackets := true or false.
ListObj(MyObject, EncloseInBrackets := false) {

    if (EncloseInBrackets) {
        OB := '['
        CB := ']'
    } else {
        OB := ''
        CB := ''
    }

    Output := ''

    objName := Type(MyObject)

    if (objName = "Array") {
        for value in MyObject {
            Output .= OB value CB "`n`n"
        }
    } else {
        if (objName = "Map") {
            for index, value in MyObject {
                Output .= OB index CB ": " OB value CB "`n"
            }
        }
    }

    MsgBox(Output, "Object is : " objName)

    return Output
}


If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    __DoTest_Debug()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
__DoTest_Debug() {

    ; comment out to run tests:
    SoundBeep(), ExitApp()

    ; comment out tests to skip:
    Test1()
    ;Test2()
    ;Test3()

    ; test methods
    Test1() {
        DebugList("List:",
            "`n" "Value1: ".LPad(3), "100".Concat("[", "]"), 
            "`n" "Value2: ".LPad(3), "200".Concat("[", "]"),
            "`n" "Value1: ".LPad(3), "300".Concat("[", "]"))
    }
    Test2() {
        DebugLine('Line : ',"Value1: ", 100, ", Value2: ", 200)
        DebugLine(,"Value1: ", 100, ", Value2: ", 200)
    }
    Test3() {
    }
}
