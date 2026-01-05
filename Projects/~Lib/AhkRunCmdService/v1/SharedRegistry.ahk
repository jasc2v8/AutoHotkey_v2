; TITLE  : Registry.ahk v1.0
; SOURCE : 
; LICENSE: The Unlicense, see https://unlicense.org
;

class SharedRegistry {

    KeyName   := ""
    ValueName := ""

    __New(KeyName:="SharedRegistry", ValueName:="MyValueName") {

        this.KeyName   := "HKEY_CURRENT_USER\SOFTWARE\" KeyName
        this.ValueName := ValueName

        ; if KeyName exist, verify access is OK else create it
        RegCreateKey(this.KeyName)

        ; clear the Value
        ;this.Clear()
    }

    ; if empty then return true, else return false
    IsEmpty() {
        return StrLen(this.Read()) == 0
    }

    ; Clear the contents of the shared registry
    Clear() {
        this.Write()
    }

    ; Convert string and number variables into a CSV string
    ConvertToCSV(Params*) {
        myString:= ""
        for item in Params {
            if IsSet(item)
                myString .= item ","
        }
        return RTrim(myString, ",")
    }

    ; Create and open a named event for synchronization
    ; Returns hEvent or "" if fail
    CreateEvent(EventName, ManualReset:=true, InitialState:=false) {
        return DllCall("CreateEvent", "ptr", 0, "int", ManualReset, "int", InitialState, "str", EventName, "ptr")
    }

    ; Open a named event for synchronization
    ; Returns hEvent or "" if fail
    OpenEvent(EventName, InheritHandle:= false) {
        return DllCall("OpenEvent", "uint", 0x1F0003, "int", InheritHandle, "str", EventName, "ptr")
    }

    ; Signal the event so server knows data is ready
    ; Success !=0, Fail=0
    SetEvent(EventName, InheritHandle:= false) {
        hEvent:= this.OpenEvent(EventName, InheritHandle)
        return DllCall("SetEvent", "ptr", hEvent)
    }

    ; Set the event to the nonsignaled state
    ; Success !=0, Fail=0
    ResetEvent(EventName) {
        hEvent:= this.OpenEvent(EventName)
        return DllCall("ResetEvent", "ptr", hEvent)
    }
    ; Wait for a named event
    ; Success: Returns a value for the event that caused the function to return, Fail=-1
    ; Timeout: No wait=0 milliseconds, Wait forever=-1 milliseconds
    ;WAIT_TIMEOUT=0x00000102L, WAIT_OBJECT_0=0x00000000L, WAIT_FAILED=-1L
    WaitEvent(EventName, Milliseconds:=500, InheritHandle:= false) {
        hEvent:= this.OpenEvent(EventName, InheritHandle)
        return DllCall("WaitForSingleObject", "ptr", hEvent, "uint", Milliseconds)
    }

    ; Wait for a named event then read a string from shared registry
    ; WaitRead(EventName) {
    ;     this.Wait(EventName)
    ;     return this.Read()

    ; }

    ; Wait for a named event then write to shared registry, then read back
    ; WaitWrite(EventName, text) {
    ;     this.Wait(EventName)
    ;     this.Write(text)
    ;     return this.Read()
    ; }

    ; Write a string into the shared registry
    Write(Value:="", ValueType:="REG_SZ") {

        ;MsgBox this.KeyName ", " this.ValueName, "Write"

        RegWrite(Value, ValueType, this.KeyName, this.ValueName)
    }

    ; Read a string
    Read() {
        return RegRead(this.KeyName, this.ValueName)
    }

    ; Delete a value from the registry
    Delete(KeyName:=this.KeyName, ValueName:=this.ValueName) {
        RegDelete(KeyName, ValueName)
    }

    ; Delete a subkey from the registry
    DeleteKey(KeyName:=this.KeyName) {
        RegDelete(KeyName)
    }

    ; Destructor: cleanup and close
    __Delete() {
        ; this.Clear()
    }
}

If (A_LineFile == A_ScriptFullPath)  ; if run directly, not included
    SharedRegistry__Tests()

;----------------------------------------------------------------
; --- Usage Example ---
;----------------------------------------------------------------
#Warn Unreachable, Off

SharedRegistry__Tests() {
;return

    reg := SharedRegistry()

    Test1()
    Test2()

    Test1() {
        smallString:= "Hello from shared registry!"
        largeString:= 
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
        "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" .
        "1234567890123456789012345678901234"
    
        myString:=smallString

        reg.Write(smallString)
        MsgBox reg.Read() , "Small String"

        reg.Write(largeString)
        MsgBox reg.Read() , "Large String"

        ;reg.Clear()
        ;MsgBox '[' reg.Read() ']' ", IsEmpty:" reg.IsEmpty(), "Len: " StrLen(MyString)

        reg.Write("Every Write Overwrites the string in shared registry")
        MsgBox '[' reg.Read() ']' ", IsEmpty:" reg.IsEmpty(), "Default Overwrite"

    }

    Test2() {
        val1:= "Able to write numbers to SharedRegistry"
        val2:= 3.1415927
        myCSV:= reg.ConvertToCSV(val1, val2)
        ;MsgBox myCSV
        reg.Write(myCSV)
        returnCSV:= reg.Read()
        ;MsgBox returnCSV, "Len: " StrLen(myCSV)
        split := StrSplit(returnCSV, ",")
        n:= split[2]
        MsgBox "The number is: " n
        n := n*4
        MsgBox "Multiplied by 4: " n
    }
}