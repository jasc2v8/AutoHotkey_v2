StringLib Project v1.0.0.37
1. Library Documentation
This library provides a static class Str for advanced string handling in AutoHotkey v2.

Case Conversion
Camel(str): "hello world" -> "helloWorld"

Kebab(str): "Hello World" -> "hello-world"

Snake(str): "Hello World" -> "hello_world"

Slug(str): "Hello World!!!" -> "hello-world"

Formatting & Stats
FormatBytes(bytes, precision): Converts bytes to "1.5 MB", etc.

WordCount(str): Counts words in a string.

SentenceCount(str): Estimates sentence count based on punctuation.

Lines(str): Returns an array of lines.

2. Library Code (StringLib.ahk)
AutoHotkey
/**
 * StringLib v1.0.0.37
 * A comprehensive class library for advanced string manipulation in AHK v2.
 */
class Str {
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

    static Camel(str) {
        str := this.Title(str)
        str := StrReplace(str, " ")
        return StrLower(SubStr(str, 1, 1)) . SubStr(str, 2)
    }

    static Compare(str1, str2, caseSense := false) {
        return StrCompare(str1, str2, caseSense)
    }

    static Contains(haystack, needle, caseSense := false) {
        return !!InStr(haystack, needle, caseSense)
    }

    static CountOccurrences(haystack, needle, caseSense := false) {
        if (needle = "")
            return 0
        StrReplace(haystack, needle, , caseSense, &count)
        return count
    }

    static Enclose(str, EndChars := '"') {
        return EndChars . str . EndChars
    }

    static EndsWith(haystack, needle, caseSense := false) {
        len := StrLen(needle)
        if (len = 0)
            return true
        return (SubStr(haystack, -len) = needle)
    }

    static FormatBytes(bytes, precision := 2) {
        static units := ["Bytes", "KB", "MB", "GB", "TB", "PB"]
        if (bytes <= 0)
            return "0 Bytes"
        index := Floor(Log(bytes) / Log(1024))
        value := bytes / (1024 ** index)
        formattedValue := RTrim(RTrim(Round(value, precision), "0"), ".")
        return formattedValue . " " . units[index + 1]
    }

    static FormatTime(FormatStr := "HH:mm:ss", YYYYMMDDHH24MISS := "") {
        return FormatTime(YYYYMMDDHH24MISS, FormatStr)
    }

    static IsAlnum(str) {
        return IsAlnum(str)
    }

    static IsAlpha(str) {
        return IsAlpha(str)
    }

    static IsBlank(str) {
        if (Trim(str) = "")
            return true
        return false
    }

    static IsDigit(str) {
        return IsDigit(str)
    }

    static IsEmpty(str) {
        if (str = "")
            return true
        return false
    }

    static IsLower(str) {
        return IsLower(str)
    }

    static IsSpace(str) {
        return IsSpace(str)
    }

    static IsType(val, typeName) {
        return Type(val) = typeName
    }

    static IsUpper(str) {
        return IsUpper(str)
    }

    static JoinArray(arr, delim := ",") {
        res := ""
        for i, val in arr {
            res .= (i = 1 ? "" : delim) . val
        }
        return res
    }

    static Kebab(str) {
        return StrLower(StrReplace(Trim(str), " ", "-"))
    }

    static Left(str, count) {
        return SubStr(str, 1, count)
    }

    static Lines(str) {
        return StrSplit(str, ["`r`n", "`n", "`r"])
    }

    static LTrim(str, chars := " `t") {
        return LTrim(str, chars)
    }

    static PadLeft(str, targetLen, padChar := " ") {
        diff := targetLen - StrLen(str)
        if (diff <= 0)
            return str
        return this.Repeat(padChar, diff) . str
    }

    static PadRight(str, targetLen, padChar := " ") {
        diff := targetLen - StrLen(str)
        if (diff <= 0)
            return str
        return str . this.Repeat(padChar, diff)
    }

    static Random(length := 10) {
        characters := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        result := ""
        loop length {
            result .= SubStr(characters, Random(1, StrLen(characters)), 1)
        }
        return result
    }

    static RegExMatch(str, needleRegEx, &OutputVar?, startingPos := 1) {
        return RegExMatch(str, needleRegEx, &OutputVar, startingPos)
    }

    static RegExReplace(str, needleRegEx, replacement := "", &OutputVarCount?, limit := -1, startingPos := 1) {
        return RegExReplace(str, needleRegEx, replacement, &OutputVarCount, limit, startingPos)
    }

