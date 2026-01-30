; Version: 1.0.0.18
; Description: Added Header Capture to include comments/directives above classes.

#Requires AutoHotkey v2.0

; Global variables for UI
global MainFile := ""
global OutputPath := ""

; Create GUI
MainGui := Gui("+Resize", "AHK Dependency Merger v1.0.0.18")
MainGui.SetFont("s10", "Segoe UI")

; Adding an icon using PrivateExtractIcons (Case Sensitive)
try {
    hIcon := 0
    DllCall("user32\PrivateExtractIcons", "Str", "shell32.dll", "Int", 3, "Int", 32, "Int", 32, "Ptr*", &hIcon, "Ptr*", 0, "UInt", 1, "UInt", 0)
    if (hIcon != 0)
        SendMessage(0x0080, 1, hIcon, MainGui.Hwnd)
}

MainGui.Add("Text", "w480", "Main script selector. Now captures headers (comments/directives) for all merged blocks.")
BtnMain := MainGui.Add("Button", "w100", "Select Main")
BtnMain.OnEvent("Click", SelectMain)
TxtMain := MainGui.Add("Edit", "r1 w480 ReadOnly vMainPath", "No file selected.")

MainGui.Add("Text", "", "Process Log:")
LogBox := MainGui.Add("Edit", "r12 w480 ReadOnly vLog", "")

BtnMerge := MainGui.Add("Button", "Default w480 h40", "Merge & Tree-Shake")
BtnMerge.OnEvent("Click", ProcessMerge)

BtnOpen := MainGui.Add("Button", "w480 h30 Hidden vOpenBtn", "Open Merged File Folder")
BtnOpen.OnEvent("Click", (*) => Run("explore " . DirGetParent(OutputPath)))

MainGui.Show()

; --- Event Handlers ---

SelectMain(*) {
    global MainFile
    Selected := FileSelect(3, , "Select Main Script", "Scripts (*.ahk)")
    if (Selected = "")
        return
    
    MainFile := Selected
    MainGui["MainPath"].Value := Selected
}

ProcessMerge(*) {
    global MainFile, OutputPath
    if (MainFile = "")
        return
    
    MainGui["Log"].Value := "Analyzing #Include dependencies...`n"
    SourceCode := FileRead(MainFile)
    if (SourceCode = "")
        return

    LibFiles := GetIncludePaths(SourceCode, DirGetParent(MainFile))
    ProcessedMap := Map()
    MergedCode := ResolveDependencies(SourceCode, LibFiles, ProcessedMap, MainGui)
    
    ; Strip original #Includes so the new file is standalone
    CleanMain := RegExReplace(SourceCode, "im)^#Include\s+.*", "")
    OutputPath := RegExReplace(MainFile, "\.ahk$", "_Merged.ahk")
    
    if FileExist(OutputPath)
        FileDelete(OutputPath)
        
    FileAppend(CleanMain "`n`n; --- MERGED FUNCTIONS & CLASSES ---`n" MergedCode, OutputPath)
    
    MainGui["Log"].Value .= "DONE! Created: " OutputPath "`n"
    MainGui["OpenBtn"].Visible := true
    MsgBox("Successfully merged with headers!", "Success")
}

; --- Core Logic ---

GetIncludePaths(Source, WorkingDir) {
    Paths := []
    Pos := 1
    Match := ""
    TrimChars := " `t`"" . "'"
    
    while (Pos := RegExMatch(Source, "im)^#Include\s+(.*)", &Match, Pos)) {
        RawPath := Trim(Match[1], TrimChars)
        
        if (SubStr(RawPath, 1, 1) = "<") {
            LibName := Trim(RawPath, "<>") . ".ahk"
            PossiblePaths := [
                A_MyDocuments "\AutoHotkey\Lib\" LibName,
                A_ScriptDir "\Lib\" LibName,
                DirGetParent(A_AhkPath) "\Lib\" LibName
            ]
            FullP := ""
            for P in PossiblePaths {
                if FileExist(P) {
                    FullP := P
                    break
                }
            }
        } else {
            FullP := (SubStr(RawPath, 2, 1) != ":") ? WorkingDir "\" RawPath : RawPath
        }
            
        if (FullP != "" && FileExist(FullP)) {
            Paths.Push(FullP)
            try {
                InnerCode := FileRead(FullP)
                InnerPaths := GetIncludePaths(InnerCode, DirGetParent(FullP))
                for P in InnerPaths
                    Paths.Push(P)
            }
        }
        Pos += StrLen(Match[0])
    }
    return Paths
}

