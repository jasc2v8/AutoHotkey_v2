
;#Requires AutoHotkey v2.0

IsBinaryFile(filePath, tolerance := 5) {
    if !FileExist(filePath)
        return false
   
    file := FileOpen(filePath, "r")

    if !file
        return false

    buff := Buffer(1)

    loop tolerance {

        BytesRead := file.RawRead(buff, 1)

        if (BytesRead = 0)
            break

        byte := NumGet(buff, 0, "UChar")

        ; byte < 9: Catches control characters except TAB (ASCII 9).
        ; byte > 126: Catches non-printable characters above standard ASCII.
        ; (byte < 32) and (byte > 13): Catches control characters between carriage return (13) and space (32), excluding TAB, LF, and CR.
        ; This logic is correct for most ASCII/UTF-8 text files. If any byte in the sample matches these conditions, the file is likely binary.

        if (byte < 9) or (byte > 126) or ((byte < 32) and (byte > 13)) {
            file.Close()
            return true
        }
    }

    file.Close()
    return false
}
