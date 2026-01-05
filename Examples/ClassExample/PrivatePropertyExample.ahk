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

class x {
	__new() {
		background_value := 0
		
		this.defineprop 'p', { 
			get : (this) => background_value, 
			set : (this, value) => value > 0 ? background_value := value : this.error()  
		}
		
	}
	error(){
		throw
	}
}

y := x()
y.p := 1
msgbox y.p
;y.p := -1 ;error

for k, v in x.OwnProps()
    MsgBox k " = " v, "iterate"