ResolveDependencies(SourceText, LibPaths, ProcessedMap, GuiObj) {
    NewCode := ""
    Pos := 1
    Match := ""

    ; We "clean" the search text so we don't try to resolve things inside strings
    CleanSearchText := RegExReplace(SourceText, '"[^"]*"', '""')

    while (Pos := RegExMatch(CleanSearchText, "[\w\d_]+(?=[\(\.])", &Match, Pos)) {
        ItemName := Match[0]
        Pos += StrLen(ItemName)
        
        if ProcessedMap.Has(ItemName) || IsBuiltIn(ItemName)
            continue
            
        for Path in LibPaths {
            if !FileExist(Path)
                continue
                
            FileContent := FileRead(Path)
            
            ; Check for Class first
            ClassPattern := "ismi)class\s+" ItemName "(\s+extends\s+[\w\d_.]+)?\s*\{"
            if RegExMatch(FileContent, ClassPattern, &Found) {
                GuiObj["Log"].Value .= "Importing Class: " ItemName "`n"
                FullBlock := ExtractBlockWithHeader(FileContent, Found.Pos)
                
                ProcessedMap[ItemName] := true
                Dependencies := ResolveDependencies(FullBlock, LibPaths, ProcessedMap, GuiObj)
                NewCode .= "`n" FullBlock "`n" Dependencies
                break
            }
            
            ; Check for Standalone Func
            FuncPattern := "ismi)^[ \t]*" ItemName "\s*\([^)]*\)\s*\{"
            if RegExMatch(FileContent, FuncPattern, &Found) {
                GuiObj["Log"].Value .= "Importing Func: " ItemName "`n"
                FullBlock := ExtractBlockWithHeader(FileContent, Found.Pos)
                
                ProcessedMap[ItemName] := true
                Dependencies := ResolveDependencies(FullBlock, LibPaths, ProcessedMap, GuiObj)
                NewCode .= "`n" FullBlock "`n" Dependencies
                break
            }
        }
    }
    return NewCode
}

ExtractBlockWithHeader(Text, StartPos) {
    ; 1. Look backwards for the header (comments, blank lines, directives)
    Lines := StrSplit(SubStr(Text, 1, StartPos - 1), "`n", "`r")
    Header := ""
    HeaderLines := []
    
    Loop Lines.Length {
        Idx := Lines.Length - (A_Index - 1)
        CurrentLine := Lines[Idx]
        Trimmed := Trim(CurrentLine)
        
        ; Keep going up if it's a comment, blank line, or directive
        if (Trimmed = "" || SubStr(Trimmed, 1, 1) = ";" || SubStr(Trimmed, 1, 1) = "#" || Trimmed = "*/") {
            HeaderLines.InsertAt(1, CurrentLine)
            ; If we hit a start of block comment, we definitely stop there
            if (SubStr(Trimmed, 1, 2) = "/*")
                break
        } else {
            break
        }
    }
    
    for Line in HeaderLines
        Header .= Line "`n"
        
    ; 2. Extract the actual block (braces)
    BraceCount := 0
    Started := false
    BlockBody := ""
    InBlockComment := false
    RemainingText := SubStr(Text, StartPos)
    
    Loop Parse, RemainingText, "`n", "`r" {
        Line := A_LoopField
        BlockBody .= Line "`n"
        
        ; Basic Block Comment Tracking
        Trimmed := Trim(Line)
        if (SubStr(Trimmed, 1, 2) = "/*")
            InBlockComment := true
        if (InBlockComment && InStr(Trimmed, "*/"))
            InBlockComment := false
            
        if (!InBlockComment) {
            CleanLine := RegExReplace(Line, '"[^"]*"', "") 
            CleanLine := RegExReplace(CleanLine, ";.*", "")

            if InStr(CleanLine, "{") {
                if (Started = false)
                    Started := true
                BraceCount += InStrCount(CleanLine, "{")
            }
            if InStr(CleanLine, "}")
                BraceCount -= InStrCount(CleanLine, "}")
        }
            
        if (Started = true) && (BraceCount <= 0)
            break
    }
    return Header . BlockBody
}

InStrCount(Haystack, Needle) {
    return (StrLen(Haystack) - StrLen(StrReplace(Haystack, Needle, ""))) / StrLen(Needle)
}

