;ABOUT: AhkMerge v0.0.0.0

;TODO:
;   FunctionsCSV.Txt
;       Exclude everything inside a class e.g. class Debug {}
;   [x] Exclude comments
;       also from #Include files
;   [Combine] [Merge] [Cancel]
;       Select ahk, press combine, choose multi files, combine, save as ahk_Combined.ahk

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <String_Functions>
#Include <Debug>
#Include <String>
#Include <IniLite>

;DEBUG
Escape::ExitApp()
if FileExist("DEBUG_MainScriptText.txt")
    FileDelete("DEBUG_MainScriptText.txt")
if FileExist("DEBUG_ReadInclude.txt")
    FileDelete("DEBUG_ReadInclude.txt")
if FileExist("DEBUG_FunctionsCSV.txt")
    FileDelete("DEBUG_FunctionsCSV.txt")


; #region Globals

global AhkPath          := "C:\Program Files\AutoHotkey"
global MainScriptPath    := "D:\Software\DEV\Work\AHK2\Projects\AhkMerge\MergeTestScript.ahk"

global INI := IniLite()

global IncludedFiles := ""
global MergedScript := ""

; #regin Initialize Ini

SelectedFile := INI.ReadSettings("SelectedFile")

if SelectedFile.IsEmpty() OR Not FileExist(SelectedFile) {
    SelectedFile := MainScriptPath
    INI.WriteSettings("SelectedFile", SelectedFile)
}

; #region Create Gui

myGui := Gui()
myGui.Title := "AhkMerge v1.0"
MyGui.BackColor := "4682B4" ; Steel Blue

MyGui.SetFont("S12 cWhite", "Segouie UI")
myGui.AddText("xm ym", "Select a file:")

MyGui.SetFont("S10 cDefault", "Consolas")
ScriptEdit := myGui.AddEdit("xm y+5 w600", SelectedFile)

MyGui.SetFont("S9 cWhite", "Segoe UI")
myGui.AddButton("x+8 yp w75", "Browse").OnEvent("Click", SelectFile)

MyGui.SetFont("S10 cWhite", "Segoe UI")
MyCheckBoxExcludeComments := 
    myGui.AddCheckbox("xm w350 Section", "Exclude Comments")
MyCheckBoxExcludeHeaders :=
    myGui.AddCheckbox("xm w350", "Exclude Headers")
MyCheckBoxExcludeUnusedClassesAndFunctions :=
    myGui.AddCheckbox("xm w350 Checked", "Exclude Unused Classes and Functions")

MyGui.SetFont("S09", "Segoe UI")
myGui.AddText("xm w510 h0 Hidden", "Hidden Filler")

myGui.AddButton("ys w75 Section Default", "Merge").OnEvent("Click", Button_Click)

myGui.AddButton("yp w75", "Help") ;.OnEvent("Click", (*) => ExitApp())

myGui.AddButton("xs w75", "Combine") ;.OnEvent("Click", (*) => ExitApp())

myGui.AddButton("yp w75", "Cancel").OnEvent("Click", (*) => ExitApp())

MyCheckBoxExcludeHeaders.OnEvent("Click", CheckBox_Change)

myGui.Show()

ControlFocus("Cancel", MyGui)

;OK DEBUG Test Str_Functions
;var := "The rain in [Spain] stays mainly in the plain."
; MsgBox IsEmpty(var), "Should be 0=False"
;newvar := SubStrExtract(var, '[', ']'), "[Spain]"
;MsgBox SubStrExtract(var, '[', ']'), "[Spain]"

; text := "test " ';' " comment"
; text := "test comment"
; result := Trim(StrSplit(text, ";")[1])
; Debug.MBox result


; #region Functions

CheckBox_Change(Ctrl, Info) {
    if MyCheckBoxExcludeHeaders.Value
        MyCheckBoxExcludeComments.Value := true
    else
        MyCheckBoxExcludeComments.Value := false
}

SelectFile(Ctrl, Info) {
    selectedFile := FileSelect(, ScriptEdit.Text)

    if NOT selectedFile.IsEmpty() {
        ScriptEdit.Text := selectedFile
        INI.WriteSettings("SelectedFile", selectedFile.Trim())
    } else {
        SoundBeep
    }
}

