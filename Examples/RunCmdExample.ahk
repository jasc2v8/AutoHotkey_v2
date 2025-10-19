#Requires AutoHotkey v2.0
#SingleInstance
#Include <RunCMD>

TraySetIcon(A_Comspec)
ProcessSetPriority("High")

RunCmd_Prompt()

RunCmd_Prompt()
{
    Local  MyGui,  Edit1,  Edit2,  Push1,  MySB,  W

    MyGui := Gui("+DpiScale", "RunCMD() - Realtime per line streaming demo")
    MyGui.MarginX := 16
    MyGui.MarginY := 16
    MyGui.SetFont("s10", "Consolas")

    MyGui.AddText(,"Output")
    Edit1 := MyGui.AddEdit("y+0 -Wrap +HScroll R20 -WantReturn", Format("{:81}",""))
    Edit1.Text := ""
    Edit1.GetPos(,,&W)

    MyGui.AddText("", "Command Line")
    Edit2 := MyGui.AddEdit("y+0 -Wrap w" W, 'Dir "' A_ProgramFiles '\*.exe" /s')
    Push1 := MyGui.AddButton("x+0 w0 h0 Default -Tabstop", "<F2> RunCMD")
    Push1.OnEvent("Click", RunCMD_Routine)

    MySB := MyGui.AddStatusBar()
    MySB.SetParts(200,200)
    MySB.SetText("`t<Esc> Cancel/Clear", 1)
    MySB.SetText("`t<Enter> RunCMD", 2)
    Edit2.Focus()

                      OnEscape(MyGui)
                      {
                          If (  RunCMD.PID )
                                Return ( RunCMD.PID := 0, "" )

                          Edit1.Text := ""
                          Edit2.Text := ""
                          MySB.SetText("", 3)
                      }

    MyGui.OnEvent("Escape", OnEscape)
    RunCMD.PID := 0

    MyGui.Show()

                    RunCMD_Routine(*)
                    {
                        MySB.SetText("", 3)
                        Push1.Opt("+Disabled")
                        RunCMD(A_Comspec " /c " Edit2.Text,,, RunCmd_Output, 0)
                        MySB.SetText("`tExitCode : " RunCMD.Exitcode, 3)
                        Push1.Opt("-Disabled")
                    }


                    RunCmd_Output(Line, LineNum)
                    {
                        Edit_Append(Edit1.Hwnd, Line)
                    }


                    Edit_Append(hEdit, Txt)
                    {
                        Local Len := DllCall("User32\GetWindowTextLengthW", "ptr",hEdit)
                        SendMessage(0xB1, Len, Len, hEdit)        ;  EM_SETSEL
                        SendMessage(0xC2, 0, StrPtr(Txt), hEdit)  ;  EM_REPLACESEL
                    }
}