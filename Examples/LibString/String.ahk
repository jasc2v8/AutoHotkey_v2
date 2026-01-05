; ABOUT Initial version
#Requires AutoHotkey v2.0

#Warn Unreachable, Off
Escape::ExitApp()

; () => { statements }

; #region Prototypes

String.Prototype.DefineProp := Object.Prototype.DefineProp 
; ok DefProp := {}.DefineProp

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
StringLength() {
}
String.Prototype.DefineProp("Length", {Get: StrLen}) 
; ok DefProp( "".base, "Length", { Get: StrLen } )

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
StringTrim() {
}
; String.Prototype.DefineProp("Trim", {Call: StringTrim}) 
String.Prototype.DefineProp("Trim", {Call: Trim}) 

;-------------------------------------------------------
StringLTrim() {
}
; String.Prototype.DefineProp("LTrim", {Call: StringLTrim}) 
String.Prototype.DefineProp("LTrim", {Call: LTrim}) 

;-------------------------------------------------------
StringRTrim() {
}
; String.Prototype.DefineProp("RTrim", {Call: StringRTrim}) 
String.Prototype.DefineProp("RTrim", {Call: RTrim}) 

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

; #region Tests

myString := "Hello World!"

;INOP
;MsgBox Format("Pad Right: [{:40}]", myString)
;MsgBox Format("Pad Leftt: [{:-40}]", myString)
;MsgBox myString.Format("Pad Right: [{:40}]"), "Format=Pad Right"
;MsgBox myString.Format("Pad Left: [{:40}]"), "Format=Pad Left"

;INOP
myString := "Hello Hello!"
;MsgBox InStr(myString, "ll", , myString.Length, -1)
;MsgBox r := myString.LastIndexOf("ll", false), "LastIndexOf=9"

myString := "     Hello Hello!     "

MsgBox myString.ToUpper(), "ToUpper"
MsgBox myString.ToLower(), "ToLower"
MsgBox myString.ToUpper(), "ToTitle TBD"

MsgBox "[" myString "]`n`n" "[" myString.Trim() "]", "Trim"
MsgBox "[" myString "]`n`n" "[" myString.LTrim() "]", "LTrim"
MsgBox "[" myString "]`n`n" "[" myString.RTrim() "]", "RTrim"

myString := "Hello Hello!"

MsgBox r := myString.StartsWith("HEL") ? "True" : "False", "StartsWith=True"
MsgBox r := myString.StartsWith("HEL", true) ? "True" : "False", "StartsWith=False"
MsgBox r := myString.StartsWith("LLO") ? "True" : "False", "StartsWith=False"


MsgBox r := myString.EndsWith("ld!") ? "True" : "False", "EndsWidth=True"
MsgBox r := myString.EndsWith("rld") ? "True" : "False", "EndsWidth=False"
MsgBox r := myString.EndsWith("LD!", True) ? "True" : "False", "EndsWidth=False"

MsgBox r := myString.IndexOf("OR"), "IndexOf=8"
MsgBox r := myString.IndexOf("OR", True), "IndexOf=0"

myString := ""
MsgBox r := myString.IsEmpty() ? "True" : "False", "IsEmpty=True" ; ? "true" : "False", "IsEmpty"
myString := "Hello World!"
MsgBox r := myString.IsEmpty() ? "True" : "False", "IsEmpty=False" ; ? "true" : "False", "IsEmpty"

MsgBox r := myString.Length, "Length=12"

MsgBox r := myString.Contains("wor")       ? "True" : "False", "Contains=True"
MsgBox r := myString.Contains("wor", true) ? "True" : "False", "Contains=false"

MsgBox myString.Length, "Length"

MsgBox MyString "`n`nReversed:`n`n" myString.Reverse() , "Reverse" ; Displays "!dlroW olleH"


ExitApp()


; #region Functions

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

; #region Tests

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    __DoTests_String()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------

__DoTests_String() {

    #Warn Unreachable
    
    Run_Tests := true

    if !Run_Tests
        SoundBeep(), ExitApp()


    ; comment out tests to skip:
    ;Test1() ; StrEnclose
    Test2()
    ;Test3()
    ;Test_StrSplitShortcut()

    ; test methods
    Test1() {
 	    OutputDebug(StrEnclose("MyString")) ; default := ''"'
	    OutputDebug(StrEnclose("MyString","'"))
	    OutputDebug(StrEnclose("MyString","{}"))
	    OutputDebug(StrEnclose("MyString","[]"))
	    OutputDebug(StrEnclose("MyString",'"'))
    }
    Test2() {
        Time := FormatTime(A_Now)
        OutputDebug('Time: ' Time)

        Time := FormatTime(A_Now, 'HH:mm:ss')
        OutputDebug('Time: ' Time)

    }
    Test3() {
    }
    Test_StrSplitShortcut() {
        ;path := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\Remote Desktop Connection.lnk"
        ;path := "D:\Software\DEV\Work\AHK2\AhkApps\\notepad.exe.lnk"
        path := "D:\Software\DEV\Work\AHK2\AhkApps\\temp.lnk"
        MsgBox("Path:`n`n"  LPad() path "`n`n" 
        "Target:`n`n" LPad() StrSplitShortcut(path).Target "`n`n"
        "Dir:`n`n" LPad() "[" StrSplitShortcut(path).Dir "]`n`n"
        "Args:`n`n" LPad() "[" StrSplitShortcut(path).Args "]`n`n"
        "Description:`n`n" LPad() StrSplitShortcut(path).Description,
        "StrSplitShortcut")
    }

    #Warn Unreachable, Off

}
