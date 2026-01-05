;ABOUT: Retrieves all file properties from an executable

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#Include <Class_IniLite>
#Include <Path>

; #region Globals

global propertiesArray := [
            "Choose Property",
            "Name",
            "Size",
            "ProductName", 
            "ProductVersion", 
            "FileDescription",
            "Company", 
            "Copyright", 
            "FileVersion", 
            "TargetPath", 
        ]

global INI_PATH := JoinPath(, A_Temp, 
    "AhkApps", StrReplace(A_ScriptName, ".ahk", ""), StrReplace(A_ScriptName, ".ahk", ".ini"))

OutputDebug('INI_PATH: ' INI_PATH)

; #region INI Create

INI := IniLite(INI_PATH)


OutputDebug('INI.MyIniPath: ' INI.IniPath)

#Warn Unreachable
return

    #Warn Unreachable, Off
defaultPath := IniRead("Settings", "DefaultPath")

;defaultPath := "D:\Software\DEV\Work\AHK2\AhkApps\TEMP AhkApps.lnk"

if (defaultPath == "")
    defaultPath := A_ScriptFullPath

; #region GUI Create

MyGuiTitle := "File Get Shortcut Example v1.0"
MyGui := Gui(, MyGuiTitle ) ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w532", "Segouie UI")

MyEdit := MyGui.Add("Edit", "xp w640")
MyEdit.Text := defaultPath

MyEdit := MyGui.Add("Text", "xp w640 h1 0x10")

buttonSelect := MyGui.Add("Button", "xp+0 w64 h24", "Select")
buttonSelect.OnEvent("Click", (*) => DoSelectFile())
    
buttonList := MyGui.Add("Button", "yp w64 h24 Default", "List")
buttonList.OnEvent("Click", (*) => DoListFileProperties(MyEdit.Text, propertiesArray))

;buttonNext := MyGui.Add("Button", "xm w64", "Next")
;    .OnEvent("Click", (*) => DoNext(MyEdit.Text))

DDL := MyGui.Add("DropDownList", "yp Choose1", propertiesArray)

MyX := A_ScreenWidth / 3
MyY := A_ScreenHeight / 6

MyGui.Show("x20 x" MyX "y" MyY) ; postion above the msgbox listing the file properties

buttonList.Focus()

DDL.OnEvent('Change', DDL_OnChange)

; #region Functions

DDL_OnChange(Ctrl, *) {

    if !FileExist(MyEdit.Text) {
        MsgBox("File not found:`n`n" MyEdit.Text, "DDL_OnChange ERROR", "OK Icon!")
        DDL.Choose(1)
        return
    } else if(Ctrl.Text == "Choose Property") {
            SoundBeep
            DDL.Choose(1)
    } else {
        prop := DoGetFileProperty(MyEdit.Text, Ctrl.Text)
        MsgBox(Ctrl.Text ":`n`n" prop, 'File Property')
        DDL.Choose(1)
    }

}

DoSelectFile() {

    initialDir := MyEdit.Text
    Item := "Exe Files"
    ext := '*'

    MyGui.Opt("+OwnDialogs")

    SelectedFile := FileSelect(1+2+32, initialDir, 
        "Select " Item " file", 'Exe and Lnk (*.exe;*.lnk)')

    if (SelectedFile = '') {
        MyEdit.Text := initialDir
        return
    } else {
        MyEdit.Text := SelectedFile
    }

    ; DELETE IniWrite(MyEdit.Text, INI_PATH, "Settings", "DefaultPath")

    INI.Write("Settings", "DefaultPath", MyEdit.Text)

    buttonList.Focus()

}

DoGetFileProperty(filePath, property) {

    INI.Write("Settings", "DefaultPath", MyEdit.Text)

    try
    {
        ; Create a Shell.Application COM object
        shellApp := ComObject('Shell.Application')

        ; Get the parent folder and filename
        SplitPath(filePath, &filename, &directory)
        folder := shellApp.Namespace(directory)
        fileItem := folder.ParseName(filename)

        ; Get the file version using the ExtendedProperty method
        prop := fileItem.ExtendedProperty(property)

        return prop
    }
    catch as e
    {
        MsgBox 'Error: ' e.Message
    }
}

; https://www.google.com/search?q=ahk2+how+to+use+.extendedProperty+to+get+file+version+info&rlz=1C1CHBF_enUS1066US1066&oq=ahk2+how+to+use+.extendedProperty+to+get+file+version+info&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIJCAEQIRgKGKABMgcIAhAhGKsCMgcIAxAhGI8C0gEIMTAwOGowajeoAgCwAgA&sourceid=chrome&ie=UTF-8

DoListFileProperties(filePath, properties) {

;FileGetShortcut LinkFile [, &OutTarget, &OutDir, &OutArgs, &OutDescription, &OutIcon, &OutIconNum, &OutRunState]

    if (true) {
        ;filePath := A_ScriptDir "\vscode.lnk"
        ;filePath := A_ScriptDir "\TEST.lnk"
        filePath := A_ScriptDir "\NOTEPAD.EXE.LNK"
        FileGetShortcut(filePath , &OutTarget, &OutDir, &OutArgs, &OutDescription, &OutIcon, &OutIconNum, &OutRunState)
        prop :=  OutTarget
        msgbox("File:`n`n" filePath "`n`nprop:`n`n" prop )
        return

    }


    INI.Write("Settings", "DefaultPath", MyEdit.Text)

    ;FileAppend(filePath, A_Temp "\GetFileProperties.ini")

    try
    {
        ; Create a Shell.Application COM object
        shellApp := ComObject('Shell.Application')

        ; Get the parent folder and filename
        splitPath(filePath, &filename, &directory)
        folder := shellApp.Namespace(directory)
        fileItem := folder.ParseName(filename)

        ; Get the file version using the ExtendedProperty method
        ; Note: Property names are not always consistent. 'FileVersion' and 'ProductVersion' are common.
        ; For best results, use the canonical property name if you know it.
        ;fileVersion := fileItem.ExtendedProperty('System.FileVersion')
        fileVersion := fileItem.ExtendedProperty('System.Size')

        buff := ''
        ItemCount := 0

        for key, value in propertiesArray {

            if (value != "Choose Property") {

                ItemCount++

                props := fileItem.ExtendedProperty(value)

                if (IsSet(props) && props != '') {
                    buff .= ItemCount ": " propertiesArray[key] ": " props "`n`n"
                } else {
                    buff .= ItemCount ": " propertiesArray[key] ": Not found.`n`n"
                }
            }
            
        }

        MsgBox(buff, "All Properties")
    }
    catch as e
    {
        MsgBox 'Error: ' e.Message
    }
}