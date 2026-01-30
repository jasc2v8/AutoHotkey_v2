; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

/*
    TODO:
*/

; TOML Parser and Generator for AHK v2
; Version: 1.1.0

class TOML {
    /**
     * Parse a TOML string into an AHK Map
     * @param {String} content 
     * @returns {Map}
     */
    static Parse(content) {
        if (content = "")
            return Map()

        data := Map()
        currentTable := data
        
        Loop Parse, content, "`n", "`r" {
            line := Trim(RegExReplace(A_LoopField, "\s*#.*$")) ; Remove comments
            
            if (line = "")
                continue
                
            ; Handle Tables [section.sub]
            if (RegExMatch(line, "^\[(.+)\]$", &match)) {
                sectionPath := StrSplit(match[1], ".")
                currentTable := data
                
                for part in sectionPath {
                    part := Trim(part)
                    if (!currentTable.Has(part))
                        currentTable[part] := Map()
                    currentTable := currentTable[part]
                }
                continue
            }
            
            ; Handle Key-Value Pairs
            if (InStr(line, "=")) {
                parts := StrSplit(line, "=", , 2)
                key := Trim(parts[1])
                value := Trim(parts[2])
                currentTable[key] := this._ParseValue(value)
            }
        }
        
        return data
    }

    /**
     * Convert an AHK Map/Object to a TOML string
     * @param {Map|Object} obj 
     * @param {String} section 
     * @returns {String}
     */
    static Stringify(obj, section := "") {
        output := ""
        tables := ""
        
        if (section != "")
            output .= "[" . section . "]`n"
            
        for key, val in obj {
            if (val is Map) {
                newSection := (section = "") ? key : section . "." . key
                tables .= "`n" . this.Stringify(val, newSection)
            } else {
                output .= key . " = " . this._FormatValue(val) . "`n"
            }
        }
        
        return output . tables
    }

    static _ParseValue(val) {
        if (val = "true")
            return true
        if (val = "false")
            return false
        if (IsNumber(val))
            return Number(val)
            
        ; Strings
        if (RegExMatch(val, '^"(.*)"$', &match))
            return match[1]
            
        ; Simple Arrays
        if (RegExMatch(val, "^\[(.*)\]$", &match)) {
            arr := []
            for item in StrSplit(match[1], ",") {
                arr.Push(this._ParseValue(Trim(item)))
            }
            return arr
        }
        return val
    }

    static _FormatValue(val) {
        if (IsInteger(val) || IsFloat(val))
            return val
        if (val = true)
            return "true"
        if (val = false)
            return "false"
        if (val is Array) {
            str := "["
            for i, v in val
                str .= (i=1 ? "" : ", ") . this._FormatValue(v)
            return str . "]"
        }
        return '"' . val . '"'
    }
}