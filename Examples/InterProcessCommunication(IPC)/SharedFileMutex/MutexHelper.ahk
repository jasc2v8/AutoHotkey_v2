; MutexHelpers.ahk
#Requires AutoHotkey v2.0

AcquireMutex(name) {
    hMutex := DllCall("CreateMutex", "ptr", 0, "int", true, "str", name, "ptr")
    if (DllCall("GetLastError") = 183) {
        hMutex := DllCall("OpenMutex", "uint", 0x1F0001, "int", false, "str", name, "ptr")
        DllCall("WaitForSingleObject", "ptr", hMutex, "uint", 0xFFFFFFFF) ; INFINITE wait
    }
    return hMutex
}

ReleaseMutex(hMutex) {
    if hMutex {
        DllCall("ReleaseMutex", "ptr", hMutex)
        DllCall("CloseHandle", "ptr", hMutex)
    }
}