Button_Click(Ctrl, Info) {
      
    SelectedFile := ScriptEdit.Text.Trim()

    ; If user copied as path, then paste (includes double quotes)
    if SelectedFile.Contains('"') {
        SelectedFile := SelectedFile.Replace('"', '')
        ScriptEdit.Text := SelectedFile
    }

    ; if valide, update settings
    if FileExist(SelectedFile) {
        INI.WriteSettings("SelectedFile", SelectedFile)
    } else {
        SoundBeep
        return
    }

    ;DEBUG
    if FileExist("FunctionsCSV.txt")
        FileDelete("FunctionsCSV.txt")

    ; Merge the include files
    MergedScript := MergeScript.Includes(SelectedFile)

;Debug.FileWrite(MergedScript, , true)  ; Default is .\Debug.txt

    outFile := SelectedFile.SplitPath().nameNoExt "_Merged.ahk"
    if FileExist(outfile)
        FileDelete(outfile)
    FileAppend(MergedScript, outfile)

;Debug.MBox(outFile)

    ;DEBUG
    Run("notepad " outfile)

    ;MsgBox("Done!", "Status", "icon?")

    outFile := FileSelect(PromptOverwrite:=16, ScriptEdit.Text.Replace(".ahk", "_Merged.ahk"))

    if outFile.IsEmpty()
        return

    FileDelete(outFile)
    FileAppend(MergedScript, outFile)


}

class MergeScript {

    static IncludedFiles := ""
    static MergedScript := ""
    static dividerLine := ";" "=".Repeat(100)

    ; array or csv or map?
    ; Merge files, optionally comment out all #Includes
    static Files(ScriptFilesArray, CommentOutIncludes := True) {
        this.MergedScriptFiles := ""
        return this.MergedScriptFiles
    }

    ; Merge files, optionally comment out all #Includes
    static Includes(ScriptFile) {

        if !FileExist(ScriptFile)
            return
            
        this.MainScriptFile := ScriptFile
        ;this.MainScriptText := this._ReadInclude(ScriptFile)
        this.MainScriptText := FileRead(ScriptFile)

        Debug.FileWrite(this.MainScriptText, "DEBUG_MainScriptText.txt", True)

        ; Initialize variables used in the Recursive Function
        this.IncludedFiles := ""
        this.MergedScript := ""

        ; Recursively get all #Include files in the script file and their includes
        this.IncludedFiles := this._GetIncludes(ScriptFile).RTrim(",")

        Debug.FileWrite(this.IncludedFiles, "DEBUG_IncludedFiles.txt", True)

        ; Add a pretty header
        buffer := ""

        buffer .= this._GetHeader(ScriptFile.Replace(".ahk", "_Merged.ahk"))
       
        ; Add all of the #Include files to the Header
        split := StrSplit(this.IncludedFiles, ",")
        for file in split            
            buffer .= ";" file . "`n"
        buffer .=  ";" ScriptFile "`n"

        buffer .= this.dividerLine . "`n"

        if MyCheckBoxExcludeHeaders.Value
            buffer := ""

        this.MergedScript .= buffer

        ;Debug.MBox this.MergedScript

        ; Add all of the #Include files to the MergedScript
        this.MergedScript .= this._MergeIncludes(ScriptFile, this.IncludedFiles)

        ;Debug.MBox this.MergedScript

        ; Add the script to the MergedScript
        this.MergedScript .= this._GetHeader(ScriptFile)

        ; With or without headers, comment, and unused functions?
        this.MergedScript .= this._ReadInclude(ScriptFile)

        ;Remove multiple blank lines
        CleanScript := RegExReplace(this.MergedScript, "\R{3,}", "`n`n")

        ;Remove blank lines from the end of the script (will leave one blank line at the end)
        CleanScript := RegExReplace(CleanScript, "\R+$", "")

        return CleanScript
    }

    static _AppendLine(Line) {
        this.MergedScript .= Line . "`n"
    }

    static _MergeIncludes(ScriptFile, IncludedFiles) {

        buffer := ""

        split := StrSplit(IncludedFiles, ",")

        for includeFile in split {

            buffer .= this._GetHeader(includeFile)

;            ExcludeUnused :=MyCheckBoxExcludeUnusedClassesAndFunctions.Value

            if MyCheckBoxExcludeUnusedClassesAndFunctions.Value {

                functionsCSV := ScanLibScript(includeFile)
;functionsCSV := GetFunctions(includeFile)

                ;Debug.ListVar(functionsCSV,,,'[]')
                Debug.FileWriteLine(FunctionsCSV, "DEBUG_FunctionsCSV.txt", False)

                ; Read the function from the Include file, if its in the ScriptFile
                ; Else return ""
                Loop Parse FunctionsCSV, "`n", "`r`n" {
                    ;TODO: Choose one:
                     FunctionCSVLine := A_LoopField.Trim()
                     buffer .= this._ReadFunction(ScriptFile, FunctionCSVLine)
                    ;buffer .= this._ReadFunction(ScriptFile, A_LoopField)
                }

            } else {

                Debug.FileWrite(this._ReadInclude(includeFile),"DEBUG_ReadInclude.txt", False)

                ; Merge the entire Include file
                buffer .= this._ReadInclude(includeFile)
             }

        }

        return buffer

    }

