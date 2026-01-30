;ABOUT: AhkMerge v0.0.0.104

/*
    TODO:

    Not including the last } in RunShell and others

    Move INI to RegSettings
    
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <ObjView>

#Include ScanScriptToCSV.ahk
#Include ScanScriptToMap.ahk

#Include <StringLib>
#Include <Debug>
#Include <IniFile>
#Include <Colors>

try TraySetIcon("shell32.dll", 297)

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
global MainScriptPath    := A_ScriptFullPath
global IncludedFiles := ""
global MergedScript := ""

INI_PATH := Str.JoinPath(A_Temp, "AhkApps", Str.Replace(A_ScriptName, ".ahk", ".ini"))
global INI := IniFile(INI_PATH)

; #region Initialize INI

SelectedFile := INI.ReadSettings("SelectedFile")

if Str.IsEmpty(SelectedFile) OR Not FileExist(SelectedFile) {
    SelectedFile := MainScriptPath
}

; #region Create Gui

myGui := Gui()
myGui.Title := "AhkMerge v1.0"
MyGui.BackColor := Colors.AirSuperiorityBlue

MyGui.SetFont("S12", "Segouie UI")
myGui.AddText("xm ym", "Select a file:")

MyGui.SetFont("S10 cDefault", "Consolas")
ScriptEdit := myGui.AddEdit("xm y+5 w600", SelectedFile)

MyGui.SetFont("S9", "Segoe UI")
myGui.AddButton("x+8 yp w75", "Browse").OnEvent("Click", SelectFile)

MyGui.SetFont("S10", "Segoe UI")
MyCheckBoxExcludeComments := 
    myGui.AddCheckbox("xm w350 Section", "Exclude Comments")
MyCheckBoxExcludeHeaders :=
    myGui.AddCheckbox("xm w350", "Exclude Headers")
MyCheckBoxExcludeUnusedClassesAndFunctions :=
    myGui.AddCheckbox("xm w350 Checked", "Exclude Unused Classes and Functions")

MyGui.SetFont("S09", "Segoe UI")
myGui.AddButton("x540 ys w75 Section Default", "Merge").OnEvent("Click", ButtonMerge_Click)
myGui.AddButton("yp w75", "Help").OnEvent("Click", (*) => ButtonHelp_Click())
myGui.AddButton("xs w75", "Combine").OnEvent("Click", (*) => ButtonCombine_Click())
myGui.AddButton("yp w75", "Cancel").OnEvent("Click", (*) => ExitApp())
myGui.AddText("xm w1 h1 Hidden", "Hidden Spacer")

MyCheckBoxExcludeHeaders.OnEvent("Click", CheckBox_Change)

myGui.Show()

ControlFocus("Cancel", MyGui)

;OK DEBUG Test Str._Functions
;var := "The rain in [Spain] stays mainly in the plain."
; MsgBox Str.IsEmpty(var), "Should be 0=False"
;newvar := SubStr.Extract(var, '[', ']'), "[Spain]"
;MsgBox SubStr.Extract(var, '[', ']'), "[Spain]"

; text := "test " ';' " comment"
; text := "test comment"
; result := Trim(Str.Split(text, ";")[1])
; ;Debug.MBox result

; #region Functions

ButtonCombine_Click() {

    selectedFiles := FileSelect(Multi:="M3", A_ScriptDir, "Select File(s) to Combine.","Ahk Script Files (*.ahk)")

    if selectedFiles.Length >0 {
        text := "1: " A_ScriptName . "`n`n"
        for k, v in selectedFiles
             text .= k+1 ": " Str.SplitPath(v).nameNoExt "`n`n"
        r := MsgBox("Files to Combine:`n`n" text, "ButtonCombine_Click", "YesNo Icon?")
        if (r="No")
            return

        textBuffer := ""
        for file in selectedFiles
            textBuffer .= FileRead(file)

        outFile :=FileSelect(OverWrite:=16,,"Save As...","Ahk Script Files (*.ahk)")
        if Str.IsEmpty(outFile)
            return

        if NOT outFile.EndsWith(".ahk")
            outFile .= ".ahk"

        FileAppend(textBuffer, outFile)        

    }
}

CheckBox_Change(Ctrl, Info) {
    if MyCheckBoxExcludeHeaders.Value
        MyCheckBoxExcludeComments.Value := true
    else
        MyCheckBoxExcludeComments.Value := false
}

SelectFile(Ctrl, Info) {
    selectedFile := FileSelect(, ScriptEdit.Text,,"Ahk Script Files (*.ahk)")

    if NOT Str.IsEmpty(selectedFile) {
        ScriptEdit.Text := selectedFile
        INI.WriteSettings("SelectedFile", Trim(selectedFile))
    } else {
        SoundBeep
    }
}

;
;
;   #region CLICK
;
;

ButtonMerge_Click(Ctrl, Info) {

    ; Get the main script file path
    MainScriptPath := Trim(ScriptEdit.Text)

    ; if not exist then return
    if !FileExist(MainScriptPath) {
        SoundBeep
        return
    }

    ; Read the script
    MainScript := FileRead(MainScriptPath)

    ; Map the main script
    MainScriptMap := ScanScriptToMap(MainScript, MainScriptPath)

    ;ObjView("MainScriptMap", MainScriptMap )

    ; Get Include files
    IncludeFileArray := GetIncludeFileArray(MainScript)

    ;ObjView("IncludeFileArray", IncludeFileArray )

    ; Map the Include files
    IncludeMap := GetIncludeMap(IncludeFileArray)

    ;ObjView("IncludeMap", IncludeMap )

    ; Merge the maps into a merged script
    MergedIncludes := MergeScript(MainScriptMap, IncludeMap, &ObjectsArray)

    SaveMergedScript(MainScriptPath, ObjectsArray, MergedIncludes, MainScript, IncludeComments:=true, IncludeHeaders:=true)

    ; Save the merged includes
    ; outFile := FileSelect(PromptOverwrite:=16, StrReplace(ScriptEdit.Text, ".ahk", "_Merged.ahk"))

    ; if Str.IsEmpty(outFile)
    ;     return

    ; FileDelete(outFile)
    ; FileAppend(MergedScript, outFile)

    ; ; Comment out any #Includes
    ; ;MainScript := FileRead(Trim(ScriptEdit.Text))
    ; MainScriptNoIncludes := Str.Replace(MainScript, "#Include", ";#Include")

    ; ; Append the main script after the Includes
    ; FileAppend(MainScriptNoIncludes, outFile)
}

SaveMergedScript(MainScriptPath, ObjectsArray, MergedIncludes, MainScript, IncludeComments, IncludeHeaders) {

    MergedScript := ""

    ; Select output filename
    outFile := FileSelect(PromptOverwrite:=16, StrReplace(ScriptEdit.Text, ".ahk", "_Merged.ahk"))

    ; Create the header line
    headerLine := ";" Str.Repeat("=", 100) "`n"

    ; Create the top header showing the output filename
    topHeader := headerLine "; #region 1. Merged: " outFile "`n" headerLine

    ; Add topHeader to merged script
    MergedScript := AddHeader(MergedScript, topHeader)

    ; Append instructions
    MergedScript := AddHeader(MergedScript, "; Included Scripts (Type_Name, LineNumber, LineCount, Path):`n")

    ; Append the included script file paths
    for value in ObjectsArray
        MergedScript := AddHeader(MergedScript, ";  " Str.RTrim(value, ",") "`n")

    MergedScript := AddHeader(MergedScript, headerLine)

    ; Append region for included scripts
    MergedScript := AddHeader(MergedScript, "; #region 2. Included Classes and Functions:`n" headerLine)

    ; Append the included script
    MergedScript .= MergedIncludes

    ; Append mainHeader
     MergedScript := AddHeader(MergedScript, headerLine "; #region 3. Main Script: " MainScriptPath "`n" headerLine)

    ; Comment out any #Includes
    MainScriptNoIncludes := Str.Replace(MainScript, "#Include", ";#Include")

    ; Append main script
    MergedScript .= MainScriptNoIncludes

    if MyCheckBoxExcludeComments.Value = true
        MergedScript := CleanScript(MergedScript)

    ; Save the merged script file
    FileDelete(outFile)
    FileAppend(MergedScript, outFile)

    ; ; Append the main script after the Includes
    ; FileAppend(MainScriptNoIncludes, outFile)
}

CleanScript(ScriptContent) {
    if (ScriptContent = "")
        return ""

    ; Remove block comments /* ... */
    ; The 's' option allows dot to match newlines
    ScriptContent := RegExReplace(ScriptContent, "s)/\*.*?\*/", "")

    ; Remove inline comments and full-line comments
    ; Matches a space/tab followed by a semicolon, or a semicolon at start of line
    ScriptContent := RegExReplace(ScriptContent, "m)(^\s*;.*|(?<=\s);.*)", "")

    ; Trim trailing whitespace from each line
    ScriptContent := RegExReplace(ScriptContent, "m)[ \t]+$", "")

    ; Remove extra blank lines (replaces 3+ newlines with 2)
    ScriptContent := RegExReplace(ScriptContent, "\R{3,}", "`r`n`r`n")

    ; Final trim for start and end of file
    return Trim(ScriptContent, "`r`n`t ")
}


