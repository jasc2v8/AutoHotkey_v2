; TITLE   : AhkMerge v1.0.2.2
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

        Save As, press Cancel error
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
myGui.Title := "Ahk Merge v1.0.1.1"
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
    myGui.AddCheckbox("xm w300 Section", "Exclude Headers, Comments, and Blank Lines")
MyCheckBoxExcludeHeaders :=
    myGui.AddCheckbox("xm w150", "Exclude Headers")

myGui.AddText("xm ys w314 h1 Hidden", "Hidden Spacer")

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

    ; Get Include files
    IncludeFileMap := GetIncludeFileMapRecurse(MainScriptPath, IncludeFileMap:=Map())

    ;ObjView("IncludeFileArray", IncludeFileMap )

    ;Save MergedScript
    SaveMergedScript(MainScriptPath, IncludeFileMap)

}

SaveMergedScript(MainScriptPath, IncludeFileMap) {

    MainScript := FileRead(MainScriptPath)

    ; Create the header line
    headerLine := ";" Str.Repeat("=", 100) "`n"

    MergedIncludes := ""

    subregion:=1
    for filePath, v in IncludeFileMap {
        script := FileRead(filePath)
        script := CustomCleanUp(script)
        MergedIncludes .= headerLine
        MergedIncludes .= "; #region 2." subregion " " Str.SplitPath(filepath).NameNoExt ": " filePath "`n"
        MergedIncludes .= headerLine
        MergedIncludes .= script "`n"
        subregion++

        ;MsgBox filePath '`n`n' script
    }
    ;clean1:= CustomCleanUp(MergedIncludes)

    ; Removes lines that are empty or only contain whitespace
    MergedIncludes := Str.Replace(MergedIncludes, "#Include" , ";#Include")
    MergedIncludes := Str.Replace(MergedIncludes, "#Requires", ";#Requires")
    MergedIncludes := RegExReplace(MergedIncludes, "m)^\s*\R", "")

    MergedScript := ""

    ; Select output filename
    outFile := FileSelect(PromptOverwrite:=16, StrReplace(ScriptEdit.Text, ".ahk", "_Merged.ahk"))

    ; If no file selected then return
    if Str.IsEmpty(outfile)
        return

    ; Create the top header showing the output filename
    topHeader := headerLine "; #region 1. Merged: " outFile "`n" headerLine

    ; Add topHeader to merged script
    MergedScript := AddHeader(MergedScript, topHeader)

    ; Append header
    MergedScript := AddHeader(MergedScript, "; Included Scripts:")

    ; Append the included script file paths
    for filePath, v in IncludeFileMap
        MergedScript := AddHeader(MergedScript, ";  " filePath)

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

    ; If checked then Remove Headers, Comments, and Blank Lines
    if (MyCheckBoxExcludeComments.Value = true) {
        MergedScript := CleanScript(MergedScript)
    }
    ; else {
        ; Remove extra blank lines (replaces 2+ newlines with 1)
        ;MergedScript := RegExReplace(MergedScript, "\R{2,}", "`r`n`r`n")
    ;}

    ; Save the merged script file
    FileDelete(outFile)
    FileAppend(MergedScript, outFile)

    ; ; Append the main script after the Includes
    ; FileAppend(MainScriptNoIncludes, outFile)
}

CustomCleanUp(ScriptText) {

    cleanScript := ""
    
    Loop Parse ScriptText, "`n", "`r" {

        line := A_LoopField

        ; line := Str.Replace(line, "#Include" , ";#Include")
        ; line := Str.Replace(line, "#Requires", ";#Requires")

        ; Exclude test functions at bottom of script
        if Str.StartsWith(LTrim(line), "If (A_LineFile == A_ScriptFullPath)") {
             break
        }

        ;if !Str.IsBlank(line)
            cleanScript .= line "`n"
    }
    return cleanScript
}

