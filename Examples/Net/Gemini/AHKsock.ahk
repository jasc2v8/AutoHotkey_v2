

; ==============================================================================
; AHKSOCK CORE FUNCTIONS (v2)
; ==============================================================================

AHKsock_Startup() {
    if AHKsock_Global.IsStarted
        return 0
    WSAData := Buffer(408, 0)
    if !DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSAData, "Int") {
        AHKsock_Global.IsStarted := True
        OnMessage(AHKsock_Global.MessageID, AHKsock_OnMessage)
        return 0
    }
    return 1
}

AHKsock_Listen(sPort, sFunction) {

    if AHKsock_Startup()
        return 3
    
    hints := Buffer(16 + 4 * A_PtrSize, 0)
    NumPut("Int", 1, hints, 0), NumPut("Int", 2, hints, 4), NumPut("Int", 1, hints, 8), NumPut("Int", 6, hints, 12)
    
    res := 0
    if DllCall("Ws2_32\getaddrinfo", "Ptr", 0, "Str", String(sPort), "Ptr", hints, "Ptr*", &res) return 5
    
    skt := DllCall("Ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "Ptr")
    if (skt == -1)
        return 6
    
    if DllCall("Ws2_32\bind", "Ptr", skt, "Ptr", NumGet(res, 16 + 2 * A_PtrSize, "Ptr"), "Int", NumGet(res, 16, "Int")) return 7
    DllCall("Ws2_32\freeaddrinfo", "Ptr", res)
    
    DllCall("Ws2_32\WSAAsyncSelect", "Ptr", skt, "Ptr", A_ScriptHwnd, "UInt", AHKsock_Global.MessageID, "Int", 8)
    DllCall("Ws2_32\listen", "Ptr", skt, "Int", 32)
    
    AHKsock_Global.Sockets[skt] := {Func: sFunction}
    return 0
}

AHKsock_Send(s, p, l) => DllCall("Ws2_32\send", "Ptr", s, "Ptr", p, "Int", l, "Int", 0)

AHKsock_Close(s) {
    DllCall("Ws2_32\closesocket", "Ptr", s)
    if AHKsock_Global.Sockets.Has(s)
        AHKsock_Global.Sockets.Delete(s)
}

AHKsock_OnMessage(wParam, lParam, *) {
    Critical("On")
    skt := wParam, event := lParam & 0xFFFF
    if !AHKsock_Global.Sockets.Has(skt)
        return
    
    obj := AHKsock_Global.Sockets[skt]
    if (event == 8) { ; FD_ACCEPT
        ns := DllCall("Ws2_32\accept", "Ptr", skt, "Ptr", 0, "Ptr", 0, "Ptr")
        if (ns != -1) {
            IP := GetRemoteAddr(ns)
            AHKsock_Global.Sockets[ns] := {Func: obj.Func, Addr: IP}
            DllCall("Ws2_32\WSAAsyncSelect", "Ptr", ns, "Ptr", A_ScriptHwnd, "UInt", AHKsock_Global.MessageID, "Int", 33)
            ServerLog("Accepted: " IP " (Socket " ns ")")
            obj.Func.Call("ACCEPTED", ns)
        }
    } else if (event == 1) {
        obj.Func.Call("RECEIVED", skt)
    } else if (event == 32) {
        obj.Func.Call("DISCONNECTED", skt), AHKsock_Close(skt)

    }
}