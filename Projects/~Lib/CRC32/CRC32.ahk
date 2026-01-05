#Requires AutoHotkey 2.0+

/**
 * Calculates the CRC32 hash of a string.
 * @param str The string to hash
 * @returns {String} The hex representation of the CRC32
 */
CRC32(str) {
    ; Convert string to UTF-8 buffer to ensure consistency
    buf := Buffer(StrPut(str, "UTF-8"))
    StrPut(str, buf, "UTF-8")
    
    ; Initial seed is 0
    crc := DllCall("ntdll\RtlComputeCrc32", "UInt", 0, "Ptr", buf, "UInt", buf.Size - 1, "UInt")
    
    MsgBox crc
    
    ; Return as a formatted Hex string (e.g., 0x1234ABCD)
    return Format("0x{:08X}", crc)
}

; --- Examples ---
MsgBox CRC32("AHK_RunSkipUAC") ; Returns 0xB8B79B59