IsBuiltIn(Name) {
    Static List := "Abs,ACos,ASin,ATan,BlockInput,Break,CallbackCreate,CallbackFree,CaretGetPos,Catch,Ceil,Click,ClipboardEx,ClipWait,ControlClick,ControlChooseIndex,ControlChooseString,ControlFocus,ControlGetChecked,ControlGetChoice,ControlGetEnabled,ControlGetFocus,ControlGetHwnd,ControlGetIndex,ControlGetItems,ControlGetPos,ControlGetText,ControlGetVisible,ControlHide,ControlMove,ControlSetChecked,ControlSetEnabled,ControlSetText,ControlShow,ControlAddItem,ControlDeleteItem,ControlSetExStyle,ControlSetStyle,ControlGetExStyle,ControlGetStyle,Cos,Critical,DateAdd,DateDiff,DetectHiddenText,DetectHiddenWindows,DirCopy,DirCreate,DirDelete,DirExist,DirMove,DirSelect,DllCall,Download,DriveEject,DriveGetCapacity,DriveGetFileSystem,DriveGetLabel,DriveGetList,DriveGetSerial,DriveGetSpaceFree,DriveGetStatus,DriveGetStatusCD,DriveGetType,DriveLock,DriveSetLabel,DriveUnlock,Edit,EditGetCurrentCol,EditGetCurrentLine,EditGetLine,EditGetLineCount,EditGetSelectedText,EditPaste,Else,EnvGet,EnvSet,Exit,ExitApp,Exp,FileAppend,FileCopy,FileCreateShortcut,FileDelete,FileEncoding,FileExist,FileGetAttrib,FileGetShortcut,FileGetSize,FileGetTime,FileGetVersion,FileInstall,FileMove,FileOpen,FileRead,FileRecycle,FileRecycleEmpty,FileRemoveAttrib,FileSelect,FileSetAttrib,FileSetTime,Finally,Floor,For,Format,FormatTime,GetKeyName,GetKeySC,GetKeyState,GetKeyVK,GetMethod,GetNumLockState,GetScrollLockState,GroupActivate,GroupAdd,GroupClose,GroupDeactivate,GuiCtrlFromHwnd,GuiFromHwnd,HasBase,HasMethod,HasProp,HotIf,HotIfWinActive,HotIfWinExist,HotIfWinNotActive,HotIfWinNotExist,Hotkey,Hotstring,If,IL_Add,IL_Create,IL_Destroy,ImageSearch,IniDelete,IniRead,IniWrite,InputBox,InputHook,InstallKeybdHook,InstallMouseHook,InStr,IsLabel,IsNumber,IsObject,IsSet,IsSetRef,KeyHistory,KeyWait,ListHotkeys,ListLines,ListVars,Log,Ln,Loop,Max,Min,Mod,MonitorGet,MonitorGetCount,MonitorGetName,MonitorGetWorkArea,MouseClick,MouseClickDrag,MouseMove,MsgBox,NumGet,NumPut,ObjAddRef,ObjBindMethod,ObjGetBase,ObjGetCapacity,ObjHasOwnProp,ObjOwnPropCount,ObjOwnProps,ObjPtr,ObjPtrAddRef,ObjRelease,ObjSetBase,ObjSetCapacity,OnClipboardChange,OnError,OnExit,OnMessage,OutputDebug,Pause,Persistent,PixelGetColor,PixelSearch,PostMessage,ProcessClose,ProcessExist,ProcessGetName,ProcessGetParent,ProcessGetPath,ProcessSetPriority,ProcessWait,ProcessWaitClose,Random,RegDelete,RegDeleteKey,RegExMatch,RegExReplace,RegWrite,Reload,Return,Round,Run,RunAs,RunWait,Send,SendEvent,SendInput,SendMessage,SendMode,SendPlay,SendLevel,SetCapsLockState,SetControlDelay,SetDefaultMouseSpeed,SetKeyDelay,SetMouseDelay,SetNumLockState,SetRegView,SetScrollLockState,SetStoreCapsLockMode,SetTimer,SetTitleMatchMode,SetWinDelay,SetWorkingDir,Sin,Sleep,Sort,SoundBeep,SoundGetInterface,SoundGetMute,SoundGetName,SoundGetVolume,SoundPlay,SoundSetMute,SoundSetVolume,SplitPath,Sqrt,StatusBarGetText,StatusBarWait,StrCompare,StrGet,StrLen,StrLower,StrPtr,StrPut,StrReplace,StrSplit,StrUpper,SubStr,Suspend,Switch,SysGet,SysGetIPAddresses,Tan,Thread,Throw,TickCount,ToolTip,TraySetIcon,TrayTip,Trim,Try,Type,Until,VarSetStrCapacity,VerCompare,WinActivate,WinActivateBottom,WinActive,WinClose,WinExist,WinGetClass,WinGetClientPos,WinGetControls,WinGetControlsHwnd,WinGetCount,WinGetExStyle,WinGetID,WinGetIDLast,WinGetList,WinGetMinMax,WinGetPID,WinGetPos,WinGetProcessName,WinGetProcessPath,WinGetStyle,WinGetText,WinGetTitle,WinHide,WinKill,WinMaximize,WinMinimize,WinMinimizeAll,WinMinimizeAllUndo,WinMove,WinMoveBottom,WinMoveTop,WinRedraw,WinRestore,WinSetAlwaysOnTop,WinSetEnabled,WinSetExStyle,WinSetRegion,WinSetStyle,WinSetTitle,WinSetTransColor,WinSetTransparent,WinShow,WinWait,WinWaitActive,WinWaitClose,WinWaitNotActive"
    return InStr("," List ",", "," Name ",")
}

