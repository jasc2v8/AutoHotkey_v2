;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2+

; Version: 1.0.3
; A class library for manual digit/string conversion with a testing interface.

class NumberConverter {
    /**
     * Converts a string of digits into an integer using ASCII offsets.
     */
    static StringToInteger(DigitString) {
        if (DigitString = "")
            return
        
        Result := 0
        ; Handle negative sign
        IsNegative := (SubStr(DigitString, 1, 1) = "-")
        if (IsNegative)
            DigitString := SubStr(DigitString, 2)

        Loop Parse, DigitString {
            DigitValue := Ord(A_LoopField) - 48
            Result := (Result * 10) + DigitValue
        }
        
        if (IsNegative)
            return Result * -1
            
        return Result
    }

    /**
     * Converts an integer into a string using modulo and ASCII offsets.
     */
    static IntegerToString(Number) {
        if (Number = 0)
            return "0"
        
        IsNegative := false
        if (Number < 0) {
            IsNegative := true
            Number := Abs(Number)
        }

        DigitString := ""
        while (Number > 0) {
            Digit := Mod(Number, 10)
            DigitString := Chr(Digit + 48) . DigitString
            Number := Number // 10
        }
        
        if (IsNegative)
            DigitString := "-" . DigitString
            
        return DigitString
    }
}

; --- GUI Implementation ---

MyGui := Gui("+AlwaysOnTop", "Number Converter Test")
MyGui.SetFont("s10", "Segoe UI")

MyGui.Add("Text",, "Input Value:")
EditInput := MyGui.Add("Edit", "w200", "1234")

BtnS2I := MyGui.Add("Button", "w200", "String To Integer")
BtnI2S := MyGui.Add("Button", "w200", "Integer To String")

MyGui.Add("Text",, "Result:")
TextResult := MyGui.Add("Text", "w200 r1 +Border", "")

; Event Handlers
BtnS2I.OnEvent("Click", (*) => Convert("S2I"))
BtnI2S.OnEvent("Click", (*) => Convert("I2S"))

Convert(Mode) {
    InputVal := EditInput.Value
    
    if (Mode = "S2I") {
        Converted := NumberConverter.StringToInteger(InputVal)
        TextResult.Value := Converted " (Type: " Type(Converted) ")"
    } else {
        ; Use Number() to ensure the input is treated as a numeric type for the demonstration
        ;Converted := NumberConverter.IntegerToString(Number(InputVal))
        Converted := NumberConverter.IntegerToString(74038)
        TextResult.Value := '"' . Converted . '" (Type: ' Type(Converted) ")"
    }
}

MyGui.Show()
