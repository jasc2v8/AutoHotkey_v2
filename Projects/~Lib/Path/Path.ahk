; TITLE  :  Path v1.15.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

/**
 * Path Class Library for AutoHotkey v2
 * Provides comprehensive file and directory management.
 */
class Path {
    /**
     * Splits a path into its components and returns an object.
     * @param filePath The path string to analyze.
     * @returns {Object} Contains Name, Dir, Ext, NameNoExt, and Drive.
     */
    static Split(filePath) {
        SplitPath(filePath, &Name, &Dir, &Ext, &NameNoExt, &Drive)
        
        return {
            Name: Name,
            Dir: Dir,
            Ext: Ext,
            NameNoExt: NameNoExt,
            Drive: Drive
        }
    }

    /**
     * Joins multiple strings into a single path, ensuring correct backslash placement.
     * @param Parts Variadic list of path segments.
     * @returns {String} The combined path.
     */
    static Join(Parts*) {
        Result := ""
        for Index, Part in Parts {
            if (Part = "")
                continue
            
            if (Result != "") {
                Result := RTrim(Result, "\") . "\" . LTrim(Part, "\")
            } else {
                Result := Part
            }
        }
        return Result
    }

    /**
     * Wraps a path in double quotes if it contains spaces.
     * @param filePath The path string to quote.
     * @returns {String} The quoted or original path.
     */
    static Quote(filePath) {
        if InStr(filePath, " ") {
            return '"' . filePath . '"'
        }
        
        return filePath
    }

    /**
     * Checks if a file or directory exists.
     * @param filePath The path to check.
     * @returns {Integer} Returns 1 if exists, 0 otherwise.
     */
    static Exists(filePath) {
        return FileExist(filePath) ? 1 : 0
    }

    /**
     * Converts a relative path to a full absolute path.
     * @param filePath The path to resolve.
     * @returns {String} The full absolute path.
     */
    static GetAbsolute(filePath) {
        Loop Files, filePath, "DF" {
            return A_LoopFileFullPath
        }
        return filePath
    }

    /**
     * Retrieves the size of the file in bytes.
     * @param filePath The path to the file.
     * @returns {Integer} Size in bytes.
     */
    static GetSize(filePath) {
        try {
            return FileGetSize(filePath)
        } catch {
            return 0
        }
    }

    /**
     * Converts bytes to human-readable format (KB, MB, GB, TB).
     * @param Bytes The numeric size in bytes.
     * @returns {String} Formatted string (e.g., "1.45 MB").
     */
    static FormatSize(Bytes) {
        Units := ["Bytes", "KB", "MB", "GB", "TB"]
        Index := 1
        Size := Float(Bytes)
        
        while (Size >= 1024 && Index < Units.Length) {
            Size /= 1024
            Index++
        }
        
        return Round(Size, 2) . " " . Units[Index]
    }

    /**
     * Gets the file size directly in human-readable format.
     */
    static GetSizeFormatted(filePath) {
        return this.FormatSize(this.GetSize(filePath))
    }

    /**
     * Retrieves the attribute string (RASHNDOCT).
     * @param filePath The path to the file or directory.
     * @returns {String} Attribute string.
     */
    static GetAttributes(filePath) {
        try {
            return FileGetAttrib(filePath)
        } catch {
            return ""
        }
    }

    /**
     * Checks if a path has a specific attribute.
     * @param filePath The path to check.
     * @param Attribute The letter (e.g., "H" for hidden).
     * @returns {Integer} 1 if it has the attribute, 0 otherwise.
     */
    static HasAttribute(filePath, Attribute) {
        return InStr(this.GetAttributes(filePath), Attribute) ? 1 : 0
    }

    /**
     * Sets or removes file attributes.
     * @param filePath The path to the file or directory.
     * @param Attributes The attribute string (e.g., "+H-R").
     */
    static SetAttributes(filePath, Attributes) {
        try {
            FileSetAttrib(Attributes, filePath)
            return 1
        } catch {
            return 0
        }
    }

    /**
     * Gets a file timestamp.
     * @param filePath The path to the file.
     * @param Which M = Modified (default), C = Created, A = Accessed.
     * @returns {String} YYYYMMDDHH24MISS format.
     */
    static GetTime(filePath, Which := "M") {
        try {
            return FileGetTime(filePath, Which)
        } catch {
            return ""
        }
    }

    /**
     * Sets a file timestamp.
     * @param filePath The path to the file.
     * @param TimeStamp YYYYMMDDHH24MISS format.
     * @param Which M = Modified (default), C = Created, A = Accessed.
     */
    static SetTime(filePath, TimeStamp, Which := "M") {
        try {
            FileSetTime(TimeStamp, filePath, Which)
            return 1
        } catch {
            return 0
        }
    }

    /**
     * Moves a file or directory to a new location.
     * @param Source The current path.
     * @param Dest The new path.
     * @param Overwrite 1 to overwrite existing files, 0 to fail if exists.
     */
    static Move(Source, Dest, Overwrite := 0) {
        try {
            FileMove(Source, Dest, Overwrite)
            return 1
        } catch {
            return 0
        }
    }

    /**
     * Renames a file or directory within its current folder.
     * @param filePath The current path.
     * @param NewName The new name (just the name, not the full path).
     * @param Overwrite 1 to overwrite, 0 to fail.
     */
    static Rename(filePath, NewName, Overwrite := 0) {
        SplitPath(filePath, , &Dir)
        NewPath := this.Join(Dir, NewName)
        return this.Move(filePath, NewPath, Overwrite)
    }

    /**
     * Deletes a file.
     * @param filePath The path to the file.
     * @param Recycle True to move to Recycle Bin, False to delete permanently.
     */
    static Delete(filePath, Recycle := false) {
        try {
            if (Recycle) {
                FileRecycle(filePath)
            } else {
                FileDelete(filePath)
            }
            return 1
        } catch {
            return 0
        }
    }

    /**
     * Copies a file to a new location.
     * @param Source The path to the file to copy.
     * @param Dest The path to the destination.
     * @param Overwrite 1 to overwrite existing, 0 to fail.
     */
    static Copy(Source, Dest, Overwrite := 0) {
        try {
            FileCopy(Source, Dest, Overwrite)
            return 1
        } catch {
            return 0
        }
    }

    /**
     * Creates a directory. Handles nested folders automatically.
     * @param dirPath The folder path to create.
     */
    static CreateDir(dirPath) {
        if this.Exists(dirPath)
            return 1
        
        try {
            DirCreate(dirPath)
            return 1
        } catch {
            return 0
        }
    }

    /**
     * Reads the entire contents of a file into a variable.
     * @param filePath The path to the file.
     * @returns {String} The file content.
     */
    static Read(filePath) {
        try {
            return FileRead(filePath)
        } catch {
            return ""
        }
    }

    /**
     * Writes text to a file. Overwrites existing content.
     * @param filePath The path to the file.
     * @param Text The string to write.
     */
    static Write(filePath, Text) {
        try {
            SplitPath(filePath, , &Dir)
            this.CreateDir(Dir)
            if FileExist(filePath)
                FileDelete(filePath)
            FileAppend(Text, filePath)
            return 1
        } catch {
            return 0
        }
    }

    /**
     * Appends text to a file.
     * @param filePath The path to the file.
     * @param Text The string to append.
     */
    static Append(filePath, Text) {
        try {
            SplitPath(filePath, , &Dir)
            this.CreateDir(Dir)
            FileAppend(Text, filePath)
            return 1
        } catch {
            return 0
        }
    }

    /**
     * Searches for files or folders matching a pattern.
     * @param Pattern The search pattern (e.g. "*.txt").
     * @param Mode D = Folders, F = Files (default), R = Recursive.
     * @returns {Array} An array of full paths.
     */
    static Find(Pattern, Mode := "F") {
        FileList := []
        Loop Files, Pattern, Mode {
            FileList.Push(A_LoopFileFullPath)
        }
        return FileList
    }

    /**
     * Retrieves version and metadata information from an executable file.
     * @param filePath The path to the .exe, .dll, etc.
     * @returns {Object} Metadata (Version, Company, Product, etc).
     */
    static GetFileProperties(filePath) {
        return {
            Version: FileGetVersion(filePath),
            Description: FileGetVersion(filePath, "FileDescription"),
            Company: FileGetVersion(filePath, "CompanyName"),
            Copyright: FileGetVersion(filePath, "LegalCopyright"),
            InternalName: FileGetVersion(filePath, "InternalName"),
            Product: FileGetVersion(filePath, "ProductName")
        }
    }

    /**
     * Opens a file or folder with the default system application.
     * @param filePath The path to open.
     * @param verb The action to perform (default 'open').
     */
    static Open(filePath, verb := "open") {
        try {
            Run(verb . " " . this.Quote(filePath))
            return 1
        } catch {
            return 0
        }
    }

    /**
     * Calculates a cryptographic hash of the file using CertUtil.
     * @param filePath The path to the file.
     * @param Algo MD5, SHA1, or SHA256 (default).
     * @returns {String} Hexadecimal hash string.
     */
    static GetHash(filePath, Algo := "SHA256") {
        if !this.Exists(filePath)
            return ""
        
        try {
            TempFile := A_Temp "\hash_output.txt"
            RunWait(A_ComSpec ' /c certutil -hashfile ' this.Quote(filePath) ' ' Algo ' > ' this.Quote(TempFile), , "Hide")
            Raw := FileRead(TempFile)
            FileDelete(TempFile)
            
            Lines := StrSplit(Raw, "`r`n", "`n")
            if (Lines.Length >= 2) {
                return StrReplace(Lines[2], " ", "")
            }
        } catch {
            return ""
        }
        return ""
    }
}