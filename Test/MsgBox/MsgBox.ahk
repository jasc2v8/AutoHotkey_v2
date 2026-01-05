;ABOUT: Scante <Lib>, classes > Include_classes.ahk, functions > Include_functions.ahk

#Requires AutoHotkey v2.0
#SingleInstance Force
;#NoTrayIcon

#Include <String> ; used in Tests below

; #region Functions

/**
 * TODO: NEEDS WORK!
 */
MsgBoxCustom(Message, Title := "", Options := "Ok") {
    MyGui := Gui("AlwaysOnTop +OwnDialogs")
	MyGui.Title := Title
    MyGui.BackColor := "4682B4" ; Steel Blue
    MyGui.SetFont('s11', 'Consolas') ;'Lucida Console'
    ;MyGui.SetFont('s11', 'Lucida Console') ;'Lucida Console'
	MyEdit := MyGui.Add("Edit", "w400 h400 +WantReturn")
	MyEdit.Text := Message
	button1 := MyGui.Add("Button", "xm w72 Default", Options)
    MyGui.OnEvent('Close', OnGui_Close)
    button1.OnEvent('Click', OnButton1_Click)
	button1.Focus()

	;Persistent
	MyGui.Show()
	;return
	
	OnGui_Close(*) {
		r := MyEdit.Text
		MyGui.Destroy()
		return r
	}
	 OnButton1_Click(Ctrl, Info) {
		;MyEdit.Text .= "CLICK!" "`r`n"
		; r := MyEdit.Text
		; MyGui.Destroy()
		; return r
		;Exit
		MyGui.Submit()
		ExitApp()
	 }
}
/**
 * Custom MsgBox +AlwaysOnTop
 * Example: MsgBox("Value1: ' Value1, "Value2: ' Value2)sed to list variables (good for debugging).
 * Example: MsgBoxList("MyTitle", "icon", "Value1: ' Value1, "Value2: ' Value2)
 * Output:  ***Hello
 * @param Str Text you want to pad on the left side.
 * @param Count How many times do you want to repeat adding to the left side.
 * @param PadChar Character you want to repeat adding to the left side.
 * @returns {String}
 */
MsgBoxOnTop(Message, Title := "Error", Options := "OK") {
    MyGui := Gui("AlwaysOnTop +OwnDialogs")
    MyGui.BackColor := "4682B4" ; Steel Blue
    ;MyGui.SetFont('s12', 'Consolas')
	MsgBox(Message, Title, Options)
}

