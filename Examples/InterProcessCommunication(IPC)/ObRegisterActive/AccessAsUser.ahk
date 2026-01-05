#Requires AutoHotkey v2.0

GUID:="{01234567-89AB-CDEF-0123-456789ABCDEF}"

Loop {
    try {

        x := ComObjActive(GUID)

        if MsgBox("Shared object key: " x.key, "AccessSharedObj", "OKCancel") = "Cancel"
        break

        x:=""

    } catch any as e{
        if MsgBox(e.Message, "AccessSharedObj", "OKCancel") = "Cancel"
            ExitApp()
    }
}