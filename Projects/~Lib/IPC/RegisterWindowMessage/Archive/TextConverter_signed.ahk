; Version: 1.1.2
; A class library to convert text to large integers and back.
; Features: Whitespace trimming and a Swap button to prevent manual copy errors.

class TextConverter {
    /**
     * Converts a string (like "Hello") into a large integer.
     */
    static TextToInteger(TextString) {
        if (TextString = "")
            return
        
        Result := 0
        
        Loop Parse, TextString {
            try {
                ; Shift 8 bits and add the character's code
                Result := (Integer(Result) * 256) + Ord(A_LoopField)
            } catch {
                return "Error: String too long (64-bit Overflow)"
            }
        }
        
        return Result
    }

    /**
     * Converts a large integer back into its original text string.
     */
    static IntegerToText(NumberVal) {
        ; Trim accidental whitespace from input
        NumberVal := Trim(NumberVal)

        if (NumberVal = "" || NumberVal = "0")
            return ""

        if !IsInteger(NumberVal)
            return "Error: Input contains non-numeric characters."

        try {
            Num := Integer(NumberVal)
        } catch {
            return "Error: Number exceeds 64-bit limit."
        }

        OutputText := ""
        while (Num > 0) {
            CharVal := Mod(Num, 256)
            OutputText := Chr(CharVal) . OutputText
            Num := Num // 256
        }
        
        return OutputText
    }
}

; --- GUI Implementation ---

;TextConverter_Example()

TextConverter_Example() {

    MyGui := Gui("+AlwaysOnTop", "Text <-> Integer Converter")
    MyGui.SetFont("s10", "Segoe UI")

    MyGui.Add("Text",, "Input (Text or Number):")
    EditInput := MyGui.Add("Edit", "w300 vInput", "Hello")

    BtnT2I := MyGui.Add("Button", "w300", "Convert Text to Number")
    BtnI2T := MyGui.Add("Button", "w300", "Convert Number to Text")

    ; Control buttons for easier testing
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
        
        if (InputVal = "") {
            MyGui["Result"].Value := "Error: Input is empty."
            return
        }

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
        ; Don't swap if the result is an error message
        if (SubStr(ResultVal, 1, 5) = "Error") {
            MsgBox("Cannot swap an error message.", "Error", "Icon!")
            return
        }
        
        MyGui["Input"].Value := ResultVal
        MyGui["Result"].Value := ""
    }

    MyGui.Show()

}