AddHeader(MergedScript, NewHeader) {

    if MyCheckBoxExcludeHeaders.Value = true
        return MergedScript

    NewScript := MergedScript . NewHeader

    return NewScript
}
MergeScript(MainScriptMap, IncludeMap, &ObjectsArray) {

    ObjectsArray := Array()

    script := ""

    for key, value in IncludeMap {

        if Str.StartsWith(key, "Class") {
            script .= GetCode(IncludeMap[key])
            ObjectsArray.Push(key ',' value)
            continue			
        }
        
        if Str.StartsWith(key, "Function") and MainScriptMap.Has(key) {
        
            ;MsgBox key ":`n`n" value, "DEBUG MergeScript key, value"

            codeBlock .= GetCode(IncludeMap[key]) 
            
            ;MsgBox codeBlock, "DEBUG MergeScript"

            if !Str.IsEmpty(codeBlock) {
                script .= codeBlock
                ObjectsArray.Push(key ',' value)
            }
        } else { 

            continue
        }
    }

    return script
}

GetCode(IncludeCSV) {

    split := Str.Split(IncludeCSV, ",")

    ;key        := split[1]
    lineNumber := split[1]
    lineCount  := split[2]
    filePath   := split[3]

    script := FileRead(filePath)

    split := Str.Split(script, "`n")

    codeBlock := ""

    Loop lineCount {
        codeBlock .= split[A_Index + lineNumber - 1] "`n"
    }

    ;MsgBox codeBlock, "DEBUG codeBlock"

    return codeBlock

}

