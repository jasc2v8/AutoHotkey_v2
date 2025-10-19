; ABOUT: DownloadControlTool, changed icon for standalone version
; 
#Requires AutoHotkey >=2.0

#SingleInstance Force
#NoTrayIcon
TraySetIcon('shell32.dll', 123)

; #region Version Block
; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Download Control Tool
;@Ahk2Exe-Set FileVersion, 1.0.1.2
;@Ahk2Exe-Set InternalName, DownloadControlTool
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, DownloadControlTool.exe
;@Ahk2Exe-Set ProductName, DownloadControlTool
;@Ahk2Exe-Set ProductVersion, 1.0.1.1
;@Ahk2Exe-SetMainIcon DownloadControlTool.ico

;@Inno-Set AppId, {{09F686C0-6F29-43BC-88D4-0C51BEFEEB4B}}
;@Inno-Set AppPublisher, jasc2v8

; Create a new Gui object
MyGui := Gui("+AlwaysOnTop", "Download Control Tool v1.0.1.2") ; "ToolWindow" does not have tray icon
;MyGui.Title := "New Title"
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S12 CBlack w480", "Segouie UI")
SB := MyGui.Add("StatusBar")

; Add Buttons to the GUI
Filler := MyGui.Add("Button", "xm ym w24 +Hidden")  ; "x+5 y+5"
ButtonStart := MyGui.Add("Button", "yp w72", "START")  ; "x+5 y+5"
ButtonStop := MyGui.Add("Button", "yp W72 Default", "STOP")
ButtonCancel := MyGui.Add("Button", "yp W72 Default", "Cancel")
MyLine := MyGui.Add("Text", "xm w320 h1 0x10") ;SS_ETCHEDHORZ
Filler := MyGui.Add("Button", "xm w24 +Hidden")  ; "x+5 y+5"
ButtonMovies := MyGui.Add("Button", "yp W110", "📂 Movies")
ButtonTV := MyGui.Add("Button", "yp W110", "📂 TV")
;~ MyButtonOpt3 := MyGui.Add("Button", "x+m yp W64 Default", "Opt3")

; Assign event handlers
ButtonStart.OnEvent("Click", ButtonStart_Click)
ButtonStop.OnEvent("Click", ButtonStop_Click)
ButtonCancel.OnEvent("Click", ButtonCancel_Click)
ButtonMovies.OnEvent("Click", ButtonMovies_Click)
ButtonTV.OnEvent("Click", ButtonTV_Click)
MyGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI
MyGui.Show()

gX := MyGui.MarginX

; connectionstate values: Disconnected, Connecting, Connected, Interrupted, Reconnecting, DisconnectingToReconnect, Disconnecting
output := RunSaveOutput('"C:\Program Files\Private Internet Access\piactl.exe" get connectionstate')

WriteStatus("VPN status: " . output)

; Subroutines below

StartTorrent() {

 WriteStatus("Starting qBittorrent...")

 if !ProcessExist("qbittorrent.exe") {

  Run("C:\Program Files\qBittorrent\qBittorrent.exe")

  if WinWait("ahk_exe qBittorrent.exe",, 5)
  {
    WinActivate()
    return true
  }
  else
  {
    WriteStatus("Error: qBittorrent did not start.")
    return 0
  }
 }
}

StartVPN(){

 WriteStatus("Connecting VPN...")

 if !ProcessExist("pia-client.exe") {

  Run("C:\Program Files\Private Internet Access\pia-client.exe",, "Hide") ; PIA settings: UNcheck Connect on Launch

  if WinWait("ahk_exe pia-client.exe", "", 5)
  {
   WinActivate()
  }
  else
  {
   WriteStatus("Error: VPN did not start.")
   return 0
  }
 }

 Sleep(250) ; delay until ready

 Run("C:\Program Files\Private Internet Access\piactl.exe connect",, "Hide") ; make sure its connected

 return 1

}

StartURL(){

 WriteStatus("Opening URL...")

 Run("C:\Program Files\Google\Chrome\Application\chrome.exe --incognito https://snowfl.com",, "Hide")

 SetTitleMatchMode 1 ; starts with

 if WinWait("snowfl", "", 5)
 {
  WinActivate()
 }
 else
 {
  WriteStatus("Error: URL did not open.")
  return 0
 }
 return 1
}

ButtonStart_Click(Ctrl, Info) {

 WriteStatus("Starting VPN and 0pening URL...")

 if !StartVPN() {
  return
 }
 if !StartURL() {
  return
 }

 if !StartTorrent() {
  return
 }

 WriteStatus("VPN and TOR started and URL open.")

}

ButtonStop_Click(Ctrl, Info) {

WriteStatus("Disconnecting VPN...")
Sleep(1000)

 ; disconnect and close vpn process
 output := RunSaveOutput('"C:\Program Files\Private Internet Access\piactl.exe" get connectionstate')

 if output != "Disconnected" {
  RunSaveOutput('"C:\Program Files\Private Internet Access\piactl.exe" disconnect')
  ;Sleep(1000)
 }

ProcessClose("pia-client.exe")

WriteStatus("Closing VPN Client...")
Sleep(1000)

if ProcessExist("pia-client.exe") {
   WriteStatus("Warning: VPN client did not close.")
   Sleep(1000)
}

WriteStatus("Closing URL...")
Sleep(1000)

 ; close download url
 SetTitleMatchMode 1 ; starts with
 if WinExist("snowfl") {
  WinClose()
 }

ProcessClose("qbittorrent.exe")
WriteStatus("Closing qBittorrent...")
Sleep(1000)

 if ProcessExist("qbittorrent.exe") {
   WriteStatus("Warning: qBittorrent did not close.")
   Sleep(1000)
}

 WriteStatus("VPN, URL, and qBittorrent closed.")
}

ButtonCancel_Click(Ctrl, Info) {
 ExitApp()
}

WriteStatus(Text){
 SB.SetText(StrRepeat(" ", 5) . Text)
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

ButtonMovies_Click(*) {
  Run("\\JIM-SERVER\Movies")
}
ButtonTV_Click(*) {
  Run("\\JIM-SERVER\Recorded TV")
}