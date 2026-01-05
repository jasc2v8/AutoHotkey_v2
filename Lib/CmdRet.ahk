#Requires AutoHotkey v2

;MsgBox CmdRet('ipconfig')
MsgBox CmdRet('dir c:\')

CmdRet(sCmd, callBackFunc := '', encoding := '') {
    static flags := [HANDLE_FLAG_INHERIT := 0x1, CREATE_NO_WINDOW := 0x8000000], STARTF_USESTDHANDLES := 0x100

    (encoding = '' && encoding := 'cp' . DllCall('GetOEMCP', 'UInt'))
    DllCall('CreatePipe', 'PtrP', &hPipeRead := 0, 'PtrP', &hPipeWrite := 0, 'Ptr', 0, 'UInt', 0)
    DllCall('SetHandleInformation', 'Ptr', hPipeWrite, 'UInt', flags[1], 'UInt', flags[1])

    STARTUPINFO := Buffer(size := A_PtrSize*9 + 4*8, 0)
    NumPut('UInt', size, STARTUPINFO)
    NumPut('UInt', STARTF_USESTDHANDLES, STARTUPINFO, A_PtrSize*4 + 4*7)
    NumPut('Ptr', hPipeWrite, 'Ptr', hPipeWrite, STARTUPINFO, size - A_PtrSize*2)

    PROCESS_INFORMATION := Buffer(A_PtrSize*2 + 4*2, 0)
    if !DllCall('CreateProcess', 'Ptr', 0, 'Str', sCmd, 'Ptr', 0, 'Ptr', 0, 'UInt', true, 'UInt', flags[2]
                               , 'Ptr', 0, 'Ptr', 0, 'Ptr', STARTUPINFO, 'Ptr', PROCESS_INFORMATION)
    {
        DllCall('CloseHandle', 'Ptr', hPipeRead)
        DllCall('CloseHandle', 'Ptr', hPipeWrite)
        throw OSError('CreateProcess is failed')
    }
    DllCall('CloseHandle', 'Ptr', hPipeWrite)
    temp := Buffer(4096, 0), output := ''
    while DllCall('ReadFile', 'Ptr', hPipeRead, 'Ptr', temp, 'UInt', 4096, 'UIntP', &size := 0, 'UInt', 0) {
        output .= stdOut := StrGet(temp, size, encoding)
        ( callBackFunc && callBackFunc(stdOut) )
    }
    DllCall('CloseHandle', 'Ptr', NumGet(PROCESS_INFORMATION, 'Ptr'))
    DllCall('CloseHandle', 'Ptr', NumGet(PROCESS_INFORMATION, A_PtrSize, 'Ptr'))
    DllCall('CloseHandle', 'Ptr', hPipeRead)
    return output
}