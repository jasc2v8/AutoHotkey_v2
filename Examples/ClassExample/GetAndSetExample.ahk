; ABOUT:    MySCript v1.0
; From:     https://www.autohotkey.com/boards/viewtopic.php?t=9198
; License:
/*
    TODO: 
*/
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon
esc::exitapp

#SingleInstance force



class MyClass{
	__New(){
		prop_before := this.prop
		this.prop := 1
		tooltip prop_before ", " this.prop
	}
	
	prop[test] {
		get {
			if (this._prop = ""){
				this._prop := -1
			}
			return this._prop
		}
		
		set {
			this._prop := value
			return this._prop
		}
	}
}

mc := MyClass()

mc.test := "test"
msgbox mc.test

return