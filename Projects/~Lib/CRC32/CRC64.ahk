#Requires AutoHotkey 2.0+

#Requires AutoHotkey v2.0

/**
 * Calculates the CRC64-ECMA hash of a string.
 * @param str The string to hash
 * @returns {String} Hexadecimal representation
 */
CRC64(str) {
    static table := []
    poly := 0xC96C5795D7870F42 ; ECMA-182 polynomial
    
    ; Precompute lookup table (only happens once)
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

    ; Convert input string to UTF-8 buffer
    buf := Buffer(StrPut(str, "UTF-8"))
    StrPut(str, buf, "UTF-8")
    
    crc := 0xFFFFFFFFFFFFFFFF
    
    ; Process bytes
    Loop buf.Size - 1 {
        byte := NumGet(buf, A_Index - 1, "UChar")
        index := (crc ^ byte) & 0xFF
        crc := (crc >> 8) ^ table[index + 1]
    }

    MsgBox Abs(crc)

    return Format("0x{:016X}", crc ^ 0xFFFFFFFFFFFFFFFF)
}

; --- Example ---
MsgBox("String: AHK_RunSkipUAC`n`nCRC64: " . CRC64("AHK_RunSkipUAC"))