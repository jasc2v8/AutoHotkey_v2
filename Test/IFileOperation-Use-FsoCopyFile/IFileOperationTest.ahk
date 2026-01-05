; WIP!

/*
*/
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

Source := "D:\SOURCE\source.txt" ; A_Desktop . "\~IFileOperation.txt"
Target   := "D:TARGET" ; A_MyDocuments

; Sourcefile := File()
; FilSourcefile := FileOpen(Source, "w")
; Sourcefile.Length :=  2000 * (1024**2)    ; 2 GB
; Sourcefile.Close()

FileOp := IFileOperation()
Source := FileOp.ShellItem(Source)
Dest   := FileOp.ShellItem(Dest)
MsgBox "Source: " . Source . "`nDest: " . Dest

FileOp.CopyItem(Source, Dest)
MsgBox "PerformOperations: " . (FileOp.PerformOperations() ? "ERROR" : "OK!")

ObjRelease(Source)
ObjRelease(Dest)
ExitApp


Class IFileOperation
{
    ; ===================================================================================================================
    ; INSTANCE VARIABLES
    ; ===================================================================================================================
    IFileOperation := 0


    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New()
    {
        ; v2? ComObjError(FALSE)

        ; Reference: ShObjIdl_core.h
        ; IFileOperation interface          --------- CLSID_FileOperation ----------  ---------- IID_IFileOperation ----------
        If (!(this.IFileOperation := ComObject("{3AD05575-8857-4850-9277-11B85BDB8E09}", "{947AAB5F-0A5C-4C13-B4D6-4BF7836FC9F8}")))
            Return FALSE
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775771(v=vs.85).aspx


    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete()
    {
        ObjRelease(this.IFileOperation)
    }


    ; ===================================================================================================================
    ; PRIVATE METHODS
    ; ===================================================================================================================
    vtable(n)
    {
        ; NumGet(this.IFileOperation) returns the address of the object's virtual function table (vtable for short)
        ; The remainder of the expression retrieves the address of the nth function's address from the vtable.
        ; v1 Return NumGet(NumGet(this.IFileOperation), n*A_PtrSize)
        Return NumGet(NumGet(this.IFileOperation,0), n*A_PtrSize)
        ;   IUnknown:
        ;       QueryInterface = 0, AddRef, Release
        ;   IFileOperation : public IUnknown
        ;       Advise = 3, Unadvise, SetOperationFlags, SetProgressMessage, SetProgressDialog, SetProperties, SetOwnerWindow, ApplyPropertiesToItem, ApplyPropertiesToItems
        ;       RenameItem, RenameItems, MoveItem, MoveItems, CopyItem, CopyItems, DeleteItem, DeleteItems, NewItem, PerformOperations, GetAnyOperationsAborted
    }

    Call(n, params*)
    {
        params.Push("UInt")    ; Return Value Type (S_OK || HRESULT)
        Return DllCall(this.vtable(n), "UPtr", this.IFileOperation, params*)
    }


    ; ===================================================================================================================
    ; HELPER METHODS
    ; ===================================================================================================================
    ShellItem(Item)
    {
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb762236(v=vs.85).aspx
        ;Local PIDL
        PIDL := "" ; Object()
        ; v1 If (DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &Item, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0))
        If (DllCall("Shell32.dll\SHParseDisplayName", "UPtr", Item.Ptr, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0))
            Return 0

        ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms680589(v=vs.85).aspx
        ;Local GUID
        ; v1 VarSetCapacity(GUID, 16)
        GUID := Buffer(16)
        DllCall("Ole32.dll\CLSIDFromString", "Str", "{43826D1E-E718-42EE-BC55-A1E261C37BFE}", "UPtr", &GUID)    ; IID_IShellItem

        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb762133(v=vs.85).aspx
        ;Local IShellItem
        IShellItem := Object()
        DllCall("Shell32.dll\SHCreateItemFromIDList", "UPtr", PIDL, "UPtr", &GUID, "UPtrP", IShellItem, "UInt")

        Return IShellItem    ; ObjRelease(IShellItem)
    }


    ; ===================================================================================================================
    ; PUBLIC METHODS
    ; ===================================================================================================================
    CopyItem(pItem, pDestinationFolder, CopyName := "", pProgressStatus := 0)
    {
        CopyName := CopyName == "" ? ["UPtr", 0] : ["Str", CopyName . ""], CopyName.Push("UPtr", pProgressStatus)
        Return this.Call(16, "UPtr", pItem, "UPtr", pDestinationFolder, CopyName*)
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775761(v=vs.85).aspx

    SetOperationFlags(dwOperationFlags)
    {
        Return this.Call(5, "UInt", dwOperationFlags)
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775807(v=vs.85).aspx

    PerformOperations()
    {
        Return this.Call(21)
    } ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775780(v=vs.85).aspx
}