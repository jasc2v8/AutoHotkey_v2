; TITLE  :  CSV v1.0.3
; SOURCE :  Gemini and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Class for converting between Strings and CSV Arrays
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2+

class CSV {
    /**
     * Converts a CSV formatted string into a 2D Array [Row][Column]
     * @param {String} StringContent - The raw CSV text
     * @param {String} Delimiter - The separator (default is comma)
     */
    static StringToCSV(StringContent, Delimiter := ",") {
        if (StringContent = "")
            return []

        Data := []
        Loop Parse, StringContent, "`n", "`r" {
            if (A_LoopField = "")
                continue
            
            Row := []
            ; Regular expression to handle quoted values and escaped quotes
            ; Matches: "Value", UnquotedValue, or Empty
            Pattern := "S)(?<=^|" Delimiter ")(?:`"([^`"]*(?:`"`"[^`"]*)*)`"|([^" Delimiter "]*))(?=" Delimiter "|$)"
            
            Pos := 1
            while RegExMatch(A_LoopField, Pattern, &Match, Pos) {
                Value := Match.Count = 1 ? Match[1] : (Match[2] != "" ? Match[2] : Match[1])
                ; Handle escaped double quotes
                Value := StrReplace(Value, '""', '"')
                Row.Push(Value)
                Pos := Match.Pos + Match.Len
            }
            Data.Push(Row)
        }
        return Data
    }

    /**
     * Converts a 2D Array into a CSV formatted string
     * @param {Array} ArrayData - The 2D Array to convert
     * @param {String} Delimiter - The separator (default is comma)
     */
    static CSVToString(ArrayData, Delimiter := ",") {
        if (!IsObject(ArrayData))
            return ""
            
        Output := ""
        for RowIndex, RowArray in ArrayData {
            Line := ""
            for ColIndex, Value in RowArray {
                ; Wrap in quotes if value contains delimiter, newline, or quotes
                NeedsQuotes := false
                if (InStr(Value, Delimiter) || InStr(Value, "`n") || InStr(Value, "`r") || InStr(Value, '"')) {
                    NeedsQuotes := true
                    Value := StrReplace(Value, '"', '""') ; Escape existing quotes
                }
                
                Line .= (NeedsQuotes ? '"' Value '"' : Value) . Delimiter
            }
            Output .= SubStr(Line, 1, -1) . "`r`n"
        }
        return RTrim(Output, "`r`n")
    }
}