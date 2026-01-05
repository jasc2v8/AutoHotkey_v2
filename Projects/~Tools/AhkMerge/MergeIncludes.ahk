;ABOUT: MergeIncludes v0.0.0.0

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <Debug>
#Include <String>

;DEBUG
Escape::ExitApp()

; #region Globals

global AhkPath          := "C:\Program Files\AutoHotkey"
global MainScriptPath   := "D:\Software\DEV\Work\AHK2\Projects\AhkLauncher\AhkLauncher.ahk"
global LibScriptPath    := "C:\Users\Jim\Documents\AutoHotkey\Lib\AhkFunctions.ahk"

; #region Create Gui

myGui := Gui()
myGui.Title := "File Selector"
MyGui.BackColor := "4682B4" ; Steel Blue

MyGui.SetFont("S11 CBlack w480", "Segouie UI")

myGui.AddText("xm ym", "Select a file:")

MyGui.SetFont("S11", "Consolas")
FilePathEdit := myGui.AddEdit("xm y+5 w600", MainScriptPath)

MyGui.SetFont()
myGui.AddButton("x+m yp w75", "Browse").OnEvent("Click", SelectFile)

myGui.AddText("xm w522 h0 Hidden", "Hidden Filler")
myGui.AddButton("yp w75 Default", "Merge").OnEvent("Click", Button_Click)
myGui.AddButton("yp w75", "Cancel").OnEvent("Click", (*) => ExitApp())

myGui.Show()

ControlFocus("Cancel", MyGui)

; #region Functions

SelectFile(Ctrl, Info) {
    selectedFile := FileSelect(, FilePathEdit.Value)
    if (selectedFile != "") {
        FilePathEdit.Value := selectedFile
    }
}

Button_Click(Ctrl, Info) {

    ; haystack :='"String.Prototype.DefineProp("Contains", {Call: StringContains})"'

    ; needle := '$$\text{/\("([^"]+)"/}$$'
    ; needle := '$$\text{/DefineProp\("([^"]+)"/}$$'

    ; MsgBox "Needle: [" needle "]", "Needle"

    ; RegExMatch(haystack, needle, &match)
    ; if IsObject(match)
    ;     MsgBox "Original: " haystack "`n`nExtracted: " (IsSet(match) ? match[1] : "Not Found"), "Test 3"
    ; else
    ;     MsgBox "Original: " haystack "`n`nExtracted: Not Found", "Test 3"
    
    ; ExitApp()


    ; DELETE IncludeFiles     := GetIncludeFiles(FilePathEdit.Value)

    IncludeFiles := GetIncludeFilesRecurse(FilePathEdit.Value)

    ; DEBUG MsgBox Type(IncludeFiles) ; STRING

    static outFile := "LibScriptFile_Functions.txt"
    if FileExist(outfile)
        FileDelete(outfile)

    ; DEBUG FileAppend(IncludeFiles, outfile)

;MsgBox "outFile:`n`n" outFile

    FunctionsCSV := ""

    Loop Parse IncludeFiles, ",", "`r`n" {

;MsgBox A_LoopField, "Loop"

        FunctionsCSV .= ScanLibScript(A_LoopField) 
    }

;MsgBox "FunctionsCSV:`n`n" FunctionsCSV

    FileAppend(FunctionsCSV, outfile)

    MsgBox("Done!", "Status", "iconi")

}

