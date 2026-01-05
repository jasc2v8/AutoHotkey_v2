class SharedSyncPeer {
    FilePath := ""
    DirPath := ""
    PeerId := ""
    Section := "sync"

    Seq := 0
    LastSeq := Map()
    PeerState := Map() ; peerId => "alive"/"stale"
    StaleMs := 5000

    hDir := 0
    Buffer := Buffer(4096)
    Overlapped := Buffer(32, 0)

    Events := Map()

    __New(filePath, peerId) {
        this.FilePath := filePath
        this.PeerId := peerId

        SplitPath filePath, , &dir
        this.DirPath := dir

        this._InitWatcher()
    }

    ; ---------------- WATCHER ----------------

    _InitWatcher() {
        FILE_LIST_DIRECTORY := 0x0001
        this.hDir := DllCall(
            "CreateFileW",
            "str", this.DirPath,
            "uint", FILE_LIST_DIRECTORY,
            "uint", 0x7,
            "ptr", 0,
            "uint", 3,
            "uint", 0x02000000,
            "ptr", 0,
            "ptr"
        )
        this._Watch()
    }

    _Watch() {
        DllCall(
            "ReadDirectoryChangesW",
            "ptr", this.hDir,
            "ptr", this.Buffer,
            "uint", this.Buffer.Size,
            "int", false,
            "uint", 0x00000003,
            "uint*", 0,
            "ptr", this.Overlapped,
            "ptr", CallbackCreate(ObjBindMethod(this, "_OnNotify"))
        )
    }

    _OnNotify(*) {
        
         MsgBox "Processing update", "SharedSyncPeer"

        this._ProcessUpdate()
        this._Watch()
    }

    ; ---------------- CORE ----------------

    _ProcessUpdate() {

        MsgBox "Processing update", "SharedSyncPeer"
    }

}
