;ABOUT: 

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Warn Unreachable, Off

Source := "D:\SOURCE"
Target := "D:\TARGET"
Overwrite := True

if !DirExist(Target)
   DirCreate(Target)

r := DllCall("Kernel32\CopyFile", "Str", Source, "Str", Target, "Int", Overwrite)

MsgBox (r) ? "Success": "Error" ; "True": "False"

Overwrite := True

;DirCopy(SourceFolder, TargetFolder, true)
;return

;DllCall("kernel32\CopyFile", Str,"\\?\" vPathLong, Str,"\\?\" vPathLongNew, Int,1)
;r := DllCall("Kernel32\CopyFile", "Str", SourceFolder, "Str", TargetFolder, "Int", Overwrite)

MsgBox (r) ? "True": "False"

ExitApp()

; --- Execution ---
If FolderBackup(SourceFolder, TargetFolder)
    MsgBox("Backup successful!`n`nSource:`n`n" . SourceFolder . "`n`nDestination:`n`n" . TargetFolder, "Backup Complete", 0x40)
Else
    MsgBox("Backup failed or was cancelled.", "Error", 0x10)

; --- Backup Function ---

/**
 * Copies a source folder and its contents to a destination folder.
 * @param Source The path of the folder to be copied.
 * @param Destination The path where the folder should be copied to (e.g., C:\Backups\NewFolder).
 * @returns True if successful, False otherwise.
 */
FolderBackup(Source, Destination)
{
    try
    {
        ; 1. Check if the source folder exists
        if (!DirExist(Source))
        {
            MsgBox("Error: Source folder not found at " . Source)
            return false
        }

        ; 2. Ensure the parent directory for the destination exists (e.g., C:\Backups)
        ; This prevents an error if only the final destination folder is missing.
        SplitPath(Destination, &Name, &Dir)
        if (!DirExist(Dir))
        {
            DirCreate(Dir)
        }

        ; 3. Use DirCopy to perform the backup
        ; The "1" flag ensures that existing files in the destination are overwritten.
        DirCopyWin32(Source, Destination, 1)
        ;DirCopy(Source, Destination, true)


        ; 4. Check if the destination now exists
        if (DirExist(Destination))
        {
            return true
        }
        else
        {
            MsgBox("Error: Backup failed. The destination folder was not created.")
            return false
        }
    }
    catch as e
    {
        MsgBox("An error occurred during backup: " . e.Message, "Error", 0x10)
        return false
    }
}

; This DirCopy function mimics the AHK v1 command and is commonly used in v2.
; It utilizes the Windows built-in CopyFile function for efficiency.
DirCopyWin32(Source, Destination, Overwrite := 0)
{
    return DllCall("Shlwapi\PathIsDirectoryEmpty", "Str", Source)
        || DllCall("Kernel32\CopyFile", "Str", Source, "Str", Destination, "Int", !Overwrite)
        || FileExist(Destination)
        || DllCall("Shell32\SHFileOperation", "UInt", 0, "UInt", 0x0002, "Ptr", Destination, "Str", Source, "UInt", 0)
        || DirExist(Destination)
}