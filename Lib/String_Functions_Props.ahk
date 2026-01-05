; ABOUT Initial version

#Requires AutoHotkey v2.0+

;DEBUG
;#Warn Unreachable, Off
;Escape::ExitApp()

; #region Method Calls

; Varous ways to DefineProp
String.Prototype.DefineProp := Object.Prototype.DefineProp 
StringBase := "".Base
DefProp := {}.DefineProp

; region Method Prototype Calls

;-------------------------------------------------------
StringContains(thisStr, subString, caseSense := false) {
    return InStr(thisStr, subString, caseSense) != 0
}
String.Prototype.DefineProp("Contains", {Call: StringContains}) 

;-------------------------------------------------------
StringEndsWith(Haystack, Needle, CaseSense := false) {
    return StrCompare(SubStr(Haystack, -Needle.Length, Needle.Length), Needle, CaseSense) = 0
}
String.Prototype.DefineProp("EndsWith", {Call: StringEndsWith})

;-------------------------------------------------------
StringFormat(FormatStr, Values*) {
    return Format(FormatStr, Values)
}
String.Prototype.DefineProp("Format", {Call: StringFormat})

;-------------------------------------------------------
StringIndexOf(Haystack, Needle, CaseSense:=false) {
    return InStr(Haystack, Needle, CaseSense)
}
String.Prototype.DefineProp("IndexOf", {Call: StringIndexOf})

;-------------------------------------------------------
StringIsEmpty() {
;     return this.Length = 0
}
String.Prototype.DefineProp("IsEmpty",  {Call: (this) => this=""}) 
; ok DefProp( "".base, "IsEmpty", { Call: (this) => (StrLen(this)=0) } )
; ok DefProp( "".base, "IsEmpty", { Call: (this) => this="" } )

;-------------------------------------------------------
StringIsLower() {
}
String.Prototype.DefineProp("IsLower", {Call: IsLower})

;-------------------------------------------------------
StringIsUpper() {
}
String.Prototype.DefineProp("IsUpper", {Call: IsUpper})

;-------------------------------------------------------
StringLastIndexOf(Haystack, Needle, CaseSense:=false) {
    return InStr(Haystack, Needle, CaseSense, Needle.Length, -1)
}
String.Prototype.DefineProp("LastIndexOf", {Call: StringLastIndexOf})

;-------------------------------------------------------
StringMatch(Haystack, Needle) {
    RegExMatch(Haystack, Needle, &Match)
    return IsObject(Match) ? Match.1 : ""
}
String.Prototype.DefineProp("Match", {Call: StringMatch})

;-------------------------------------------------------
StringReplace(Haystack, Needle, Replacement:="") {
    return RegExReplace(Haystack, Needle, Replacement)
}
String.Prototype.DefineProp("Replace", {Call: StringReplace})

;-------------------------------------------------------
StringReverse(this) {
    reversedString := ""
    Loop Parse, this
        reversedString := A_LoopField . reversedString
    return reversedString
}
String.Prototype.DefineProp("Reverse", {Call: StringReverse})

;-------------------------------------------------------
StringStartsWith(Haystack, Needle, CaseSense := false) {
    return StrCompare(SubStr(Haystack, 1, Needle.Length), Needle, CaseSense) = 0
}
String.Prototype.DefineProp("StartsWith", {Call: StringStartsWith})

;-------------------------------------------------------
StringTrim(this, OmitChars:=" `t`r`n") {
    return Trim(this, OmitChars)
}
String.Prototype.DefineProp("Trim", {Call: StringTrim})
;DefProp( "".base, "Trim", { Call: StringTrim } )

;-------------------------------------------------------
StringLTrim(this, OmitChars:=" `t`r`n") {
    return LTrim(this, OmitChars)
}
String.Prototype.DefineProp("LTrim", {Call: StringLTrim}) 

;-------------------------------------------------------
StringRTrim(this, OmitChars:=" `t`r`n") {
    return RTrim(this, OmitChars)
}
String.Prototype.DefineProp("RTrim", {Call: StringRTrim}) 

;-------------------------------------------------------
StringSplit_TODO() {

}
;String.Prototype.DefineProp("ToPascal", {Call: StringSplit}) 

;-------------------------------------------------------
StringSubStr_TODO() {

}
;String.Prototype.DefineProp("ToPascal", {Call: StringToPascal}) 

;-------------------------------------------------------
StringToPascal_TODO(Str) {
;     return ?
}
;String.Prototype.DefineProp("ToPascal", {Call: StringToPascal}) 

;-------------------------------------------------------
StringToUpper(Str) {
}
;String.Prototype.DefineProp("ToUpper", {Call: StringToUpper}) 
String.Prototype.DefineProp("ToUpper", {Call: StrUpper}) 

;-------------------------------------------------------
 StringToLower(Str) {
 }
; String.Prototype.DefineProp("ToLower", {Call: StringToLower}) 
String.Prototype.DefineProp("ToLower", {Call: StrLower}) 

;-------------------------------------------------------
StringToTitle(Str) {
}
;String.Prototype.DefineProp("ToTitle", {Call: StringToTitle}) 
String.Prototype.DefineProp("ToTitle", {Call: StrTitle}) 

; region Object Property Access (Get)

;-------------------------------------------------------
StringLength() {
}
String.Prototype.DefineProp("Length", {Get: StrLen}) 
; ok DefProp( "".base, "Length", { Get: StrLen } )

;-------------------------------------------------------
;
; no: this only return the variable name 'test'
;
; StringName(this) {
;     try        
;         SomeFunction(this)
;     catch as e {
;         ;MsgBox(type(e) " in " e.What ", which was called at line " e.Line "`n`nstack:`n`n" e.Stack)

;         pattern := "SomeFunction\(([^)]+)\)"

;         r := RegExMatch(e.Stack, pattern, &Match)

;         ;MsgBox "Result:`n`n" r "`n`nMatch:`n`n" match[1]

;         return match[1]
;     }

;     SomeFunction(var) {
;         throw Error("Fail", -1)
;     }

; }
; String.Prototype.DefineProp("Name", {Call: StringName}) 
