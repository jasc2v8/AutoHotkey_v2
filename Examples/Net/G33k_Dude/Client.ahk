#Requires AutoHotkey v2.0
#Include Socket.ahk

; 1. Create a new TCP Socket
Client := SocketTCP()

try {

    Client.OnRecv := OnReceive 

    ; 2. Attempt to connect to your server
    ; Using "127.0.0.1" (localhost) and port 1337
    Client.Connect(["127.0.0.1", 1337])
    
    ; 3. Send a basic HTTP-style GET request
    Client.SendText("GET / HTTP/1.0`r`nHost: localhost`r`n`r`n")
    
    ; We'll wait a brief moment for the server to process
    Sleep(200)
    ; 4. Receive the response
    ; Sleep(200)
    ; Response := Client.RecvText()
    
    ; if (Response != "")
    ;     MsgBox("Server Response:`n`n" Response)
    ; else
    ;     MsgBox("Connected, but received no data.")

} catch Error as e {
    MsgBox("Connection Failed!`n`n" e.Message)
}

OnReceive(ServerObj)
{
    ;MsgBox("OnReceive!")

    ;Sleep(200)
    Response := Client.RecvText()
    
    if (Response != "")
        MsgBox("Server Response:`n`n" Response)
    else
        MsgBox("Connected, but received no data.")

}

; 5. Cleanup
Client.Disconnect()
;MsgBox("Client Discconect and Exit.")
ExitApp()