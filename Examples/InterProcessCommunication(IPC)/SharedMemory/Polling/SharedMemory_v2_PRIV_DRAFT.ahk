#Requires AutoHotkey v2.0

class SharedMemory {

    ; --- WinAPI Constants ---
    PAGE_READWRITE := 0x04 
    FILE_MAP_ALL_ACCESS := 0xF001F

    ; Storage for security descriptor pointer (needs to be freed later)
    pSecurityDescriptor := 0 
    
    ; SDDL: D:(A;;GA;;;BU) 
    ; D: = DACL (Discretionary Access Control List)
    ; (A;;GA;;;BU) = Access Control Entry:
    ;   A = Allow Access
    ;   GA = Generic All (Read/Write/Execute)
    ;   BU = Built-in Users group (which includes all non-admin interactive users)
    SDDL_BUILTIN_USERS_RW := "D:(A;;GA;;;BU)"
    SDDL_REVISION_1 := 1

    ; Constructor: open or create a shared memory mapping
    __New(name, size := 4096, access := "rw") {

        ; --- WinAPI Constants ---
        PAGE_READWRITE := 0x04 
        FILE_MAP_ALL_ACCESS := 0xF001F

        ; Storage for security descriptor pointer (needs to be freed later)
        pSecurityDescriptor := 0 
        
        ; SDDL: D:(A;;GA;;;BU) 
        ; D: = DACL (Discretionary Access Control List)
        ; (A;;GA;;;BU) = Access Control Entry:
        ;   A = Allow Access
        ;   GA = Generic All (Read/Write/Execute)
        ;   BU = Built-in Users group (which includes all non-admin interactive users)
        SDDL_BUILTIN_USERS_RW := "D:(A;;GA;;;BU)"
        SDDL_REVISION_1 := 1

        ; Enforce Global namespace for inter-session communication
        ;this.name := SubStr(name, 1, 7) == "Global\" ? name : "Global\" . name
        this.name := "\MySharedMemory"
        this.size := size

        ; ----------------------------------------------------
        ; --- 1. SETUP SECURITY ATTRIBUTES (Required for permissions) ---
        ; ----------------------------------------------------
        
        ; Call ConvertStringSecurityDescriptorToSecurityDescriptorW to create the raw descriptor
        pSD := 0 ; Output pointer for the security descriptor
        ret := DllCall("Advapi32\ConvertStringSecurityDescriptorToSecurityDescriptorW"
                     , "Str", this.SDDL_BUILTIN_USERS_RW
                     , "UInt", this.SDDL_REVISION_1
                     , "PtrP", pSD    ; Output: Address of the newly allocated security descriptor
                     , "Ptr", 0)

        if (ret = 0)
            throw Error("Failed to convert SDDL to Security Descriptor. Last Error: " . A_LastError)
        
        ; Store the pointer for cleanup in __Delete
        this.pSecurityDescriptor := pSD 

        ; Create Buffer for SECURITY_ATTRIBUTES structure:
        ; Size: 4 (DWORD nLength) + A_PtrSize (LPVOID lpSecurityDescriptor) + 4 (BOOL bInheritHandle)
        saSize := 4 + A_PtrSize + 4
        sa := Buffer(saSize, 0)

        ; Populate the SECURITY_ATTRIBUTES structure:
        NumPut("UInt", saSize, sa, 0)                          ; nLength (offset 0)
        NumPut("Ptr", pSD, sa, 4)                              ; lpSecurityDescriptor (offset 4)
        NumPut("Int", 0, sa, 4 + A_PtrSize)                    ; bInheritHandle = 0 (offset 4+A_PtrSize)
        
        ; Pointer to the SECURITY_ATTRIBUTES buffer
        pSA := sa.Ptr 

        ; Determine desired access for MapViewOfFile/OpenFileMapping
        desiredAccess := this.FILE_MAP_ALL_ACCESS ; (access == "r") ? this.FILE_MAP_READ : this.FILE_MAP_ALL_ACCESS

        ; --- 2. Try to open existing mapping ---
        this.hMap := DllCall("Kernel32\OpenFileMappingW", "UInt", desiredAccess, "Int", 0, "Str", this.name, "Ptr")

        if (this.hMap = 0) {
            ; --- 3. If not found, create one, passing the custom security descriptor ---
            this.hMapFile := DllCall("CreateFileMappingW"
                , "ptr", -1                ; hFile
                , "ptr", 0                ; lpSecurityAttributes TODO
                , "uint", 0x04             ; PAGE_READWRITE
                , "uint", 0                ; dwMaximumSizeHigh
                , "uint", size             ; dwMaximumSizeLow
                , "wstr", name             ; lpName
                , "ptr")                   ; return HANDLE
        }

        if (this.hMap = 0)
            throw Error("Failed to create/open shared memory. Last Error: " . A_LastError)

        ; --- 4. Map a view ---
        this.pMapView := DllCall("MapViewOfFile"
            , "ptr", this.hMapFile
            , "uint", 0xF001F          ; FILE_MAP_ALL_ACCESS
            , "uint", 0
            , "uint", 0
            , "uptr", size
            , "ptr")

        if (!this.pMapView) {
            DllCall("CloseHandle", "ptr", this.hMapFile)
            throw Error("MapViewOfFile failed. LastError=" DllCall("GetLastError","uint"))
        }

    }
    
    ; --- Data Access Methods (same as before) ---
    ReadRaw(len) {
        buf := Buffer(len)
        DllCall("Kernel32\RtlMoveMemory", "Ptr", buf, "Ptr", this.pBuf, "UPtr", len)
        return buf
    }

    WriteRaw(buf) {
        copySize := (buf.Size <= this.size) ? buf.Size : this.size
        DllCall("Kernel32\RtlMoveMemory", "Ptr", this.pBuf, "Ptr", buf, "UPtr", copySize)
    }

        ; Read as string
    ReadString(encoding := "UTF-16") {
        return StrGet(this.pBuf, this.size, encoding)
    }

    ; Write a string
    WriteString(text, encoding := "UTF-16") {
        StrPut(text, this.pBuf, this.size, encoding)
    }

    ; Cleanup
    __Delete() {
        if (this.pBuf != 0)
            DllCall("Kernel32\UnmapViewOfFile", "Ptr", this.pBuf)
        if (this.hMap != 0)
            DllCall("Kernel32\CloseHandle", "Ptr", this.hMap)
        
        ; ----------------------------------------------------
        ; --- 5. CLEANUP SECURITY DESCRIPTOR (CRITICAL) ---
        ; Must free the memory allocated by ConvertStringSecurityDescriptorToSecurityDescriptorW
        ; ----------------------------------------------------
        if (this.pSecurityDescriptor != 0)
            DllCall("Kernel32\LocalFree", "Ptr", this.pSecurityDescriptor)
    }
}
