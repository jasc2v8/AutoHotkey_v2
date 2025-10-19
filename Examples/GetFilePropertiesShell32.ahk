#Requires AutoHotkey v2.0
#SingleInstance Force

; -------------------------------------------------------------------------
; Configuration
; -------------------------------------------------------------------------

; IMPORTANT: Replace this with the path to your actual .lnk shortcut file.
; This example uses the Calculator shortcut, which is common on Windows.
LnkFilePath := A_StartMenu "\Programs\Accessories\Calculator.lnk"

; We will extract two useful properties from the TARGET file (e.g., Calculator.exe):
PropertyIndex_CompanyName := 21 ; Common index for Company Name
PropertyIndex_FileDesc := 2      ; Common index for File Description

; --- Main Script ---
MyGui := Gui()
MyGui.Title := "AHK v2 LNK Target Shell32 Query"
MyGui.Add("Text", "w450", "Querying Shortcut: " LnkFilePath)
TargetText := MyGui.Add("Text", "w450 vTargetText", "Target: Resolving...")
CompanyText := MyGui.Add("Text", "w450 vCompanyText", "Company: N/A")
DescText := MyGui.Add("Text", "w450 vDescText", "Description: N/A")
MyGui.Show()

; 1. Resolve the Target Path
TargetPath := ResolveLinkTarget(LnkFilePath)
TargetText.Text := "Target: " TargetPath

if (TargetPath = "") {
    msgbox("ERROR 1")
    ;MsgBox("Error: Could not resolve the shortcut target.", "Error", "IconStop")
    ExitApp
}

; 2. Query the Target Path using Shell32.Shell (Shell.Application)
CompanyName := GetShellFileDetail(TargetPath, PropertyIndex_CompanyName)
FileDescription := GetShellFileDetail(TargetPath, PropertyIndex_FileDesc)

; 3. Display Results
CompanyText.Text := "Company Name (Index " PropertyIndex_CompanyName "): " CompanyName
DescText.Text := "File Description (Index " PropertyIndex_FileDesc "): " FileDescription

; -------------------------------------------------------------------------
; Helper Functions
; -------------------------------------------------------------------------
#Include <AhkFunctions>

; Function 1: Resolves the Target path of a .lnk file using WScript.Shell
; This is the most reliable way to get the target path in AHK COM.
ResolveLinkTarget(lnkPath)
{
    try {
        ; Create the WScript.Shell COM object
        shell := ComObject("WScript.Shell")
        
        ; Create a shortcut object and load the .lnk file
        shortcut := shell.CreateShortcut(lnkPath)

        ; Retrieve and return the TargetPath property
        target := shortcut.TargetPath
        
        ; Release objects
        shell := shortcut := ""
        
        return target
    } catch {
        return "" ; Return empty string on failure
    }
}

; Function 2: Retrieves an extended property detail from a file using Shell32.Shell
; (This is the function requested by the user, applied to the resolved target)
GetShellFileDetail(filePath, propertyIndex)
{
    if (!FileExist(filePath)) {
        return "Target File Not Found"
    }
    
    ; Split path into directory and filename for Shell.Application
    dirPath := SplitPathObj(filePath).Dir ; Dirname(filePath)
    fileName := SplitPathObj(filePath).Filename ;Filename(filePath)
    try
    {
        ; 1. Create the Shell Application COM Object (Shell32.Shell)
        shellApp := ComObject("Shell.Application")

        ; 2. Get the Folder object for the file's directory
        folderObj := shellApp.NameSpace(dirPath)

        ; 3. Get the File Item object within that folder
        fileItem := folderObj.ParseName(fileName)

        ; 4. Retrieve the detail using GetDetailsOf
        detailValue := folderObj.GetDetailsOf(fileItem, propertyIndex)
        
        ; Release objects (good practice)
        shellApp := folderObj := fileItem := ""

        return detailValue

    } catch as e {
        return "COM Error: " e.Message
    }
}
