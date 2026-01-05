;ABOUT: Retrieves all file properties from an executable

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon


; #region Version Info Block

;@Ahk2Exe-Set ProductName, GetFileProperties
;@Ahk2Exe-Set FileVersion, 1.0.0.1
;@Ahk2Exe-Set ProductVersion, 1.0.0.0
;@Ahk2Exe-Set LegalCopyright, © 2025 jasc2v8
;@Ahk2Exe-Set CompanyName, AhkApps
;@Ahk2Exe-Set FileDescription, Get File Properties
;@Ahk2Exe-Set OriginalFilename, GetFileProperties.exe
;@Ahk2Exe-SetMainIcon GetFileProperties.ico

;@Inno-Set AppId, {{8D2C2750-0620-4B47-9BAA-A66368292E8D}}}
;@Inno-Set AppPublisher, AhkApps

; #region Globals

global INI_PATH := A_Temp "\" StrReplace(A_ScriptName, ".ahk", ".ini")

global propertiesArray := [
            "Choose Property", ; what a hack, haha
            "Name",
            "Size",
            "ProductName", 
            "ProductVersion", 
            "FileDescription",
            "Company", 
            "Copyright", 
            "FileVersion", 
        ]

; #region GUI Create

defaultPath := DoIniRead("DefaultPath")

MyGuiTitle := "Get File Properties v1.0"
MyGui := Gui(, MyGuiTitle ) ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w532", "Segouie UI")

buttonSelect := MyGui.Add("Button", "xm ym w128 h24", "Select")
    .OnEvent("Click", (*) => DoSelectFile())
MyEdit := MyGui.Add("Edit", "yp w640")
MyEdit.Text := defaultPath

buttonList := MyGui.Add("Button", "yp w64 h24 Default", "List")
    .OnEvent("Click", (*) => DoListFileProperties(MyEdit.Text, propertiesArray))

;buttonNext := MyGui.Add("Button", "xm w64", "Next")
;    .OnEvent("Click", (*) => DoNext(MyEdit.Text))

DDL := MyGui.Add("DropDownList", "xm w128 Choose1", propertiesArray)

MyEditProperty := MyGui.Add("Edit", "yp w640")

MyY := A_ScreenHeight / 8

MyGui.Show("x20 y" MyY) ; postion above the msgbox listing the file properties

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
        MyEditProperty.Text := prop
    }

}
DoIniRead(key := "DefaultPath") {

     if FileExist(INI_PATH ) {
        defaultPath := IniRead(INI_PATH, "Settings", key)

    } else {
        defaultPath := A_ScriptFullPath
        try {
            FileAppend("[Settings]", INI_PATH)
            ;DEBUG Run(INI_PATH)
        } catch as e {
            MsgBox("Error creating file:`n" e.Message, "Error", "Stop")
        }
    }
    return defaultPath
}

DoIniWrite(key := "DefaultPath") {

    try {
        IniWrite(MyEdit.Text, INI_PATH, "Settings", "DefaultPath") 
    } catch Error as e {
        MsgBox('!! Error !!`n`n'
        . 'Message:`n`n' e.Message '`n'
        . 'Details:`n`n' e.Extra '`n`n'
        . 'Line: ' e.Line,
        'DoIniWrite Error', 'IconX')
    }
}

DoReset() {
    DDL.Choose(1)
    ;MyEdit.Text := DoIniRead()
    MyEditProperty.Text := ''

}
DoSelectFile() {

    DoReset()

    initialDir := MyEdit.Text
    Item := "Exe Files"
    ext := '*'

    MyGui.Opt("+OwnDialogs")

    SelectedFolder := FileSelect(1+2, initialDir, 
        "Select " Item " file", Item "Exe Files (*.exe")

    if (SelectedFolder = '') {
        MyEdit.Text := initialDir
        return
    } else {
        MyEdit.Text := SelectedFolder
    }

    DoIniWrite()

}

SplitPathObj(path) {
    SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    SplitPath(Dir,,,,&ParentDir)
    return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}

DoGetFileProperty(filePath, property) {

    DoIniWrite()

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

    DDL.Choose(1)
    MyEditProperty.Text := ''

    DoIniWrite()

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