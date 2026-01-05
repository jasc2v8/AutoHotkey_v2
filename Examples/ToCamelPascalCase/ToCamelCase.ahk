; ABOUT: ToCamelCase

/*
    camelCase   : Go, JavaScript, Java and C# for variable and function names.
    PascalCase  : Go, C#, Java and TypeScript for class and type names.
    snake_case  : Python, Ruby and JavaScript  for variable and function names.
    kebab-case  : HTML and CSS for class names, file names and URLs.

*/

CamelCase(inputString) {
    ; Convert the entire string to lowercase first for consistency
    local result := StrLower(inputString)

    ; Replace non-alphanumeric characters with spaces to prepare for word splitting
    ; This handles cases like "hello-world" or "hello_world"
    result := RegExReplace(result, "[^a-zA-Z0-9]+", " ")

    ; Split the string into words
    local words := StrSplit(result, " ")

    ; Process each word
    local camelCaseString := ""
    Loop words.Length {
        local word := words[A_Index]
        if (word != "") { ; Skip empty words that might result from multiple spaces
            if (A_Index = 1) {
                ; The first word remains lowercase
                camelCaseString .= word
            } else {
                ; Capitalize the first letter of subsequent words
                camelCaseString .= StrUpper(SubStr(word, 1, 1)) . SubStr(word, 2)
            }
        }
    }
    return camelCaseString
}

; Example Usage:
myString := "New file name"
camelCaseResult := CamelCase(myString)
MsgBox "Original: " . myString . "`n`nCamelCase: " . camelCaseResult

myString := "this is a test string-for_camelCase"
camelCaseResult := CamelCase(myString)
MsgBox "Original: " . myString . "`n`nCamelCase: " . camelCaseResult

myString2 := "another example with different separators"
camelCaseResult2 := CamelCase(myString2)
MsgBox "Original: " . myString2 . "`n`nCamelCase: " . camelCaseResult2