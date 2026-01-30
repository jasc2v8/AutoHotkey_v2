;====================================================================================================
; #region 1. Merged: D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\BackupTool_Merged.ahk
;====================================================================================================
; Included Scripts:

;  C:\Users\Jim\Documents\AutoHotkey\Lib\Colors.ahk
;  C:\Users\Jim\Documents\AutoHotkey\Lib\IniFile.ahk
;  C:\Users\Jim\Documents\AutoHotkey\Lib\LogFile.ahk
;  C:\Users\Jim\Documents\AutoHotkey\Lib\NamedPipe.ahk
;  C:\Users\Jim\Documents\AutoHotkey\Lib\ProcessMonitor.ahk
;  C:\Users\Jim\Documents\AutoHotkey\Lib\RunAdmin.ahk
;  C:\Users\Jim\Documents\AutoHotkey\Lib\RunCMD.ahk
;  C:\Users\Jim\Documents\AutoHotkey\Lib\RunShell.ahk
;  C:\Users\Jim\Documents\AutoHotkey\Lib\SystemCursor.ahk
;====================================================================================================
; #region 2. Included Classes and Functions:
;====================================================================================================
;====================================================================================================
; #region 2.1 Colors: C:\Users\Jim\Documents\AutoHotkey\Lib\Colors.ahk
;====================================================================================================
; TITLE  :  Colors v1.0.0.13
; SOURCE :  Gemini and https://www.color-meanings.com/
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Colors for Guis and Controls
; USAGE  :
; NOTES  :
/*
    TODO:
*/
;#Requires AutoHotkey v2+
/*
    Version: 1.0.0.13
*/
class Colors {
    ;; --- ~ MY FAVORITES ~ ---
    static AirSuperiorityBlue   := "72A0C1"
    static AlaskanBlue          := "6DA9D2"
    static ArticBlue            := "C6E6FB"
    static CarolinaBlue         := "4B9CD3"
    static ColumbiaBlue         := "B9D9EB"
    static MarianBlue           := "E1EBEE"
    static NonPhotoBlue         := "A4DDED"
    static OceanBlue            := "009DC4"
    static SteelBlue            := "4682B4"
    static SteelBlueLight05     := "517FBF"
    static SteelBlueLight10     := "5888B9"
    static SteelBlueLight15     := "628FBE"
    static SteelBlueLight20     := "6B9BC3"
    static SteelBlueLight25     := "74A1C7"
    static SilverLakeBlue       := "5D89BA"
    static StoneBlue            := "819EA8"
    static WinterBlue           := "9EBACF"
    static MyGui                := this.AirSuperiorityBlue
    static Gold                 := "FFD700"
    static SourLemon            := "FFEAA7"
    static Windstorm            := "6B9BC2"
    static WedgeWood            := "4E7F9E"
    static MyCtrl               := this.SourLemon
    ;; --- BLACKS ---
    static Black := "000000"
    static CafeNoir := "4B3621"
    static Charcoal := "36454F"
    static Ebony := "555D50"
    static Jet := "343434"
    static Licorice := "1A1110"
    static Midnight := "2B2B2B"
    static Obsidian := "080808"
    static Oil := "3B3131"
    static Onyx := "353839"
    static OuterSpace := "414A4C"
    static Raisin := "242124"
    ;; --- BLUES ---
    static Azure := "007FFF"
    static Blue := "0000FF"
    static Cerulean := "007BA7"
    static CornflowerBlue := "6495ED"
    static MidnightBlue := "191970"
    static NavyBlue := "000080"
    static RoyalBlue := "4169E1"
    static SkyBlue := "87CEEB"
    static Teal := "008080"
    ;; --- CYANS ---
    static Aqua := "00FFFF"
    static Aquamarine := "7FFFD4"
    static Celeste := "B2FFFF"
    static Cyan := "00FFFF"
    static DarkCyan := "008B8B"
    static DarkTurquoise := "00CED1"
    static ElectricBlue := "7DF9FF"
    static LightCyan := "E0FFFF"
    static PaleTurquoise := "AFEEEE"
    static RobinEggBlue := "00CCCC"
    static TiffanyBlue := "0ABAB5"
    static Turquoise := "40E0D0"
    ;; --- GRAYS ---
    static AshGray := "B2BEB5"
    static BattleshipGray := "848482"
    static CadetGray := "91A3B0"
    static CoolGray := "8C92AC"
    static DarkGray := "A9A9A9"
    static DimGray := "696969"
    static Gainsboro := "DCDCDC"
    static Gray := "808080"
    static Gunmetal := "2A3439"
    static LightGray := "D3D3D3"
    static LightSlateGray := "778899"
    static Platinum := "E5E4E2"
    static Silver := "C0C0C0"
    static SlateGray := "708090"
    ;; --- GREENS ---
    static Emerald := "50C878"
    static ForestGreen := "228B22"
    static Green := "008000"
    static JungleGreen := "29AB87"
    static KellyGreen := "4CBB17"
    static Lime := "00FF00"
    static MintGreen := "98FB98"
    static Olive := "808000"
    static SageGreen := "9DC183"
    static SeaGreen := "2E8B57"
    ;; --- MAGENTAS ---
    static AfricanViolet := "B284BE"
    static AmaranthMagenta := "ED3CCA"
    static DarkMagenta := "8B008B"
    static Fuchsia := "FF00FF"
    static HotMagenta := "FF1DCE"
    static Magenta := "FF00FF"
    static Orchid := "DA70D6"
    static QuinacridoneMagenta := "8E3A59"
    static RazzleDazzleRose := "FF33CC"
    static SkyMagenta := "CF71AF"
    static SteelPink := "CC33CC"
    ;; --- ORANGES ---
    static AlloyOrange := "C35214"
    static Amber := "FFBF00"
    static Apricot := "FBCEB1"
    static Coral := "FF7F50"
    static DarkOrange := "FF8C00"
    static Orange := "FFA500"
    static Peach := "FFE5B4"
    static Pumpkin := "FF7518"
    static Tangerine := "F28500"
    static VividOrange := "FF5E0E"
    ;; --- PURPLES & PINKS ---
    static Amaranth := "E52B50"
    static DeepPink := "FF1493"
    static HotPink := "FF69B4"
    static Lavender := "E6E6FA"
    static Pink := "FFC0CB"
    static Plum := "DDA0DD"
    static Purple := "800080"
    ;; --- REDS ---
    static BarnRed := "7C0A02"
    static ChiliRed := "C21807"
    static Crimson := "B80F0A"
    static DarkRed := "8B0000"
    static FireBrick := "B22222"
    static ImperialRed := "ED2939"
    static IndianRed := "CD5C5C"
    static Red := "FF0000"
    static Scarlet := "FF2400"
    static Tomato := "FF6347"
    ;; --- WHITES ---
    static Alabaster := "EDEAE0"
    static AntiqueWhite := "FAEBD7"
    static Beige := "F5F5DC"
    static Cornsilk := "FFF8DC"
    static Cream := "FFFDD0"
    static Eggshell := "F0EAD6"
    ;; --- YELLOWS ---
    static CanaryYellow := "FFEF00"
    static Citrine := "E4D00A"
    static CyberYellow := "FFD300"
    static Flax := "EEDC82"
    static Goldenrod := "DAA520"
    static LemonChiffon := "FFFACD"
    static Maize := "FBEC5D"
    static Mustard := "FFDB58"
    static RoyalYellow := "FADA5E"
    static Saffron := "F4C430"
    static SelectiveYellow := "FFBA00"
    static Yellow := "FFFF00"
    ;; FUNCTIONS
    static GetName(Hex) {
        Hex := StrReplace(StrUpper(Hex), "#", "")
        for Name, Value in this.OwnProps() {
            if (Value = Hex)
                return Name
        }
        return "Unknown"
    }
}
; --- Example Usage ---
; Accessing a property
; MsgBox("The hex for Steel Blue is: " . Colors.SteelBlue)
; ; Using the helper function
; MyHex := "72A0C1"
; ColorName := Colors.GetName(MyHex)
; if (ColorName = "Unknown")
;     return
; MsgBox("The name for " . MyHex . " is " . ColorName)
;====================================================================================================
; #region 2.2 IniFile: C:\Users\Jim\Documents\AutoHotkey\Lib\IniFile.ahk
;====================================================================================================
; ABOUT IniFile v1.0
/*
    TODO:
        Update tests below
*/
;#Requires AutoHotkey v2.0+
;-----------------------------------------------------------------
; USAGE:    INI := IniFile(Path) ; defalult A_ScriptFullPath.ini
;           Read(section, key)
;           ReadSection(section)
;           ReadSectionNames()
;           ReadSettings(key)
;           Write(section, key, value)
;           WriteSettings(key, value)
; RETURNS:  Read:   Success=Value, Error=''
;           Write:  Success=true, Error=false 
;----------------------------------------------------------------
class IniFile
{
    Path := ''
    __New(IniFilePath:="")
    {
        if IniFilePath = "" {
            IniFilePath := this.StrSplitPath(A_ScriptFullPath).NameNoExt ".ini"
        } else {
            SplitPath(IniFilePath,, &IniDir)
            if !DirExist(IniDir)
            DirCreate(IniDir)
        }
        if !FileExist(IniFilePath)
            FileAppend("[Settings]`r`n", IniFilePath)
            
        this.Path := IniFilePath
        return this.GetPath()
	}
    GetPath() => this.Path
    Read(section, key) {
        try {
            if FileExist(this.Path) {
                return IniRead(this.Path, section, key)
            } else {
                return
            }
        } catch Error as e {
            return
        }
	}
    ReadSection(section) {
        try {
            if FileExist(this.Path) {
                return IniRead(this.Path, section)
            } else {
                return
            }
        } catch Error as e {
            return
        }
	}
    ReadSectionNames() {
        try {
            if FileExist(this.Path) {
                return IniRead(this.Path)
            } else {
                return
            }
        } catch Error as e {
            return
        }
	}
	ReadSettings(key) {
        try {
            if FileExist(this.Path) {
        		return IniRead(this.Path, "Settings", key)
            } else {
                return
            }
        } catch Error as e {
            return
        }
	}
    Write(section, key, value) {
		try {
			if FileExist(this.Path) {
				IniWrite(value, this.Path, section, key)
				return true
			} else {
				return false
			}
		} catch Error as e {
			return false
		}
	}
	
