; Version: 1.0.0.12
; Description: Fixed Parameter #1 error by handling FileSelect array return correctly.

#Requires AutoHotkey v2.0

; Global variables for UI
global MainFile := ""
global LibFiles := []
global OutputPath := ""

; Create GUI
MainGui := Gui("+Resize", "AHK Dependency Merger v1.0.0.12")
MainGui.SetFont("s10", "Segoe UI")

; Adding an icon using PrivateExtractIcons (Case Sensitive)
try {
    hIcon := 0
    DllCall("user32\PrivateExtractIcons", "Str", "shell32.dll", "Int", 3, "Int", 32, "Int", 32, "Ptr*", &hIcon, "Ptr*", 0, "UInt", 1, "UInt", 0)
    if (hIcon != 0)
        SendMessage(0x0080, 1, hIcon, MainGui.Hwnd)
}

MainGui.Add("Text", "w400", "Step 1: Select your main script file.")
BtnMain := MainGui.Add("Button", "w100", "Select Main")
BtnMain.OnEvent("Click", SelectMain)
TxtMain := MainGui.Add("Edit", "r1 w480 ReadOnly vMainPath", "No file selected.")

MainGui.Add("Text", "w400", "Step 2: Add library files to search within.")
BtnLib := MainGui.Add("Button", "w100", "Add Library")
BtnLib.OnEvent("Click", AddLib)
TxtLib := MainGui.Add("Edit", "r3 w480 ReadOnly vLibPaths", "")

MainGui.Add("Text", "", "Process Log:")
LogBox := MainGui.Add("Edit", "r10 w480 ReadOnly vLog", "")

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

AddLib(*) {
    global LibFiles
    ; In v2, Multi-select returns an Array
    Selected := FileSelect("M3", , "Select Library Files", "Scripts (*.ahk)")
    if (Selected = "")
        return
    
    ; FIXED: Selected is already an array in v2 when using "M"
    for Item in Selected {
        LibFiles.Push(Item)
    }
    
    DisplayPath := ""
    for Path in LibFiles
        DisplayPath .= Path "`n"
    MainGui["LibPaths"].Value := DisplayPath
}

ProcessMerge(*) {
    global MainFile, LibFiles, OutputPath
    if (MainFile = "")
        return
    
    MainGui["Log"].Value := "Starting merge...`n"
    SourceCode := FileRead(MainFile)
    if (SourceCode = "")
        return

    ProcessedMap := Map()
    MergedFunctions := ResolveDependencies(SourceCode, LibFiles, ProcessedMap, MainGui)
    
    CleanMain := RegExReplace(SourceCode, "im)^#Include\s+.*", "")
    OutputPath := RegExReplace(MainFile, "\.ahk$", "_Merged.ahk")
    
    if FileExist(OutputPath)
        FileDelete(OutputPath)
        
    FileAppend(CleanMain "`n`n; --- MERGED FUNCTIONS ---`n" MergedFunctions, OutputPath)
    
    MainGui["Log"].Value .= "DONE! Created: " OutputPath "`n"
    MainGui["OpenBtn"].Visible := true
    MsgBox("Successfully merged!", "Success")
}

; --- Core Logic ---

