; Version: 1.1.3
; A class library to convert ANY length text to a series of integers.
; Handles the 64-bit limit by chunking text into 7-character segments.

class TextConverter {
    /**
     * Converts a long string into an array of integers.
     */
    static TextToIntegerArray(TextString) {
        if (TextString = "")
            return
        
        IntArray := []
        
        ; Process in chunks of 7 characters (safe for 64-bit)
        Loop Ceil(StrLen(TextString) / 7) {
            Chunk := SubStr(TextString, ((A_Index - 1) * 7) + 1, 7)
            Result := 0
            
            Loop Parse, Chunk {
                Result := (Result * 256) + Ord(A_LoopField)
            }
            IntArray.Push(Result)
        }
        
        return IntArray
    }

    /**
     * Converts an array of integers back into a single string.
     */
    static IntegerArrayToText(IntArray) {
        if !IsObject(IntArray)
            return ""

        FullText := ""
        for index, Num in IntArray {
            ChunkText := ""
            TempNum := Num
            
            while (TempNum > 0) {
                CharVal := Mod(TempNum, 256)
                ChunkText := Chr(CharVal) . ChunkText
                TempNum := TempNum // 256
            }
            FullText .= ChunkText
        }
        
        return FullText
    }
}

; --- GUI Implementation ---

MyGui := Gui("+AlwaysOnTop", "Unlimited Text <-> Integer Converter")
MyGui.SetFont("s10", "Segoe UI")

MyGui.Add("Text",, "Input Text (No Length Limit):")
EditInput := MyGui.Add("Edit", "w400 r3 vInput", "Programming is fun!")

BtnT2I := MyGui.Add("Button", "w400", "Convert Text to Number Array")
BtnI2T := MyGui.Add("Button", "w400", "Convert Number Array to Text")

BtnSwap := MyGui.Add("Button", "w195 x10", "↑ Swap ↓")
BtnClear := MyGui.Add("Button", "w195 x+10", "Clear")

MyGui.Add("Text", "x10", "Result (Numbers separated by commas):")
EditResult := MyGui.Add("Edit", "w400 r5 +Border vResult", "")

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
        Arr := TextConverter.TextToIntegerArray(InputVal)
        Output := ""
        for i, val in Arr
            Output .= val . (i = Arr.Length ? "" : ", ")
        MyGui["Result"].Value := Output
    } else {
        ; Split the comma-separated string back into an array
        NumStrings := StrSplit(InputVal, ",", " ")
        IntArray := []
        for val in NumStrings {
            if IsInteger(val)
                IntArray.Push(Integer(val))
        }
        MyGui["Result"].Value := TextConverter.IntegerArrayToText(IntArray)
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