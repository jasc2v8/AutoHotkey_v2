; TITLE   : AhkMerge v1.0.0.107
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
myGui.Title := "Ahk Merge v1.0.0.107"
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
        MsgBox "File not Exist: " MainScriptPath
        return
    }

    ; Read the script
    MainScript := FileRead(MainScriptPath)

    ; Map the main script
    MainScriptMap := ScanScriptToMap(MainScript, MainScriptPath)

    ObjView("MainScriptMap", MainScriptMap )

    ; Get Include files
    IncludeFileArray := GetIncludeFileArray(MainScript, MainScriptPath)

    ObjView("IncludeFileArray", IncludeFileArray )

    ; Map the Include files
    IncludeMap := ScanIncludesToMap(IncludeFileArray)

     ObjView("IncludeMap", IncludeMap )

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

ScanScriptToMap_increment(ScriptText, ScriptFullPath) {

    /*
        Loop ScriptText

            ; don't count braces inside comment or comment block!

            ; block count includes comments inside the block
            if CountBraces {

                if (not in comment) and (not in commentblock) 
                    braceCount + or -
                    blockCount++
                    if braceCount = 0
                        save Type_Name, lineNumber, LineCount, Path?
                        CountBraces := false
                        continue
                    else
                        blockCount++                
                    continue
            }

            if line is commentBlock start
                IsCommentBlock  := true
            else if line is commentBlock end
                IsCommentBlock  := false

            if line is comment or line is commentBlock
                continue

            if line is class
                CountBraces := true

            else if line is function
                CountBraces := true

            else
                continue




    */

    ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

    ClassBlockStart := false
    InClassBlock := false
    InCommentBlock := false
    ScriptLineNumber := 0
    IgnoreToEnd := False

    FunctionCSV := ""

    Loop {
   
        if IgnoreToEnd
            break

        ScriptLineNumber++

        if ScriptLineNumber > ScriptTextArray.Length
            break

;        functionName := ""

        ;remove leading whitespace
        line := ScriptTextArray[ScriptLineNumber].LTrim()

        if Str.StartsWith(line, "/*")
            InCommentBlock := true
        else if Str.StartsWith(line, "*/")
            InCommentBlock := false

        if InCommentBlock
            continue

        if line.IsEmpty() OR Str.StartsWith(line, ";")
            continue

        ; Exclude test functions at bottom of script
        if Str.StartsWith(line, "If (A_LineFile == A_ScriptFullPath)") {
            IgnoreToEnd := True
            continue
        }

        if Str.StartsWith(line, "class") {

            ClassBlockStart := true

            ;functionName := "#Include"

        }

        ; Check for Class
        if RegExMatch(Line, "i)^class\s+(?P<Name>[a-zA-Z0-9_]+)", &Match) {
            itemType := "Class"
            itemName := Match["Name"]
            scriptLine := ScriptLineNumber

        ; Check for Function (standard or fat-arrow: QuickLog(msg) => FileAppend(msg "`n", "log.txt"))
        } else if RegExMatch(Line, "(?i)(?:if\s+)?(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match) {
            itemType := "Function"
            itemName := Match["Name"]
            scriptLine := ScriptLineNumber

        ; Continue scanning
        } else {
            continue
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

        ;if NOT InClassBlock
        ;    FunctionCSV .= functionName ", " LibScriptFile ", " ScriptLineNumber

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

ScanScriptToMap(ScriptText, ScriptFullPath) {

    /*
        Loop ScriptText

            ; don't count braces inside comment or comment block!

            ; block count includes comments inside the block
            if CountBraces {

                if (not in comment) and (not in commentblock) 
                    braceCount + or -
                    blockCount++
                    if braceCount = 0
                        save Type_Name, lineNumber, LineCount, Path?
                        CountBraces := false
                        continue
                    else
                        blockCount++                
                    continue
            }

            if line is commentBlock start
                IsCommentBlock  := true
            else if line is commentBlock end
                IsCommentBlock  := false

            if line is comment or line is commentBlock
                continue

            if line is class
                CountBraces := true

            else if line is function
                CountBraces := true

            else
                continue
    */

    ;ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

    ItemType        := ""
    ItemName        := ""

    objMap          := Map()

    ; ClassBlockStart := false
    ; InClassBlock := false
    ; ScriptLineNumber := 0
    ; IsClass         := false

    IgnoreToEnd := false
    CountBraces := false
    InCommentBlock := false

    braceCount := 0
    blockCount := 0

    ;SplitPath(ScriptFullPath, , &BaseDir)
    ;Lines := StrSplit(ScriptText, "`n", "`r")
    ;for Index, RawLine in Lines {

    scriptArray := StrSplit(ScriptText, "`n", "`r")

    ;Loop Parse, ScriptText, "`n", "`r" {
    Loop scriptArray.Length {

        lineNumber := A_Index

        line := scriptArray[lineNumber]

        if (IgnoreToEnd)
            break

        if Str.IsEmpty(line)
            continue

        line := Trim(line)

        if Str.StartsWith(line, "/*")
            InCommentBlock := true
        else if Str.StartsWith(line, "*/")
            InCommentBlock := false

        if (InCommentBlock)
            continue

        if Str.StartsWith(line, ";")
            continue

        ; Exclude test functions at bottom of script
        if Str.StartsWith(line, "If (A_LineFile == A_ScriptFullPath)") {
            IgnoreToEnd := True
            continue
        }

        ; if (not in comment) and (not in commentblock) 
        ; if (CountBraces) {

        ;     if Str.Contains(line,"}") and Str.Contains(line,"{") {
        ;         braceCount += 0
        ;     } else if Str.Contains(line,"{") {
        ;         braceCount += 1
        ;     } else if Str.Contains(line,"}") {
        ;         braceCount -= 1
        ;     }
            
        ; ;MsgBox "Script: " OutName "`n`nScriptLineNumber: " ScriptLineNumber "`n`nbraceCount: " braceCount , "Loop 1"

        ;     if (braceCount = 0) {

        ;         objMap.Set(itemType "_" itemName, itemLine ", " blockCount ", " ScriptFullPath)

        ;         message := ScriptFullPath "`n`n" line "`n`n" itemtype "`n`n" itemName "`n`n" itemLine "`n`n" blockCount "`n`n" CountBraces

        ;         MsgBox message, "DEBUG"

        ;         CountBraces := false

        ;         continue

        ;     } else {
        ;         blockCount++
        ;         continue
        ;     }
        ; } else {
        ;     blockCount := 0
        ; }

        ; Skip the code block inside a class
        ; if Str.StartsWith(line, "class") {
        ;     ClassBlockStart := true
        ;     ; ? functionName := "#Include"
        ; }

        ; If at end of aray then don't look ahead
        if (lineNumber + 1 > scriptArray.Length)
            continue

        ; Check for a code block
        ;if Str.Contains(line, "{") or Str.StartsWith(scriptArray[lineNumber + 1], "{") {

            ;MsgBox line, 'CODE BLOCK'

            ; Else if next line starts with { then add { to this line and clear next line
            ; } else if Str.StartsWith(scriptArray[lineNumber + 1], "{") {
            ;     scriptArray[lineNumber] .= "{"
            ;     scriptArray[lineNumber + 1] := ""        
            ; }

            ; Check for Class
            if RegExMatch(Line, "i)^class\s+(?P<Name>[a-zA-Z0-9_]+)", &Match) {

                itemType := "Class"
                itemName := Match["Name"]
                itemLine := A_Index
                ;CountBraces := true

            ; RegExMatch(Line, "(?i)(?:if\s+)?(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match)

            ; Check for Function (standard or fat-arrow: QuickLog(msg) => FileAppend(msg "`n", "log.txt"))
            } else if RegExMatch(Line, "(?i)^\s*(?:if\s+)?(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match) {

                itemType := "Function"
                itemName := Match["Name"]
                itemLine := A_Index
                ;CountBraces := true

            } else {
                itemType := ""
                itemName := ""
                itemLine := 0
            }

            if (itemType="Class" or itemType="Function") {

                blockCount := 1

                if (Str.Contains(line, "{")) or (Str.StartsWith(scriptArray[lineNumber + 1], "{")) {
                    blockCount := GetBlockCount(scriptArray, itemLine)
                }

                objMap.Set(itemType "_" itemName, itemLine ", " 0 ", " ScriptFullPath)

                message := ScriptFullPath "`n`n" line "`n`n" itemtype "`n`n" itemName "`n`n" itemLine "`n`n" blockCount
                MsgBox message, "DEBUG " ItemType
            }
        ;}
    }
    return objMap
}

GetBlockCount(scriptArray, lineNumber) {

    blockStart := false
    blockCount := 0
    braceCount := 0

    Loop scriptArray.Length {

        line := Trim(scriptArray[lineNumber])

        if lineNumber > lineNumber + 1
            break

        if Str.Contains(line,"{")
            blockStart := lineNumber

        if (blockStart) {

            if Str.Contains(line,"}") and Str.Contains(line,"{") {
                braceCount += 0
            } else if Str.Contains(line,"{") {
                braceCount += 1
            } else if Str.Contains(line,"}") {
                braceCount -= 1
            }
            
            if (braceCount = 0) {
                break
            }

            blockCount++
            lineNumber++
        }
      
    }
    return blockCount
}

ScanScriptToMap_Gemini(ScriptText, ScriptFullPath) {

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
            ItemType := ""
            ItemName := ""

            ; 1. Check for Class
            if RegExMatch(Line, "i)^class\s+(?P<Name>[a-zA-Z0-9_]+)", &Match) {
                ItemType := "Class"
                ItemName := Match["Name"]
            } 
            ; 2. Check for Function (standard or fat-arrow)
            else if RegExMatch(Line, "(?i)(?:if\s+)?(?P<Name>[a-zA-Z0-9_]+)\(.*\)\s*(\{?|=>)", &Match) {
                ItemType := "Function"
                ItemName := Match["Name"]
            }

            ; Initialize tracker for Class or Function blocks
            if (ItemType != "") {
                CurrentItem := {
                    Type: ItemType, 
                    Name: ItemName, 
                    StartLine: Index, 
                    LineCount: 1,
                    Path: ScriptFullPath
                }
                
                ; Fat arrow functions end on the same line
                if (ItemType = "Function" && InStr(Line, "=>")) {
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

; MsgBox IncludeCSV, "GetCode"
    
    split := Str.Split(IncludeCSV, ",")

    lineNumber := split[1]
    lineCount  := split[2]
    filePath   := Trim(split[3])

;MsgBox filePath, "GetCode"

    script := FileRead(filePath)

    split := Str.Split(script, "`n")

    codeBlock := ""

    Loop lineCount {
        codeBlock .= split[A_Index + lineNumber - 1] "`n"
    }

    return codeBlock

}

GetIncludeFileArray(ScriptText, MainScriptPath) {

    ;TODO change to IncludeFilesListArray.Push()...

    IncludeFilesList := ""

    Loop Parse ScriptText, "`n", "`r`n" {

        if Str.StartsWith(A_LoopField, "#Include") {
    
            FileName := ExtractIncludeName(A_LoopField)

            includeFile := FindInLibrary(FileName, MainScriptPath)

            if (NOT Str.IsEmpty(includeFile)) AND (NOT Str.Contains(IncludeFilesList, includeFile)) {
                IncludeFilesList .= includeFile ","
                GetIncludes(includeFile, MainScriptPath)
            }
        }
    }

    return StrSplit(IncludeFilesList, ",")
}

ScanIncludesToMap(IncludeFileArray) {

    static combinedMap := Map()

    for IncludeFilePath in IncludeFileArray {

        if !Str.IsEmpty(IncludeFilePath) {

            script := FileRead(IncludeFilePath)

            combinedMap := _CombineMaps(combinedMap, ScanScriptToMap(script, IncludeFilePath))

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

GetIncludes(ScriptText, MainScriptPath) {

    IncludeFilesList := ""

    Loop Parse ScriptText, "`n", "`r`n" {

        if Str.StartsWith(A_LoopField, "#Include") {
    
            includeFile := FindInLibrary(A_LoopField, MainScriptPath)

            if (NOT Str.IsEmpty(includeFile)) AND (NOT Str.Contains(IncludeFilesList, includeFile)) {
                IncludeFilesList .= includeFile ","
                GetIncludes(includeFile, MainScriptPath)
            }
        }
    }

    return IncludeFilesList
}

FindInLibrary(FileName, MainScriptPath) {
        
    MainScriptDir := Str.SplitPath(MainScriptPath).Dir

    if !IsSet(FileName) OR Str.IsEmpty(FileName)
        return

    FileName := Str.EndsWith(FileName, ".ahk") ? FileName : FileName ".ahk"

    ahkdir := MainScriptDir    "\"                 FileName
    loclib := MainScriptDir    "\Lib\"             FileName
    usrlib := A_MyDocuments    "\AutoHotkey\Lib\"  FileName
    stdlib := Ahkpath          "\Lib\"             FileName

    libraries := [ahkdir, loclib, usrlib, stdlib]

    libfile := ""

    for includeFile in libraries {
        if (FileExist(includeFile)) {
            libFile := includeFile
            Break		
        }
    }

    return libfile

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
