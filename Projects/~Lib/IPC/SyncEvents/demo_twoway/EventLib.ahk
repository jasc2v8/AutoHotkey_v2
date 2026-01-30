; Version 1.0.2
class EventLib {
    static Create(eventName) {
        return DllCall("kernel32\CreateEventA", "Ptr", 0, "Int", 1, "Int", 0, "AStr", eventName, "Ptr")
    }

    static Open(eventName) {
        return DllCall("kernel32\OpenEventA", "UInt", 0x1F0003, "Int", 0, "AStr", eventName, "Ptr")
    }

    static Set(hEvent) {
        return DllCall("kernel32\SetEvent", "Ptr", hEvent)
    }

    static Reset(hEvent) {
        return DllCall("kernel32\ResetEvent", "Ptr", hEvent)
    }

    static Wait(hEvent, timeout := -1) {
        return DllCall("kernel32\WaitForSingleObject", "Ptr", hEvent, "UInt", timeout)
    }

    static Close(hEvent) {
        return DllCall("kernel32\CloseHandle", "Ptr", hEvent)
    }
}