    static Repeat(str, count) {
        res := ""
        loop count
            res .= str
        return res
    }

    static Replace(str, needle, replacement, caseSense := false) {
        return StrReplace(str, needle, replacement, caseSense)
    }

    static Reverse(str) {
        res := ""
        loop StrLen(str)
            res := SubStr(str, A_Index, 1) . res
        return res
    }

    static Right(str, count) {
        return SubStr(str, -count)
    }

    static RTrim(str, chars := " `t") {
        return RTrim(str, chars)
    }

    static SentenceCount(str) {
        if (this.IsBlank(str))
            return 0
        RegExReplace(str, "[.!?](\s+|$)", , &count)
        return count
    }

    static Slug(str) {
        str := StrLower(str)
        str := RegExReplace(str, "[^a-z0-9\s-]", "")
        str := RegExReplace(str, "[\s-]+", "-")
        return Trim(str, "-")
    }

    static Snake(str) {
        return StrLower(StrReplace(Trim(str), " ", "_"))
    }

    static Sort(str, options := "") {
        return Sort(str, options)
    }

    static SplitPath(path) {
        path := StrReplace(path, "\\", "\")
        SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
        SplitPath(Dir,,&ParentDir)
        return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
    }

    static SplitShortcut(LinkFile) {
        FileGetShortcut(LinkFile, &OutTarget, &OutDir, &OutArgs, &OutDescription, &OutIcon, &OutIconNum, &OutRunState)
        return {Target: OutTarget, Dir: OutDir, Args: OutArgs, Description: OutDescription, Icon: OutIcon, IconNum: OutIconNum, RunState: OutRunState}
    }

    static StartsWith(haystack, needle, caseSense := false) {
        if (needle = "")
            return true
        return (InStr(haystack, needle, caseSense) = 1)
    }

    static StrJoin(Separator := ",", Parts*) {
        res := ""
        for i, val in Parts {
            res .= (i = 1 ? "" : Separator) . val
        }
        return res
    }

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

    static SubStr(str, pos, len?) {
        if IsSet(len)
            return SubStr(str, pos, len)
        return SubStr(str, pos)
    }

    static Title(str) {
        return StrTitle(str)
    }

    static Trim(str, chars := " `t") {
        return Trim(str, chars)
    }

    static Truncate(str, length := 30, suffix := "...") {
        if (StrLen(str) <= length)
            return str
        return SubStr(str, 1, length) . suffix
    }

    static WordCount(str) {
        if (this.IsBlank(str))
            return 0
        RegExReplace(Trim(str), "s)\s+", , &count)
        return count + 1
    }

    static Wrap(str, limit := 80, delim := "`n") {
        return RegExReplace(str, "s).{1," . limit . "}(?:\s+|$)","$0" . delim)
    }
}
3. Unit Test Script (StringLib_Test.ahk)
AutoHotkey
/**
 * StringLib Unit Tester v1.0.0.37
 */
#Include StringLib.ahk

RunTests()

RunTests() {
    Passed := 0, Failed := 0, Results := ""
    Assert(Name, Actual, Expected) {
        if (Actual = Expected) {
            Passed++
            return "PASS: " . Name . "`n"
        } else {
            Failed++
            return "FAIL: " . Name . " (Expected: " . Expected . " | Got: " . Actual . ")`n"
        }
    }

    ; Tests
    Results .= Assert("CamelCase", Str.Camel("hello world"), "helloWorld")
    Results .= Assert("KebabCase", Str.Kebab("Hello World"), "hello-world")
    Results .= Assert("SnakeCase", Str.Snake("Hello World"), "hello_world")
    Results .= Assert("Slug", Str.Slug("Hello World!!!"), "hello-world")
    Results .= Assert("IsAlpha-True", Str.IsAlpha("ABC"), 1)
    Results .= Assert("IsType-Array", Str.IsType([], "Array"), 1)
    Results .= Assert("Between", Str.Between("[X]Y[/X]", "[X]", "[/X]"), "Y")
    Results .= Assert("FormatBytes-Exact", Str.FormatBytes(1048576), "1 MB")
    Results .= Assert("FormatBytes-Decimal", Str.FormatBytes(1572864), "1.5 MB")
    Results .= Assert("WordCount", Str.WordCount("One two three"), 3)

    MsgBox("--- Summary ---`nPassed: " . Passed . "`nFailed: " . Failed . "`n`n" . Results)
}