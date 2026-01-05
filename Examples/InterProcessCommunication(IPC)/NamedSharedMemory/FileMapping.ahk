; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

Class FileMapping {
	; http://msdn.microsoft.com/en-us/library/windows/desktop/aa366556(v=vs.85).aspx
	; http://www.autohotkey.com/board/topic/86771-i-want-to-share-var-between-2-processes-how-to-copy-memory-do-it/#entry552031
    ; Source: https://www.autohotkey.com/board/topic/93305-filemapping-class/

	__New(szName?, dwDesiredAccess := 0xF001F, flProtect := 0x4, dwSize := 10000) {	; Opens existing or creates new file mapping object with FILE_MAP_ALL_ACCESS, PAGE_READ_WRITE
        static INVALID_HANDLE_VALUE := -1
        this.BUF_SIZE := dwSize, this.szName := szName ?? ""
		if !(this.hMapFile := DllCall("OpenFileMapping", "Ptr", dwDesiredAccess, "Int", 0, "Ptr", IsSet(szName) ? StrPtr(szName) : 0)) {
		    ; OpenFileMapping Failed - file mapping object doesn't exist - that means we have to create it

; --- 1. Create a SECURITY_ATTRIBUTES structure (SA) for cross-user access ---
; Setting lpSecurityDescriptor to 0 (NULL) usually grants full access 
; for kernel objects to all authenticated users.
StructSize := A_PtrSize * 3 + 4 ; SECURITY_ATTRIBUTES structure size
SA := Buffer(StructSize, 0)
NumPut('UInt', StructSize, SA, 0) ; nLength
NumPut('Ptr', 0, SA, 4) ; lpSecurityDescriptor (NULL for default, permissive security)
NumPut('Int', 0, SA, 4 + A_PtrSize) ; bInheritHandle


			if !(this.hMapFile := DllCall("CreateFileMapping", "Ptr", INVALID_HANDLE_VALUE, "Ptr", SA.Ptr, "Int", flProtect, "Int", 0, "Int", dwSize, "Str", szName)) ; CreateFileMapping Failed
				throw Error("Unable to create or open the file mapping", -1)
		}
		if !(this.pBuf := DllCall("MapViewOfFile", "Ptr", this.hMapFile, "Int", dwDesiredAccess, "Int", 0, "Int", 0, "Int", dwSize))	; MapViewOfFile Failed
			throw Error("Unable to map view of file")
	}
	Write(data, offset := 0) {
		if (this.pBuf) {
            if data is String
			    StrPut(data, this.pBuf+offset, this.BUF_SIZE-offset)
            else if data is Buffer
                DllCall("RtlCopyMemory", "ptr", this.pBuf+offset, "ptr", data, "int", Min(data.Size, this.BUF_SIZE-offset))
            else
                throw TypeError("The data type can be a string or a Buffer object")
        } else
            throw Error("File already closed!")
	}
    ; If a buffer object is provided then data is transferred from the file mapping to the buffer
	Read(buffer?, offset := 0, size?) => IsSet(buffer) ? DllCall("RtlCopyMemory", "ptr", buffer, "ptr", this.pBuf+offset, "int", Min(buffer.size, this.BUF_SIZE-offset, size ?? this.BUF_SIZE-offset)) : StrGet(this.pBuf+offset)
	Close() {
		DllCall("UnmapViewOfFile", "Ptr", this.pBuf), DllCall("CloseHandle", "Ptr", this.hMapFile)
		this.szName := "", this.BUF_SIZE := "", this.hMapFile := "", this.pBuf := ""
	}
	__Delete() => this.Close()
}