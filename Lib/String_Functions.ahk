; ABOUT String_Functions

#Requires AutoHotkey v2.0+

;DEBUG
;#Warn Unreachable, Off
;Escape::ExitApp()

; #region Function Calls

/**
 *  IsEmpty(str)
 *  LPad(Str:='', Count:=4, PadChar:=A_Space) 
 *  StrEnclose(str, EndChars:='"'
 *  StrJoin(Separator := ',', Parts*)
 *  StrJoinPath(Parts*)
 *  StrSplitPath(path)
 *  StrSplitShortcut(LinkFile)
 *  SubStrExtract(Text, StartChar, EndChar 
 *   
 */

SubStrExtract(Text, StartChar, EndChar)
{
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