;-----------------------------------------------------------------------------
;Summary: MsgBox used to list variables (good for debugging).
;Example: MsgBoxList("MyTitle", "icon", "Value1: ' Value1, "Value2: ' Value2)
;Returns: MsbBox Object (test MsgBox.Button)
;Library: MsgBox.ahk
MsgBoxList(Title:='', Options:='', Args*) {
	msg:=''
   	Loop Args.length
		msg .= Args[A_Index]
	;return MsgBox(msg, Title, Options)
	MsgBox(msg, Title, Options)
}

; #region Tests

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    __DoTests_MsgBox()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
__DoTests_MsgBox() {

    #Warn Unreachable, Off
	
    Run_Tests := true

    if !Run_Tests
        SoundBeep(), ExitApp()

    ; comment out tests to skip:
    ;Test1()
    ;Test2()
    Test3()

    ; test methods

    Test1() {

		NL:= "`n"
		NL2:= "`n`n"

		r:=MsgBox("Value1: " 100 ", Value2: " 200 ", Value3: " 300, 
			"Test1a - STANDARD AHK MSGBOX: One Line", "OKCancel")
		r = 'Cancel' ? ExitApp() : Exit

		r:=MsgBoxList('Test1b - MsgBoxList: One Line', "OKCancel",
			"Value1:", 100, ", Value2:", 200, ", Value3:", 300)
		r = 'Cancel' ? ExitApp() : Exit

		r:=MsgBoxList('Test1c - MsgBoxList: Single Space', "OKCancel",
			"Value1:", 100, NL, "Value2:", 200, NL, "Value3:", 300)
		r = 'Cancel' ? ExitApp() : Exit

		r:=MsgBoxList('Test1d - MsgBoxList: Double Space', "OKCancel",
			"Value1:", 100, NL2, "Value2:", 200, NL2, "Value3:", 300)
		r = 'Cancel' ? ExitApp() : Exit

		r:=MsgBoxList('Test1e - MsgBoxList: No Space','icon OKCancel',
			"Value1:", 100, "Value2:", 200)
		r = 'Cancel' ? ExitApp() : Exit
			
		r:=MsgBoxList('MyTestf - MsgBoxList: Question',
			'icon? OKCancel', "Value1: ", 100, ", Value2: ", 200, ", Value3: ", 300)
		r = 'Cancel' ? ExitApp() : Exit

		r:=MsgBoxList('Testg - MsgBoxList: Exclamation',
			'icon! OKCancel', "Value1: ", 100, ", Value2: ", 200, ", Value3: ", 300)
		r = 'Cancel' ? ExitApp() : Exit

		r:=MsgBoxList('Testg - MsgBoxList: Information',
			'iconI OKCancel', "Value1: ", 100, ", Value2: ", 200, ", Value3: ", 300)
		r = 'Cancel' ? ExitApp() : Exit

		r:=MsgBoxList('Testg - MsgBoxList: Stop/Error',
			'iconX OKCancel', "Value1: ", 100, ", Value2: ", 200, ", Value3: ", 300)
		r = 'Cancel' ? ExitApp() : Exit

		r:=MsgBoxList('Test1H - MsgBoxList: Double Space with Icon', "OKCancel icon?",
			"Value1:", 100, NL2, "Value2:", 200, NL2, "Value3:", 300)
		r = 'Cancel' ? ExitApp() : Exit


    }
    Test2() {
		L1 := "Lorem ipsum dolor sit amet. Aut voluptatem sequi non voluptate quam ad error eius. In modi quibusdam ex vero quaerat eum laboriosam ullam aut odio totam."
		L2 := "`n`n"
		L3 := "Ex nobis eligendi et quia doloribus eos corrupti velit 33 earum quam. Ut laudantium incidunt et expedita adipisci et officiis molestias qui itaque error et similique impedit qui minus galisum! In veritatis voluptas cum culpa quidem et vitae velit."
		L4 := "`n`n"
		L5 := "Ea nulla voluptatem aut necessitatibus obcaecati est aspernatur deserunt et quisquam corrupti ea rerum temporibus! Sed magni commodi sit enim praesentium aut unde iste ex tenetur porro! Et consequatur aliquam eum voluptate voluptas aut enim quae aut voluptates ipsa sit sunt suscipit aut odit fugit. Ut laboriosam voluptas est dolores repellat et obcaecati odit sed omnis omnis eum iusto dolores."
		msg := L1 L2 L3 L4 L5

		MsgBox(msg, "STANDARD MSGBOX")
		MsgBoxOnTop(msg, "CUSTOM MSGBOX +AlwaysOnTop")
		MsgBoxOnTop(msg, "CUSTOM MSGBOX WITH ICON", "iconX OKCancel")

    }
    Test3() {
				L1 := "Lorem ipsum dolor sit amet. Aut voluptatem sequi non voluptate quam ad error eius. In modi quibusdam ex vero quaerat eum laboriosam ullam aut odio totam."
		L2 := "`n`n"
		L3 := "Ex nobis eligendi et quia doloribus eos corrupti velit 33 earum quam. Ut laudantium incidunt et expedita adipisci et officiis molestias qui itaque error et similique impedit qui minus galisum! In veritatis voluptas cum culpa quidem et vitae velit."
		L4 := "`n`n"
		L5 := "Ea nulla voluptatem aut necessitatibus obcaecati est aspernatur deserunt et quisquam corrupti ea rerum temporibus! Sed magni commodi sit enim praesentium aut unde iste ex tenetur porro! Et consequatur aliquam eum voluptate voluptas aut enim quae aut voluptates ipsa sit sunt suscipit aut odit fugit. Ut laboriosam voluptas est dolores repellat et obcaecati odit sed omnis omnis eum iusto dolores."
		msg := L1 L2 L3 L4 L5

		r := MsgBoxCustom(msg, "My Custom MsgBox")

		MsgBox('r: ' r)

		if r != ''
			MsgBoxCustom("number of chars: " StrLen(r))
    }
}
