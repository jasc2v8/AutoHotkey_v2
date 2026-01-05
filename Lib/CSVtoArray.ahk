
#Requires AutoHotkey 2.0+

CsvToArray(csv, delim := ",") {
    result := []
    for line in StrSplit(csv, "`n", "`r") {
        if line = ""
            continue
        result.Push(StrSplit(line, delim))
    }
    return result
}

; Demo
csv := "id,name,score`n1,Alice,95`n2,Bob,88"
arr := CsvToArray(csv)

MsgBox arr[2][2]  ; → Alice
MsgBox arr[3][3]  ; → 88