DirGetParent(Path) {
    if !InStr(Path, "\")
        return Path
    return SubStr(Path, 1, InStr(Path, "\", , -1) - 1)
}

IsBuiltIn(Name) {
    Static List := "Abs,ACos,ASin,ATan,BlockInput,Break,CallbackCreate,CallbackFree,CaretGetPos,Catch,Ceil,Click,ClipboardEx,ClipWait,ControlClick,ControlChooseIndex,ControlChooseString,ControlFocus,ControlGetChecked,ControlGetChoice,ControlGetEnabled,ControlGetFocus,ControlGetHwnd,ControlGetIndex,ControlGetItems,ControlGetPos,ControlGetText,ControlGetVisible,ControlHide,ControlHideDropDown,ControlMove,ControlSetChecked,ControlSetEnabled,ControlSetText,ControlShow,ControlShowDropDown,ControlAddItem,ControlDeleteItem,ControlSetExStyle,ControlSetStyle,ControlGetExStyle,ControlGetStyle,Cos,Critical,DateAdd,DateDiff,DetectHiddenText,DetectHiddenWindows,DirCopy,DirCreate,DirDelete,DirExist,DirMove,DirSelect,DllCall,Download,DriveEject,DriveGetCapacity,DriveGetFileSystem,DriveGetLabel,DriveGetList,DriveGetSerial,DriveGetSpaceFree,DriveGetStatus,DriveGetStatusCD,DriveGetType,DriveLock,DriveSetLabel,DriveUnlock,Edit,EditGetCurrentCol,EditGetCurrentLine,EditGetLine,EditGetLineCount,EditGetSelectedText,EditPaste,Else,EnvGet,EnvSet,Exit,ExitApp,Exp,FileAppend,FileCopy,FileCreateShortcut,FileDelete,FileEncoding,FileExist,FileGetAttrib,FileGetShortcut,FileGetSize,FileGetTime,FileGetVersion,FileInstall,FileMove,FileOpen,FileRead,FileRecycle,FileRecycleEmpty,FileRemoveAttrib,FileSelect,FileSetAttrib,FileSetTime,Finally,Floor,For,Format,FormatTime,GetKeyName,GetKeySC,GetKeyState,GetKeyVK,GetMethod,GetNumLockState,GetScrollLockState,GroupActivate,GroupAdd,GroupClose,GroupDeactivate,GuiCtrlFromHwnd,GuiFromHwnd,HasBase,HasMethod,HasProp,HotIf,HotIfWinActive,HotIfWinExist,HotIfWinNotActive,HotIfWinNotExist,Hotkey,Hotstring,If,IL_Add,IL_Create,IL_Destroy,ImageSearch,IniDelete,IniRead,IniWrite,InputBox,InputHook,InstallKeybdHook,InstallMouseHook,InStr,IsLabel,IsNumber,IsObject,IsSet,IsSetRef,KeyHistory,KeyWait,ListHotkeys,ListLines,ListVars,Log,Ln,Loop,Max,Min,Mod,MonitorGet,MonitorGetCount,MonitorGetName,MonitorGetWorkArea,MouseClick,MouseClickDrag,MouseMove,MsgBox,NumGet,NumPut,ObjAddRef,ObjBindMethod,ObjGetBase,ObjGetCapacity,ObjHasOwnProp,ObjOwnPropCount,ObjOwnProps,ObjPtr,ObjPtrAddRef,ObjRelease,ObjSetBase,ObjSetCapacity,OnClipboardChange,OnError,OnExit,OnMessage,OutputDebug,Pause,Persistent,PixelGetColor,PixelSearch,PostMessage,ProcessClose,ProcessExist,ProcessGetName,ProcessGetParent,ProcessGetPath,ProcessSetPriority,ProcessWait,ProcessWaitClose,Random,RegDelete,RegDeleteKey,RegExMatch,RegExReplace,RegWrite,Reload,Return,Round,Run,RunAs,RunWait,Send,SendEvent,SendInput,SendMessage,SendMode,SendPlay,SendLevel,SetCapsLockState,SetControlDelay,SetDefaultMouseSpeed,SetKeyDelay,SetMouseDelay,SetNumLockState,SetRegView,SetScrollLockState,SetStoreCapsLockMode,SetTimer,SetTitleMatchMode,SetWinDelay,SetWorkingDir,Sin,Sleep,Sort,SoundBeep,SoundGetInterface,SoundGetMute,SoundGetName,SoundGetVolume,SoundPlay,SoundSetMute,SoundSetVolume,SplitPath,Sqrt,StatusBarGetText,StatusBarWait,StrCompare,StrGet,StrLen,StrLower,StrPtr,StrPut,StrReplace,StrSplit,StrUpper,SubStr,Suspend,Switch,SysGet,SysGetIPAddresses,Tan,Thread,Throw,TickCount,ToolTip,TraySetIcon,TrayTip,Trim,Try,Type,Until,VarSetStrCapacity,VerCompare,WinActivate,WinActivateBottom,WinActive,WinClose,WinExist,WinGetClass,WinGetClientPos,WinGetControls,WinGetControlsHwnd,WinGetCount,WinGetExStyle,WinGetID,WinGetIDLast,WinGetList,WinGetMinMax,WinGetPID,WinGetPos,WinGetProcessName,WinGetProcessPath,WinGetStyle,WinGetText,WinGetTitle,WinHide,WinKill,WinMaximize,WinMinimize,WinMinimizeAll,WinMinimizeAllUndo,WinMove,WinMoveBottom,WinMoveTop,WinRedraw,WinRestore,WinSetAlwaysOnTop,WinSetEnabled,WinSetExStyle,WinSetRegion,WinSetStyle,WinSetTitle,WinSetTransColor,WinSetTransparent,WinShow,WinWait,WinWaitActive,WinWaitClose,WinWaitNotActive"
    return InStr("," List ",", "," Name ",")
}