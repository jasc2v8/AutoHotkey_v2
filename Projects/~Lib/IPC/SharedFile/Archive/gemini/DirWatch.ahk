#Requires AutoHotkey v2.0

global hDir:=0

; -----------------------------
; Configuration
; -----------------------------
watchDir := "D:\WatchFolder"  ; Change to your folder
if !FileExist(watchDir)
    DirCreate(watchDir)

; -----------------------------
; Create buffer and overlapped struct
; -----------------------------
Buff := Buffer(4096)
Overlapped := Buffer(32, 0)

TrayTip "Watching " watchDir

IniWatcher(watchDir)
Watch(hDir)

    IniWatcher(watchDir) {
        global hDir
        FILE_LIST_DIRECTORY := 0x0001
        hDir := DllCall("CreateFileW"
            , "str", watchDir
            , "uint", FILE_LIST_DIRECTORY
            , "uint", 0x7              ; FILE_SHARE_READ|WRITE|DELETE
            , "ptr", 0
            , "uint", 3                 ; OPEN_EXISTING
            , "uint", 0x02000000        ; FILE_FLAG_OVERLAPPED
            , "ptr", 0
            , "ptr"
        )
    }
    Watch(hDir) {
        DllCall(
            "ReadDirectoryChangesW",
            "ptr", hDir,
            "ptr", Buff,
            "uint", Buff.Size,
            "int", false,
            "uint", 0x00000003,
            "uint*", 0,
            "ptr", Overlapped,
            "ptr", CallbackCreate(OnNotify)
        )
    }

    OnNotify(*) {
        MsgBox "Processing update", "SharedSyncPeer"
        ProcessUpdate()
        Watch(hDir)
    }

    ProcessUpdate() {
        MsgBox "Processing update", "SharedSyncPeer"
    }


; -----------------------------
; Callback function
; -----------------------------
; DirCallback(pOverlapped, dwErrorCode, dwBytesTransferred, lpOverlapped) {

;     MsgBox "Callback"
;     ; global buff
;     ; ; Read notifications from buff
;     ; offset := 0
;     ; while offset < dwBytesTransferred {
;     ;     info := NumGet(buff, offset, "Uint64") ; FILE_NOTIFY_INFORMATION structure
;     ;     action := NumGet(buff, offset+4, "UInt")
;     ;     nameLength := NumGet(buff, offset+8, "UInt")
;     ;     fileName := StrGet(buff + offset + 12, nameLength, "UTF-16")
;     ;     ; Print change
;     ;     MsgBox Format("Action: {} File: {}", action, fileName)
;     ;     ; Move to next record
;     ;     nextOffset := NumGet(buff, offset, "UInt")
;     ;     if nextOffset = 0
;     ;         break
;     ;     offset += nextOffset
;     ;}
;     ; Re-issue watch
;     DllCall("ReadDirectoryChangesW"
;         , "ptr", hDir
;         , "ptr", buff
;         , "uint", buff.Size
;         , "int", false
;         , "uint", 0x00000003      ; FILE_NOTIFY_CHANGE_FILE_NAME | LAST_WRITE
;         , "uint*", 0
;         , "ptr", lpOverlapped
;         , "ptr", CallbackCreate(DirCallback)
;     )
; }

; ; -----------------------------
; ; Start watching
; ; -----------------------------
; TrayTip "Watching " watchDir

; DllCall("ReadDirectoryChangesW"
;     , "ptr", hDir
;     , "ptr", buff
;     , "uint", buff.Size
;     , "int", false
;     , "uint", 0x00000003
;     , "uint*", 0
;     , "ptr", overlapped
;     , "ptr", CallbackCreate(DirCallback)
; )


MsgBox "Press OK to exit."

; -----------------------------
; Cleanup
; -----------------------------
DllCall("CloseHandle", "ptr", hDir)