GetIncludeFileArray(ScriptText) {

    ; if !FileExist(ScriptFilePath)
    ; return

    ; ScriptText := FileRead(ScriptFilePath)

    combinedMap := Map()

    IncludeFilesList := GetIncludes(ScriptText)

    return StrSplit(IncludeFilesList, ",")
}

GetIncludeMap(IncludeFileArray) {

    static combinedMap := Map()

    for ScriptFilePath in IncludeFileArray {

        ;MsgBox "[" includeFile "]", "DEBUG"

        if !Str.IsEmpty(ScriptFilePath) {

            script := FileRead(ScriptFilePath)

            ;myMap := ScanScriptToMap(ScriptFilePath)
            ;ObjView("GetIncludeMap", myMap)

           combinedMap := _CombineMaps(combinedMap, ScanScriptToMap(script, ScriptFilePath))

           ;ObjView("GetIncludeMap: combinedMap", combinedMap)

        }
    }

    _CombineMaps(m1, m2) {
        newMap := m1.Clone()
        for key, value in m2
            newMap[key] := value
        return newMap
    }

    ;ObjView("GetIncludeMap: combinedMap", combinedMap)

    return combinedMap
}

GetIncludes(ScriptText) {

    ;if !FileExist(ScriptPath)        return

    IncludeFilesList := ""

    ;ScriptText := FileRead(ScriptPath)

    Loop Parse ScriptText, "`n", "`r`n" {

        if Str.StartsWith(A_LoopField, "#Include") {
    
            includeFile := FindInLibrary(A_LoopField)

            if (NOT Str.IsEmpty(includeFile)) AND (NOT Str.Contains(IncludeFilesList, includeFile)) {
                IncludeFilesList .= includeFile ","
                GetIncludes(includeFile)
            }
        }
    }

    return IncludeFilesList
}