    static _GetHeader(ScriptFile) {

        header := this.dividerLine . "`n"
        header .= ";" ScriptFile . "`n"
        header .= this.dividerLine . "`n"

        if MyCheckBoxExcludeHeaders.Value
            header := ""

        return header
    }
    
    static _ReadInclude(ScriptFile) {

        if ScriptFile.IsEmpty()
            return

        ScriptText := FileRead(ScriptFile)

        ;ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

        IgnoreToEnd := False

        InCommentBlock := False

        textBuffer := ""

        Loop Parse ScriptText, "`n", "`r`n"{

            if IgnoreToEnd
                continue

            line        := A_LoopField
            lineTrim    := A_LoopField.Trim()

            if lineTrim.StartsWith("/*")
                InCommentBlock := true

            if lineTrim.StartsWith("*/") {
                InCommentBlock := false
                continue
            }

            if InCommentBlock
                continue

            ; Avoid multiple #Requires
            if lineTrim.StartsWith("#Requires AutoHotkey")
                line := ";" line "`n"

            ; Avoid multiple #Include of the same file
            if lineTrim.StartsWith("#Include") {
                line := ";" line "`n"
            }

            ; Exclude test functions at bottom of script
            if lineTrim.StartsWith("If (A_LineFile == A_ScriptFullPath)") {
                IgnoreToEnd := True
                continue
            }

            ; if CheckBox Exclude Comments is checked
            if (lineTrim.StartsWith(";") AND MyCheckBoxExcludeComments.Value)
                continue

            ; if CheckBox Exclude Comments is checked, remove inline comment
            if MyCheckBoxExcludeComments.Value {
                static needle := A_Space . ";"
                if lineTrim.Contains(needle)
                    line := StrSplit(line, needle)[1].Trim()
            }

            textBuffer .= line "`n"
        }
        return textBuffer
    }

    static _GetIncludes(ScriptFile) {

        if ScriptFile.IsEmpty()
            return

        ScriptText := FileRead(ScriptFile)

        ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

        Loop ScriptTextArray.Length {

            line := ScriptTextArray[A_Index]

            if line.StartsWith("#Include") {

                includeFile := this._FindInLibrary(line)

                if (NOT includeFile.IsEmpty()) AND (NOT this.IncludedFiles.Contains(includeFile)) {
                    this.IncludedFiles .= includeFile ","
                    this._GetIncludes(includeFile)
                }
            }
        }

        ;Remove multiple blank lines
        ;CleanScript := RegExReplace(this.MergedScript, "\R{3,}", "`n`n")

        ;Remove blank lines from the end of the script (will leave one blank line at the end)
        ;CleanScript := RegExReplace(CleanScript, "\R+$", "")

        return this.IncludedFiles
    }

    static _ReadFunction(ScriptFile, IncludeLine) {

        ;Debug.MBox "[" FunctionsCSV "]", "ReadFunction"

        split := IncludeLine.Split(",")

        if split.Length < 4 {
            return ""
        }
    
        ; ok Debug.ListVar split

        functionName := split[1].Trim()
        includeFile := split[2].Trim()
        lineNumber := split[3].Trim()
        lineCount := split[4].Trim()

        ; Debug.WriteLine("ScriptFile: " ScriptFile "`n" .
        ;     'includeFile: ' includeFile  "`n" .
        ;     'function: ' functionName  "`n" .
        ;     'lineNumber: ' lineNumber "`n" . 
        ;     'lineCount: ' lineCount)

        ; search for String in #Include <String> works, but;
        ; should search for #Include ... String because it could be ./Lib/String.ahk etc.
        ;StartsWith := (functionName.Compare("#Include")=0) ? includeFile.SplitPath().nameNoExt : ""
        if (functionName.Compare("#Include")=0) {
            StartsWith := functionName
            functionName := includeFile.SplitPath().nameNoExt
        } else {
            StartsWith := ""
        }
        

        if NOT this._FindIn(this.MainScriptText, StartsWith, functionName)
            return

        ScriptText := FileRead(includeFile)

        ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

        functionText := ""

        Loop ScriptTextArray.Length {

            if A_Index != lineNumber
                continue

            ;Debug.MBox A_Index ", " lineNumber

            index := A_Index

            Loop lineCount {
                functionText .= ScriptTextArray[index] . "`n"
                index++
                if index >= ScriptTextArray.Length
                    break
            }

            break
        }

        ;Debug.WriteLine('functionText: ' functionText)

        return functionText            ;Debug.MBox "[" line "]" "`n`n" "[" split[1] "]" "`n`n" "[" split[2] "]" "`n`n" "[" split[3] "]" "`n`n" "[" split[4] "]", "ReadFunction"
        
    }