ResolveDependencies(SourceText, LibPaths, ProcessedMap, GuiObj) {
    NewCode := ""
    Pos := 1
    Match := ""

    while (Pos := RegExMatch(SourceText, "[\w\d_]+(?=\()", &Match, Pos)) {
        FuncName := Match[0]
        Pos += StrLen(FuncName)
        
        if ProcessedMap.Has(FuncName) || IsBuiltIn(FuncName)
            continue
            
        for Path in LibPaths {
            if !FileExist(Path)
                continue
                
            FileContent := FileRead(Path)
            Pattern := "ismi)^" FuncName "\s*\([^)]*\)\s*\{"
            
            if RegExMatch(FileContent, Pattern, &Found) {
                GuiObj["Log"].Value .= "Found: " FuncName " in " (InStr(Path, "\") ? SubStr(Path, InStr(Path, "\", , -1) + 1) : Path) "`n"
                Body := ExtractFunctionBody(FileContent, Found.Pos)
                if (Body = "")
                    continue
                
                ProcessedMap[FuncName] := true
                Dependencies := ResolveDependencies(Body, LibPaths, ProcessedMap, GuiObj)
                NewCode .= "`n" Body "`n" Dependencies
                break
            }
        }
    }
    return NewCode
}

ExtractFunctionBody(Text, StartPos) {
    BraceCount := 0
    Started := false
    Result := ""
    RemainingText := SubStr(Text, StartPos)
    
    Loop Parse, RemainingText, "`n", "`r" {
        Line := A_LoopField
        Result .= Line "`n"
        
        CleanLine := RegExReplace(Line, '"[^"]*"', "") 
        CleanLine := RegExReplace(CleanLine, ";.*", "")

        if InStr(CleanLine, "{") {
            if (Started = false)
                Started := true
            BraceCount += InStrCount(CleanLine, "{")
        }
        
        if InStr(CleanLine, "}")
            BraceCount -= InStrCount(CleanLine, "}")
            
        if (Started = true) && (BraceCount <= 0)
            break
    }
    return Result
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
    Static List := "Abs,ACos,ASin,ATan,BlockInput,Break,CallbackCreate,CallbackFree,CaretGetPos,Catch,Ceil,Click,ClipboardEx,ClipWait,ControlClick,ControlChooseIndex,ControlChooseString,ControlFocus,ControlGetChecked,ControlGetChoice,ControlGetEnabled,ControlGetFocus,ControlGetHwnd,ControlGetIndex,ControlGetItems,ControlGetPos,ControlGetText,ControlGetVisible,ControlHide,ControlMove,ControlSetChecked,ControlSetEnabled,ControlSetText,ControlShow,ControlAddItem,ControlDeleteItem,ControlSetExStyle,ControlSetStyle,ControlGetExStyle,ControlGetStyle,Cos,Critical,DateAdd,DateDiff,DetectHiddenText,DetectHiddenWindows,DirCopy,DirCreate,DirDelete,DirExist,DirMove,DirSelect,DllCall,Download,DriveEject,DriveGetCapacity,DriveGetFileSystem,DriveGetLabel,DriveGetList,DriveGetSerial,DriveGetSpaceFree,DriveGetStatus,DriveGetStatusCD,DriveGetType,DriveLock,DriveSetLabel,DriveUnlock,Edit,EditGetCurrentCol,EditGetCurrentLine,EditGetLine,EditGetLineCount,EditGetSelectedText,EditPaste,Else,EnvGet,EnvSet,Exit,ExitApp,Exp,FileAppend,FileCopy,FileCreateShortcut,FileDelete,FileEncoding,FileExist,FileGetAttrib,FileGetShortcut,FileGetSize,FileGetTime,FileGetVersion,FileInstall,FileMove,FileOpen,FileRead,FileRecycle,FileRecycleEmpty,FileRemoveAttrib,FileSelect,FileSetAttrib,FileSetTime,Finally,Floor,For,Format,FormatTime,GetKeyName,GetKeySC,GetKeyState,GetKeyVK,GetMethod,GetNumLockState,GetScrollLockState,GroupActivate,GroupAdd,GroupClose,GroupDeactivate,GuiCtrlFromHwnd,GuiFromHwnd,HasBase,HasMethod,HasProp,HotIf,HotIfWinActive,HotIfWinExist,HotIfWinNotActive,HotIfWinNotExist,Hotkey,Hotstring,If,IL_Add,IL_Create,IL_Destroy,ImageSearch,IniDelete,IniRead,IniWrite,InputBox,InputHook,InstallKeybdHook,InstallMouseHook,InStr,IsLabel,IsNumber,IsObject,IsSet,IsSetRef,KeyHistory,KeyWait,ListHotkeys,ListLines,ListVars,Log,Ln,Loop,Max,Min,Mod,MonitorGet,MonitorGetCount,MonitorGetName,MonitorGetWorkArea,MouseClick,MouseClickDrag,MouseMove,MsgBox,NumGet,NumPut,ObjAddRef,ObjBindMethod,ObjGetBase,ObjGetCapacity,ObjHasOwnProp,ObjOwnPropCount,ObjOwnProps,ObjPtr,ObjPtrAddRef,ObjRelease,ObjSetBase,ObjSetCapacity,OnClipboardChange,OnError,OnExit,OnMessage,OutputDebug,Pause,Persistent,PixelGetColor,PixelSearch,PostMessage,ProcessClose,ProcessExist,ProcessGetName,ProcessGetParent,ProcessGetPath,ProcessSetPriority,ProcessWait,ProcessWaitClose,Random,RegDelete,RegDeleteKey,RegExMatch,RegExReplace,RegWrite,Reload,Return,Round,Run,RunAs,RunWait,Send,SendEvent,SendInput,SendMessage,SendMode,SendPlay,SendLevel,SetCapsLockState,SetControlDelay,SetDefaultMouseSpeed,SetKeyDelay,SetMouseDelay,SetNumLockState,SetRegView,SetScrollLockState,SetStoreCapsLockMode,SetTimer,SetTitleMatchMode,SetWinDelay,SetWorkingDir,Sin,Sleep,Sort,SoundBeep,SoundGetInterface,SoundGetMute,SoundGetName,SoundGetVolume,SoundPlay,SoundSetMute,SoundSetVolume,SplitPath,Sqrt,StatusBarGetText,StatusBarWait,StrCompare,StrGet,StrLen,StrLower,StrPtr,StrPut,StrReplace,StrSplit,StrUpper,SubStr,Suspend,Switch,SysGet,SysGetIPAddresses,Tan,Thread,Throw,TickCount,ToolTip,TraySetIcon,TrayTip,Trim,Try,Type,Until,VarSetStrCapacity,VerCompare,WinActivate,WinActivateBottom,WinActive,WinClose,WinExist,WinGetClass,WinGetClientPos,WinGetControls,WinGetControlsHwnd,WinGetCount,WinGetExStyle,WinGetID,WinGetIDLast,WinGetList,WinGetMinMax,WinGetPID,WinGetPos,WinGetProcessName,WinGetProcessPath,WinGetStyle,WinGetText,WinGetTitle,WinHide,WinKill,WinMaximize,WinMinimize,WinMinimizeAll,WinMinimizeAllUndo,WinMove,WinMoveBottom,WinMoveTop,WinRedraw,WinRestore,WinSetAlwaysOnTop,WinSetEnabled,WinSetExStyle,WinSetRegion,WinSetStyle,WinSetTitle,WinSetTransColor,WinSetTransparent,WinShow,WinWait,WinWaitActive,WinWaitClose,WinWaitNotActive"
    return InStr("," List ",", "," Name ",")
}