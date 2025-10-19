#Requires AutoHotkey v2.0
#SingleInstance Force

; -------------------------------------------------------------------------
; Configuration & Usage Example
; -------------------------------------------------------------------------

; Note: Property indexes are system-dependent and can vary.
; Common Indexes:
; 1: Size (KB)
; 3: Date Modified
; 4: Date Created
; 9: Date Accessed
; 21: Company Name (for EXE/DLL)
; 29: Date Taken (for image files)

;TargetFile := A_ScriptDir "\test_file.txt" 
TargetFile := A_ScriptDir "\TEMP.lnk" 

PropertyIndex := 3 ; We will look up 'Date Modified' (Index 3)

; --- Main Setup ---
MyGui := Gui()
MyGui.Title := "AHK v2 Shell32.Shell Example"
MyGui.Add("Text", "w450", "File: " TargetFile)
ResultControl := MyGui.Add("Text", "w450 vResultText", "Result: Querying...")
MyGui.Show()

; Ensure the test file exists for the demonstration
if (!FileExist(TargetFile)) {
    FileAppend("This is a temporary file created for demonstration.", TargetFile)
}

; -------------------------------------------------------------------------
; Query and Display Results
; -------------------------------------------------------------------------

resultText := ""

Loop 1000 {

    PropertyIndex := A_Index

    ; 1. Find the name of the property based on index (for display purposes)
    PropertyName := GetShellPropertyName(A_ScriptDir, PropertyIndex)

    ; 2. Get the actual value for the file
    DetailValue := GetShellFileDetail(TargetFile, PropertyIndex)

    ; 3. Update the GUI
    ;ResultControl.Text := "Property [" PropertyName "] (" PropertyIndex "): " DetailValue

    if (DetailValue != '')
        resultText .= "Property [" PropertyName "] (" PropertyIndex "): " DetailValue "`n"

}

msgbox(resultText)
ResultControl.Text := resultText
    
; -------------------------------------------------------------------------
; Function to Retrieve Extended File Detail
; -------------------------------------------------------------------------
#Include <AhkFunctions>


; Retrieves a specific extended property detail for a file using the Shell COM object.
GetShellFileDetail(filePath, propertyIndex)
{
    ; Extract the directory and filename from the full path.
    dirPath := SplitPathObj(filePath).Dir ; Dirname(filePath)
    fileName := SplitPathObj(filePath).Filename ;Filename(filePath)

    if (!FileExist(filePath)) {
        return "File Not Found"
    }

    try
    {
        ; 1. Create the Shell Application COM Object.
        shellApp := ComObject("Shell.Application")

        ; 2. Get the Folder object for the file's directory path.
        folderObj := shellApp.NameSpace(dirPath)

        ; 3. Get the File Item object within that folder.
        fileItem := folderObj.ParseName(fileName)

        ; 4. Retrieve the detail using GetDetailsOf, which returns the extended property value.
        ; The first argument can be the file item object.
        detailValue := folderObj.GetDetailsOf(fileItem, propertyIndex)
        
        ; 5. Explicitly release COM objects (good practice)
        shellApp := folderObj := fileItem := ""

        return detailValue

    } catch as e {
        ; Use an explicit error message instead of failing silently
        return "COM Error: " e.Message
    }
}

; Helper function to get the name of the property index for display.
GetShellPropertyName(dirPath, propertyIndex) {
    try {
        shellApp := ComObject("Shell.Application")
        folderObj := shellApp.NameSpace(dirPath)
        ; Calling GetDetailsOf with an empty first parameter retrieves the column/property header name.
        name := folderObj.GetDetailsOf("", propertyIndex)
        shellApp := folderObj := ""
        return name
    } catch {
        return "Unknown Property"
    }
}
