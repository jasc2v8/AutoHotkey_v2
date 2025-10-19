; ABOUT Initial version
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
    Test2()
    Test3()

    ; test methods
    Test1() {
        DebugList("List:",
            "`n" LPad("Value1: ", 3), StrEnclose(100, '[]'), 
            "`n" LPad(, 3) "Value2: ", StrEnclose(200, '[]'),
            "`n" LPad(, 3, ' ') "Value3: ", StrEnclose(300, '[]'))
    }
    Test2() {
        DebugLine('Line : ',"Value1: ", 100, ", Value2: ", 200)
        DebugLine(,"Value1: ", 100, ", Value2: ", 200)
    }
    Test3() {
    }
}
