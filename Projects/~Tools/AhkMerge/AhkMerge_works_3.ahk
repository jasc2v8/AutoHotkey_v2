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
#Include <ScanLibScript>

;DEBUG
Escape::ExitApp()

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
myGui.AddButton("ys w75 Default", "Merge").OnEvent("Click", Button_Click)
myGui.AddButton("yp w75", "Cancel").OnEvent("Click", (*) => ExitApp())

MyCheckBoxExcludeHeaders.OnEvent("Click", CheckBox_Change)

myGui.Show()

ControlFocus("Cancel", MyGui)

;OK DEBUG Test Str_Functions
;var := "The rain in [Spain] stays mainly in the plain."
; MsgBox IsEmpty(var), "Should be 0=False"
; MsgBox SubStrExtract(var, '[', ']'), "[Spain]"
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

class ScanScript {

    static Includes() {

    }

    static _GetIncludedFilesRecurse(LibScriptFile) {

        ; global Output
        ;MsgBox LibScriptFile, "GetIncludedFilesRecurse"

        static Output := ""

        Buffer := FileRead(LibScriptFile)

        if Buffer.Contains("#Include") {

        ;MsgBox "Buffer contains #Include:`n`n" LibScriptFile, "GetIncludedFilesRecurse"

                Output .= LibScriptFile "," ; "`n"

                loop parse Buffer, "`n", "`r`n" {

                    line := A_LoopField.Trim()

                    if line.StartsWith("#Include") {

        ;MsgBox "Buffer contains #Include: " LibScriptFile "`n`nLine: " line, "GetIncludedFilesRecurse"

                        includeFile := this._FindInLibrary(line)

        ;MsgBox  "Line: " line "`n`nInclude File: " includeFile, "GetIncludedFilesRecurse"

                        if !includeFile.IsEmpty() {

                            Output .= includeFile "," ;"`n"

        ;MsgBox "Output: " Output, "GetIncludedFilesRecurse"

                            if !InStr(Output, includeFile)
                                this._GetIncludedFilesRecurse(includeFile)

                        }
                    }
                }
            }

        MsgBox "Output: " Output, "GetIncludedFilesRecurse"

        return Output.RTrim(",`n")
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
        this.MainScriptText := this._ReadInclude(ScriptFile)

        ;Debug.FileWrite(this.MainScriptText, "MainScriptText.txt", True)

        ; Initialize variables used in the Recursive Function
        this.IncludedFiles := ""
        this.MergedScript := ""

        ; Recursively get all #Include files in the script file and their includes
        this.IncludedFiles := this._GetIncludes(ScriptFile).RTrim(",")

        ; Add a pretty header
        buffer := ""

        buffer .= this._GetHeader(ScriptFile.Replace(".ahk", "_Merged.ahk"))
    
        ; Add all of the #Include files to the Header
        split := StrSplit(this.IncludedFiles, ",")
        for file in split            
            buffer .= ";" file . "`n"
        buffer .=  ";" ScriptFile "`n"

        if MyCheckBoxExcludeHeaders.Value
            buffer := ""

        this.MergedScript .= buffer

        ;Debug.MBox this.MergedScript

        ; Add all of the #Include files to the MergedScript
        this.MergedScript .= this._MergeIncludes(ScriptFile, this.IncludedFiles)

        ;Debug.MBox this.MergedScript

        ; Add the main script to the MergedScript
        this.MergedScript .= this._GetHeader(ScriptFile)
        this.MergedScript .= this._ReadInclude(ScriptFile)
        ;this.MergedScript .= ";DEBUG: MAIN SCRIPT GOES HERE"

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

            ; DEBUG this will add a header even if there is no function in the file
            buffer .= this._GetHeader(includeFile)

            if MyCheckBoxExcludeUnusedClassesAndFunctions.Value {

                functionsCSV := ScanLibScript(includeFile)

                ;Debug.ListVar(functionsCSV,,,'[]')
                Debug.FileWriteLine(FunctionsCSV, "FunctionsCSV.txt", False)

                ; Read the function from the Include file, if its in the ScriptFile
                ; Else return ""
                Loop Parse FunctionsCSV, "`n", "`r`n" {
                    includeLine := A_LoopField.Trim()
                    buffer .= this._ReadFunction(ScriptFile, includeLine)
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
            if (Trim(line).StartsWith(";") AND MyCheckBoxExcludeComments.Value)
                continue

            ; if CheckBox Exclude Comments is checked, remove inline comment
            if MyCheckBoxExcludeComments.Value {
                static needle := A_Space . ";"
                if Trim(line).Contains(needle)
                    line := Trim(StrSplit(line, needle)[1])
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
        ;     'function: ' function  "`n" .
        ;     'lineNumber: ' lineNumber "`n" . 
        ;     'lineCount: ' lineCount)

        if NOT this._FindIn(this.MainScriptText, functionName)
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

        Debug.WriteLine('functionText: ' functionText)

        return functionText            ;Debug.MBox "[" line "]" "`n`n" "[" split[1] "]" "`n`n" "[" split[2] "]" "`n`n" "[" split[3] "]" "`n`n" "[" split[4] "]", "ReadFunction"
        
    }

    static _FindIn(ScriptText, FunctionName) {

        found := false
        InCommentBlock := false
        Loop Parse ScriptText, "`n", "`r`n" {

            line := A_LoopField.Trim()

            if line.IsEmpty() OR line.StartsWith(";")
                continue

            if line.StartsWith("/*")
                InCommentBlock := true
            else if line.StartsWith("*/")
                InCommentBlock := false

            if InCommentBlock
                continue

            if line.Contains(FunctionName) {
                found := true
                break
            }
        }
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