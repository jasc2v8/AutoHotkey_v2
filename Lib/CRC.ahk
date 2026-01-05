; TITLE:    CRC.ahk v1.0
; SOURCE:   Gemini and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  CRC32 and CRC64
; USEAGE:   hexCRC32 := CRC.Get32("AHK_RunSkipUAC")         ; default = hex
;           decCRC64 := CRC.Get64("AHK_RunSkipUAC", "Dec")  ; "Dec" or "Decimal"

/*
    TODO:
*/

#Requires AutoHotkey 2.0+

class CRC {

    /**
     * Calculates CRC32 using UTF-16 encoding (AHK Native)
     * @param str The string to hash
     * @param fmt "Hex" (default) or "Dec"
     */
    static Get32(str, fmt := "Hex") {
        ; Calculate required buffer size for UTF-16 (2 bytes per character)
        ; We do not include the null terminator in the hash
        byteCount := StrLen(str) * 2
        
        buf := Buffer(byteCount)
        StrPut(str, buf, "UTF-16")
        
        ; Calculate CRC32 using Windows native API
        crc := DllCall("ntdll\RtlComputeCrc32", "UInt", 0, "Ptr", buf, "UInt", byteCount, "UInt")
        
        ; Clean return logic
        if (StrLower(fmt) = "hex") {
           return Format("0x{:08X}", crc)
        } else {
            return crc
        }
    }

    /**
     * Calculates CRC64 (ECMA) using UTF-16 encoding.
     * @param str The string to hash
     * @param fmt "Hex" (default) or "Dec"
     */
    static Get64(str, fmt := "Hex") {
        static table := []
        poly := 0xC96C5795D7870F42 ; ECMA-182 polynomial
        
        ; Precompute lookup table once
        if (table.Length = 0) {
            Loop 256 {
                crc := A_Index - 1
                Loop 8 {
                    if (crc & 1)
                        crc := (crc >> 1) ^ poly
                    else
                        crc >>= 1
                }
                table.Push(crc)
            }
        }

        ; UTF-16 uses 2 bytes per character
        byteCount := StrLen(str) * 2
        crc := 0xFFFFFFFFFFFFFFFF
        
        ; Access the raw memory of the string directly (UTF-16)
        ptr := StrPtr(str)
        
        Loop byteCount {
            byte := NumGet(ptr, A_Index - 1, "UChar")
            index := (crc ^ byte) & 0xFF
            crc := (crc >> 8) ^ table[index + 1]
        }

        finalCrc := crc ^ 0xFFFFFFFFFFFFFFFF
        
        return (StrLower(fmt) = "hex") ? Format("0x{:016X}", finalCrc) : finalCrc
    }
}

; EXAMPLES

;CRC_EXAMPLES()

CRC_EXAMPLES() {

    val := "AHK_RunSkipUAC"

    MsgBox "String: " val "`n`n" 
        . "Hex: " CRC.Get32(val) "`n`n" 
        . "Dec: " CRC.Get32(val, "Dec"), "CRC-32"


    MsgBox "String: " val "`n`n" 
        . "Hex: " CRC.Get64(val) "`n`n" 
        . "Dec: " CRC.Get64(val, "Decimal"), "CRC-64"

}
