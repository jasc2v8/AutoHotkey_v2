#SingleInstance
;#NoTrayIcon
Persistent

Tray := A_TrayMenu ; For convenience.
Tray.Delete() ; Delete the standard items.
Tray.Add() ; separator
Tray.Add("TestToggleCheck", TestToggleCheck)
Tray.Add("TestToggleEnable", TestToggleEnable)
Tray.Add("TestDefault", TestDefault)
Tray.Add("TestAddStandard", TestAddStandard)
Tray.Add("TestDelete", TestDelete)
Tray.Add("TestDeleteAll", TestDeleteAll)
Tray.Add("TestRename", TestRename)
Tray.Add("Test", Test)
Tray.Add("Exit", (*) => ExitApp())

MsgBox("Script running. Right-click tray icon for menu.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestToggleCheck(*)
{
    Tray.ToggleCheck("TestToggleCheck")
    Tray.Enable("TestToggleEnable") ; Also enables the next test since it can't undo the disabling of itself.
    Tray.Add("TestDelete", TestDelete) ; Similar to above.
}

TestToggleEnable(*)
{
    Tray.ToggleEnable("TestToggleEnable")
}

TestDefault(*)
{
    if Tray.Default = "TestDefault"
        Tray.Default := ""
    else
        Tray.Default := "TestDefault"
}

TestAddStandard(*)
{
    Tray.AddStandard()
}

TestDelete(*)
{
    Tray.Delete("TestDelete")
}

TestDeleteAll(*)
{
    Tray.Delete()
}

TestRename(*)
{
    static OldName := "", NewName := ""
    if NewName != "renamed"
    {
        OldName := "TestRename"
        NewName := "renamed"
    }
    else
    {
        OldName := "renamed"
        NewName := "TestRename"
    }
    Tray.Rename(OldName, NewName)
}

Test(Item, *)
{
    MsgBox("You selected " Item)
}
