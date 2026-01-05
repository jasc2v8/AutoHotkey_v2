; ABOUT:    MySCript v1.0
; From:     https://www.autohotkey.com/boards/viewtopic.php?t=73588
; License:
/*
    TODO: 
*/
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
esc::exitapp

class MyClassName {

    __new(var) {

        this.param:=var
    }
	__property[name] {
		set => this.%name% := value
		get => this.%name%
	}
}

myclass := MyClassName("new")

myclass.property := "property"
msgbox "test: " myclass.property, "myclass.property"

myclass.anyproperty := "any property"
msgbox "test: " myclass.anyproperty, "myclass.anyproperty"


msgbox "test: " myclass.param, "myclass.param"

for k, v in myclass.OwnProps()
    MsgBox k " = " v, "iterate"