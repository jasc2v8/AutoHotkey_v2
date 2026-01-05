;ABOUT: AhkMerge v0.0.0.0

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <Debug>
#Include <String>
#Include <IniLite>

;DEBUG
Escape::ExitApp()

; #region Globals

global AhkPath          := "C:\Program Files\AutoHotkey"
global MainScriptPath    := "D:\Software\DEV\Work\AHK2\Projects\AhkMerge\MergeTestScript.ahk"

global INI := IniLite()

global IncludeFiles := ""
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
MyGui.SetFont("S11", "Segouie UI")

myGui.AddText("xm ym", "Select a file:")

MyGui.SetFont("S10", "Consolas")
ScriptEdit := myGui.AddEdit("xm y+5 w600", SelectedFile)

MyGui.SetFont("S10", "Segoe UI")
myGui.AddButton("x+8 yp w75", "Browse").OnEvent("Click", SelectFile)

myGui.AddText("xm w518 h0 Hidden", "Hidden Filler")
myGui.AddButton("yp w75 Default", "Merge").OnEvent("Click", Button_Click)
myGui.AddButton("yp w75", "Cancel").OnEvent("Click", (*) => ExitApp())

myGui.Show()

ControlFocus("Cancel", MyGui)

; #region Functions

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

    if FileExist(SelectedFile) {
        INI.WriteSettings("SelectedFile", SelectedFile)
    } else {
        SoundBeep
        return
    }

    ;f1 := "D:\Software\DEV\Work\AHK2\Projects\AhkMerge\Lib\MergeFile_1.ahk"
    ; f1 := "D:\Software\DEV\Work\AHK2\Projects\AhkMerge\MergeTestScript.ahk"
    ; f2 := "D:\Software\DEV\Work\AHK2\Projects\AhkMerge\Lib\MergeFile_1.ahk"
    ; f3 := "" ; "D:\Software\DEV\Work\AHK2\Projects\AhkMerge\Lib\MergeFile_3.ahk"
    ; ScripFilesArray := [f1 , f2, f3]
    ; MergedScript := MergeScript.Files(ScripFilesArray) ; Script and #Includes
    ; MergedScript := MergeScript.Includes(f2)

    MergedScript := MergeScript.Includes(SelectedFile)
    
Debug.FileWrite(MergedScript, , true)  ; Default is .\Debug.txt

    outFile := SelectedFile.SplitPath().nameNoExt "_Merged.ahk"
    if FileExist(outfile)
        FileDelete(outfile)
    FileAppend(MergedScript, outfile)

Debug.MBox(outFile)

    ;DEBUG
    Run("notepad " outfile)

    MsgBox("Done!", "Status", "icon?")

}

class MergeScript {

    static IncludeFiles := ""
    static MergedScript := ""

    static GetMergedScript() {
        return MergedScript
    }

    static GetIncludeFiles() {
        return IncludeFiles
    }

    ; array or csv or map?
    static Files(ScriptFilesArray) {
        ; Initialize variables used in the Recursive Function
        this.MergedScriptFiles := ""
        for ScriptFile in ScriptFilesArray
            this.MergedScriptFiles .= this._MergeIncludes(ScriptFile)

        ; static _CleanScript()

        ;Remove multiple blank lines
        ;CleanScript := RegExReplace(this.MergedScript, "\R{3,}", "`n`n")

        ;Remove blank lines from the end of the script (will leave one blank line at the end)
        ;CleanScript := RegExReplace(CleanScript, "\R+$", "")
        return this.MergedScriptFiles
    }

    static Includes(ScriptFile) {
        ; Initialize variables used in the Recursive Function
        this.IncludeFiles := ""
        this.MergedScript := ""
        ; Perform the recursive Includes
        return this._MergeIncludes(ScriptFile)
    }

    static _MergeIncludes(ScriptFile) {

        if ScriptFile.IsEmpty()
            return

        ScriptText := FileRead(ScriptFile)

        ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

        Loop ScriptTextArray.Length {

            line := ScriptTextArray[A_Index]

            ; Avoid multiple #Requires
            if line.StartsWith("#Requires AutoHotkey") AND this.MergedScript.Contains("#Requires AutoHotkey")
                continue ; line := ""

            ; Avoid multiple #Include of the same file
            ;;;if line.StartsWith("#Include") AND this.MergedScript.Contains(line)
                ;;;continue

            if line.StartsWith("#Include") {

                this.MergedScript .= ";" line "`n"

                includeFile := this._FindInLibrary(line)

                ;TODO: Is this better?
                ;;if (NOT includeFile.IsEmpty()) AND (NOT this.IncludeFiles.Contains(includeFile))
                    this.IncludeFiles .= includeFile ","

                    this.Includes(includeFile)
            }
            this.MergedScript .= line "`n"
        }

        ;Remove multiple blank lines
        CleanScript := RegExReplace(this.MergedScript, "\R{3,}", "`n`n")

        ;Remove blank lines from the end of the script (will leave one blank line at the end)
        CleanScript := RegExReplace(CleanScript, "\R+$", "")

        return CleanScript
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