; Purpose:  Find Functions and save to include in the MainScriptFile
; Return:   CSV file of functionName, LibScriptFile, ScriptLineNumber, FunctionLineCount
;---------------------------------------------------------------------------------------
ScanLibScript(LibScriptFile) {

;MsgBox LibScriptFile, "ScanLibScript"

    FunctionCSV := ""

    ScriptText := FileRead(LibScriptFile)

    ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

    InCommentBlock := false

    ScriptLineNumber := 0

    Loop {

        ScriptLineNumber++

        if ScriptLineNumber > ScriptTextArray.Length
            break

    SplitPath(LibScriptFile, &OutName)
    ;MsgBox "Script: " OutName "`n`nScriptLineNumber: " ScriptLineNumber "`n`nInCommentBlock: " InCommentBlock, "Loop 1"

        line := ScriptTextArray[ScriptLineNumber]

        if line.StartsWith("/*")
            InCommentBlock := true
        else if line.StartsWith("*/")
            InCommentBlock := false

        if InCommentBlock
            continue

        if line.IsEmpty() OR line.StartsWith(";")
            continue

        ;TODO: find prototypes: String.Prototype.DefineProp("LastIndexOf", {Call: StringLastIndexOf})

        ; This RegExMatch pattern will find and capture the function name: ".*?(\w+)\("
        ;   .*?     : This is a non-greedy match for any character (.) zero or more times (*?).
        ;               It will match as few chars as possible from the beginning of the string until the next part of the pattern can be satisfied.
        ;               This is useful for skipping over things like if or leading whitespace.
        ;   (\w+)   : This is the capturing group.
        ;               It matches one or more "word" characters (letters, numbers, and underscores).
        ;               This will capture the function name (e.g., DirExist).
        ;   \(      : This matches the literal opening parenthesis that immediately follows the function name, 
        ;               confirming it's a function call.
        RegExMatch(line, ".*?(\w+)\(", &match)

        if !IsObject(match)
            continue

        functionName := match[1]

        ;static excludedFunctionNames := "for, if, MsgBox, while"
        static excludedFunctionNames := "MsgBox"

        if excludedFunctionNames.Contains(functionName)
            continue

        ;If next line > end of Array then Break
        if (ScriptLineNumber + 1) > ScriptTextArray.Length
            break

        ;If next line starts with { then add { to this line and clear next line
        if ScriptTextArray[ScriptLineNumber + 1].StartsWith("{") {
            ScriptTextArray[ScriptLineNumber] .= "{"
            ScriptTextArray[ScriptLineNumber + 1] := ""        
        }

        ;save the function, script name, and line number
        FunctionCSV .= functionName ", " LibScriptFile ", " ScriptLineNumber

        ; Preset counters
        FunctionLineCount := 1
        BraceCount := 0

    ;MsgBox "Script: " OutName "`n`nFunctionName:`n`n" functionName "`n`nlineNumber: " ScriptLineNumber "`n`nInCommentBlock: " InCommentBlock, "Loop 1"


        ; If this line contains { then Count braces
        if ScriptTextArray[ScriptLineNumber].Contains("{") {

    ;MsgBox "Script: " OutName "`n`nCounting Braces.", "Loop 1"

            Loop {

                line := ScriptTextArray[ScriptLineNumber]

                if line.Contains("}") and line.Contains("{") {
                    BraceCount += 0
                } else if line.Contains("{") {
                    BraceCount += 1
                } else if line.Contains("}") {
                    BraceCount -= 1
                }

    ;MsgBox "Script: " OutName "`n`nScriptLineNumber: " ScriptLineNumber "`n`nBraceCount: " BraceCount , "Loop 1"

                if (BraceCount = 0)
                    break ; 2
                
                FunctionLineCount++

                ScriptLineNumber++
                
                if ScriptLineNumber > ScriptTextArray.Length
                    break ; 2
            }

        }

    ;MsgBox "Script: " OutName "`n`nScriptLineNumber: " ScriptLineNumber "`n`FunctionLineCount: " FunctionLineCount, "Loop 1"

        ; ?ScriptLineNumber--

        ;If BraceCount is zero then add function line count 1, else add function line count to the FunctionCSV
        ; if (BraceCount = 0)
        ;     FunctionCSV .= ", " 1 "`n"
        ; else
            FunctionCSV .= ", " FunctionLineCount "`n"

    } ; end loop

    return FunctionCSV
}

GetFunctionLineCount(Buffer, FunctionName, LineNumber) {

;TODO: Buffer[] needs to be an Array so we can step through it to count function lines

    ;MsgBox "FunctionName: " FunctionName ", LineNumber: " LineNumber, "GetFunctionLineCount"

    FunctionLineCount := BraceCount := 0

    Loop Parse Buffer, "`n" {

    ;     split := StrSplit(A_LoopField, ",")

    ; MsgBox "split[3]: " split[3], "Loop"

        ; if split.Length >= 4
        ;     lineNumber := split[3]
        ; else
        ;     continue


        if A_Index != lineNumber
            continue

        ; Found Function in Buffer, now count braces
        line := A_LoopField.Trim()

        Loop {

            FunctionLineCount := 0
        
        ;MsgBox "line: " line "`n`nlineNumber: " lineNumber, "Loop"

        ;MsgBox "lineNumber: " lineNumber, "Loop"

            if line.Contains("}") and line.Contains("{") {
                BraceCount += 0
            } else if line.Contains("{") {
                BraceCount += 1
            } else if line.Contains("}") {
                BraceCount -= 1
            }

            if (BraceCount = 0) {
                break
            }

            if (BraceCount > 0)
                FunctionLineCount++

        }
    }

    MsgBox "FunctionName: " FunctionName "`n`nBraceCount: " BraceCount "`n`nFunctionLineCount: " FunctionLineCount "`n`n", "Loop"

    return FunctionLineCount
}

; Search Main Script for #Includes, return CSV of file names
;--------------------------------------------------------------
GetIncludeFiles(LibScriptFile) {

   Buffer := FileRead(LibScriptFile)

   Output := ""

   loop parse Buffer, "`n", "`r`n" {

        line := A_LoopField.Trim()

        if line.StartsWith("#Include") {
; MsgBox line        
            found := FindInLibrary(line)

            if !found.IsEmpty()
                Output .= found ","
        }
    }
; MsgBox Output
; MsgBox LibScriptFile ", " Output := Output.IsEmpty() ? "No Includes Found" : Output
   return Output.RTrim(",")
}

GetIncludeFilesRecurse(LibScriptFile) {

;MsgBox LibScriptFile, "GetIncludeFilesRecurse"

   static Output := ""

   Buffer := FileRead(LibScriptFile)

   if Buffer.Contains("#Include") {

        Output .= LibScriptFile "," "`n"

        loop parse Buffer, "`n", "`r`n" {

            line := A_LoopField.Trim()

            if line.StartsWith("#Include") {

                includeFile := FindInLibrary(line)

                if !includeFile.IsEmpty() {

                    if !InStr(Output, includeFile)
                        GetIncludeFilesRecurse(includeFile)

                }
            }
        }
    }
   return Output.RTrim(",`n")
}

RemoveComment(Haystack) {
    ; AutoHotkey sees comments as a semicolon preceded by a space or tab
    Needle := "[ `t]+;.*"
    Return RegExReplace(Haystack, Needle)
}

;SubStrExtract
;SubStrSeg

; SubStrExtract(Text, StartChar, EndChar) {
;     StartPos := InStr(Text, StartChar) + 1
;     EndPos := InStr(Text, EndChar)
;     Length := EndPos - StartPos
;     return SubStr(Text, StartPos, Length)
; }

FindInLibrary(IncludeLine) {

	;Input: "C:\Users\Jim\Documents\AutoHotkey\Lib\AHKLX_LIB_TEST.ahk"
	if FileExist(IncludeLine)
		Return IncludeLine
		
	if Not IncludeLine.StartsWith("#")
		Return ""
	
    ; remove any inline comment
	;IncludeLine := RemoveComment(IncludeLine)
	
	if IncludeLine.Contains(">") {	
        ;RegExMatch(IncludeLine, "<(.+?)>", &Match)
        ;fname := Match.1
        fname := IncludeLine.Match("<(.+?)>")
        fname := fname.IsEmpty() ? "" : fname.Trim()

;MsgBox "Match.1: " Match.1

	} else {
        split := StrSplit(IncludeLine, " ")
        fname := split.Length >= 2 ? split[2].Trim() : ""

;MsgBox "IncludeLine: " IncludeLine "`n`nsplit1: " split[1] "`n`nsplit2: " split[2] "`n`nfname: " fname

}

    if !IsSet(fname) OR fname.IsEmpty()
        return

    fname := fname.EndsWith(".ahk") ? fname : fname ".ahk"

;MsgBox "fname: " fname

	;regread, ahkpath, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\AutoHotkey.exe

	loclib := A_ScriptDir   "\Lib\"             fname
	usrlib := A_MyDocuments "\AutoHotkey\Lib\"  fname
	stdlib := Ahkpath       "\Lib\"             fname
	nolib  := A_ScriptDir   "\"                 fname

	libraries := loclib "," usrlib "," stdlib ","  nolib

;MsgBox "libraries:`n`n" libraries

	;libfile := "ERROR_LOCATING: " fname
	libfile := ""

	Loop Parse libraries, "CSV"
	{
 ;       MsgBox "A_LoopField: " A_LoopField

		if (FileExist(A_LoopField)) {
			libfile := A_LoopField
			Break		
		}
	}

    return FileExist(libfile) ? libfile : ""
}