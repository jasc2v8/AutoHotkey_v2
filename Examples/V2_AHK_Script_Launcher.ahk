;SOURCE: https://www.autohotkey.com/boards/viewtopic.php?t=102798

#Requires Autohotkey v2.0
#SingleInstance Force
	; ^ =Ctrl - # =Win - ! =Alt - + =Shift

;added
UserProfilePath := EnvGet("USERPROFILE")
DesktopPath := UserProfilePath "\Desktop\AutoHotkey\*.ahk"
DocumentsPath := UserProfilePath "\Documents\AutoHotkey\Lib\*.ahk"
PythonPath := UserProfilePath "\Desktop\Script Python\*.py"

Gui1 := Gui()
RetrievedTitle := Gui1.Title
Gui1.SetFont("s12")  ; Set a font size (12-point).
Gui1.Add("Text",, "Pick a file to launch from the list below.")
Tab  := Gui1.AddTab3(, ["   AHK Desktop Folder   ","   AHK Documents Folder   ","   Python Folder   "])

; LV1
Tab.UseTab(1)
LV1 := Gui1.Add("ListView", "r20 w700", ["Name","In Folder","Size (KB)","Type"])
		LV1.ModifyCol(1, 280)  ; Auto-size each column to fit its contents.
        LV1.ModifyCol(2, 270)  ; Auto-size each column to fit its contents.
        LV1.ModifyCol(3, 70)  ; Make the Size column at little wider to reveal its header.
        LV1.ModifyCol(4, 50,)  ; Make the Size column at little wider to reveal its header.
			Loop Files, DesktopPath  ; Change UserName
        LV1.Add(, A_LoopFileName, A_LoopFileDir, A_LoopFileSizeKB, A_LoopFileExt)


; LV2
Tab.UseTab(2)
LV2 := Gui1.Add("ListView", "r20 w700", ["Name","In Folder","Size (KB)","Type"])
		LV2.ModifyCol(1, 280)  ; Auto-size each column to fit its contents.
        LV2.ModifyCol(2, 270)  ; Auto-size each column to fit its contents.
        LV2.ModifyCol(3, 70)  ; Make the Size column at little wider to reveal its header.
        LV2.ModifyCol(4, 50,)  ; Make the Size column at little wider to reveal its header.
			Loop Files, DocumentsPath  ; Change UserName
        LV2.Add(, A_LoopFileName, A_LoopFileDir, A_LoopFileSizeKB, A_LoopFileExt)

; LV3
Tab.UseTab(3)
LV3 := Gui1.Add("ListView", "r20 w700", ["Name","In Folder","Size (KB)","Type"])
		LV3.ModifyCol(1, 280)  ; Auto-size each column to fit its contents.
        LV3.ModifyCol(2, 270)  ; Auto-size each column to fit its contents.
        LV3.ModifyCol(3, 70)  ; Make the Size column at little wider to reveal its header.
        LV3.ModifyCol(4, 50,)  ; Make the Size column at little wider to reveal its header.
			Loop Files, PythonPath  ; Change UserName
        LV3.Add(, A_LoopFileName, A_LoopFileDir, A_LoopFileSizeKB, A_LoopFileExt)

gui1.Show

; Events
LV1.OnEvent('DoubleClick', RunFile)
LV2.OnEvent('DoubleClick', RunFile)
LV3.OnEvent('DoubleClick', RunFile)

RunFile(LV, RowNumber)
{
    FileName := LV.GetText(RowNumber, 1) ; Get the text of the first field.
    FileDir := LV.GetText(RowNumber, 2)  ; Get the text of the second field.
    try
        Run(FileDir "\" FileName)
    catch
        MsgBox("Could not open " FileDir "\" FileName ".")
    WinMinimize()
}