	WriteSettings(key, value) {
                try {
            if FileExist(this.Path) {
                return IniWrite(value, this.Path, "Settings", key )
            } else {
                return false
            }
        } catch Error as e {
            return false
        }
	}
    StrSplitPath(path) {
        path := StrReplace(path, "\\", "\")
        SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
        SplitPath(Dir,,&ParentDir)
        return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
    }
}
;====================================================================================================
; #region 2.3 LogFile: C:\Users\Jim\Documents\AutoHotkey\Lib\LogFile.ahk
;====================================================================================================
; TITLE  :  LogFileHelper v1.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
/*
    TODO:
*/
;#Requires AutoHotkey v2.0+
class LogFile
{
    LogFilePath := ""
    Label       := ""
    Disabled    := false
    __New(LogFilePath:="", Label:="", Enabled:=true)
    {
        if LogFilePath
            this.LogFilePath := LogFilePath
        else
            this.LogFilePath := "D:\LogFile.txt"
        if Label
            this.Label := Label
        else
            this.Label := "DEBUG"
        this.Disabled := !Enabled
    }
    Clear()
    {
        this.Delete()
        FileAppend("", this.LogFilePath)
    }
    Delete()
    {
        if FileExist(this.LogFilePath)
            FileDelete(this.LogFilePath)
    }
    Disable(Bool:=true)
    {
        this.Disabled := Bool
    }
    Write(Message, Label:=this.Label)
    {
        if (this.Disabled)
            return
        msg:= FormatTime(A_Now, "HH:mm:ss") . ":" . A_MSec . " " Label . ": " . Message . "`n"
        FileAppend(msg, this.LogFilePath)
    }
    Save()
    {
        newPath:= StrReplace(this.LogFilePath, ".txt", "_" FormatTime(A_Now, "HH_mm_ss") ".txt")
        if FileExist(this.LogFilePath)
            FileMove(this.LogFilePath, newPath)
    }
}
;====================================================================================================
; #region 2.4 NamedPipe: C:\Users\Jim\Documents\AutoHotkey\Lib\NamedPipe.ahk
;====================================================================================================
; TITLE  :  NamedPipeHelper v1.0
; SOURCE :  chatGPT and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Helper for Named Pipe IPC communication
; BENEFIT:  Send and Receive are Synchronous for easy read/write sharing.
/*
    TODO:
*/
;#Requires AutoHotkey v2.0+
class NamedPipe
{
    PipeName := ""
    Handle   := 0
    static SDDL := "D:(A;;GA;;;BU)(A;;GA;;;BA)"
    __New(pipeName:="")
    {
        if (pipeName = "")
            this.PipeName := "\\.\pipe\Global\AHK_Pipe"
        else
            this.PipeName := "\\.\pipe\Global\" pipeName
    }
    ; =========================
    ; SERVICE SIDE (SERVER)
    ; =========================
    Create()
    {
        if this.PipeExists(this.PipeName) {
            ;return
            
            throw Error("Pipe already exists")
            ;if DllCall("kernel32\ConnectNamedPipe", "Ptr", this.Handle, "Ptr", 0) = 0
            ;    throw Error("ConnectNamedPipe failed")
        }
        
        sa := this._CreateSecurityAttributes()
        this.Handle := DllCall("kernel32\CreateNamedPipeW"
            , "Str", this.PipeName
            , "UInt", 0x00000003                      ; PIPE_ACCESS_DUPLEX
            , "UInt", 0x00000004 | 0x00000002         ; MESSAGE | READMODE_MESSAGE
            , "UInt", 1
            , "UInt", 4096
            , "UInt", 4096
            , "UInt", 0
            , "Ptr", sa
            , "Ptr")
        if this.Handle = -1
            throw Error("CreateNamedPipe failed")
        if DllCall("kernel32\ConnectNamedPipe", "Ptr", this.Handle, "Ptr", 0) = 0
            throw Error("ConnectNamedPipe failed")
    }
    ; =========================
    ; USER SIDE (CLIENT)
    ; =========================
    Wait(timeout := -1) {
        sa := this._CreateSecurityAttributes()
        startTime := A_TickCount
        
        Loop {
            ; Attempt to open the pipe
            ; GENERIC_READ (0x80000000) | GENERIC_WRITE (0x40000000) = 0xC0000000
            ; OPEN_EXISTING = 3
            hPipe := DllCall("CreateFileW", 
                "Str",  this.PipeName, 
                "UInt", 0xC0000000, ; Access: Read/Write
                "UInt", 0,          ; No sharing
                "Ptr",  0,          ; Security attributes
                "UInt", 3,          ; Creation disposition: OPEN_EXISTING
                "UInt", 0,          ; Attributes
                "Ptr",  0)
            ; Success! Pipe is opened.
            if (hPipe != -1) {
                this.Handle := hPipe
                return true
            }
            lastErr := A_LastError
            ; Case 1: Pipe does not exist yet (Error 2)
            if (lastErr == 2) {
                if (timeout != -1 && (A_TickCount - startTime) >= timeout)
                    return 0
                Sleep(100) ; Wait and try again
                continue
            }
            ; Case 2: Pipe exists but all instances are busy (Error 231)
            if (lastErr == 231) {
                ; WaitNamedPipe will actually wait until an instance is free
                ; We use 500ms for the Win32 wait, then loop back to CreateFile
                DllCall("WaitNamedPipe", "Str", this.PipeName, "UInt", 500)
                continue
            }
            ; Case 3: Any other unexpected error
            return 0
        }
    }
    ; =========================
    ; SEND UTF-16 MESSAGE
    ; =========================
    Send(text)
    {
        len := StrPut(text, "UTF-16")
        buf := Buffer(len * 2)
        StrPut(text, buf, "UTF-16")
        ; Synchronous write then wait until a Read operation completes on the other end of the pipe.
        if !DllCall("kernel32\WriteFile"
            , "Ptr", this.Handle
            , "Ptr", buf
            , "UInt", buf.Size
            , "UInt*", 0
            , "Ptr", 0)
            throw Error("WriteFile failed")
        Sleep 10 ; Delay to allow buffers to reset
    }
    ; =========================
    ; RECEIVE UTF-16 MESSAGE
    ; =========================
    Receive()
    {
        buf := Buffer(4096)
        bytes := 0
        ; Synchronous read then wait until a Write operation completes on the other end of the pipe.
        if !DllCall("kernel32\ReadFile"
            , "Ptr", this.Handle
            , "Ptr", buf
            , "UInt", buf.Size
            , "UInt*", &bytes
            , "Ptr", 0)
            throw Error("ReadFile failed")
        return StrGet(buf, bytes // 2, "UTF-16")
    }
    ; =========================
    ; CLEANUP
    ; =========================
    Close()
    {
        if this.Handle
        {
            DllCall("kernel32\DisconnectNamedPipe", "Ptr", this.Handle)
            DllCall("kernel32\CloseHandle", "Ptr", this.Handle)
            this.Handle := 0
        }
    }
    PipeExists(PipeName) {
        ; GENERIC_READ = 0x80000000
        ; OPEN_EXISTING = 3
        hPipe := DllCall("CreateFile", 
            "Str", PipeName, 
            "UInt", 0x80000000, 
            "UInt", 0, 
            "Ptr", 0, 
            "UInt", 3, 
            "UInt", 0, 
            "Ptr", 0, 
            "Ptr")
        if (hPipe != -1) {
            DllCall("CloseHandle", "Ptr", hPipe)
            return true
        }
        
        ; If CreateFile failed, check if it's because the pipe is busy or doesn't exist
        lastError := A_LastError
        ; ERROR_PIPE_BUSY = 231
        ; If the pipe is busy, it definitely exists.
        return (lastError == 231)
    }
    ; =========================
    ; INTERNAL: SECURITY ATTRS
    ; =========================
    _CreateSecurityAttributes()
    {
        sa := Buffer(A_PtrSize * 3, 0)
        sd := 0
        if !DllCall("advapi32\ConvertStringSecurityDescriptorToSecurityDescriptorW"
            , "Str", NamedPipe.SDDL
            , "UInt", 1
            , "Ptr*", &sd
            , "Ptr", 0)
            throw Error("SDDL conversion failed")
        NumPut("Ptr", sd, sa, A_PtrSize)        ; lpSecurityDescriptor
        NumPut("Int", 0,  sa, A_PtrSize*2)      ; bInheritHandle = FALSE
        return sa
    }
}
;====================================================================================================
; #region 2.5 ProcessMonitor: C:\Users\Jim\Documents\AutoHotkey\Lib\ProcessMonitor.ahk
;====================================================================================================
; TITLE  :  ProcessMonitor v1.1.0.6 - Add Now
; SOURCE :  jasc2v8 and Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Periodically monitors a process and signals status/completion.
; USAGE  :
; NOTES  :
; ==============================================================================
; Name .........: ProcessMonitor
; Description ..: Periodically monitors a process and signals status/completion.
; Version ......: 1.1.6
; AHK Version ..: v2.0
; ==============================================================================
class ProcessMonitor {
    static Version := "1.1.6"
    __New(ProcessNameOrPID, WorkingDir := "", AutoStart := false, CheckInterval := 500) {
        this.Target := ProcessNameOrPID
        this.Interval := CheckInterval
        this.AutoStart := AutoStart
        this.WorkingDir := WorkingDir
        this.IsRunning := false
        this.StartTime := 0
        this.OnExitCallback := ""
        this.OnStatusCallback := ""
        this.OnStopCallback := ""
        this.TimerInstance := ObjBindMethod(this, "_CheckStatus")
        ; Handle AutoStart logic immediately on creation
        if (this.AutoStart && !this.PID)
        {
            try 
            {
                Run(this.Target, this.WorkingDir)
            }
            catch Error as e
            {
                MsgBox("Failed to auto-start process: " . this.Target . "`n`n" . e.Message)
                return
            }
        }
    }
    ; Returns the current time as a formatted string (HH:mm:ss)
    Now {
        get {
            return FormatTime(A_Now, "HH:mm:ss")
        }
    }
    ; Returns the Process ID if it exists, otherwise 0
    PID {
        get {
            return ProcessExist(this.Target)
        }
    }
    ; Returns the elapsed time as a formatted string (HH:mm:ss)
    Elapsed {
        get {
            if (this.StartTime = 0)
            {
                return "00:00:00"
            }
            
            Diff := DateDiff(A_Now, this.StartTime, "Seconds")
            return Format("{1:02}:{2:02}:{3:02}", Floor(Diff/3600), Floor(Mod(Diff,3600)/60), Mod(Diff,60))
        }
    }
    ; Change the process priority (Low, BelowNormal, Normal, AboveNormal, High, Realtime)
    SetPriority(Level := "Normal") {
        if (this.PID)
        {
            ProcessSetPriority(Level, this.PID)
        }
        return
    }
    ; Starts the monitoring loop
    Start(OnExitNotify, OnStatusNotify := "", OnStopNotify := "") {
        this.OnExitCallback := OnExitNotify
        this.OnStatusCallback := OnStatusNotify
        this.OnStopCallback := OnStopNotify
        this.IsRunning := true
        this.StartTime := A_Now
        SetTimer(this.TimerInstance, this.Interval)
    }
    ; Stops the monitoring loop manually
    Stop() {
        SetTimer(this.TimerInstance, 0)
        this.IsRunning := false
        
        if (this.OnStopCallback != "")
        {
            this.OnStopCallback.Call("Stopped")
        }
    }
    ; Restarts the process and resets the timer
    Restart() {
        ; Kill current process if it exists
        if (this.PID)
        {
            ProcessClose(this.Target)
        }
        try 
        {
            Run(this.Target, this.WorkingDir)
            this.StartTime := A_Now
        }
        catch Error as e
        {
            MsgBox("Failed to restart process: " . this.Target . "`n`n" . e.Message)
            return
        }
    }
    ; Internal check logic
    _CheckStatus() {
        ; Check if process exists
        if (!this.PID)
        {
            SetTimer(this.TimerInstance, 0)
            this.IsRunning := false
            
            if (this.OnExitCallback != "")
            {
                this.OnExitCallback.Call("Finished")
            }
            return
        }
        ; If still running, trigger status callback if defined
        if (this.OnStatusCallback != "")
        {
            this.OnStatusCallback.Call("Running")
        }
    }
}
;====================================================================================================
; #region 2.6 RunAdmin: C:\Users\Jim\Documents\AutoHotkey\Lib\RunAdmin.ahk
;====================================================================================================
; TITLE  :  RunAdmin v1.0.0.5
; SOURCE :  AHK Forums and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt.
; SUMMARY:  On-Demand Task must be in Task Scheduler: Name=RunAdmin, Target=RunAdmin.ahk.
;           Controller Script must ;#Include <RunAdmin>.
; USAGE  :  Two Use Cases:
;               1. Controller Script Launches Worker Elevated, Controller Script sends Run (no Reply) or RunWait (Reply) to Worker.
;               2. ShortCut Target="AdminRun CommandLine" Launches AdminRun Elevated, AdminRun sends Run (no Reply) "CommandLine".
; CASE #1:  Controller Script Launches Worker Elevated, Controller Script sends Run (no Reply) or RunWait (Reply) to Worker.
;               Controller StartTask which runs RunAdmin.ahk Elevated in Listen mode.
;               Controller sends Run(Worker) or RunWait(Worker) 
;               Controller Receives reply from Worker
;               Controller performs post-run actions
; CASE #2:  ShortCut Target="AdminRun CommandLine" Launches AdminRun Elevated, AdminRun sends Run (no Reply) "CommandLine".
;               ShortCut Launches AdminRun
;               AdminRun StartTask which runs RunAdmin Elevated in Listen mode.
;               AdminRun sends Run(MyApp) (No Reply)
/*
    TODO:
        Do NOT implement AutoStart, stick with StartTask (much simpler, don't have to identify which script will listen)
*/
;#Requires AutoHotkey v2+
#SingleInstance Off ; must allow multiple instances to work with shortcuts (Use Case #2)
;#Include <LogFile>
;#Include <NamedPipe>
;#Include <RunShell>
class RunAdmin {
    logger := LogFile("D:\RunAdmin.log", "RunAdmin", false)
    TaskName := "RunAdmin"
    PipeName := "RunAdminPipe"
    __New(TaskName:="", PipeName:="") {
        if (TaskName)
            this.TaskName := TaskName
        if (PipeName)
            this.PipeName := PipeName
    }
    Listen(PipeName:=this.PipeName) {
        this.logger.Write("Create pipe")
        pipe := NamedPipe(PipeName)
        pipe.Create()
        this.logger.Write("Pipe Listen")
        commandCSV:= pipe.Receive()
        pipe.Close()
        pipe:=""
        split:= StrSplit(commandCSV, ",")
        runAction:=split[1]
        this.logger.Write("runAction: [" runAction "]")
        commandCSV := StrReplace(commandCSV, runAction ",")
        this.logger.Write("commandCSV: " commandCSV)
        commandCSV := this.CheckIfAhkCommand(commandCSV)
        this.logger.Write("CheckIfAhkCommand: " commandCSV)
        this.logger.Write(runAction ": " commandCSV)
        result := RunShell(commandCSV)
        if (runAction = "/RunWait")
            this.Send("ACK: " result)
    }
    CheckIfAhkCommand(commandCSV) {
        split := StrSplit(commandCSV, ",")
        if (InStr(split[1], ".ahk")>0)
            commandCSV := A_AhkPath . ", " . commandCSV
        return commandCSV
    }
    Run(commandCSV) {
        this.Send("/Run," commandCSV)
    }
    RunWait(commandCSV) {
        this.Send("/RunWait," commandCSV)
    }
    Send(Request, PipeName:=this.PipeName) {
        pipe:= NamedPipe(PipeName)
        r := pipe.Wait(5000)
        if (!r) {
            this.logger.Write("Timeout Waiting for SEND pipe.")
            return false
        }
        pipe.Send(Request)
        pipe.Close()
        pipe:=""
        return true
    }
    Receive(PipeName:=this.PipeName) {
        pipe:= NamedPipe(PipeName)
        pipe.Create()
        reply:= pipe.Receive()
        pipe.Close()
        pipe:=""
        return reply
    }
    StartTask(TaskName:="") {
        if (TaskName)
            this.TaskName := TaskName
        cmd := Format('schtasks /run /tn "{}"', this.TaskName)
        r := RunWait(A_ComSpec ' /c ' cmd, , "Hide")
        if (r) 
            throw Error("Failed to run task: " this.TaskName)
    }
    __Delete() {
        ; Nothing needs to be cleaned up here - the GC will do it.
        ;this.logger.Write("Delete!")
    }
}
logger2 := LogFile("D:\RunAdminArgs.log", "RunAdminArgs", false)
logger2.Write("A_IsAdmin: " A_IsAdmin)
 runner:= RunAdmin()
if (A_IsAdmin) {
    logger2.Write("Args len: " A_Args.Length)
    if (A_Args.Length > 0 ) {
        ;
        ; The Admin Task is already started. Combine args into a commandCSV
        ;
        commandCSV := RunShell.ArrayToCSV(A_Args)
        logger2.Write("cmdLine: " commandCSV)
        ;
        ; Run the commandCSV, no wait and no reply
        ;
        runner.Run(commandCSV)
        logger2.Write("Running: " commandCSV)
    } else {
        ;
        ; Wait for command CSV
        ;
        logger2.Write("Listening...")
        runner.Listen()
    }
} else {
    if (A_Args.Length > 0 ) {
        runner.StartTask()
        commandCSV := RunShell.ArrayToCSV(A_Args)
        runner.Run(commandCSV)
    }
}
;====================================================================================================
; #region 2.7 RunCMD: C:\Users\Jim\Documents\AutoHotkey\Lib\RunCMD.ahk
;====================================================================================================
; ABOUT: RunCMD v1.0
;#Requires AutoHotkey 2.0+
; SUMMARY : Runs a command (handles spaces in the arguments) and returns the Output.
; RETURNS : StdOut and StdErr: success=Instr(output, "Error")=0, error=Instr(output, "Error")>0
; EXAMPLES:
;   RunCMD(Command)                         ; Determines if Array, CSV, String, and Executable,or CMD.
;   RunCMD([My App.exe, p1, p2])            ; Array (RunCMD will add quotes as needed).
;   RunCMD("My App.exe, p1, p2")            ; CSV   (RunCMD will add quotes as needed).
;   RunCMD("dir /b D:\My Dir")              ; String, CMD
;   RunCMD("MyApp.exe D:\MyDir")            ; String, EXE (User must add quotes as needed.)
;   RunCMD(Format('"{}" {}', exe, params))  ; String, EXE (User must add quotes as needed.)
;------------------------------------------------------------------------------------------------
class RunCMD{
    static Call(CommandLine) {
        if this.IsType(CommandLine, "CSV") {
            
            ;MsgBox CommandLine, "CSV"
            splitCSV := StrSplit(CommandLine, ",")
            return this.RunArray(splitCSV)
        } else if this.IsType(CommandLine, "Array") {
            ;MsgBox CommandLine[1], "Array"
            return this.RunArray(CommandLine)
        } else if this.IsType(CommandLine, "String") {
            ;MsgBox CommandLine, Type(CommandLine)
            split := StrSplit(CommandLine, " ")
            thisType := (InStr(split[1], "\") > 0) ? "EXE" : "CMD"
            return this.RunWait(CommandLine, thisType)
        } else {
            return "Error: Invalid command line: " Type(CommandLine) "`n`nMust be Array, CSV, or String."
        }
    }
    static RunArray(CommandArray) {
        DQ:= '"'
        CommandLine := ""
        Type := (InStr(CommandArray[1], "\") > 0) ? "EXE" : "CMD"
        for part in CommandArray {
            part := Trim(part)
            if (Type = "CMD")
                ;if InStr(value, "\") > 0
                ; Add quotes if the part contains a space and isn't already quoted
                if InStr(part, " ") && !RegExMatch(part, '^".*"$')                  
                    CommandLine .= DQ part DQ A_Space
                else
                    CommandLine .= part A_Space
            else
                CommandLine .= DQ part DQ A_Space
        }
        CommandLine :=  RTrim(CommandLine, A_Space)
        return this.RunWait(CommandLine, Type)
    }
    static RunWait(Command, Type:="CMD") {
        ;MsgBox "Cmd:`n`n" Command, Type
        DetectHiddenWindows(true)
        Run(A_ComSpec, , 'Hide', &pid)
        WinWait('ahk_pid ' pid) 
        if (DllCall("AttachConsole", "UInt", pid)) {
            try {
                shell := ComObject("WScript.Shell")
                if (Type = "CMD")
                    exec := shell.Exec(A_ComSpec ' /Q /C ' Command)
                else
                    exec := shell.Exec(Command)
                result := exec.StdOut.ReadAll() . "`n" . exec.StdErr.ReadAll()
                DllCall("FreeConsole")
                ProcessClose(pid)                
                return result
            } catch any as e {
                DllCall("FreeConsole")
                ProcessClose(pid)
                return "Error: " e.Message
            }
        }
        return 'Error: Could not attach console.'
    }
    static ToArray(Params*) {
        myArray:=Array()
        for item in Params {
            ;if IsSet(item)
                myArray.Push(item)
        }
        return MyArray
    }
    static ToCSV(Params*) {
        myString:= ""
        for item in Params {
            if IsSet(item)
                myString .= item . ","
        }
        return RTrim(myString, ",")
    }
    ; Returns String: Array, Class, CSV, Float, Func, Integer, Map, String
    static IsType(val, guess:="") {      
    if (guess="") {
        if Type(val) = "String" && InStr(val, ",")
            return "CSV"
        else
            return Type(val)        
    }
    valType  := Type(val)
    valGuess := Type(guess)
    if (valType = guess)
        return true
    else if (valType = "String" && InStr(val, ",") && guess = "CSV")
        return true
    else
        return false
    }
}
;====================================================================================================
; #region 2.8 RunShell: C:\Users\Jim\Documents\AutoHotkey\Lib\RunShell.ahk
;====================================================================================================
;#Requires AutoHotkey 2+
; TITLE   : RunShell v1.0.0.2
; SUMMARY : Runs a command (handles spaces in the arguments) and returns the Output.
; RETURNS : StdOut and StdErr: success=Instr(output, "Error")=0, error=Instr(output, "Error")>0
; EXAMPLES:
;   RunShell(Command)                         ; Determines if Array, CSV, String, and Executable,or CMD.
;   RunShell([My App.exe, p1, p2])            ; Array (RunShell will add quotes as needed).
;   RunShell("My App.exe, p1, p2")            ; CSV   (RunShell will add quotes as needed).
;   RunShell("dir /b D:\My Dir")              ; String, CMD
;   RunShell("MyApp.exe D:\MyDir")            ; String, EXE (User must add quotes as needed.)
;   RunShell(Format('"{}" {}', exe, params))  ; String, EXE (User must add quotes as needed.)
;------------------------------------------------------------------------------------------------
class RunShell{
    static Call(CommandLine) {
        if this.IsType(CommandLine, "CSV") {
            
            ;MsgBox CommandLine, "CSV"
            splitCSV := StrSplit(CommandLine, ",")
            return this.RunArray(splitCSV)
        } else if this.IsType(CommandLine, "Array") {
            ;MsgBox CommandLine[1], "Array"
            return this.RunArray(CommandLine)
        } else if this.IsType(CommandLine, "String") {
            ;MsgBox CommandLine, Type(CommandLine)
            split := StrSplit(CommandLine, " ")
            thisType := (InStr(split[1], "\") > 0) ? "EXE" : "CMD"
            return this.RunWait(CommandLine, thisType)
        } else {
            return "Error: Invalid command line: " Type(CommandLine) "`n`nMust be Array, CSV, or String."
        }
    }
    static RunArray(CommandArray) {
        DQ:= '"'
        CommandLine := ""
        Type := (InStr(CommandArray[1], "\") > 0) ? "EXE" : "CMD"
        for part in CommandArray {
            part := Trim(part)
            if (Type = "CMD")
                ;if InStr(value, "\") > 0
                ; Add quotes if the part contains a space and isn't already quoted
                if InStr(part, " ") && !RegExMatch(part, '^".*"$')                  
                    CommandLine .= DQ part DQ A_Space
                else
                    CommandLine .= part A_Space
            else
                CommandLine .= DQ part DQ A_Space
        }
        CommandLine :=  RTrim(CommandLine, A_Space)
        return this.RunWait(CommandLine, Type)
    }
    static RunWait(Command, Type:="CMD") {
        ;MsgBox "Cmd:`n`n" Command, Type
        DetectHiddenWindows(true)
        Run(A_ComSpec, , 'Hide', &pid)
        WinWait('ahk_pid ' pid) 
        if (DllCall("AttachConsole", "UInt", pid)) {
            try {
                shell := ComObject("WScript.Shell")
                if (Type = "CMD")
                    exec := shell.Exec(A_ComSpec ' /Q /C ' Command)
                else
                    exec := shell.Exec(Command)
                result := exec.StdOut.ReadAll() . "`n" . exec.StdErr.ReadAll()
                DllCall("FreeConsole")
                ProcessClose(pid)                
                return result
            } catch any as e {
                DllCall("FreeConsole")
                ProcessClose(pid)
                return "Error: " e.Message
            }
        }
        return 'Error: Could not attach console.'
    }
    static ToArray(Params*) {
        myArray:=Array()
        for item in Params {
            ;if IsSet(item)
                myArray.Push(item)
        }
        return MyArray
    }
    static ToCSV(Params*) {
        myString:= ""
        for item in Params {
            if IsSet(item)
                myString .= item . ","
        }
        return RTrim(myString, ",")
    }
    static ArrayToCSV(InputArray) {
        if (InputArray.Length = 0)
                return ""
            
        CSVString := ""
        
        for Index, Value in InputArray {
            CurrentVal := String(Value)
            CSVString .= (Index = 1 ? "" : ",") . CurrentVal
        }
        
        return CSVString
    }
    static ArrayToCmdLine(paramArray) {
        str := ""
        for index, value in paramArray {
            if (InStr(value, A_Space)>0) {
                value := '"' . value . '"'
            }
            str .= value . A_Space
        }
        return RTrim(str) ; Remove the trailing space
    }
    ; Returns String: Array, Class, CSV, Float, Func, Integer, Map, String
    static IsType(val, guess:="") {      
    if (guess="") {
        if Type(val) = "String" && InStr(val, ",")
            return "CSV"
        else
            return Type(val)        
    }
    valType  := Type(val)
    valGuess := Type(guess)
    if (valType = guess)
        return true
    else if (valType = "String" && InStr(val, ",") && guess = "CSV")
        return true
    else
        return false
    }
}
;====================================================================================================
; #region 2.9 SystemCursor: C:\Users\Jim\Documents\AutoHotkey\Lib\SystemCursor.ahk
;====================================================================================================
/*
 * SystemCursor v1.1.0.6
 * Added 'Type' helper for friendly name mapping.
 */
class SystemCursor {
    ; Static map of friendly names to Windows IDs
    static Type := Map(
        "Arrow",    32512,
        "IBeam",    32513,
        "Wait",     32514,
        "Cross",    32515,
        "UpArrow",  32516,
        "SizeNWSE", 32642,
        "SizeNESW", 32643,
        "SizeWE",   32644,
        "SizeNS",   32645,
        "SizeAll",  32646,
        "No",       32648,
        "Hand",     32649,
        "AppStarting", 32650,
        "Help",     32651
    )
    hCursor := 0
    isActive := false
    TargetHWND := 0
    isGlobal := false
    CursorID := 32512 
    /**
     * @param GuiObj - Pass a Gui Object for local, or 0 for system-wide.
     * @param CursorID - Pass a number (32514) OR a string ("Hand").
     */
    __New(GuiObj := 0, CursorID := 0) {
        if (IsObject(GuiObj)) {
            this.TargetHWND := GuiObj.Hwnd
            this.isGlobal := false
        } else {
            this.TargetHWND := 0
            this.isGlobal := true
        }
        ; Check if the user provided a custom ID or Name
        if (CursorID != 0) {
            if (SystemCursor.Type.Has(CursorID)) {
                this.CursorID := SystemCursor.Type[CursorID]
            } else {
                this.CursorID := CursorID
            }
        } else {
            this.CursorID := SystemCursor.Type["Wait"]
        }
    }
    Start() {
        if (this.isActive)
            return
        this.hCursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", this.CursorID, "Ptr")
        this.isActive := true
        
        if (this.isGlobal) {
            hCopy := DllCall("CopyIcon", "Ptr", this.hCursor, "Ptr")
            DllCall("SetSystemCursor", "Ptr", hCopy, "UInt", 32512)
        } else {
            this._TimerCallback := () => this._CheckAndSet()
            SetTimer(this._TimerCallback, 10)
        }
    }
    Stop() {
        if (!this.isActive)
            return
        if (this.isGlobal) {
            DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0)
        } else {
            SetTimer(this._TimerCallback, 0)
            this._TimerCallback := ""
            
            hArrow := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32512, "Ptr")
            DllCall("SetCursor", "Ptr", hArrow)
        }
        
        this.isActive := false
    }
    _CheckAndSet() {
        if (!this.isActive)
            return
        MouseGetPos(,, &hoverHwnd)
        if (hoverHwnd = this.TargetHWND) {
            DllCall("SetCursor", "Ptr", this.hCursor)
        }
    }
}
class AppStartingCursor extends SystemCursor {
    CursorID := 32650 
}
class CrossCursor extends SystemCursor {
    CursorID := 32515 
}
class WaitCursor extends SystemCursor {
    CursorID := 32514 
}
;====================================================================================================
; #region 3. Main Script: D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\BackupTool.ahk
;====================================================================================================
; TITLE   : BackupTool v3.3.0.15
; SOURCE  : Gemini and jasc2v8
; LICENSE : The Unlicense, see https://unlicense.org
; PURPOSE : Run SyncBack.exe as Admin with no UAC prompt.
; OVERVIEW: BackupTool run Task RunAdmin, which runs RunAdmin.ahk, which runs BackupWorker at runLevel='highest'
;           Uses NamedPipe IPC to communicate with other scripts.
; SCRIPTS : BackupTool.ahk => run Task RunAdmin => RunAdmin.ahk => BackupControlWorker.ahk





/*
  TODO:
    fix exe, profile, postaction
*/
#Requires AutoHotkey 2+
#SingleInstance Off ; must allow multiple instances
TraySetIcon('shell32.dll', 294) ; Backup/Restore Icon

;#Include <Colors>
;#Include <RunAdmin>
;#Include <IniFile>
;#Include <LogFile>
;#Include <NamedPipe>
;#Include <RunCMD>
;#Include <ProcessMonitor>
;#Include <SystemCursor>

; #region Version Block

; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Backup Tool
;@Ahk2Exe-Set FileVersion, 3.3.0.15
;@Ahk2Exe-Set InternalName, BackupTool
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, �2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE�
;@Ahk2Exe-Set OriginalFilename, BackupTool.exe
;@Ahk2Exe-Set ProductName, BackupTool
;@Ahk2Exe-Set ProductVersion, 3.3.0.15
;@Ahk2Exe-SetMainIcon D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\Icons\backup.ico

;@Inno-Set AppId, {{C65404BE-5F4B-4A2D-962E-389622530D4D}}
;@Inno-Set AppPublisher, jasc2v8

; #region Globals

global LogPath          := "D:\BackupTool.log"
global logger           := LogFile(LogPath, "CONTROL", false)  ; true=Enable, false=Disable

;global WorkerPath       := "C:\ProgramData\AutoHotkey\BackupTool\BackupWorker.ahk"
;global WorkerPath       := '"' A_AhkPath '"' A_Space "D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\BackupTool.ahk  /worker"
;global WorkerPath       := '"' A_AhkPath '"' A_Space "C:\Users\Jim\Documents\AutoHotkey\Ahkrunner\AhkApps\BackupTool.ahk"
global WorkerPath       := "D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\BackupTool.ahk /worker"

global SyncBackPath     := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
global SyncBackProfiles := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Profiles Backup"
global SyncBackLogDir   := EnvGet("LOCALAPPDATA") "\2BrightSparks\SyncBack\Logs"
global SyncBackPostAction := "Nothing"
global DefaultProfile   := "~Backup JIM-PC folders to JIM-SERVER"
global SyncBackProcessName  := "SyncBackSE.exe"

global SoundSuccess     := "C:\Windows\Media\Windows Notify Calendar.wav"
global SoundError       := "C:\Windows\Media\Windows Critical Stop.wav"

global INI_PATH         := "C:\ProgramData\AutoHotkey\BackupTool\BackupTool.ini"
global INI              := IniFile(INI_PATH)

global SyncBackSelectedProfile := INI.ReadSettings("PROFILE")

global IsRunning        := false
global CancelPressed    := false
global StartTime := 0
global BackupJob:=""
global BackupRequest :=""

global pm := 0

; #region Create Gui

MyGui := Gui("-AlwaysOnTop", "Backup Tool v3.1.0.1")
MyGui.BackColor := Colors.AirSuperiorityBlue

; #region Create Controls

MyGui.SetFont("S10", "Segouie UI")
TextProfile := MyGui.AddEdit('xm w410 h20 Center Background' Colors.LemonChiffon, SyncBackSelectedProfile)
ButtonSelectProfile := MyGui.AddButton("yp w60 h20", "Profile")

MyGui.AddGroupBox("xm w480 h100", "Action after Backup:")

;MyGui.SetFont("S11 CBlack w400", "Segouie UI")
TextFiller      := MyGui.AddText("xm yp+40 w0 +Hidden")
ButtonNothing   := MyGui.AddButton("yp w70", "Nothing")
ButtonMonOff    := MyGui.AddButton("yp w70", "MonOff")
ButtonLogOff    := MyGui.AddButton("yp w70", "LogOff")
ButtonSleep     := MyGui.AddButton("yp w70 Default", "Sleep")
ButtonHibernate := MyGui.AddButton("yp w70", "Hibernate")
ButtonShutdown  := MyGui.AddButton("yp w70", "Shutdown")

MyGui.SetFont()
TextFiller    := MyGui.AddText("xm yp+75 w145 +Hidden")
ButtonLogs    := MyGui.AddButton("yp w75", "Logs")
;ButtonClear   := MyGui.AddButton("yp w75", "Clear")
ButtonCancel  := MyGui.AddButton("yp w75", "Cancel")

SB := MyGui.AddStatusBar()

WriteStatus('Ready.')

; #region Event Handlers

ButtonSelectProfile.OnEvent("Click", ButtonSelectProfile_Click)
ButtonLogs.OnEvent("Click", ButtonLogs_Click)
;ButtonClear.OnEvent("Click", ButtonClear_Click)

ButtonNothing.OnEvent("Click", ButtonCommon_Click)
ButtonMonOff.OnEvent("Click", ButtonCommon_Click)
ButtonLogOff.OnEvent("Click", ButtonCommon_Click)
ButtonSleep.OnEvent("Click", ButtonCommon_Click)
ButtonHibernate.OnEvent("Click", ButtonCommon_Click)
ButtonShutdown.OnEvent("Click", ButtonCommon_Click)
ButtonCancel.OnEvent("Click", ButtonCancel_Click)

MyGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI
MyGui.Show()

; Focus on the default button to Unselect the text in the profile box
ControlFocus("Sleep", MyGui)

global sc := SystemCursor(MyGui, "AppStarting")

pm := ProcessMonitor("SyncBackSE.exe")

;
; #region Classes
;

class SyncBackParams {
  static Path       := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
  static Profile    := "TEST"
  static PostAction := "Nothing"
}

;
; #region Functions
;

ButtonCancel_Click(Ctrl, Info) {

  if !ProcessExist(SyncBackProcessName) {
    ExitApp()

  } else {

    buttonPress:= Msgbox("Stop Backup Job?", "Cancel Pressed", "YesNo Icon?")

    if (buttonPress = "Yes")
    {
      if ProcessExist(SyncBackProcessName)
      {
        ProcessClose(SyncBackProcessName)
        pm.Stop()
      } 
    }
  }
}

;
; #region START
;

ButtonCommon_Click(Ctrl, Info){

  WriteStatus("Ready.")

  timedOut := CountdownAndBlock(Ctrl.Text, 5)

  if (timedOut) {

    SyncBackParams.PostAction := Ctrl.Text

    StartBackup() ; Waits for Process to exist

    pm.Start(OnFinishedNotify, OnStatusNotify, OnStopNotify)

    ToggleButtons()

    sc.Start()
  }

}

OnFinishedNotify(Reason) {
    WriteStatus(Reason . " at: " pm.Now ", Elapsed: " pm.Elapsed)

    sc.Stop()

    SoundPlay "C:\Windows\Media\Windows Hardware Insert.wav"

    ; Restore if user minimized
    WinActivate(MyGui.Hwnd)

    ToggleButtons()

    if (Reason = "Finished")
      PostActionHandler()

}

OnStatusNotify(Status) {
    WriteStatus("Backup then " SyncBackParams.PostAction . " " . Status . " at: " pm.Now ", Elapsed: " pm.Elapsed)
}

OnStopNotify(Reason) {
    WriteStatus(Reason . " at: " pm.Now ", Elapsed: " pm.Elapsed)

    SoundPlay "C:\Windows\Media\Windows Hardware Fail.wav"
    
    ; Restore if user minimized
    WinActivate(MyGui.Hwnd)

    ToggleButtons()

    sc.Stop()

}

StartBackup() {

  WriteStatus("Backup then " SyncBackParams.PostAction " Started at: " FormatTime(A_Now, "HH:mm:ss"))

  ;
  ; Start the Task RunAdmin which runs RunAdmin.ahk, which launches this script as /worker
  ;

  logger.Write("Run Task")

  runner:= RunAdmin()

  runner.StartTask()

  ;
  ; Send BackupRequest to RunAdmin
  ;

  BackupRequest:= RunCMD.ToCSV(SyncBackPath, SyncBackPostAction, SyncBackSelectedProfile)

  runner.Run(BackupRequest)

  timeout := ProcessWait(SyncBackProcessName) 

  if (timeout=0) {
    MsgBox "Timeout Waiting for Process: " SyncBackProcessName
    return
  }

}

ButtonLogs_Click(Ctrl, Info) {
  Run('explorer.exe ' '"' SyncBackLogDir '"')
}

ButtonClear_Click(Ctrl, Info) {
  WriteStatus('Ready.')
}

ButtonSelectProfile_Click(Ctrl, Info) {
  global SyncBackSelectedProfile
  WriteStatus("Ready.")
  selection := FileSelect(0, SyncBackProfiles)
  if (selection != "") {
    SplitPath(selection, , , , &OutNameNoExt)

    SyncBackSelectedProfile := OutNameNoExt
    SyncBackParams.Profile:= OutNameNoExt

    TextProfile.Text := SyncBackSelectedProfile
    INI.WriteSettings("PROFILE", SyncBackSelectedProfile)
  }
}

CheckTimeout(timeout, number) {
    if (timeout)
        MsgBox("Timeout Number: " number , A_ScriptName, "iconX")
}

CountdownAndBlock(Title, Seconds)
{
  ; Define initial variables
  global TimerGui := ''
  global TimerRunning := true
  global RemainingTime := Seconds
  returnValue := true ; true=timedout, false=canceled

  ; Create the new GUI object
  TimerGui := Gui("+AlwaysOnTop -Caption +Border")
  TimerGui.Title := ''
  TimerGui.BackColor := "Yellow"

  ; Add a text control for the title
  TimerGui.SetFont("s18 bold", "Consolas")
  TimerText := TimerGui.AddText("Center", 'Backup then`n' Title ' in:')

  ; Add a text control to display the countdown
  TimerGui.SetFont("s48 bold cRed", "Consolas")
  TimerText := TimerGui.AddText("w200 Center vCountdownText", RemainingTime)

  ; add buttons
  TimerGui.SetFont("s12 Norm", "Consolas")
  TimerGui.AddButton("xm w100 Default","OK").OnEvent("Click", ButtonOK_Click)
  TimerGui.AddButton("yp w100","Cancel").OnEvent("Click", ButtonCancel_Click)

  ; Display the GUI and center it.
  TimerGui.Show("Center")

  ; Set up the Timer function (runs every 1000ms / 1 second)
  SetTimer UpdateTimer, 1000

  ; While the GUI is open and the timer is running, the main script thread pauses here.
  While (TimerRunning)
  {
      Sleep(100) ; Wait 100ms before checking the flag again
  }

  ; Cleanup after the loop finishes
  TimerGui.Destroy()

  return returnValue

  ButtonOK_Click(*)
  {
    SetTimer UpdateTimer, 0
    TimerRunning := false
    returnValue := true
  }
  ButtonCancel_Click(*)
  {
    SetTimer UpdateTimer, 0
    TimerRunning := false
    returnValue := false
  }

  UpdateTimer(*)
  {
    global TimerGui
    global TimerRunning
    global RemainingTime
      
    if (RemainingTime <= 1)
    {
        SetTimer UpdateTimer, 0
        TimerRunning := false    
        return
    }
    RemainingTime--
    TimerGui["CountdownText"].Text := RemainingTime
  }
}

ToggleButtons() {

    static IsActive := true
    
    IsActive := !IsActive
    
    if (IsActive) {
      for GuiCtrlObj in MyGui
          if (GuiCtrlObj.Type = "Button") and (GuiCtrlObj.Text != "Cancel")
              GuiCtrlObj.Enabled := true
    } else {
      for GuiCtrlObj in MyGui
          if (GuiCtrlObj.Type = "Button") and (GuiCtrlObj.Text != "Cancel")
              GuiCtrlObj.Enabled := false
    }

    ControlFocus("Cancel", MyGui)
}

WriteStatus(Message) {
  SB.Text := '    ' Message
}

ReadIni() {
  profilePath := INI.ReadSettings("PROFILE")
  if (profilePath = '') {
    profilePath := DefaultProfile
    INI.WriteSettings("PROFILE", profilePath)
  }
  return profilePath
}

WriteIni(profilePath) {
  INI.WriteSettings("PROFILE", profilePath)
}

PostActionHandler() {

    ; BackupParameters = (SyncBackPath, SyncBackParams, SyncBackProfile)

    ; parse params
    ; -hybernate      DllCall('PowrProf\SetSuspendState','Int',1,'Int',0,'Int',0,'Int',0) ; Hibernate Mode (S4) (USB off, mouse)
    ; -logoff         Shutdown(0)     ; 0=Logoff, 1=Shutdown, 2=Reboot, 4=Force, 8=Power down
    ; -logoffforce    Shutdown(0+3)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 4=Force, 8=Power down
    ; -monoff         SendMessage 0x0112, 0xF170, 2,, "Program Manager"  ; 0x0112 is WM_SYScommandLine, 0xF170 is SC_MONITORPOWER.
    ; -shutdown       Shutdown(1+8)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 4=Force, 8=Power down
    ; -shutdownforce  Shutdown(1+3)   ; 0=Logoff, 1=Shutdown, 2=Reboot, 4=Force, 8=Power down
    ; -sleep          DllCall('PowrProf\SetSuspendState','Int',0,'Int',0,'Int',0,'Int',0) ; Sleep Mode (S3) USB poweron, mouse will wakeup
    ; -standby        alias for -sleep

    ; if (BackupParameters = "")
    ;   ExitApp()

    ;logger.Write("DEBUG BackupParameters: [" BackupParameters "]")

    ; Get Post Action from Parameters (SyncBackPath, SyncBackParams, SyncBackProfile)
    ; split := StrSplit(BackupParameters, ",")
    ; if (split.Length < 3) {
    ;     logger.Write("ERROR Expected 3 parameters, got: " split.Length)
    ;     return
    ; }

    ;postAction:= split[2]

    postAction :=  SyncBackParams.PostAction

    ;MsgBox postAction, "POST ACTION"

    ;logger.Write("DEBUG PostAction: [" postAction "]")

    switch postAction, CaseSense:="Off" {
        case "MonOff":
            action:= "-monoff"
        case "LogOff":
            action:= "-logoffforce"
        case "Sleep":
            action:= "-sleep"
        case "Hibernate":
            action:= "-hybernate"
        case "Shutdown":
            action:= "-shutdown"
        default:
            action:= "Nothing"
    }

    switch action {
        case "-monoff":
            SendMessage 0x0112, 0xF170, 2,, "Program Manager"  ; 0x0112 is WM_SYScommandLine, 0xF170 is SC_MONITORPOWER.
        case "-logoff", "-signoff":
            Shutdown(0)  ; PowerControlTool
        case "-sleep", "-standby":
            DllCall('PowrProf\SetSuspendState', 'Int', 0, 'Int', 0, 'Int', 0, 'Int') ; Sleep with USB power off
        case "-hybernate":
            DllCall('PowrProf\SetSuspendState', 'Int', 1, 'Int', 0, 'Int', 0, 'Int') ; SAME AS SLEEP! PowerControlTool
        case "-shutdown":
            Shutdown(1+8)  ; PowerControlTool
        case "-shutdownforce":
            Shutdown(1+4+8) 
        case "-logoffforce", "-signoffforce":
            Shutdown(0+4)
        default:
            doNothing:=true
    }

    logger.Write("FINISH: [" postAction "]") ; may not have time to write this.

}
