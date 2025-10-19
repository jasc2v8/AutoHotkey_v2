
/************************************************************************
 * @description 
 * @author 
 * @date 2025/09/16
 * @version 0.0.1
 ***********************************************************************/

#Requires AutoHotkey v2.0

#SingleInstance force

MsgBox("Press OK to clear the output window then write output from this function.")

ClearVSCodeOutput()

SourceFile := "D:\Software\DEV\Work\csharp\Projects\Download Control Tool\DownloadControlTool.sln"

dir := GetPathPart(SourceFile, "Dir")

WriteConsole("SourceFile: " . SourceFile)
WriteConsole("GetPathPart(SourceFile, 'Dir'): " . GetPathPart(SourceFile, "Dir"))
WriteConsole("GetPathPart(SourceFile, 'Name'): " . GetPathPart(SourceFile, "Name"))
WriteConsole("GetPathPart(SourceFile, 'Ext'): " . GetPathPart(SourceFile, "Ext"))
WriteConsole("GetPathPart(SourceFile, 'Drive'): " . GetPathPart(SourceFile, "Drive"))
WriteConsole("GetPathPart(SourceFile, 'ParentDir'): " . GetPathPart(SourceFile, "ParentDir"))
WriteConsole()


WriteConsole(Text := "") {
	stdout := FileOpen("*", "w")
	stdout.WriteLine(Text)
	stdout.Close()
}


/*
  Function: GetPathPart(ByVal Path, ByVal PartName)

  Description:
    A wrapper function for AHK2's built-in SplitPath() that returns a specific part of a file path.
    This simplifies getting a single component without an array index or out parameter.

  Parameters:
    - Path: The full path to a file or folder.
    - PartName: A string specifying which part of the path to return.
      Valid options are: 'Dir', 'Name', 'Ext', 'Drive'.

  Returns:
    A string containing the requested part of the path.
*/
GetPathPart(Path, PartName) {
    SplitPath(Path, &Name, &Dir, &Ext, &Drive)
    SplitPath(Dir,&ParentDir) 
    
    switch (PartName) {
        case 'Dir':
            return Dir
        case 'Name':
            return Name
        case 'Ext':
            return Ext
        case 'Drive':
            return Drive
        case 'ParentDir':
            return ParentDir
        default:
            throw Error("Invalid PartName. Must be 'Dir', 'Name', 'Ext', 'Drive', or 'ParentDir'.")
    }
}

; Function to clear the VS Code output window
ClearVSCodeOutput() {
    ; Simulate Ctrl+Shift+P to open the command palette
    Send "^+p"
    Sleep 1000 ; Give VS Code time to open the command palette

    ; Type "Clear Output" and press Enter
    Send "Clear Output"
    Sleep 1000 ; Give VS Code time to filter commands
    Send "{Enter}"
}
