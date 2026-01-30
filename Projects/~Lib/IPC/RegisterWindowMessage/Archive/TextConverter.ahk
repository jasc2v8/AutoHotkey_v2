; Version: 1.1.5
; A class library to convert text to 64-bit UNSIGNED integers and back.
; Features: Swap functionality and unsigned range support up to 18.4 Quintillion.

class TextConverter {
    /**
     * Converts a string into an unsigned 64-bit integer string.
     */
    static TextToInteger(TextString) {
        if (TextString = "")
            return
        
        Result := 0
        Loop Parse, TextString {
            ; Shift 8 bits and add character code
            Result := (Result * 256) + Ord(A_LoopField)
        }
        
        ; Format as unsigned decimal string to handle the 2^63 to 2^64 range
        return Format("{:u}", Result)
    }

    /**
     * Converts an unsigned 64-bit integer string back into text.
     */
    static IntegerToText(NumberVal) {
        NumberVal := Trim(NumberVal)

        if (NumberVal = "" || NumberVal = "0")
            return ""

        if !IsNumber(NumberVal)
            return "Error: Input contains non-numeric characters."

        ; Use Float to avoid signed integer wrap-around during math
        Num := Float(NumberVal)
        OutputText := ""
        
        while (Num >= 1) {
            CharVal := Integer(Mod(Num, 256))
            OutputText := Chr(CharVal) . OutputText
            Num := Floor(Num / 256)
        }
        
        return OutputText
    }
}

; --- GUI Implementation ---

MyGui := Gui("+AlwaysOnTop", "Unsigned 64-bit Converter")
MyGui.SetFont("s10", "Segoe UI")

MyGui.Add("Text",, "Input (Text or Number):")
EditInput := MyGui.Add("Edit", "w300 vInput", "Hello!!")

BtnT2I := MyGui.Add("Button", "w300", "Convert Text to Unsigned Int")
BtnI2T := MyGui.Add("Button", "w300", "Convert Unsigned Int to Text")

; Control buttons
BtnSwap := MyGui.Add("Button", "w145 x10", "↑ Swap ↓")
BtnClear := MyGui.Add("Button", "w145 x+10", "Clear")

MyGui.Add("Text", "x10", "Result:")
EditResult := MyGui.Add("Edit", "w300 r3 +Border vResult", "")

; Event Handlers
BtnT2I.OnEvent("Click", (*) => Process("T2I"))
BtnI2T.OnEvent("Click", (*) => Process("I2T"))
BtnSwap.OnEvent("Click", (*) => SwapValues())
BtnClear.OnEvent("Click", (*) => (MyGui["Input"].Value := "", MyGui["Result"].Value := ""))

Process(Mode) {
    InputVal := MyGui["Input"].Value
    
    if (InputVal = "")
        return

    if (Mode = "T2I") {
        Result := TextConverter.TextToInteger(InputVal)
        MyGui["Result"].Value := Result
    } else {
        Result := TextConverter.IntegerToText(InputVal)
        MyGui["Result"].Value := Result
    }
}

SwapValues() {
    ResultVal := MyGui["Result"].Value
    
    if (SubStr(ResultVal, 1, 5) = "Error")
        return
    
    MyGui["Input"].Value := ResultVal
    MyGui["Result"].Value := ""
}

MyGui.Show()