    static _FindIn(ScriptText, StartsWith, FunctionName) {
        ; Search the entire file including comments

        found := false

        ;InCommentBlock := false
        ;debugCount := 0

        Loop Parse ScriptText, "`n", "`r`n" {

            ;debugCount++

            line := A_LoopField.Trim()

            ;if line.IsEmpty() OR line.StartsWith(";")
            ;    continue

            ; if line.StartsWith("/*")
            ;     InCommentBlock := true
            ; else if line.StartsWith("*/")
            ;     InCommentBlock := false

            ; if InCommentBlock
            ;     continue

            ; if StartsWith.Contains("#Include")
            ;  if FunctionName.Contains("ScanLibScript")
            ;      Debug.MBox("StartsWith: " StartsWith "`n`nFunctionName: " FunctionName, "FindIn")

            if line.StartsWith(StartsWith) AND line.Contains(FunctionName) {
                found := true
                 ;Debug.MBox("debugCount: " debugCount "`n`nFunctionName: " FunctionName, "FindIn")
                break
            }

        }
        ;Debug.MBox("debugCount: " debugCount "`n`nFunctionName: " FunctionName, "FindIn")

        return found
    }
    static _FindInLibrary(IncludeLine) {

        if FileExist(IncludeLine)
            Return IncludeLine
            
        if Not IncludeLine.StartsWith("#")
            Return ""
                
        if IncludeLine.Contains(">") {	
            fname := IncludeLine.Match("<(.+?)>")
            fname := fname.IsEmpty() ? "" : fname.Trim()
        } else {
            split := StrSplit(IncludeLine, " ")
            fname := split.Length >= 2 ? split[2].Trim() : ""
        }

        if !IsSet(fname) OR fname.IsEmpty()
            return

        fname := fname.EndsWith(".ahk") ? fname : fname ".ahk"

        loclib := A_ScriptDir   "\Lib\"             fname
        usrlib := A_MyDocuments "\AutoHotkey\Lib\"  fname
        stdlib := Ahkpath       "\Lib\"             fname

        libraries := loclib "," usrlib "," stdlib

        libfile := ""

        Loop Parse libraries, "CSV"
        {
            if (FileExist(A_LoopField)) {
                libfile := A_LoopField
                Break		
            }
        }
        return FileExist(libfile) ? libfile : ""
    }
}

; Purpose:  Find Functions to include in the MainScriptFile.
; Return:   CSV file of functionName, LibScriptFile, ScriptLineNumber, FunctionLineCount.
;----------------------------------------------------------------------------------------
ScanLibScript(LibScriptFile) {

    FunctionCSV := ""

    ScriptText := FileRead(LibScriptFile)

    ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

    ClassBlockStart := false
    InClassBlock := false
    InCommentBlock := false
    ScriptLineNumber := 0
    IgnoreToEnd := False

    Loop {
   
        if IgnoreToEnd
            break

        ScriptLineNumber++

        if ScriptLineNumber > ScriptTextArray.Length
            break

        functionName := ""

        ;remove leading whitespace
        line := ScriptTextArray[ScriptLineNumber].LTrim()

        if line.StartsWith("/*")
            InCommentBlock := true
        else if line.StartsWith("*/")
            InCommentBlock := false

        if InCommentBlock
            continue

        if line.IsEmpty() OR line.StartsWith(";")
            continue

        ; Exclude test functions at bottom of script
        if line.StartsWith("If (A_LineFile == A_ScriptFullPath)") {
            IgnoreToEnd := True
            continue
        }

        if line.StartsWith("class") {

            ClassBlockStart := true

            ;match the second word
            ;functionName := line.Match("^\s*\S+\s+(\S+)")

            ; if class search for the name of the class e.g. class Debug {, Debug.ahk
            ;functionName := LibScriptFile.SplitPath().NameNoExt
            functionName := "#Include"

            ;Debug.MBox("LibScriptFile: " LibScriptFile "`n`nfunctionName: " functionName)


            ;OutputDebug("class: " line ", name: " r)

        }

        if functionName.IsEmpty() {
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

            ;Debug.WriteLine("functionName: " functionName)
            ;Debug.MBox("functionName: " functionName)

        }

        ; if still empty we didn't detect a function name in this line, continue
        if functionName.IsEmpty()
            continue

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

        ;if not in class block, save the function, script name, and line number
        if FunctionCSV.Contains(functionName)
            continue

        if NOT InClassBlock
            FunctionCSV .= functionName ", " LibScriptFile ", " ScriptLineNumber

        if ClassBlockStart
            InClassBlock := true

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

                if (BraceCount = 0) {
                    ;DEBUG THIS ISN'T USED, REMOVE
                    if InClassBlock
                        InClassBlock := false
                    break
                }
                
                FunctionLineCount++

                ScriptLineNumber++
                
                if ScriptLineNumber > ScriptTextArray.Length
                    break ; 2
            }

        }

        FunctionCSV .= ", " FunctionLineCount "`n"

    } ; end loop

    ;Debug.ListVar FunctionCSV

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
