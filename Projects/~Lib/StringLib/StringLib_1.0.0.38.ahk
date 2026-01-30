/**
 * StringLib v1.0.0.38
 * A comprehensive class library for advanced string manipulation in AHK v2.
 */
class Str {
    /**
     * Extracts a substring between two delimiters.
     */
    static Between(str, startMarker, endMarker) {
        posStart := InStr(str, startMarker)
        if (posStart = 0)
            return ""
        posStart += StrLen(startMarker)
        posEnd := InStr(str, endMarker, , posStart)
        if (posEnd = 0)
            return ""
        return SubStr(str, posStart, posEnd - posStart)
    }

    /**
     * Converts a string to camelCase (e.g., "hello world" -> "helloWorld").
     */
    static Camel(str) {
        str := this.Title(str)
        str := StrReplace(str, " ")
        return StrLower(SubStr(str, 1, 1)) . SubStr(str, 2)
    }

    /**
     * Compares two strings. Default is case-insensitive.
     */
    static Compare(str1, str2, caseSense := false) {
        return StrCompare(str1, str2, caseSense)
    }

    /**
     * Checks if a string contains a specific needle.
     */
    static Contains(haystack, needle, caseSense := false) {
        return !!InStr(haystack, needle, caseSense)
    }

    /**
     * Counts how many times a needle appears in the haystack.
     */
    static CountOccurrences(haystack, needle, caseSense := false) {
        if (needle = "")
            return 0
        StrReplace(haystack, needle, , caseSense, &count)
        return count
    }

    /**
     * Encloses the string with the specified characters.
     */
    static Enclose(str, EndChars := '"') {
        return EndChars . str . EndChars
    }

    /**
     * Checks if a string ends with a specific needle.
     */
    static EndsWith(haystack, needle, caseSense := false) {
        len := StrLen(needle)
        if (len = 0)
            return true
        return (SubStr(haystack, -len) = needle)
    }

    /**
     * Converts bytes into a human-readable string.
     * Logic corrected for AHK v2 Log() and trailing zeros.
     */
    static FormatBytes(bytes, precision := 2) {
        static units := ["Bytes", "KB", "MB", "GB", "TB", "PB"]
        if (bytes <= 0)
            return "0 Bytes"
        
        index := Floor(Log(bytes) / Log(1024))
        value := bytes / (1024 ** index)
        
        ; Round and then trim trailing zeros and decimal point
        formattedValue := RTrim(RTrim(Round(value, precision), "0"), ".")
        return formattedValue . " " . units[index + 1]
    }

    /**
     * Formats a YYYYMMDDHH24MISS timestamp into a readable string.
     */
    static FormatTime(FormatStr := "HH:mm:ss", YYYYMMDDHH24MISS := "") {
        return FormatTime(YYYYMMDDHH24MISS, FormatStr)
    }

    /**
     * Checks if the string contains only alphanumeric characters.
     */
    static IsAlnum(str) {
        return IsAlnum(str)
    }

    /**
     * Checks if the string contains only alphabetic characters.
     */
    static IsAlpha(str) {
        return IsAlpha(str)
    }

    /**
     * Checks if the string is empty or contains only whitespace.
     */
    static IsBlank(str) {
        if (Trim(str) = "")
            return true
        return false
    }

    /**
     * Checks if the string contains only digits.
     */
    static IsDigit(str) {
        return IsDigit(str)
    }

    /**
     * Checks if the string is exactly empty (length of 0).
     */
    static IsEmpty(str) {
        if (str = "")
            return true
        return false
    }

    /**
     * Checks if the string is entirely lowercase.
     */
    static IsLower(str) {
        return IsLower(str)
    }

    /**
     * Checks if the string contains only whitespace characters.
     */
    static IsSpace(str) {
        return IsSpace(str)
    }

    /**
     * Checks if a value matches a specific type.
     */
    static IsType(val, typeName) {
        return Type(val) = typeName
    }

    /**
     * Checks if the string is entirely uppercase.
     */
    static IsUpper(str) {
        return IsUpper(str)
    }

    /**
     * Converts an array into a single string joined by a delimiter.
     */
    static JoinArray(arr, delim := ",") {
        res := ""
        for i, val in arr {
            res .= (i = 1 ? "" : delim) . val
        }
        return res
    }

    /**
     * Converts a string to kebab-case (e.g., "Hello World" -> "hello-world").
     */
    static Kebab(str) {
        return StrLower(StrReplace(Trim(str), " ", "-"))
    }

    /**
     * Returns the leftmost N characters of a string.
     */
    static Left(str, count) {
        return SubStr(str, 1, count)
    }

    /**
     * Splits a string into an array of lines.
     */
    static Lines(str) {
        return StrSplit(str, ["`r`n", "`n", "`r"])
    }

    /**
     * Trims specified characters from the beginning of a string.
     */
    static LTrim(str, chars := " `t") {
        return LTrim(str, chars)
    }

    /**
     * Pads the string on the left to reach a specific length.
     */
    static PadLeft(str, targetLen, padChar := " ") {
        diff := targetLen - StrLen(str)
        if (diff <= 0)
            return str
        return this.Repeat(padChar, diff) . str
    }

    /**
     * Pads the string on the right to reach a specific length.
     */
    static PadRight(str, targetLen, padChar := " ") {
        diff := targetLen - StrLen(str)
        if (diff <= 0)
            return str
        return str . this.Repeat(padChar, diff)
    }