GetBlockCount(scriptArray, lineNumber) {

    blockStart := false
    blockCount := 0
    braceCount := 0
    InCommentBlock := false
    
    Loop scriptArray.Length {

        line := LTrim(scriptArray[lineNumber])

    ;MsgBox line, "GetBlockCount"

        if lineNumber > lineNumber + 1
            break
        
        if Str.StartsWith(line, "/*") and Str.EndsWith(line, "*/")
            continue
        else if Str.StartsWith(line, "/*")
            InCommentBlock := true
        else if Str.EndsWith(line, "*/")
            InCommentBlock := false

        ; Skip comment block
        if (InCommentBlock)
            continue

        ; Skip comment line
        if Str.StartsWith(line, ";")
            continue

        if Str.Contains(line, "{")
            blockStart := !blockStart

        if (blockStart) {

            if Str.Contains(line,"}") and Str.Contains(line,"{") {
                ;braceCount += 0
            } else if Str.Contains(line,"{") {
                braceCount += 1
            } else if Str.Contains(line,"}") {
                braceCount -= 1
            }
            
            if (braceCount = 0) and (blockCount>1) {
                break
            }

            blockCount++
        }
      
        lineNumber++

        if (lineNumber > scriptArray.Length)
            break
    }
    return blockCount
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

    ; Remove extra blank lines (replaces 2+ newlines with 1)
    ScriptContent := RegExReplace(ScriptContent, "\R{2,}", "`r`n")

    ; Final trim for start and end of file
    return Trim(ScriptContent, "`r`n`t ")
}

AddHeader(MergedScript, NewHeader) {

    if MyCheckBoxExcludeHeaders.Value = true
        return MergedScript

    NewScript := MergedScript . "`n" . NewHeader

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

GetIncludeFileArray(MainScriptPath) {

    ;TODO change to IncludeFilesListArray.Push()...

    ScriptText := FileRead(MainScriptPath)

    IncludeFilesList := ""
    IncludeFileArray := []

    Loop Parse ScriptText, "`n", "`r`n" {

        if Str.StartsWith(A_LoopField, "#Include") {
    
            FileName := ExtractIncludeName(A_LoopField)

            includeFile := FindInLibrary(FileName, MainScriptPath)

            if (NOT Str.IsEmpty(includeFile)) AND (NOT Str.Contains(IncludeFilesList, includeFile)) {
                ;IncludeFilesList .= includeFile ","
                IncludeFileArray.Push(includeFile)
                GetIncludes(includeFile, MainScriptPath)
            }
        }
    }

    return StrSplit(IncludeFilesList, ",")
}

GetIncludeFileMapRecurse(ScriptPath, IncludeFileMap:=Map()) {

    Script := FileRead(ScriptPath)

    Loop Parse Script, "`n", "`r`n" {

        line := Trim(A_LoopField)

        if Str.StartsWith(line, "#Include") {

            FileName := ExtractIncludeName(line)

            includeFilePath := FindInLibrary(FileName, ScriptPath)

    ; ok MsgBox "ScriptPath:`n`n" ScriptPath "`n`nline: " line "`n`n" "path: " includeFilePath, "FOUND INCLUDE"

            if (NOT Str.IsEmpty(includeFilePath)) AND (NOT IncludeFileMap.Has(includeFilePath)) {

                IncludeFileMap.Set(includeFilePath, 1)

                GetIncludeFileMapRecurse(includeFilePath, IncludeFileMap)

            }
        }
    }
    return IncludeFileMap
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
