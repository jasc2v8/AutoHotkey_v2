; ABOUT:    FontCompare v0.1
; SOURCE:   TheArkive https://github.com/TheArkive/FontPicker_ahk2
;           originally posted by maestrith https://autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/
; LICENSE:  MIT License Copyright (c) 2021 TheArkive

/*
    TODO:
        clean up all the hacks (.bold or .weight?)

    Font Defaults
		Gui:	s9, Segoe UI
		Edit	s8, Microsoft Sans Serif
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <Debug>
#Include <IniLite>

Escape::ExitApp()

global INI := IniLite() ; Default is A_ScriptFullPath.SplitPath().NameNoExt ".ini"

Global fontObj := {}

; global EditColors := Array()
; loop 10
;     EditColors.Push("")

global EditColors := Map()
loop 10 {
    index := Format('{:02}', A_Index)
    key := 'MyEdit' index
    EditColors[key] := ""
}

global g := unset

MonoSpaceFonts := [ "Cascadia Code","Cascadia Mono","Consolas","Courier","Courier New",
                    "Lucida Console","Lucida Sans", "Microsoft Sans Serif", "Microsoft Sans Serif", "Microsoft Sans Serif"]

; for name in MonoSpaceFonts
;     Msgbox name

g := Gui("","Compare Fonts")
g.OnEvent("close", gui_exit)
;g.SetFont("s9", "Segoe UI")
g.SetFont()
; ctl.SetFont("bold underline italic strike c0xFF0000")

SampleText := "The quick brown fox jumps over the lazy dog."

Loop 10 {
    index := Format('{:02}', A_Index)
    g.AddButton("xm Default","Font" index).OnEvent("click", ButtonFont_Click)
    ; g.AddEdit("yp w150 h30 -Multi vFontName" index, "Veranda")
    ; g.AddEdit("yp w500 h30 -Multi vMyEdit" index, SampleText)

    ; g.AddText("yp w150 h30 -Multi BackgroundWhite -Border -Wrap vFontName" index, "Veranda")
    ; g.AddText("yp w500 h30 -Multi BackgroundWhite -Border -Wrap vMyEdit" index, SampleText)

    g.AddEdit("yp w150 h30 -Multi BackgroundWhite -Border -Wrap vFontName" index, "")
    MyEdit := g.AddEdit("yp w500 h30 -Multi BackgroundWhite -Border -Wrap vMyEdit" index, SampleText)
}

g.AddText("xm w720 h2 0x10","Horizontal Line")  ;SS_ETCHEDHORZ
g.AddButton("xm w75 Default","MonoSpace").OnEvent("click", ButtonMonoSpace_Click)
g.AddButton("yp w75","Save").OnEvent("click", ButtonSave_Click)
g.AddButton("yp w75","Load").OnEvent("click", ButtonLoad_Click)
g.AddButton("yp w75","Cancel").OnEvent("Click", (*) => ExitApp())
g.AddText("xm w1 h2 Hidden","Hidden Spacer")  ;SS_ETCHEDHORZ

; ctl := g.AddEdit("yp w500 h20 vMyEdit1", SampleText)
; g.AddEdit("w500 h200 vMyEdit2","Sample Text")
;g["Btn"].Focus()

fontObj := {name:"Courier", size:12, color:0x000000, strike:0, underline:0, italic:0, bold:0}
;MsgBox fontObj.name

LoadFromIni()

g.Show()

ButtonFont_Click(ctl,info) {
    Global fontObj, EditColors
    
    ; MsgBox ctl.Text ; "Font01" Button

    If (!fontObj.HasProp("name")) ; init font obj and pre-populate settings
        ;fontObj := {name:"Verdana", size:14, color:0xFF0000, strike:1, underline:1, italic:1, bold:1} ; init font obj (optional)
        fontObj := {name:"Segoe UI", size:09, color:0x000000, strike:0, underline:0, italic:0, bold:0} ; init font obj (optional)
    
    fontObj := SetFontInfo(fontObj, ctl.gui.hwnd) ; shows the user the font selection dialog

    if Type(fontObj) != 'Object'
        return

    ; 'Font01' => '01'
    index := Trim(SubStr(ctl.Text, ctl.Text.Length - 1, 2))

    ctl.gui["FontName" index].Text := fontObj.name " " Round(Trim(fontObj.size))
    ; Help SetFont:
    ; Norm returns the font to normal weight/boldness and turns off italic, strike, and underline, 
    ;   (but it retains the existing color and size).
    ; Reset color to default
    ctl.gui["MyEdit" index].SetFont("cDefault")
    ; Change color if included in options.
    ctl.gui["MyEdit" index].SetFont(fontObj.options, fontObj.name)

    EditColors.Set("MyEdit" index, " c" fontObj.color)

}

ButtonLoad_Click(ctl,info) {
    ;Global fontObj

    ;fobj := GetFontInfo(g['MyEdit01'].hwnd)
    ;Debug.ListVar(fobj, "ButtonFont_Click")

    loadFile := FileSelect(Prompt:=3, A_ScriptDir, "Load Font Info from...", "Ini Files (*.ini)")

    if loadFile = ""
        return
    
    LoadFromIni(loadFile)

    ;DEBUG
    Run "notepad.exe " loadFile
}

ButtonSave_Click(ctl,info) {
    ;Global fontObj
    
    fobj := GetFontInfo(g['MyEdit' index].hwnd)
; g := ctl.gui.g['MyEdit01']



    ;fobj := GetFontInfo(g['MyEdit01'].hwnd)
    ;Debug.ListVar(fobj, "ButtonFont_Click")

    saveFile := FileSelect(Prompt:="S27", A_ScriptDir, "Save Fonts As...", "Ini Files (*.ini)")

    ; if !FileExist(savefile)
    ;     return

    ;FileAppend("[Settings]", savefile)

    SplitPath saveFile,,,&Ext

    ;MsgBox Ext="", "ext"

    if !Ext
        saveFile .= ".ini"

    SaveToIni(savefile)

    ;DEBUG
    Run "notepad.exe " savefile
}

LoadFromIni(loadFile:="") {

    ; TODO: EditControlCount := 10
    Loop 10 {

        index := Format('{:02}', A_Index)

        fobj := GetFontInfo(g['MyEdit' index].hwnd)

        ;MsgBox 'MyEdit' index ": " fobj.name

        key := 'MyEdit' index

        ; iniItem := "norm s10.0 strike, Segoe, 99.9" ; extract s10.0
        ; split := StrSplit(iniItem, ",")
        ; fontObj := {str: split[1], name: split[2], size: split[3]}

        ;iniItem := "norm s10.0 strike, Segoe, 99.9" ; extract s10.0
        ;value := '"' fobj.Options ", " fobj.name

        INI := IniLite(loadFile)

        value :=INI.ReadSettings(key)

        ;MsgBox value, "LoadFromIni"

        split := StrSplit(value, ",")
        Options := split[1]
        Name := split[2]

        ; Match weight wXXX
        if RegExMatch(split[1], "\bw\d+", &match)
            size := match[0]
        else
            size := ""

        size := StrReplace(size, "w", "")


        ;MsgBox key ": " Options

        ; bold := (InStr(split[1], "w700") != 0) ? "bold" : ""

        ; ;fontObj := {str: split[1], name: split[2], size: split[3]}
        ; fontObj := {options: split[1], name: split[2], bold: bold, size: size,
        ;     italic: 0}

        ;SetFontInfo(fontObj, g['MyEdit' index].hwnd)

        g["FontName" index].Text := name " " Trim(size)
        g["MyEdit" index].SetFont(Options, name)

        ; fObj := {}

        ; fObj.name := name

        ; options := ""
        ; ;options .= fObj.bold      ? "bold" : ""
        ; options .= weight = 400  ? "" : " w" weight
        ; options .= italic    ? " italic" : ""
        ; str .= strike    ? " strike" : ""
        ; options .= color     ? " c" color : ""
        ; options .= pointSize      ? " s" pointSize : ""
        ; options .= underline ? " underline" : ""
        
        ; fObj.options := "norm " Trim(options) 

        ;Debug.ListVar(fObj, "GetFontInfo")

        ; return fObj
    }

}

SaveToIni(saveFile) {
    global EditColors

    ; Debug.MBox EditColors.Length ", " EditColors[1], "SaveToIni"
    ; Debug.MBox EditColors.Length ", " EditColors[01], "SaveToIni"


    Loop 10 {

        index := Format('{:02}', A_Index)

        key := 'MyEdit' index

        fobj := GetFontInfo(g[key].hwnd)

        color := EditColors[key]

        fobj.Options .= " " color

        ;MsgBox 'MyEdit' index ": " fobj.name

        ;iniItem := "norm s10.0 strike cRed, Segoe UI" ; extract s10.0
        value := fobj.Options ", " fobj.name

        INI := IniLite(saveFile)

        INI.WriteSettings(key, value)
    }


        ;fobj := GetFontInfo(g['MyEdit01'].hwnd)
    ;Debug.ListVar(fobj, "ButtonFont_Click")

        ;fontObj := FormatFontObj(values)
    ; str: SplitCSV(values).name
    ; name: SplitCSV(values).name
    ; size: SplitCSV(values).name

    ;text := "norm s11.0 strike, Segoe, 12"

    ; Match size sX.X
    ; if RegExMatch(text, "s)(?<=\bs)\d+(\.\d+)?", &match)
    ;     MsgBox "Matched value: " match[0]
    ; else
    ;     MsgBox "No match found"


    ;TODO:
    ; iniItem := "norm s10.0 strike, Segoe, 99.9" ; extract s10.0
    ; split := StrSplit(iniItem, ",")
    ; fontObj := {str: split[1], name: split[2], size: split[3]}

}

gui_exit(g) {
    ExitApp
}

ButtonMonoSpace_Click(ctl,info) {
    Global MonoSpaceFonts

    ;ctl.gui["FontName10"].Text := "My Font"

    for index, name in MonoSpaceFonts {

        if name = "Microsoft Sans Serif" {
            size := 8
            name := "Default (MS Sans Serif)"
        } else {
            size := 12
        }


        ; defaultFont := "Default (MS Sans Serif, " size ")" 

        ; name := (name = "Microsoft Sans Serif") ? defaultFont : name
        ; size := (name = "Default") ? "8" : "10"
        ; name := (name = "Default") ? size:=8 : size

        ctl.gui["FontName" Format('{:02}', index)].Text := name " " Round(size)

        ctl.gui["MyEdit"   Format('{:02}', index)].SetFont("norm cDefault", name)
        ctl.gui["MyEdit"   Format('{:02}', index)].SetFont("norm s" size, name)
    }
}

SaveObjectToIni(obj, filePath, section) {

    value := "norm s10.0 strike, Segoe, 12"
    INI.Write('TEST', 'Font01', value)
    return

    for key, value in obj.OwnProps()
        INI.Write(section, key, value)
}

; ======================================================================
; END Example
; ======================================================================

; ==================================================================
; Parameters
; ==================================================================
; fObj           = Initialize the dialog with specified values.
; hwnd           = Parent gui hwnd for modal, leave blank for not modal
; effects        = Allow selection of underline / strike out / italic
; ==================================================================
; fontObj output:
;
;    fontObj.str        = string to use with AutoHotkey to set GUI values - see examples
;    fontObj.size       = size of font
;    fontObj.name       = font name
;    fontObj.bold       = true/false
;    fontObj.italic     = true/false
;    fontObj.strike     = true/false
;    fontObj.underline  = true/false
;    fontObj.color      = 0xRRGGBB
; ==================================================================
SetFontInfo(fObj:="", hwnd:=0, Effects:=true) {
    Static _temp := {name:"", size:10, color:0, strike:0, underline:0, italic:0, bold:0}
    Static p := A_PtrSize, u := StrLen(Chr(0xFFFF)) ; u = IsUnicode
    
    fObj := (fObj="") ? _temp : fObj
    
    If (StrLen(fObj.name) > 31)
        throw Error("Font name length exceeds 31 characters.")
        
    LOGFONT := Buffer(!u ? 60 : 96,0) ; LOGFONT size based on IsUnicode, not A_PtrSize
    hDC := DllCall("GetDC","UPtr",0)
    LogPixels := DllCall("GetDeviceCaps","UPtr",hDC,"Int",90)
    Effects := 0x041 + (Effects ? 0x100 : 0)
    DllCall("ReleaseDC", "UPtr", 0, "UPtr", hDC) ; release DC
    
    fObj.bold := fObj.bold ? 700 : 400
    fObj.size := Floor(fObj.size*LogPixels/72)
    
    NumPut "uint", fObj.size, LOGFONT
    NumPut "uint", fObj.bold, "char", fObj.italic, "char", fObj.underline, "char", fObj.strike, LOGFONT, 16
    StrPut(fObj.name,LOGFONT.ptr+28)
    
    CHOOSEFONT := Buffer((p=8)?104:60,0)
    NumPut "UInt", CHOOSEFONT.size,     CHOOSEFONT
    NumPut "UPtr", hwnd,                CHOOSEFONT, p
    NumPut "UPtr", LOGFONT.ptr,         CHOOSEFONT, (p*3)
    NumPut "UInt", effects,             CHOOSEFONT, (p*4)+4
    NumPut "UInt", RGB_BGR(fObj.color), CHOOSEFONT, (p*4)+8
    
    r := DllCall("comdlg32\ChooseFont","UPtr",CHOOSEFONT.ptr) ; Font Select Dialog opens
    
    if !r
        return false
    
    ;TODO: change.bold to .weight?
    ;fObj.weight :=
    fObj.Name := StrGet(LOGFONT.ptr+28)
    fObj.bold := ((b := NumGet(LOGFONT,16,"UInt")) <= 400) ? 0 : 1
    fObj.italic := !!NumGet(LOGFONT,20,"Char")
    fObj.underline := NumGet(LOGFONT,21,"Char")
    fObj.strike := NumGet(LOGFONT,22,"Char")
    fObj.size := NumGet(CHOOSEFONT,p*4,"UInt") / 10
    
    c := NumGet(CHOOSEFONT,(p=4)?6*p:5*p,"UInt") ; convert from BGR to RBG for output
    fObj.color := Format("0x{:06X}",RGB_BGR(c))
    
    options := ""
    options .= fObj.bold      ? "bold" : ""
    options .= fObj.italic    ? " italic" : ""
    options .= fObj.strike    ? " strike" : ""
    options .= fObj.color     ? " c" fObj.color : ""
    options .= fObj.size      ? " s" fObj.size : ""
    options .= fObj.underline ? " underline" : ""
    
    fObj.options := "norm " Trim(options)
    return fObj
    
    RGB_BGR(c) {
        return ((c & 0xFF) << 16 | c & 0xFF00 | c >> 16)
    }
}

; typedef struct tagLOGFONTW {
  ; LONG  lfHeight;                 |4        / 0
  ; LONG  lfWidth;                  |4        / 4
  ; LONG  lfEscapement;             |4        / 8
  ; LONG  lfOrientation;            |4        / 12
  ; LONG  lfWeight;                 |4        / 16
  ; BYTE  lfItalic;                 |1        / 20
  ; BYTE  lfUnderline;              |1        / 21
  ; BYTE  lfStrikeOut;              |1        / 22
  ; BYTE  lfCharSet;                |1        / 23
  ; BYTE  lfOutPrecision;           |1        / 24
  ; BYTE  lfClipPrecision;          |1        / 25
  ; BYTE  lfQuality;                |1        / 26
  ; BYTE  lfPitchAndFamily;         |1        / 27
  ; WCHAR lfFaceName[LF_FACESIZE];  |[32|64]  / 28  ---> size [60|92] -- 32 TCHARs [UTF-8|UTF-16]
; } LOGFONTW, *PLOGFONTW, *NPLOGFONTW, *LPLOGFONTW;


;                                           size        offset [32|64]
; typedef struct tagCHOOSEFONTW {
  ; DWORD        lStructSize;               |4        / 0
  ; HWND         hwndOwner;                 |[4|8]    / [ 4| 8]  A_PtrSize * 1
  ; HDC          hDC;                       |[4|8]    / [ 8|16]  A_PtrSize * 2
  ; LPLOGFONTW   lpLogFont;                 |[4|8]    / [12|24]  A_PtrSize * 3
  ; INT          iPointSize;                |4        / [16|32]  A_PtrSize * 4
  ; DWORD        Flags;                     |4        / [20|36]
  ; COLORREF     rgbColors;                 |4        / [24|40] --- this lines up with code
  ; LPARAM       lCustData;                 |[4|8]    / [28|48]
  ; LPCFHOOKPROC lpfnHook;                  |[4|8]    / [32|56]
  ; LPCWSTR      lpTemplateName;            |[4|8]    / [36|64]
  ; HINSTANCE    hInstance;                 |[4|8]    / [40|72]
  ; LPWSTR       lpszStyle;                 |[4|8]    / [44|80]
  ; WORD         nFontType;                 |2        / [48|88]
  ; WORD         ___MISSING_ALIGNMENT__;    |2        / [50|90]
  ; INT          nSizeMin;                  |4        / [52|92]
  ; INT          nSizeMax;                  |4        / [56|96] -- len: 60 / 104
; } CHOOSEFONTW;

GetFontInfo(hwnd) {
    global g
    
    WM_GETFONT := 0x31
    hFont := SendMessage(WM_GETFONT, 0, 0, hwnd)
    if !hFont
        throw Error("Failed to get font handle")

    LOGFONT := Buffer(92, 0)  ; LOGFONT structure size
    if !DllCall("GetObject", "Ptr", hFont, "Int", 92, "Ptr", LOGFONT)
        throw Error("GetObject failed")

    name := StrGet(LOGFONT.Ptr + 28, "UTF-16")  ; lfFaceName offset
    height := NumGet(LOGFONT, 0, "Int")
    weight := NumGet(LOGFONT, 16, "Int")
    italic := NumGet(LOGFONT, 20, "UChar")
    underline := NumGet(LOGFONT, 21, "UChar")
    strike := NumGet(LOGFONT, 22, "UChar")

    hdc := DllCall("GetDC", "Ptr", hwnd, "Ptr")
    dpi := DllCall("GetDeviceCaps", "Ptr", hdc, "Int", 90, "Int")  ; LOGPIXELSY

    ; INOP and a big hassle to fiddle with. Just use a Map().
    ;color := DllCall("GetTextColor", "Ptr", hdc, "UInt")

    DllCall("ReleaseDC", "Ptr", hwnd, "Ptr", hdc)

    pointSize := Round(Abs(height) * 72 / dpi)

    ; Convert COLORREF (BGR) to RGB hex
    ;r := color & 0xFF
    ;g := (color >> 8) & 0xFF
    ;b := (color >> 16) & 0xFF
    ;rgbHex := Format("0x{:02X}{:02X}{:02X}", r, g, b)

    ;if (color)
        ;Debug.MBox "Font color (RGB): " rgbHex
        ;Debug.MBox "Font color: " color

    ;debug
    color := ""

    fObj := {}
    fObj.name := name

    options := ""
    options .= bold := (weight >= 700) ? "bold" : ""
    options .= weight = 400  ? "" : " w" weight
    options .= italic    ? " italic" : ""
    options .= strike    ? " strike" : ""
    options .= color     ? color : ""
    options .= pointSize      ? " s" pointSize : ""
    options .= underline ? " underline" : ""
    
    fObj.options := "norm " Trim(options) 

    ;Debug.MBox("color: " color)
    ;Debug.ListVar(fObj, "GetFontInfo")

    return fObj
}

GetTextColor(hwnd) {

    ;hBrush := SendMessage(hwnd, $WM_CTLCOLORSTATIC, $hMemDC, $hWnd) ;do not delete returned brush


    hdc := DllCall("GetDC", "Ptr", hwnd, "Ptr")
    color := DllCall("GetTextColor", "Ptr", hdc, "UInt")
}
