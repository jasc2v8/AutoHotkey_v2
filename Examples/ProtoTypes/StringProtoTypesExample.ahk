Escape::ExitApp()

; Varous ways to DefineProp
String.Prototype.DefineProp := Object.Prototype.DefineProp 
StringBase := "".Base
DefProp := {}.DefineProp

;-------------------------------------------------------
StringContains(thisStr, subString, caseSense := false) {
    return InStr(thisStr, subString, caseSense) != 0
}
String.Prototype.DefineProp("Contains", {Call: StringContains}) 

;-------------------------------------------------------
StringLength1(this) {
    return StrLen(this)
}
String.Prototype.DefineProp("Length1", {Call: StringLength1}) 

;-------------------------------------------------------
StringLength2(this) {
    return StrLen(this)
}
StringBase.DefineProp("Length2", {Call: StringLength2}) 

;-------------------------------------------------------
StringLength3(this) {
    return StrLen(this)
}
"".Base.Length3 := StringLength3.Bind()

;-------------------------------------------------------
StringLength4 := (this) => StrLen(this)
Length4 := StringLength4.Bind()

;-------------------------------------------------------
DefProp( "".base, "Length5", { get: StrLen } )

;-------------------------------------------------------
; StringLength() {
; }
; String.Prototype.DefineProp("Length", {Get: StrLen}) 
AnyString := "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

SoundBeep(), Test_Debug()
SoundBeep(), Test_HasProp()
SoundBeep(), Test_Contains()
SoundBeep(), Test_Length()

SoundBeep(), SoundBeep()
ExitApp()


Test_Debug() {

    msgbox AnyString.Length5
}

Test_HasProp() {

    ; True
    MsgBox "HasProp Contains: " ((HasProp(StringBase    ,"Contains")   = 1) ? "True" : "False"), "HasProp"

    ; All True
    MsgBox "HasProp1: " ((HasProp(StringBase,"Length1")      = 1) ? "True" : "False"), "HasProp Length1"
    MsgBox "HasProp2: " ((HasProp(StringBase,"Length2")         = 1) ? "True" : "False"), "HasProp Length2"
    MsgBox "HasProp3: " ((HasProp(StringBase,"Length3")         = 1) ? "True" : "False"), "HasProp Length3"

    ; This is a Bind, not a Property of StringBase hence False
    MsgBox "HasProp4: " ((HasProp(StringBase,"Length4")      = 1) ? "True" : "False"), "HasProp Length4"

    ; No Property Length5, hence False
    MsgBox "HasProp5: " ((HasProp(StringBase,"Length5")   =   1) ? "True" : "False"), "HasProp Length5"
}

Test_Contains() {
    MsgBox "Contains(amet): " ((AnyString.Contains("amet")) ? "True" : "False"), "Contains"
    MsgBox "Contains(AMET)): " ((AnyString.Contains("AMET")) ? "True" : "False"), "Contains"
    MsgBox "Contains(test): " ((AnyString.Contains("test")) ? "True" : "False"), "Contains"
}


Test_Length() {

    ; Method Call
    MsgBox AnyString.Length1(), "Length1=" StrLen(AnyString)
    MsgBox AnyString.Length2(), "Length2=" StrLen(AnyString)
    MsgBox AnyString.Length3(), "Length3=" StrLen(AnyString)

    ; Function Call
    MsgBox Length4(AnyString), "Length4=" StrLen(AnyString)

    ; Object Property Access (Get)
    MsgBox AnyString.Length5, "Length5=" StrLen(AnyString)
}




Rot13(This) {
    NewString := ""
    for char in StrSplit(This) {
        if (char = "A")
            NewString .= "N"
        else
            NewString .= char
    }
    return NewString
}
