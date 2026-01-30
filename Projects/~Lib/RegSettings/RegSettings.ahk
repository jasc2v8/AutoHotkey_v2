#Requires AutoHotkey v2.0+

; RegistrySettings Class v1.0.0.3

class RegSettings extends RegistrySettings {
    
}

class RegistrySettings {

    __New(SubKey := StrReplace(A_ScriptName, ".ahk")) {
        this.RootKey := "HKEY_CURRENT_USER\Software\AHK_Scripts"
        this.SubKey := SubKey
    }

    Read(ValueName, Default := "") {
        try {
            return RegRead(this.RootKey "\" this.SubKey, ValueName)
        }
        catch {
            return Default
        }
    }

    Write(ValueName, Value) {

        ; Automatic Type Detection

        if (Type(Value) = "String" and SubStr(Value, 1,2) = "0x")
            RegType := "REG_BINARY"
        else if (Type(Value) = "String" and InStr(Value, ",")>0)
            RegType := "REG_MULTI_SZ"
        else if (Type(Value) = "String")
            RegType := "REG_SZ"
        else if Type(Value) = "Integer"
            RegType := "REG_DWORD"
        else if Type(Value) = "Float"
            RegType := "REG_SZ"
        else
            RegType := "REG_SZ"

        if (RegType = "REG_BINARY")
            Value := StrReplace(Value, "0x")

        ;MsgBox Value ": " Type(Value), RegType
        
        try {
            RegWrite(Value, RegType, this.RootKey "\" this.SubKey, ValueName)
            return true
        }
        catch {
            return false
        }
    }

    Delete(ValueName) {
        try {
            RegDelete(this.RootKey "\" this.SubKey, ValueName)
            return true
        }
        catch {
            return false
        }
    }

    DeleteKey() {
        try {
            RegDeleteKey(this.RootKey "\" this.SubKey)
            return true
        }
        catch {
            return false
        }
    }
}