;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=131893
;Source: https://www.autohotkey.com/board/topic/9327-a-handy-dialogue-technique-and-colorful-msgboxs
#Requires Autohotkey v2
#SingleInstance Force
#NoTrayIcon

MyVar := 'World'

MsgBox Deref('Hello ${MyVar}!', &MyVar)

Deref(str, vars*)
{
    for var in vars
        str := StrReplace(str, '${' NameOf(&var) '}', &var)
    return str
    
    ; https://github.com/thqby/ahk2_lib/blob/master/nameof.ahk
    NameOf(&value) => StrGet(NumGet(ObjPtr(&value) + 8 + 6 * A_PtrSize, 'Ptr'), 'UTF-16')
}
