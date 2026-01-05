; ABOUT Initial version

#Requires AutoHotkey v2.0

;#Warn Unreachable, Off
;Escape::ExitApp()

; () => { statements }

; WIP Force these lines to be #Included because MergeIncludes.ahk can't parse them properly
;@MergeIncludes-All
;@MergeIncludes-Begin
;@MergeIncludes-End

; #region Method Calls

; Varous ways to DefineProp
String.Prototype.DefineProp := Object.Prototype.DefineProp 
StringBase := "".Base
DefProp := {}.DefineProp

; region Method Calls

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

; #region Function Calls

StringLength4 := (this) => StrLen(this)
Length4 := StringLength4.Bind()

SubStrExtract(Text, StartChar, EndChar) {
    StartPos := InStr(Text, StartChar) + 1
    EndPos := InStr(Text, EndChar)
    Length := EndPos - StartPos
    return SubStr(Text, StartPos, Length)
}

;-------------------------------------------------------------------------------
; Summary:  Left pads the Str, Count times, with the PadChar.
; Returns:  The padded Str.
; Library:  String.ahk
LPad(Str:='', Count:=4, PadChar:=A_Space) {
    Loop Count
        Str := PadChar Str
    return Str
}
; Library: String
CR := "`r"
LF := "`n"
NL := "`n"
CRLF := CR . LF

; Library: String
IsEmpty(str) {
    return str = ''
}
;-------------------------------------------------------------------------------
; FUNCTION: StrEnclose(str, EndChars:='"')
; Purpose: Encloses the str with the EndChars.
;          Accepts single char for both ends ('"')
;          Accepts two chars for each end, '()'
; Returns: String enclosed with the EndChars
; Library: String
StrEnclose(str, EndChars:='"') {
    return SubStr(EndChars, 1, 1) str SubStr(EndChars, -1, 1)
}
;----------------------------------------------------------------------------
; FUNCTION: StrJoin(Separator, Parts*)
; Purpose: Joins the string parts with the separator.
; Returns: Joined strubg without duplicate separators.
; Library: String
StrJoin(Separator := ',', Parts*) {
    joinedPath := ""
    for index, value in Parts {
        joinedPath .= value . Separator
    }
    while (InStr(joinedPath, Separator Separator) > 0)
        joinedPath := StrReplace(joinedPath, Separator . Separator, Separator)
    return SubStr(joinedPath, 1, -StrLen(Separator))
}
;----------------------------------------------------------------------------
; FUNCTION: StrJoinPath(Parts*)
; Purpose: Joins the path parts with the '\' separator.
; Returns: Joined path without duplicate separators.
; Library: String
StrJoinPath(Parts*) {
    Separator := '\'
    joinedPath := ""
    for index, value in Parts {
        joinedPath .= value . Separator
    }
    while (InStr(joinedPath, Separator Separator) > 0)
        joinedPath := StrReplace(joinedPath, Separator . Separator, Separator)
    return SubStr(joinedPath, 1, -StrLen(Separator))
}
;-------------------------------------------------------------------------------
; FUNCTION: StrSplitPath(path)
; Purpose: Splits the path into its components.
; Returns: Each component as a Map object.
; Library: String
StrSplitPath(path) {
    path := StrReplace(path, "\\", "\")
    SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    SplitPath(Dir,,&ParentDir)
    return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}
;-------------------------------------------------------------------------------
; FUNCTION: StrSplitShortcut(path)
; Purpose: Gets the information about the shortcut,
;          and splits the information into its components.
; Returns: Each component as a Map object.
; Library: String
StrSplitShortcut(LinkFile) {
    FileGetShortcut LinkFile , &OutTarget, &OutDir, &OutArgs, &OutDescription, &OutIcon, &OutIconNum, &OutRunState
    return {Target: OutTarget, Dir: OutDir, Args: OutArgs, Description: OutDescription, Icon: OutIcon, RunState: OutRunState}
}

; ======================================================
; #region Object Property Access (Get)
; ======================================================

;-------------------------------------------------------------------------------
; Purpose: There is no Standard Property for String.Length.
; Returns: The Length of the String.
; Example: String.Length
StringLengthProperty(){
    ; This is not used, only for documentation
}
;-------------------------------------------------------
DefProp( "".base, "Length", { get: StrLen } )

