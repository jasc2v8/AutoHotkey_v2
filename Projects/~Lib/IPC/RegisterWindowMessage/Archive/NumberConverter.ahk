; Version: 1.0.7
; A class library for manual digit/string conversion using ASCII offsets.

class NumberConverter {
    /**
     * Converts a string of digits into an integer using ASCII offsets.
     * Logic: (Result * 10) + NewDigit
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
            ; Convert character to numeric value (ASCII '0' is 48)
            DigitValue := Ord(A_LoopField) - 48
            Result := (Result * 10) + DigitValue
        }
        
        if (IsNegative)
            return Result * -1
            
        return Result
    }

    /**
     * Converts an integer into a string using modulo and ASCII offsets.
     * Logic: Mod(Number, 10) and Number // 10
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
            ; Isolate last digit and convert to character
            Digit := Mod(Number, 10)
            DigitString := Chr(Digit + 48) . DigitString
            ; Remove last digit
            Number := Number // 10
        }
        
        if (IsNegative)
            return "-" . DigitString
            
        return DigitString
    }
}

; --- GUI Implementation ---

MyGui := Gui("+AlwaysOnTop", "Number Converter Test")
MyGui.SetFont("s10", "Segoe UI")

MyGui.Add("Text",, "Input Value:")
EditInput := MyGui.Add("Edit", "w250", "1234")

BtnS2I := MyGui.Add("Button", "w250", "String To Integer (Manual)")
BtnI2S := MyGui.Add("Button", "w250", "Integer To String (Manual)")

MyGui.Add("Text",, "Result:")
TextResult := MyGui.Add("Text", "w250 r2 +Border", "")

; Event Handlers
BtnS2I.OnEvent("Click", (*) => ProcessConversion("S2I"))
BtnI2S.OnEvent("Click", (*) => ProcessConversion("I2S"))

ProcessConversion(Mode) {
    InputVal := EditInput.Value
    
    if (InputVal = "") {
        TextResult.Value := "Error: Input is empty."
        return
    }

    if (Mode = "S2I") {
        ; Use the manual algorithm
        Converted := NumberConverter.StringToInteger(InputVal)
        TextResult.Value := Converted " (Type: " Type(Converted) ")"
    } else {
        ; Verify the input is a valid number before attempting conversion
        ;if IsNumber(InputVal) {
            NumValue := Number(InputVal)
            Converted := NumberConverter.IntegerToString(NumValue)
            TextResult.Value := '"' . Converted . '" (Type: ' Type(Converted) ")"
        ;} else {
        ;    TextResult.Value := "Error: '" InputVal "' is not a valid number."
        ;}
    }
}

MyGui.Show()