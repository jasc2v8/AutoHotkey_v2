; ABOUT: AhkLauncher_Setup initial version
; 
#Requires AutoHotkey >=2.0

#SingleInstance Force
#NoTrayIcon
TraySetIcon('cmd.exe', 1)

; #regions Create Gui

MyGui := Gui("+AlwaysOnTop", "AhkLauncher Setup v0.1") ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S12 CBlack w480", "Segouie UI")
SB := MyGui.AddStatusBar()

; Add Buttons to the GUI
ButtonGetOutput := MyGui.AddButton( , "Get Output")
ButtonSaveOutput := MyGui.AddButton( "yp", "Save Output")

ButtonGetOutput.OnEvent("Click", ButtonGetOutput_Click)
ButtonSaveOutput.OnEvent("Click", ButtonSaveOutput_Click)

;ButtonCancel.OnEvent("Click", ButtonCancel_Click)

MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.Show("")

WriteStatus("Press START...")

; Subroutines below

ButtonGetOutput_Click(Ctrl, Info) {

  WriteStatus("Working, PLEASE BE PATIENT...")

  outPut := RunGetOutput('Dir %USERPROFILE%')

  WriteStatus("Done.")

  MsgBox(outPut)

}

ButtonSaveOutput_Click(Ctrl, Info) {

  WriteStatus("Working, PLEASE BE PATIENT...")

  outPut := RunSaveOutput('Dir %USERPROFILE%')

  WriteStatus("Done.")

  MsgBox(outPut)

}
ButtonCancel_Click(Ctrl, Info) {
 ExitApp()
}

WriteStatus(Text){
 SB.SetText(Text)
}

StrRepeat(text, times) {
 return StrReplace(Format("{:" times "}", ""), " ", text)
}

RunGetOutput(command) {
 ; cmd window briefly shown
 shell := ComObject("WScript.Shell")
 exec := shell.Exec(A_ComSpec . " /C " . command)
 output := exec.StdOut.ReadAll()
 return output
}

RunSaveOutput(command) {
 ; no cmd window shown, tempFile must not have spaces (fix TBD)
 tempFile := A_Temp . "\MyOutput.txt"
 RunWait(A_ComSpec . " /C " . command . " > " . tempFile, , 'Hide')
 output := FileRead(tempFile)
 FileDelete(tempFile)
 FileDelete(A_Temp . "\xml_file*.xml") ; cleanup from RunWait function
 return output
}
