;ABOUT: Retrieves all file properties from an executable

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; #region Globals

;global INI_PATH := A_Temp "\AhkApps\" StrReplace(A_ScriptName, ".ahk", ".ini")
global INI_PATH := StrReplace(A_ScriptName, ".ahk", ".ini")

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
            "Type", 
            "Attributes", 
            "Target", 
            "FileLocation", 
            "DateCreated", 
            "DateModified", 
            "Owner", 
            "Filename", 
            "OriginalFilename", 
            "Target", 
            "TargetPath", 
        ]

; #region GUI Create

defaultPath := IniRead(INI_PATH, "Settings","DefaultPath")

if (defaultPath == "")
    defaultPath := A_ScriptFullPath

MyGuiTitle := "Get File Properties Example v1.0"
MyGui := Gui(, MyGuiTitle ) ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S11 CBlack w532", "Segouie UI")

buttonSelect := MyGui.Add("Button", "xm ym w64 h24", "Select")
    .OnEvent("Click", (*) => DoSelectFile())
MyEdit := MyGui.Add("Edit", "yp w640")
MyEdit.Text := defaultPath

buttonList := MyGui.Add("Button", "yp w64 h24 Default", "List")
    .OnEvent("Click", (*) => DoListFileProperties(MyEdit.Text, propertiesArray))

;buttonNext := MyGui.Add("Button", "xm w64", "Next")
;    .OnEvent("Click", (*) => DoNext(MyEdit.Text))

DDL := MyGui.Add("DropDownList", "yp Choose1", propertiesArray)

MyY := A_ScreenHeight / 8

MyGui.Show("x20 y" MyY) ; postion above the msgbox listing the file properties

DDL.OnEvent('Change', DDL_OnChange)

; #region Main

if FileExist("D:\Software\DEV\Work\AHK2\AhkApps\TEMP AhkApps.lnk") {
    OutputDebug("Exist")
    MyEdit.Text := "D:\Software\DEV\Work\AHK2\AhkApps\TEMP AhkApps.lnk"
}
else
    OutputDebug("NOT Exist")



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

    SelectedFile := FileSelect(1+2, initialDir, 
        ;"Select " Item " file", Item "Exe Files (*.exe")
        "Select " Item " file",)

    if (SelectedFile = '') {
        MyEdit.Text := initialDir
        return
    } else {
        MyEdit.Text := SelectedFile
    }

    IniWrite(MyEdit.Text, INI_PATH, "Settings", "DefaultPath")

}

SplitPathObj(path) {
    SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
    SplitPath(Dir,,,,&ParentDir)
    return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
}

DoGetFileProperty(filePath, property) {

    IniWrite(MyEdit.Text, INI_PATH, "Settings", "DefaultPath")

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

    ; if (true) {
    ;     filePath := "D:\Software\DEV\Work\AHK2\AhkApps\TEMP AhkApps.lnk"
    ;     msgbox DoGetFileProperty(filePath, "Target")
    ;     return

    ; }


    IniWrite(MyEdit.Text, INI_PATH, "Settings", "DefaultPath")

    FileAppend(filePath, A_Temp "\GetFileProperties.ini")

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