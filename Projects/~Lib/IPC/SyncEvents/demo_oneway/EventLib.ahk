; Version 1.0.1
class EventLib {
    static Create(eventName) {
        ; CreateEventA(lpEventAttributes, bManualReset, bInitialState, lpName)
        return DllCall("kernel32\CreateEventA", "Ptr", 0, "Int", 1, "Int", 0, "AStr", eventName, "Ptr")
    }

    static Open(eventName) {
        ; OpenEventA(dwDesiredAccess, bInheritHandle, lpName)
        ; EVENT_MODIFY_STATE = 0x0002, SYNCHRONIZE = 0x00100000
        return DllCall("kernel32\OpenEventA", "UInt", 0x1F0003, "Int", 0, "AStr", eventName, "Ptr")
    }

    static Set(hEvent) {
        return DllCall("kernel32\SetEvent", "Ptr", hEvent)
    }

    static Wait(hEvent, timeout := -1) {
        ; WaitForSingleObject
        return DllCall("kernel32\WaitForSingleObject", "Ptr", hEvent, "UInt", timeout)
    }

    static Close(hEvent) {
        return DllCall("kernel32\CloseHandle", "Ptr", hEvent)
    }
}