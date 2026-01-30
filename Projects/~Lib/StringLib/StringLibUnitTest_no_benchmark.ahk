/**
 * StringLib Unit Tester v1.0.0.37
 * Comprehensive suite to validate all Str class methods.
 */

#Include StringLib.ahk

RunTests()

RunTests() {
    Passed := 0
    Failed := 0
    Results := ""

    ; Helper to log results
    Assert(Name, Actual, Expected) {
        if (Actual = Expected) {
            Passed++
            return "PASS: " . Name . "`n"
        } else {
            Failed++
            return "FAIL: " . Name . " (Expected: " . Expected . " | Got: " . Actual . ")`n"
        }
    }

    ; --- Begin Testing ---
    
    ; Case Conversions
    Results .= Assert("CamelCase", Str.Camel("hello world"), "helloWorld")
    Results .= Assert("KebabCase", Str.Kebab("Hello World"), "hello-world")
    Results .= Assert("SnakeCase", Str.Snake("Hello World"), "hello_world")
    Results .= Assert("TitleCase", Str.Title("hello world"), "Hello World")
    Results .= Assert("Slug", Str.Slug("Hello World!!!"), "hello-world")

    ; Validation
    Results .= Assert("IsAlpha-True", Str.IsAlpha("ABC"), 1)
    Results .= Assert("IsAlpha-False", Str.IsAlpha("A1"), 0)
    Results .= Assert("IsDigit-True", Str.IsDigit("123"), 1)
    Results .= Assert("IsLower-True", Str.IsLower("abc"), 1)
    Results .= Assert("IsUpper-True", Str.IsUpper("ABC"), 1)
    Results .= Assert("IsBlank-True", Str.IsBlank("   `t"), 1)
    Results .= Assert("IsEmpty-True", Str.IsEmpty(""), 1)
    Results .= Assert("IsType-Array", Str.IsType([], "Array"), 1)

    ; Manipulation
    Results .= Assert("Between", Str.Between("[Tag]Content[/Tag]", "[Tag]", "[/Tag]"), "Content")
    Results .= Assert("Enclose", Str.Enclose("Code", "'"), "'Code'")
    Results .= Assert("Left", Str.Left("AutoHotkey", 4), "Auto")
    Results .= Assert("Right", Str.Right("AutoHotkey", 3), "key")
    Results .= Assert("Reverse", Str.Reverse("ABC"), "CBA")
    Results .= Assert("Repeat", Str.Repeat("A", 3), "AAA")
    Results .= Assert("Replace", Str.Replace("A B A", "A", "C"), "C B C")
    Results .= Assert("Truncate", Str.Truncate("Long String", 4, "..."), "Long...")

    ; Trimming
    Results .= Assert("Trim", Str.Trim("  X  "), "X")
    Results .= Assert("LTrim", Str.LTrim("  X  "), "X  ")
    Results .= Assert("RTrim", Str.RTrim("  X  "), "  X")

    ; Search & Logic
    Results .= Assert("Contains-True", Str.Contains("ABC", "B"), 1)
    Results .= Assert("StartsWith-True", Str.StartsWith("Apple", "Ap"), 1)
    Results .= Assert("EndsWith-True", Str.EndsWith("Apple", "le"), 1)
    Results .= Assert("CountOccurrences", Str.CountOccurrences("banana", "a"), 3)

    ; Formatting (Corrected for v1.0.0.37 trailing zero logic)
    Results .= Assert("FormatBytes-Exact", Str.FormatBytes(1048576), "1 MB")
    Results .= Assert("FormatBytes-Decimal", Str.FormatBytes(1572864), "1.5 MB")
    
    ; Arrays & Paths
    Results .= Assert("JoinArray", Str.JoinArray(["A", "B"], "|"), "A|B")
    Results .= Assert("StrJoinPath", Str.StrJoinPath("C:", "Windows", "System32"), "C:\Windows\System32")
    
    ; Stats
    Results .= Assert("WordCount", Str.WordCount("One two three"), 3)
    Results .= Assert("SentenceCount", Str.SentenceCount("Hi. Bye! Ok?"), 3)
    Results .= Assert("LinesCount", Str.Lines("Line1`nLine2").Length, 2)

    ; --- Summary Display ---
    Summary := "--- StringLib Test Summary v1.0.0.37 ---`n"
    Summary .= "Passed: " . Passed . "`n"
    Summary .= "Failed: " . Failed . "`n"
    Summary .= "Total: " . (Passed + Failed) . "`n`n"
    
    if (Failed > 0) {
        MsgBox(Summary . "Details:`n" . Results, "Test Results", 48)
    } else {
        MsgBox(Summary . "All tests passed successfully!", "Test Results", 64)
    }
}