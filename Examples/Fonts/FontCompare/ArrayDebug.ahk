#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <Debug>
#Include <IniLite>

Escape::ExitApp()


;OOPS USING BRACKETS VS PARENTHESIS

users2 := Array()
    users2.Push[A_UserName] ; A_Index = MyEditNN
    ; users2.Push["1"] ; A_Index = MyEditNN
    ; users2.Push["2"]  ; A_Index = MyEditNN
    ;MsgBox '[' index '], ' testArray.Length ', [' fontObj.color ']'
    MsgBox users2.Length ;

    users := Array()
    users.Push(A_UserName)
    users.Push(A_UserName)
    users.Push(A_UserName)
    ;MsgBox users.Length ", " users[1], "users"
    Debug.ListVar(users, "ButtonFont_Click")
    users.Push(A_UserName)
    users.Push(A_UserName)
    users.Push(A_UserName)
    Debug.ListVar(users, "ButtonFont_Click")

