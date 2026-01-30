;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2+

; Version: 1.0.1
; Converts a string of digits into a numeric integer using ASCII offset math.

StringToInteger(DigitString) {
    if (DigitString = "")
        return
    
    Result := 0
    
    ; Loop through each character in the string
    Loop Parse, DigitString {
        ; 1. Convert character to numeric value via ASCII offset ('0' is 48)
        DigitValue := Ord(A_LoopField) - 48
        
        ; 2. Multiply current result by 10 to shift digits left
        ; 3. Add the new digit value
        Result := (Result * 10) + DigitValue
    }
    
    return Result
}

; Example usage:
;MsgBox StringToInteger("the quick brown fox") ; Displays the number 4321