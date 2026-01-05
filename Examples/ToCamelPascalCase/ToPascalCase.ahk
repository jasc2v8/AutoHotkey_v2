; ABOUT: ToPascalCase

/*
    camelCase   : Go, JavaScript, Java and C# for variable and function names.
    PascalCase  : Go, C#, Java and TypeScript for class and type names.
    snake_case  : Python, Ruby and JavaScript  for variable and function names.
    kebab-case  : HTML and CSS for class names, file names and URLs.

*/


PascalCase(inputString) {
    ; Convert to lowercase and replace non-alphanumeric characters with spaces
    local processedString := RegExReplace(StrLower(inputString), "[^a-z0-9]+", " ")
    
    MsgBox processedString,"Processed String"

    ; Capitalize the first letter of each word and remove spaces
    local pascalString := ""
    for each, word in StrSplit(processedString, " ", true) { ; true to omit empty items
        if (word != "") {
            pascalString .= StrUpper(SubStr(word, 1, 1)) . SubStr(word, 2)
        }
    }
    return pascalString
}

; Example usage:
myString := "this is a test_string-with-hyphens"
pascalCasedString := PascalCase(myString)
MsgBox myString . " -> " . pascalCasedString ; Output: ThisIsATestStringWithHyphens

myString := "newFileName"
pascalCasedString := PascalCase(myString)
MsgBox myString . " -> " . pascalCasedString ; Output: ThisIsATestStringWithHyphens

anotherString := "another_example_string"
pascalCasedString2 := PascalCase(anotherString)
MsgBox anotherString . " -> " . pascalCasedString2 ; Output: AnotherExampleString