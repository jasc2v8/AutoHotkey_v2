
#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include WatchFolder.ahk

folder:="D:\WatchFolder"

; User's choices - set to 1 if you want to watch that option, otherwise set to 0
Files := 0       ; Watch for file changes
Folders := 0     ; Watch for folder changes
Attr := 0        ; Watch for attribute changes
Size := 0       ; Watch for size changes
Write := 0       ; Watch for last write changes
Access := 1      ; Watch for last access changes
Creation := 0    ; Watch for creation changes
Security := 0    ; Watch for security descriptor changes

Watch := (Files ? 1 : 0) | (Folders ? 2 : 0) | (Attr ? 4 : 0) | (Size ? 8 : 0) | (Write ? 16 : 0) | (Access ? 32 : 0) | (Creation ? 64 : 0) | (Security ? 256 : 0)

WatchFolder(folder, "NotifyFolderChanges", False, Watch)

NotifyFolderChanges(Folder, Changes) {
    Static Actions := ["1 (added)", "2 (removed)", "3 (modified)", "4 (renamed)"]
    For Key, Change In Changes {
        ActionText := Actions[Change.Action]
        Name := Change.HasOwnProp("Name") ? Change.Name : ""
        IsDir := Change.HasOwnProp("IsDir") ? Change.IsDir : ""
        OldName := Change.HasOwnProp("OldName") ? Change.OldName : ""
        MsgBox("TickCount: " A_TickCount
            . "`nFolder: " Folder
            . "`nAction: " ActionText
            . "`nName: " Name
            . "`nIsDir: " IsDir
            . "`nOldName: " OldName)
    }
}