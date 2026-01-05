; ABOUT Initial version
#Requires AutoHotkey v2.0

#Warn Unreachable, Off

StringContains(thisStr, subString, caseSense := false) {
    return InStr(thisStr, subString, caseSense) != 0
}

String.Prototype.DefineProp := Object.Prototype.DefineProp 
String.Prototype.DefineProp("Contains", { Call: StringContains}) 

; Add the 'Contains' method to the String.Prototype using a Call descriptor
;String.Prototype.DefineProp("Contains", {Call: StringContains})

; --- Usage ---
mainString := "The quick brown fox jumps."

; Use the new custom method
if mainString.Contains("fox") {
    MsgBox("Found 'fox' (case-insensitive)")
}

if mainString.Contains("FOX", true) { ; Case-sensitive search
    MsgBox("Found 'FOX' (case-sensitive)") ; This message box will not appear
}

ExitApp

;Copy the DefineProp method from the Object prototype to the String prototype
String.Prototype.DefineProp := Object.Prototype.DefineProp 

; Use DefineProp to add a 'length' property to all strings
; The 'get' descriptor calls the StrLen function implicitly passing the string itself as the first parameter ("this")
String.Prototype.DefineProp("length", {get: StrLen}) 

; --- Usage ---
myString := "Hello, AHK!"
MsgBox("The length of the string is: " myString.length) ; Access as a property

ExitApp

DefProp := {}.DefineProp
DefProp( "".base, "Length", { get: StrLen } )
; ok MsgBox A_AhkPath.length " == " StrLen(A_AhkPath)

myString := "Hello World!"
DefProp( "".base, "IsEmpty", { get: IsStringEmpty } )
r := myString.IsEmpty
MsgBox r
myString := ""
r := myString.IsEmpty
MsgBox r

ExitApp

; Define the Reverse method

    StringReverse(this) {
        reversedString := ""
        Loop Parse, this
        {
            reversedString := A_LoopField . reversedString
        }
        return reversedString
    }

; class StringReverseOLD {
;     static Call(this) {
;         reversedString := ""
;         Loop Parse, this
;         {
;             reversedString := A_LoopField . reversedString
;         }
;         return reversedString
;     }
; }

; Add the Reverse method to String.Prototype
;String.Prototype.DefineProp("Reverse", {Call: StringReverse.Call})
String.Prototype.DefineProp("Reverse", {Call: StringReverse})
; Example usage:
myString := "Hello World!"
reversed := myString.Reverse()
MsgBox reversed ; Displays "!dlroW olleH"

ExitApp

; param := ""
; r :=  param.IsStringEmpty()

; MsgBox r


; ; #region Prototypes

; ;String.Prototype.IsEmpty := IsStringEmpty
; String.Prototype.DefineProp("Contains", {Call:IsStringEmpty})

IsStringEmpty(this)
{
    return this.Length = 0
}

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
