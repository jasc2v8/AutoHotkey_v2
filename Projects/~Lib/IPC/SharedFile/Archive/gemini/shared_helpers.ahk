; TITLE  :  Sharedfile with Enmpty/Full Sync
; SOURCE :  jasc2v8 12/15/2025
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    SharedFile.txt Attributes
    -------------------------
     A = Full
    -A = Empty

*/

#Requires AutoHotkey v2.0+

SharedFile := A_Temp "\ahk_shared_sync.ini"

AtomicWrite(file, text) {
    tmp := file ".tmp"
    if FileExist(tmp)
        FileDelete(tmp)
    FileAppend(text, tmp, "UTF-8")
    FileMove(tmp, file, 1)
}

ReadIni(file) {
    if !FileExist(file)
        return Map()

    data := Map()
    for line in StrSplit(FileRead(file, "UTF-8"), "`n", "`r") {
        if RegExMatch(line, "^\s*([^=]+)=(.*)$", &m)
            data[Trim(m[1])] := m[2]
    }
    return data
}

WriteIni(file, map) {
    buf := "[sync]`n"
    for k, v in map
        buf .= k "=" v "`n"
    AtomicWrite(file, buf)
}