FindInLibrary(IncludeLine) {

    ;if FileExist(IncludeLine)        Return IncludeLine
        
    if Not Str.StartsWith(IncludeLine, "#Include")
        Return ""

    fname := ExtractIncludeName(IncludeLine)

    ; if Str.Contains(IncludeLine, ">") {	
    ;     fname := RegExMatch(IncludeLine, "i)^#Include\s+<*\s*([^>\s;]+)", &Match) ? Match[1] : ""
    ;     fname := Str.IsEmpty(fname) ? "" : Trim(fname)
    ; } else {
    ;     split := Str.Split(IncludeLine, " ")
    ;     fname := split.Length >= 2 ? Trim(split[2]) : ""
    ; }

    if !IsSet(fname) OR Str.IsEmpty(fname)
        return

;MsgBox IncludeLine "`n`n" fname, "DEBUG _FindInLibrary"

    fname := Str.EndsWith(fname, ".ahk") ? fname : fname ".ahk"

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

ExtractIncludeName(Line) {
    if (Line = "")
        return ""

    CleanPath := ""

    if RegExMatch(Line, "i)^#Include(?:Again)?\s+(?P<Path>[^;]+)", &Match) {
                RawPath := Match["Path"]

                IsLib := (SubStr(Trim(RawPath), 1, 1) = "<")
                
                ; Character list for trim: space, double-quote, single-quote, <, >
                CleanPath := Trim(RawPath, " `"'<>")
    }

    ; ; Clean up comments and the directive
    ; CleanLine := Trim(StrSplit(Line, ";")[1])
    ; NamePart := Trim(StrReplace(CleanLine, "#Include", "", false))
    
    ; ; Strip brackets or quotes
    ; NamePart := StrReplace(NamePart, "<", "")
    ; NamePart := StrReplace(NamePart, ">", "")
    ; NamePart := StrReplace(NamePart, '"', "")
    ; NamePart := StrReplace(NamePart, "'", "")
    
    ; return Trim(NamePart)

    return CleanPath
}

;
;
; #region CLICK OLD
;
;





ButtonMerge_Click_OLD(Ctrl, Info) {

    SelectedFile := Trim(ScriptEdit.Text)

    ; If user copied as path, then paste (includes double quotes)
    if Str.Contains(SelectedFile, '"') {
        SelectedFile := StrReplace(SelectedFile, '"', '')
        ScriptEdit.Text := SelectedFile
    }

    ; if valid then update settings
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
    MergedScript := Merge.Includes(SelectedFile)

;Debug.FileWrite(MergedScript, , true)  ; Default is .\;Debug.txt

    outFile := Str.SplitPath(SelectedFile).nameNoExt "_Merged.ahk"
    if FileExist(outfile)
        FileDelete(outfile)
    FileAppend(MergedScript, outfile)

;Debug.MBox(outFile)

    ;DEBUG
    Run("notepad " outfile)

    ;MsgBox("Done!", "Status", "icon?")

    outFile := FileSelect(PromptOverwrite:=16, StrReplace(ScriptEdit.Text, ".ahk", "_Merged.ahk"))

    if Str.IsEmpty(outFile)
        return

    FileDelete(outFile)
    FileAppend(MergedScript, outFile)

}

ButtonHelp_Click() {
    helpText := "
(
__________________________________________________________________

                                    AhkMerge
__________________________________________________________________

This tool has two main functions:

1. ButtonMerge_Click an AHK script with all of the #Include files in the script.
    a. Optionally excludes all unused functions from the #Include files.
    b. Optionally excludes Comment and/or Headings.

2. Combines multiple scripts into one.
    a. Combines entire scripts.
    b. Doesn't process #Include files.

Buttons:

    [Browse]    Select the main AutoHotkey script (.ahk).

    [Merge]     ButtonMerge_Click the selected script with its #Include files.
                        [ ] Exclude Comments.
                        [ ] Exclude Headers.
                        [ ] Exclude Unused Classes and Functions.

    [Combine]   Opens a FileSelect Dialog to select file(s) to combine.
                        [ ] Checkboxes are ignored.

    [Help]      Shows this help text.

    [Cancel]    Closes the application.

)"
    MsgBox(helpText, "Help")
}

class Merge {

    static IncludedFiles := ""
    static MergedScript := ""
    static dividerLine := ";" Str.Repeat("=", 100)

    ; array or csv or map?
    ; Merge files, optionally comment out all #Includes
    static Files(ScriptPathsArray, CommentOutIncludes := True) {
        this.MergedScriptPaths := ""
        return this.MergedScriptPaths
    }

    ; Merge files, optionally comment out all #Includes
    static Includes(ScriptPath) {

        if !FileExist(ScriptPath)
            return
            
        this.MainScriptPath := ScriptPath
        ;this.MainScriptText := this._ReadInclude(ScriptPath)
        this.MainScriptText := FileRead(ScriptPath)

        ;Debug.FileWrite(this.MainScriptText, "DEBUG_MainScriptText.txt", True)

        ; Initialize variables used in the Recursive Function
        this.IncludedFiles := ""
        this.MergedScript := ""

        ; Recursively get all #Include files in the script file and their includes
        this.IncludedFiles := Str.RTrim(this._GetIncludes(ScriptPath), ",")

    Debug.FileWrite(this.IncludedFiles, "DEBUG_IncludedFiles.txt", True)

        ; Add a pretty header
        buffer := ""

        buffer .= StrReplace(this._GetHeader(ScriptPath), ".ahk", "_Merged.ahk")
       
        ; Add all of the #Include files to the Header
        split := Str.Split(this.IncludedFiles, ",")
        for file in split            
            buffer .= ";" file . "`n"
        buffer .=  ";" ScriptPath "`n"

        buffer .= this.dividerLine . "`n"

        if MyCheckBoxExcludeHeaders.Value
            buffer := ""

        this.MergedScript .= buffer

        ;;Debug.MBox this.MergedScript

        ; Add all of the #Include files to the MergedScript
        this.MergedScript .= this._MergeIncludes(ScriptPath, this.IncludedFiles)

        ;;Debug.MBox this.MergedScript

        ; Add the script to the MergedScript
        this.MergedScript .= this._GetHeader(ScriptPath)

        ; With or without headers, comment, and unused functions?
        this.MergedScript .= this._ReadInclude(ScriptPath)

        ;Remove multiple blank lines
        CleanScript := RegExReplace(this.MergedScript, "\R{3,}", "`n`n")

        ;Remove blank lines from the end of the script (will leave one blank line at the end)
        CleanScript := RegExReplace(CleanScript, "\R+$", "")

        return CleanScript
    }

    static _AppendLine(Line) {
        this.MergedScript .= Line . "`n"
    }

    static _MergeIncludes(ScriptPath, IncludedFiles) {

        buffer := ""

        split := Str.Split(IncludedFiles, ",")

        for includeFile in split {

            buffer .= this._GetHeader(includeFile)

;            ExcludeUnused :=MyCheckBoxExcludeUnusedClassesAndFunctions.Value

            if MyCheckBoxExcludeUnusedClassesAndFunctions.Value {

                functionsCSV := ScanLibScript(includeFile)
;functionsCSV := GetFunctions(includeFile)

                ;;Debug.ListVar(functionsCSV,,,'[]')
Debug.FileWriteLine(FunctionsCSV, "DEBUG_FunctionsCSV.txt", False)

                ; Read the function from the Include file, if its in the ScriptPath
                ; Else return ""
                Loop Parse FunctionsCSV, "`n", "`r`n" {
                    ;TODO: Choose one:
                     FunctionCSVLine := Trim(A_LoopField)
                     buffer .= this._ReadFunction(ScriptPath, FunctionCSVLine)
                    ;buffer .= this._ReadFunction(ScriptPath, A_LoopField)
                }

            } else {

                ;Debug.FileWrite(this._ReadInclude(includeFile),"DEBUG_ReadInclude.txt", False)

                ; Merge the entire Include file
                buffer .= this._ReadInclude(includeFile)
             }

        }

        return buffer

    }

    static _GetHeader(ScriptPath) {

        header := this.dividerLine . "`n"
        header .= ";" ScriptPath . "`n"
        header .= this.dividerLine . "`n"

        if MyCheckBoxExcludeHeaders.Value
            header := ""

        return header
    }
    
    static _ReadInclude(ScriptPath) {

        if Str.IsEmpty(ScriptPath)
            return

        ScriptText := FileRead(ScriptPath)

        ;ScriptTextArray := Str.Split(ScriptText, "`n", "`r")

        IgnoreToEnd := False

        InCommentBlock := False

        textBuffer := ""

        Loop Parse ScriptText, "`n", "`r`n"{

            if IgnoreToEnd
                continue

            line        := A_LoopField
            lineTrim    := Trim(A_LoopField)

            if Str.StartsWith(lineTrim, "/*")
                InCommentBlock := true

            if Str.StartsWith(lineTrim, "*/") {
                InCommentBlock := false
                continue
            }

            if InCommentBlock
                continue

            ; Avoid multiple #Requires
            if Str.StartsWith(lineTrim, "#Requires AutoHotkey")
                line := ";" line "`n"

            ; Avoid multiple #Include of the same file
            if Str.StartsWith(lineTrim, "#Include") {
                line := ";" line "`n"
            }

            ; Exclude test functions at bottom of script
            if Str.StartsWith(lineTrim, "If (A_LineFile == A_ScriptFullPath)") {
                IgnoreToEnd := True
                continue
            }

            ; if CheckBox Exclude Comments is checked
            if (Str.StartsWith(lineTrim, ";") AND MyCheckBoxExcludeComments.Value)
                continue

            ; if CheckBox Exclude Comments is checked, remove inline comment
            if MyCheckBoxExcludeComments.Value {
                static needle := A_Space . ";"
                if Str.Contains(lineTrim, needle)
                    line := Trim(Str.Split(line, needle)[1])
            }

            textBuffer .= line "`n"
        }
        return textBuffer
    }

    static _GetIncludes(ScriptPath) {

        if Str.IsEmpty(ScriptPath)
            return

        ScriptText := FileRead(ScriptPath)

        ScriptTextArray := Str.Split(ScriptText, "`n", "`r")

        Loop ScriptTextArray.Length {

            line := ScriptTextArray[A_Index]

            if Str.StartsWith(line, "#Include") {

        
                includeFile := this._FindInLibrary(line)

        ;MsgBox line "`n`n" includeFile, "DEBUG"

            if (NOT Str.IsEmpty(includeFile)) AND (NOT Str.Contains(this.IncludedFiles, includeFile)) {
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

    static _ReadFunction(ScriptPath, IncludeLine) {

        ;;Debug.MBox "[" FunctionsCSV "]", "ReadFunction"

        split := Str.Split(IncludeLine, ",")

        if split.Length < 4 {
            return ""
        }
    
        ; ok ;Debug.ListVar split

        functionName := Trim(split[1])
        includeFile  := Trim(split[2])
        lineNumber   := Trim(split[3])
        lineCount    := Trim(split[4])

        ; ;Debug.WriteLine("ScriptPath: " ScriptPath "`n" .
        ;     'includeFile: ' includeFile  "`n" .
        ;     'function: ' functionName  "`n" .
        ;     'lineNumber: ' lineNumber "`n" . 
        ;     'lineCount: ' lineCount)

        ; search for Str.ing in #Include <Str.ing> works, but;
        ; should search for #Include ... Str.ing because it could be ./Lib/Str.ing.ahk etc.
        ;StartsWith := (functionName.Compare("#Include")=0) ? includeFile.SplitPath().nameNoExt : ""
        if Str.Compare(functionName, "#Include") {
            StartsWith := functionName
            functionName := Str.SplitPath(includeFile).nameNoExt
        } else {
            StartsWith := ""
        }

        if NOT this._FindIn(this.MainScriptText, StartsWith, functionName)
            return

        ScriptText := FileRead(includeFile)

        ScriptTextArray := Str.Split(ScriptText, "`n", "`r")

        functionText := ""

        Loop ScriptTextArray.Length {

            if A_Index != lineNumber
                continue

            ;;Debug.MBox A_Index ", " lineNumber

            index := A_Index

            Loop lineCount {
                functionText .= ScriptTextArray[index] . "`n"
                index++
                if index >= ScriptTextArray.Length
                    break
            }

            break
        }

        ;;Debug.WriteLine('functionText: ' functionText)

        return functionText            ;;Debug.MBox "[" line "]" "`n`n" "[" split[1] "]" "`n`n" "[" split[2] "]" "`n`n" "[" split[3] "]" "`n`n" "[" split[4] "]", "ReadFunction"
        
    }

    static _FindIn(ScriptText, StartsWith, FunctionName) {
        ; Search the entire file including comments

        found := false

        ;InCommentBlock := false
        ;debugCount := 0

        Loop Parse ScriptText, "`n", "`r`n" {

            ;debugCount++

            line := Trim(A_LoopField)

            ;if line.Str.IsEmpty() OR line.StartsWith(";")
            ;    continue

            ; if line.StartsWith("/*")
            ;     InCommentBlock := true
            ; else if line.StartsWith("*/")
            ;     InCommentBlock := false

            ; if InCommentBlock
            ;     continue

            ; if StartsWith.Contains("#Include")
            ;  if FunctionName.Contains("ScanLibScript")
            ;      ;Debug.MBox("StartsWith: " StartsWith "`n`nFunctionName: " FunctionName, "FindIn")

            if Str.StartsWith(line, StartsWith) AND Str.Contains(line, FunctionName) {
                found := true
                 ;;Debug.MBox("debugCount: " debugCount "`n`nFunctionName: " FunctionName, "FindIn")
                break
            }

        }
        ;;Debug.MBox("debugCount: " debugCount "`n`nFunctionName: " FunctionName, "FindIn")

        return found
    }
    static _FindInLibrary(IncludeLine) {

        if FileExist(IncludeLine)
            Return IncludeLine
            
        if Not Str.StartsWith(IncludeLine, "#")
            Return ""
                
        if Str.Contains(IncludeLine, ">") {	
            fname := RegExMatch(IncludeLine, "i)^#Include\s+<*\s*([^>\s;]+)", &Match) ? Match[1] : ""
            fname := Str.IsEmpty(fname) ? "" : Trim(fname)
        } else {
            split := Str.Split(IncludeLine, " ")
            fname := split.Length >= 2 ? Trim(split[2]) : ""
        }

        if !IsSet(fname) OR Str.IsEmpty(fname)
            return

    ;MsgBox IncludeLine "`n`n" fname, "DEBUG _FindInLibrary"

        fname := Str.EndsWith(fname, ".ahk") ? fname : fname ".ahk"

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

; Purpose:  Find Functions to include in the MainScriptPath.
; Return:   if functions then CSV file of functionName, LibScriptPath, ScriptLineNumber, FunctionLineCount.
; Return:   if class     then CSV file of '#Include', LibScriptPath, ScriptLineNumber, ClassLineCount.
;---------------------------------------------------------------------------------------------------------
ScanLibScript(LibScriptPath) {

    ; else 
    FunctionCSV := ""

    ScriptText := FileRead(LibScriptPath)

    ScriptTextArray := Str.Split(ScriptText, "`n", "`r")

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
        line := Str.LTrim(ScriptTextArray[ScriptLineNumber])

        if Str.StartsWith(line, "/*")
            InCommentBlock := true
        else if Str.StartsWith(line, "*/")
            InCommentBlock := false

        if InCommentBlock
            continue

        if Str.IsEmpty(line) OR Str.StartsWith(line, ";")
            continue

        ; Exclude test functions at bottom of script
        if Str.StartsWith(line, "If (A_LineFile == A_ScriptFullPath)") {
            IgnoreToEnd := True
            continue
        }

        if Str.StartsWith(line, "class") {

            ClassBlockStart := true

            ;match the second word
            ;functionName := line.Match("^\s*\S+\s+(\S+)")

            ; if class search for the name of the class e.g. class Debug {, ;Debug.ahk
            ;functionName := LibScriptPath.SplitPath().NameNoExt
            functionName := "#Include"

            ;;Debug.MBox("LibScriptPath: " LibScriptPath "`n`nfunctionName: " functionName)


            ;OutputDebug("class: " line ", name: " r)

        }

        if Str.IsEmpty(functionName) {
            ; This RegExMatch pattern will find and capture the function name: ".*?(\w+)\("
            ;   .*?     : This is a non-greedy match for any character (.) zero or more times (*?).
            ;               It will match as few chars as possible from the beginning of the Str.ing until the next part of the pattern can be satisfied.
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

            ;;Debug.WriteLine("functionName: " functionName)
            ;;Debug.MBox("functionName: " functionName)

        }

        ; if still empty we didn't detect a function name in this line, continue
        if Str.IsEmpty(functionName)
            continue

        static builtInFunctionNames :=  "Abs,ACos,ASin,ATan,BlockInput,Break,CallbackCreate,CallbackFree,CaretGetPos,Catch,Ceil,Click,ClipboardEx,ClipWait,ControlClick,ControlChooseIndex,ControlChooseString,ControlFocus,ControlGetChecked,ControlGetChoice,ControlGetEnabled,ControlGetFocus,ControlGetHwnd,ControlGetIndex,ControlGetItems,ControlGetPos,ControlGetText,ControlGetVisible,ControlHide,ControlHideDropDown,ControlMove,ControlSetChecked,ControlSetEnabled,ControlSetText,ControlShow,ControlShowDropDown,ControlAddItem,ControlDeleteItem,ControlSetExStyle,ControlSetStyle,ControlGetExStyle,ControlGetStyle,Cos,Critical,DateAdd,DateDiff,DetectHiddenText,DetectHiddenWindows,DirCopy,DirCreate,DirDelete,DirExist,DirMove,DirSelect,DllCall,Download,DriveEject,DriveGetCapacity,DriveGetFileSystem,DriveGetLabel,DriveGetList,DriveGetSerial,DriveGetSpaceFree,DriveGetStatus,DriveGetStatusCD,DriveGetType,DriveLock,DriveSetLabel,DriveUnlock,Edit,EditGetCurrentCol,EditGetCurrentLine,EditGetLine,EditGetLineCount,EditGetSelectedText,EditPaste,Else,EnvGet,EnvSet,Exit,ExitApp,Exp,FileAppend,FileCopy,FileCreateShortcut,FileDelete,FileEncoding,FileExist,FileGetAttrib,FileGetShortcut,FileGetSize,FileGetTime,FileGetVersion,FileInstall,FileMove,FileOpen,FileRead,FileRecycle,FileRecycleEmpty,FileRemoveAttrib,FileSelect,FileSetAttrib,FileSetTime,Finally,Floor,For,Format,FormatTime,GetKeyName,GetKeySC,GetKeyState,GetKeyVK,GetMethod,GetNumLockState,GetScrollLockState,GroupActivate,GroupAdd,GroupClose,GroupDeactivate,GuiCtrlFromHwnd,GuiFromHwnd,HasBase,HasMethod,HasProp,HotIf,HotIfWinActive,HotIfWinExist,HotIfWinNotActive,HotIfWinNotExist,Hotkey,Hotstring,If,IL_Add,IL_Create,IL_Destroy,ImageSearch,IniDelete,IniRead,IniWrite,InputBox,InputHook,InstallKeybdHook,InstallMouseHook,InStr,IsLabel,IsNumber,IsObject,IsSet,IsSetRef,KeyHistory,KeyWait,ListHotkeys,ListLines,ListVars,Log,Ln,Loop,Max,Min,Mod,MonitorGet,MonitorGetCount,MonitorGetName,MonitorGetWorkArea,MouseClick,MouseClickDrag,MouseMove,MsgBox,NumGet,NumPut,ObjAddRef,ObjBindMethod,ObjGetBase,ObjGetCapacity,ObjHasOwnProp,ObjOwnPropCount,ObjOwnProps,ObjPtr,ObjPtrAddRef,ObjRelease,ObjSetBase,ObjSetCapacity,OnClipboardChange,OnError,OnExit,OnMessage,OutputDebug,Pause,Persistent,PixelGetColor,PixelSearch,PostMessage,ProcessClose,ProcessExist,ProcessGetName,ProcessGetParent,ProcessGetPath,ProcessSetPriority,ProcessWait,ProcessWaitClose,Random,RegDelete,RegDeleteKey,RegExMatch,RegExReplace,RegWrite,Reload,Return,Round,Run,RunAs,RunWait,Send,SendEvent,SendInput,SendMessage,SendMode,SendPlay,SendLevel,SetCapsLockState,SetControlDelay,SetDefaultMouseSpeed,SetKeyDelay,SetMouseDelay,SetNumLockState,SetRegView,SetScrollLockState,SetStoreCapsLockMode,SetTimer,SetTitleMatchMode,SetWinDelay,SetWorkingDir,Sin,Sleep,Sort,SoundBeep,SoundGetInterface,SoundGetMute,SoundGetName,SoundGetVolume,SoundPlay,SoundSetMute,SoundSetVolume,SplitPath,Sqrt,StatusBarGetText,StatusBarWait,StrCompare,StrGet,StrLen,StrLower,StrPtr,StrPut,StrReplace,StrSplit,StrUpper,SubStr,Suspend,Switch,SysGet,SysGetIPAddresses,Tan,Thread,Throw,TickCount,ToolTip,TraySetIcon,TrayTip,Trim,Try,Type,Until,VarSetStrCapacity,VerCompare,WinActivate,WinActivateBottom,WinActive,WinClose,WinExist,WinGetClass,WinGetClientPos,WinGetControls,WinGetControlsHwnd,WinGetCount,WinGetExStyle,WinGetID,WinGetIDLast,WinGetList,WinGetMinMax,WinGetPID,WinGetPos,WinGetProcessName,WinGetProcessPath,WinGetStyle,WinGetText,WinGetTitle,WinHide,WinKill,WinMaximize,WinMinimize,WinMinimizeAll,WinMinimizeAllUndo,WinMove,WinMoveBottom,WinMoveTop,WinRedraw,WinRestore,WinSetAlwaysOnTop,WinSetEnabled,WinSetExStyle,WinSetRegion,WinSetStyle,WinSetTitle,WinSetTransColor,WinSetTransparent,WinShow,WinWait,WinWaitActive,WinWaitClose,WinWaitNotActive"

        if Str.Contains(builtInFunctionNames, functionName)
            continue

        ;If next line > end of Array then Break
        if (ScriptLineNumber + 1) > ScriptTextArray.Length
            break

        ;If next line starts with { then add { to this line and clear next line
        if Str.StartsWith(ScriptTextArray[ScriptLineNumber + 1], "{") {
            ScriptTextArray[ScriptLineNumber] .= "{"
            ScriptTextArray[ScriptLineNumber + 1] := ""        
        }

        ;if not in class block, save the function, script name, and line number
        if Str.Contains(FunctionCSV, functionName)
            continue

        if NOT InClassBlock
            FunctionCSV .= functionName ", " LibScriptPath ", " ScriptLineNumber

        if ClassBlockStart
            InClassBlock := true

        ; Preset counters
        FunctionLineCount := 1
        BraceCount := 0

    ;MsgBox "Script: " OutName "`n`nFunctionName:`n`n" functionName "`n`nlineNumber: " ScriptLineNumber "`n`nInCommentBlock: " InCommentBlock, "Loop 1"


        ; If this line contains { then Count braces
        if Str.Contains(ScriptTextArray[ScriptLineNumber], "{") {

    ;MsgBox "Script: " OutName "`n`nCounting Braces.", "Loop 1"

            Loop {

                line := ScriptTextArray[ScriptLineNumber]

                if Str.Contains(line, "}") and Str.Contains(line, "{") {
                    BraceCount += 0
                } else if Str.Contains(line, "{") {
                    BraceCount += 1
                } else if Str.Contains(line, "}") {
                    BraceCount -= 1
                }

    ;MsgBox "Script: " OutName "`n`nScriptLineNumber: " ScriptLineNumber "`n`nBraceCount: " BraceCount , "Loop 1"

                if (BraceCount = 0) {
                    ;DEBUG THIS ISN'T USED, REMOVE
                    ; if InClassBlock
                    ;     InClassBlock := false
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

    ;;Debug.ListVar FunctionCSV

    return FunctionCSV
}

GetFunctionLineCount(Buffer, FunctionName, LineNumber) {

;TODO: Buffer[] needs to be an Array so we can step through it to count function lines

    ;MsgBox "FunctionName: " FunctionName ", LineNumber: " LineNumber, "GetFunctionLineCount"

    FunctionLineCount := BraceCount := 0

    Loop Parse Buffer, "`n" {

    ;     split := Str.Split(A_LoopField, ",")

    ; MsgBox "split[3]: " split[3], "Loop"

        ; if split.Length >= 4
        ;     lineNumber := split[3]
        ; else
        ;     continue


        if A_Index != lineNumber
            continue

        ; Found Function in Buffer, now count braces
        line := Trim(A_LoopField)

        Loop {

            FunctionLineCount := 0
        
        ;MsgBox "line: " line "`n`nlineNumber: " lineNumber, "Loop"

        ;MsgBox "lineNumber: " lineNumber, "Loop"

            if Str.Contains(line,"}") and Str.Contains(line, "{") {
                BraceCount += 0
            } else if Str.Contains(line, "{") {
                BraceCount += 1
            } else if Str.Contains(line, "}") {
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
