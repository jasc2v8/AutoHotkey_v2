
#Requires AutoHotkey v2.0+

class SharedMemory {

    static PAGE_READWRITE := 0x04
    static FILE_MAP_ALL_ACCESS := 0xF001F

    static Name := "Local\SharedMemory"
    static Size := 4096
    static IsServer := false

    __New(IsServer := false, Name:="Global\SharedMemory", Size := 4096) {
        
        this.Name := Name
        ;this.Name := "Local\" . Name

        ; if (A_IsAdmin)
        ;     this.Name := "Global\" . Name
        ; else
        ;     this.Name := "Local\" . Name
    
        ; MsgBox this.Name ": " A_IsAdmin, "SharedMemory"

        ; globalName := "Global\" . Name
        ; localName  := "Local\"  . Name
        ; this.Name = (A_IsAdmin) ? globalName : localName
        ; this.Name = (A_IsAdmin) ? globalName : localName

        this.Size := Size
        this.IsServer := IsServer ; Track if this instance is the Server or Client
        
        ; 1. Setup Security Descriptor (Grant Everyone access)
        ;sa := Buffer(A_PtrSize * 3, 0)
        ;sd := 0
        SD := Buffer(100, 0)
        DllCall("Advapi32\ConvertStringSecurityDescriptorToSecurityDescriptor", "Str", "D:(A;;GA;;;WD)", "UInt", 1, "Ptr*", &pSD := 0, "Ptr", 0)
        SA := Buffer(A_PtrSize == 8 ? 24 : 12, 0)
        NumPut("UInt", SA.Size, SA, 0), NumPut("Ptr", pSD, SA, A_PtrSize)
        ;NumPut("Ptr", sd, sa, A_PtrSize)        ; lpSecurityDescriptor
        ;NumPut("Int", 0,  sa, A_PtrSize*2)      ; bInheritHandle = FALSE


        ; Admin (Global) or User (Local)
        ;this.Name := (A_IsAdmin) ? "Global\" . Name : "Local\\" . Name
        ;_SA :=  (A_IsAdmin) ? SA : 0

        ; 2. Map Memory - Server will Create, Client will Open
        this.Mapping := DllCall("CreateFileMapping", "Ptr", -1, "Ptr", SA, "UInt", SharedMemory.PAGE_READWRITE, "UInt", 0, "UInt", this.Size, "Str", this.Name, "Ptr")
        this.View := DllCall("MapViewOfFile", "Ptr", this.Mapping, "UInt", SharedMemory.FILE_MAP_ALL_ACCESS, "UInt", 0, "UInt", 0, "Ptr", this.Size, "Ptr")

        ; 3. Setup Events
        this.hEventServer := DllCall("CreateEvent", "Ptr", SA, "Int", 0, "Int", 0, "Str", this.Name . "_Server", "Ptr")
        this.hEventClient := DllCall("CreateEvent", "Ptr", SA, "Int", 0, "Int", 0, "Str", this.Name . "_Client", "Ptr")

        DllCall("LocalFree", "Ptr", pSD)
    }

    ; Automatically writes and then signals the OTHER side
    Write(Text) {
        ; Zero stale memory
        DllCall("RtlZeroMemory", "Ptr", this.View, "Ptr", this.Size)
        StrPut(Text, this.View, "UTF-16")
        ; If I am server, signal Srv event (for client to hear). 
        ; If I am client, signal Cli event (for server to hear).
        ; hEvent := this.IsServer ? this.hEventServer : this.hEventClient
        ; DllCall("SetEvent", "Ptr", hEvent)
    }

    ; Waits for a signal from the OTHER side and then returns the string
    WaitRead(Timeout := -1) {
        
        ; If I am server, wait for Cli event. If I am client, wait for Srv event.
        hEventWait := this.IsServer ? this.hEventClient : this.hEventServer
        
        result := DllCall("WaitForSingleObject", "Ptr", hEventWait, "UInt", Timeout)
        
        if (result == 0) { ; WAIT_OBJECT_0 (Success)
            text:= StrGet(this.View, "UTF-16")
            ; Zero memory for next read
            DllCall("RtlZeroMemory", "Ptr", this.View, "Ptr", this.Size)
            return text

        }
        return "" ; Timeout or error
    }

    Read() {
        return StrGet(this.View, "UTF-16")
    }

    __Delete() {
        
        if (this.View)
            DllCall("UnmapViewOfFile", "Ptr", this.View)
        if (this.Mapping)
            DllCall("CloseHandle", "Ptr", this.Mapping)
        if (this.hEventServer)
            DllCall("CloseHandle", "Ptr", this.hEventServer)
        if (this.hEventClient)
            DllCall("CloseHandle", "Ptr", this.hEventClient)
    }
}