    /**
     * Generates a random alphanumeric string of a given length.
     */
    static Random(length := 10) {
        characters := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        result := ""
        loop length {
            result .= SubStr(characters, Random(1, StrLen(characters)), 1)
        }
        return result
    }

    /**
     * Searches a string for a pattern using Regular Expressions.
     */
    static RegExMatch(str, needleRegEx, &OutputVar?, startingPos := 1) {
        return RegExMatch(str, needleRegEx, &OutputVar, startingPos)
    }

    /**
     * Replaces occurrences of a pattern with a replacement string.
     */
    static RegExReplace(str, needleRegEx, replacement := "", &OutputVarCount?, limit := -1, startingPos := 1) {
        return RegExReplace(str, needleRegEx, replacement, &OutputVarCount, limit, startingPos)
    }

    /**
     * Repeats a string N times.
     */
    static Repeat(str, count) {
        res := ""
        loop count
            res .= str
        return res
    }

    /**
     * Replaces occurrences of a needle with a replacement string.
     */
    static Replace(str, needle, replacement, caseSense := false) {
        return StrReplace(str, needle, replacement, caseSense)
    }

    /**
     * Reverses the character order of a string.
     */
    static Reverse(str) {
        res := ""
        loop StrLen(str)
            res := SubStr(str, A_Index, 1) . res
        return res
    }

    /**
     * Returns the rightmost N characters of a string.
     */
    static Right(str, count) {
        return SubStr(str, -count)
    }

    /**
     * Trims specified characters from the end of a string.
     */
    static RTrim(str, chars := " `t") {
        return RTrim(str, chars)
    }

    /**
     * Returns the approximate number of sentences in a string.
     */
    static SentenceCount(str) {
        if (this.IsBlank(str))
            return 0
        RegExReplace(str, "[.!?](\s+|$)", , &count)
        return count
    }

    /**
     * URL-friendly version of a string (lowercase, no special chars, hyphens).
     */
    static Slug(str) {
        str := StrLower(str)
        str := RegExReplace(str, "[^a-z0-9\s-]", "")
        str := RegExReplace(str, "[\s-]+", "-")
        return Trim(str, "-")
    }

    /**
     * Converts a string to snake_case (e.g., "Hello World" -> "hello_world").
     */
    static Snake(str) {
        return StrLower(StrReplace(Trim(str), " ", "_"))
    }

    /**
     * Sorts a delimited string.
     */
    static Sort(str, options := "") {
        return Sort(str, options)
    }

    /**
     * Splits a path into its components and returns an object.
     */
    static SplitPath(path) {
        path := StrReplace(path, "\\", "\")
        SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
        SplitPath(Dir,,&ParentDir)
        return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
    }

    /**
     * Retrieves information about a shortcut file (.lnk).
     */
    static SplitShortcut(LinkFile) {
        FileGetShortcut(LinkFile, &OutTarget, &OutDir, &OutArgs, &OutDescription, &OutIcon, &OutIconNum, &OutRunState)
        return {Target: OutTarget, Dir: OutDir, Args: OutArgs, Description: OutDescription, Icon: OutIcon, IconNum: OutIconNum, RunState: OutRunState}
    }

    /**
     * Checks if a string starts with a specific needle.
     */
    static StartsWith(haystack, needle, caseSense := false) {
        if (needle = "")
            return true
        return (InStr(haystack, needle, caseSense) = 1)
    }

    /**
     * Joins multiple string arguments into one string.
     */
    static StrJoin(Separator := ",", Parts*) {
        res := ""
        for i, val in Parts {
            res .= (i = 1 ? "" : Separator) . val
        }
        return res
    }

    /**
     * Joins multiple strings into a valid Windows file path.
     */
    static StrJoinPath(Parts*) {
        res := ""
        for i, val in Parts {
            if (val = "")
                continue
            
            val := Trim(val, "\")
            
            if (InStr(val, ":") = 2 && StrLen(val) = 2)
                val .= "\"
            
            if (res = "") {
                res := val
            } else {
                res := RTrim(res, "\") . "\" . val
            }
        }
        return res
    }

    /**
     * Returns a section of a string.
     */
    static SubStr(str, pos, len?) {
        if IsSet(len)
            return SubStr(str, pos, len)
        return SubStr(str, pos)
    }

    /**
     * Capitalizes the first letter of every word.
     */
    static Title(str) {
        return StrTitle(str)
    }

    /**
     * Trims specified characters from the beginning and end of a string.
     */
    static Trim(str, chars := " `t") {
        return Trim(str, chars)
    }

    /**
     * Limits a string to a certain length and adds a suffix.
     */
    static Truncate(str, length := 30, suffix := "...") {
        if (StrLen(str) <= length)
            return str
        return SubStr(str, 1, length) . suffix
    }

    /**
     * Returns the number of words in a string.
     */
    static WordCount(str) {
        if (this.IsBlank(str))
            return 0
        RegExReplace(Trim(str), "s)\s+", , &count)
        return count + 1
    }

    /**
     * Wraps a string to a maximum number of characters per line.
     * Fixed RegEx logic to handle exact multiples correctly.
     */
    static Wrap(str, limit := 80, delim := "`n") {
        if (limit <= 0)
            return str
        ; Corrected RegEx to insert delimiter after every N characters
        return RegExReplace(str, "(.{" . limit . "})(?!$)", "$1" . delim)
    }
}