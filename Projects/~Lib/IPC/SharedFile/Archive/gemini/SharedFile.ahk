; TITLE  :  Sharedfile with Enmpty/Full Sync
; SOURCE :  jasc2v8 12/15/2025
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    [sync]
    server_seq=12
    client_seq=8
    server_data=...
    client_data=...

*/

#Requires AutoHotkey v2.0+

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

    ; ================= EVENTS =================

    On(eventName, handler) {
        if !this.Events.Has(eventName)
            this.Events[eventName] := []

        this.Events[eventName].Push(handler)
        return this
    }

    Off(eventName, handler := unset) {
        if !this.Events.Has(eventName)
            return

        if !IsSet(handler) {
            this.Events.Delete(eventName)
            return
        }

        arr := this.Events[eventName]
        for i, fn in arr {
            if (fn = handler) {
                arr.RemoveAt(i)
                break
            }
        }
    }

    _Emit(eventName, params*) {
        if !this.Events.Has(eventName)
            return

        for fn in this.Events[eventName] {
            try fn.Call(params*)
        }
    }

    ; ================= PUBLIC =================

    Send(msg) {
        this.Seq++
        this._AtomicIniWrite(Map(
            this._Key("seq"), this.Seq,
            this._Key("data"), msg,
            this._Key("ts"), A_TickCount
        ))

        this._Emit("LocalSend", msg)
    }

    ; ================= WATCHER =================

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
        this._ProcessUpdate()
        this._Watch()
    }

    ; ================= CORE =================

    _ProcessUpdate() {
        peers := this._EnumeratePeers()
        now := A_TickCount

        for peerId in peers {
            if (peerId = this.PeerId)
                continue

            seq := this._IniRead("peer_" peerId "_seq", -1)
            ts  := this._IniRead("peer_" peerId "_ts", 0)

            lastState := this.PeerState.Get(peerId, "alive")

            if (now - ts > this.StaleMs) {
                if lastState != "stale" {
                    this.PeerState[peerId] := "stale"
                    if this.Events.Has("PeerStale")
                        this._Emit("PeerStale", peerId)
                }
                continue
            }

            if lastState = "stale" {
                this.PeerState[peerId] := "alive"
                if this.Events.Has("PeerAlive")
                    this._Emit("PeerAlive", peerId)
            }

            lastSeq := this.LastSeq.Get(peerId, -1)
            if seq != lastSeq {
                this.LastSeq[peerId] := seq
                msg := this._IniRead("peer_" peerId "_data", "")
                if this.Events.Has("Message")
                    this._Emit("Message", peerId, msg)
            }
        }
    }


    ; ================= INI HELPERS =================

    _Key(suffix) {
        return "peer_" this.PeerId "_" suffix
    }

    _IniRead(key, default := "") {
        try return IniRead(this.FilePath, this.Section, key, default)
        catch
            return default
    }

    _EnumeratePeers() {
        if !FileExist(this.FilePath)
            return []

        text := FileRead(this.FilePath, "UTF-8")
        peers := Map()

        for line in StrSplit(text, "`n", "`r") {
            if RegExMatch(line, "peer_(.+?)_seq=", &m)
                peers[m[1]] := true
        }
        return peers.Keys()
    }

    _AtomicIniWrite(pairs) {
        tmp := this.FilePath ".tmp"

        if FileExist(tmp)
            FileDelete(tmp)

        if FileExist(this.FilePath)
            FileCopy(this.FilePath, tmp, 1)

        for k, v in pairs
            IniWrite(v, tmp, this.Section, k)

        FileMove(tmp, this.FilePath, 1)
    }
}