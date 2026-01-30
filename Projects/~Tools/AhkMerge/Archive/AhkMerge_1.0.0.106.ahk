; TITLE   : AhkMerge v1.0.0.106
; AUTHOR  : jasc2v8 and Gemini
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : This tool will Merge an AHK script with all of the #Include files in the script.  Optionally excludes Comment and/or Headings.
; OVERVIEW: This is my unique alogrithim. Gemini was a great help for many supporting functions. 
;   Scans the main script for all #Include files and saves the filepaths in an array.
;   Scans the main script and saves all the classes and functions in a map.
;   Recursive scans the include scripts and saves all the classes and functions in a map.
;   Each map has a key: "Name_Type", value: "LineNumber, LineCount, FilePath"
;   Loop IncludeMap: if MainScriptMap.Has(IncludeMap[key]) then include this class or function in the merged script.
;   Optionally excludes Comment and/or Headings.
; NOTES   : Support a one-liner fat arrow funcion.
;           Does NOT support Object.Prototype.DefineProp functions. Example: MyVar.StringIsEmpty()          

/*
    TODO:
    
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include <ObjView> ; for debug

#Include <StringLib>
#Include <Debug>
#Include <IniFile>
#Include <Colors>
#Include <RegSettings>

try TraySetIcon("shell32.dll", 297) ; Folder with plus

;DEBUG Escape::ExitApp()

if FileExist("DEBUG_MainScriptText.txt")
    FileDelete("DEBUG_MainScriptText.txt")
if FileExist("DEBUG_ReadInclude.txt")
    FileDelete("DEBUG_ReadInclude.txt")
if FileExist("DEBUG_FunctionsCSV.txt")
    FileDelete("DEBUG_FunctionsCSV.txt")

; #region Globals

global AhkPath          := "C:\Program Files\AutoHotkey"
global MainScriptPath   := A_ScriptFullPath
global IncludedFiles    := ""
global MergedScript     := ""


; #region Initialize

global reg := RegistrySettings()

SelectedFile := reg.Read("SelectedFile")

if Str.IsEmpty(SelectedFile) OR Not FileExist(SelectedFile) {
    SelectedFile := MainScriptPath
}

; #region Create Gui

myGui := Gui()
myGui.Title := "Ahk Merge v1.0.0.106"
MyGui.BackColor := Colors.AirSuperiorityBlue

MyGui.SetFont("S10", "Segoe UI")
myGui.AddText("xm", "Select a file:")

MyGui.SetFont("S10 cDefault", "Consolas")
ScriptEdit := myGui.AddEdit("xm y+5", SelectedFile)

MyGui.SetFont("S8", "Segoe UI")
myGui.AddButton("yp w55 h22", "Browse").OnEvent("Click", SelectFile)

MyGui.SetFont("S10", "Segoe UI")

MyGui.Add("Text", "xm w560 h1 0x10 -Border vDivider") ; 0x10=SS_ETCHEDHORZ

MyCheckBoxExcludeComments := 
    myGui.AddCheckbox("xm w150 Section", "Exclude Comments")
MyCheckBoxExcludeHeaders :=
    myGui.AddCheckbox("xm w150", "Exclude Headers")

myGui.AddText("xm ys w310 h1 Hidden", "Hidden Spacer")

myGui.AddButton("yp w55 Default", "Merge").OnEvent("Click", ButtonMerge_Click)

myGui.AddButton("yp w55", "Help").OnEvent("Click", (*) => ButtonHelp_Click())

myGui.AddButton("yp w55", "Cancel").OnEvent("Click", (*) => ExitApp())

MyCheckBoxExcludeHeaders.OnEvent("Click", CheckBox_Change)

myGui.Show()

ControlFocus("Cancel", MyGui)

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
        reg.Write("SelectedFile", Trim(selectedFile))
    }
}

; #region CLICK

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

    ; ObjView("IncludeMap", IncludeMap )

    ; Merge the maps into a merged script
    MergedIncludes := MergeScript(MainScriptMap, IncludeMap, &ObjectsArray)

    SaveMergedScript(MainScriptPath, ObjectsArray, MergedIncludes, MainScript)

}

SaveMergedScript(MainScriptPath, ObjectsArray, MergedIncludes, MainScript) {

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

ScanScriptToMap(ScriptText, ScriptFullPath) {

    ResultMap := Map()
    BraceDepth := 0
    CurrentItem := unset

    SplitPath(ScriptFullPath, , &BaseDir)

    Lines := StrSplit(ScriptText, "`n", "`r")

    for Index, RawLine in Lines {
        Line := Trim(RawLine)
        IsActive := IsSet(CurrentItem)

        ; Skip processing for empty lines/comments unless we are counting inside a block
        if (Line = "" || SubStr(Line, 1, 1) = ";") {
            if (IsActive)
                CurrentItem.LineCount++
            continue
        }

        PreBraceDepth := BraceDepth
        StrReplace(Line, "{", , , &OpenCount)
        StrReplace(Line, "}", , , &CloseCount)
        BraceDepth += OpenCount - CloseCount

        ; Only identify definitions at the root level (Depth 0)
        if (PreBraceDepth = 0) {
            Match := ""
            FoundType := ""
            ItemName := ""

            ; 1. Check for Class
            if RegExMatch(Line, "i)^class\s+(?P<Name>[a-zA-Z0-9_]+)", &Match) {
                FoundType := "Class"
                ItemName := Match["Name"]
            } 
            ; 2. Check for Function (standard or fat-arrow)
            else if RegExMatch(Line, "(?i)(?:if\s+)?(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match) {
                FoundType := "Function"
                ItemName := Match["Name"]
            }

            ; Initialize tracker for Class or Function blocks
            if (FoundType != "") {
                CurrentItem := {
                    Type: FoundType, 
                    Name: ItemName, 
                    StartLine: Index, 
                    LineCount: 1,
                    Path: ScriptFullPath
                }
                
                ; Fat arrow functions end on the same line
                if (FoundType = "Function" && InStr(Line, "=>")) {
                    ResultMap.Set(CurrentItem.Type "_" CurrentItem.Name, CurrentItem.StartLine "," CurrentItem.LineCount "," CurrentItem.Path)
                    CurrentItem := unset
                }
                
                continue
            }
        }

        ; Increment count if we are currently inside a block
        if IsSet(CurrentItem) {
            CurrentItem.LineCount++
            
            ; Block closed when depth returns to 0
            if (BraceDepth = 0) {
                ResultMap.Set(CurrentItem.Type "_" CurrentItem.Name, CurrentItem.StartLine "," CurrentItem.LineCount "," CurrentItem.Path)
                CurrentItem := unset
            }
        }
    }
    return ResultMap
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

    lineNumber := split[1]
    lineCount  := split[2]
    filePath   := split[3]

    script := FileRead(filePath)

    split := Str.Split(script, "`n")

    codeBlock := ""

    Loop lineCount {
        codeBlock .= split[A_Index + lineNumber - 1] "`n"
    }

    return codeBlock

}

GetIncludeFileArray(ScriptText) {

    combinedMap := Map()

    IncludeFilesList := GetIncludes(ScriptText)

    return StrSplit(IncludeFilesList, ",")
}

GetIncludeMap(IncludeFileArray) {

    static combinedMap := Map()

    for ScriptFilePath in IncludeFileArray {

        if !Str.IsEmpty(ScriptFilePath) {

            script := FileRead(ScriptFilePath)

            combinedMap := _CombineMaps(combinedMap, ScanScriptToMap(script, ScriptFilePath))

        }
    }

    _CombineMaps(m1, m2) {
        newMap := m1.Clone()
        for key, value in m2
            newMap[key] := value
        return newMap
    }

    return combinedMap
}

GetIncludes(ScriptText) {

    IncludeFilesList := ""

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
        
    if Not Str.StartsWith(IncludeLine, "#Include")
        Return ""

    fname := ExtractIncludeName(IncludeLine)

    if !IsSet(fname) OR Str.IsEmpty(fname)
        return

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
    return CleanPath
}


ButtonHelp_Click() {
    helpText := "
(

This tool will Merge an AHK script with all of the #Include files in the script.  Optionally excludes Comment and/or Headings.

Buttons:

    [Browse]    Select the main AutoHotkey script (.ahk).

    [Merge]     Merge the selected script with its #Include files.
                        [ ] Exclude Comments.
                        [ ] Exclude Headers.

    [Help]      Shows this help text.

    [Cancel]    Closes the application.

)"
    MsgBox(helpText, "AHK Merge Help")
}
