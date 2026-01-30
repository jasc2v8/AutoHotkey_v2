; TITLE: DownloadTool 1.0.0.2
; 
#Requires AutoHotkey 2+

#SingleInstance Force
TraySetIcon('shell32.dll', 123) ; white square with blue down arrow

; #region Version Block
; Language codes (en-US=1033): https://www.autoitscript.com/autoit3/docs/appendix/OSLangCodes.htm
;@Ahk2Exe-Set CompanyName, jasc2v8
;@Ahk2Exe-Set FileDescription, Download Tool
;@Ahk2Exe-Set FileVersion, 1.0.0.2
;@Ahk2Exe-Set InternalName, Download Tool
;@Ahk2Exe-Set Language, 1033
;@Ahk2Exe-Set LegalCopyright, ©2025 jasc2v8
;@Ahk2Exe-Set LegalTrademarks, NONE™
;@Ahk2Exe-Set OriginalFilename, DownladTool.exe
;@Ahk2Exe-Set ProductName, DownloadTool
;@Ahk2Exe-Set ProductVersion, 1.0.0.2
;@Ahk2Exe-SetMainIcon DownloadTool.ico

;@Inno-Set AppId, {{D32B7F87-C16A-4383-B997-CC0C47ADD99D}}
;@Inno-Set AppPublisher, jasc2v8

#Include <IniFile>
#Include <RunCMD>

global PiaPath    := "C:\Program Files\Private Internet Access\pia-client.exe"
global PiaCtlPath := "C:\Program Files\Private Internet Access\piactl.exe"

global UrlPath    := "C:\Program Files\Google\Chrome\Application\chrome.exe --incognito https://snowfl.com"

global MoviesFolder := "\\JIM-SERVER\Movies"
global TVFolder := "\\JIM-SERVER\Recorded TV"
global TorrentPath:= "C:\Program Files\qBittorrent\qBittorrent.exe"
global TorrentIniPath := A_AppData "\qBittorrent\qBittorrent.ini"

; #region Create Gui

MyGui := Gui("+AlwaysOnTop", "Download Tool v1.0")
;MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.BackColor := "7DA7CA" ; Steel Blue +2.5 Glaucous
MyGui.SetFont("S10", "Segoe UI")
SB := MyGui.Add("StatusBar")

; Add Buttons to the GUI
Filler := MyGui.Add("Button", "xm ym w24 +Hidden")
ButtonStart := MyGui.Add("Button", "yp w72", "START")
ButtonStop := MyGui.Add("Button", "yp W72 Default", "STOP")
ButtonCancel := MyGui.Add("Button", "yp W72 Default", "Cancel")
MyLine := MyGui.Add("Text", "xm w320 h1 0x10") ;SS_ETCHEDHORZ

;Filler := MyGui.Add("Button", "xm w1 +Hidden")
MyGui.SetFont("S9", "Segoe UI")
ButtonMovies := MyGui.Add("Button", "xm+28 W75", "📂 Movies")
ButtonTV := MyGui.Add("Button", "yp W75", "📂 TV")
ButtonSaveDir := MyGui.Add("Button", "yp W75", "📂 SaveDir")

; Assign event handlers
ButtonStart.OnEvent("Click", ButtonStart_Click)
ButtonStop.OnEvent("Click", ButtonStop_Click)
ButtonCancel.OnEvent("Click", ButtonCancel_Click)
ButtonMovies.OnEvent("Click", ButtonMovies_Click)
ButtonTV.OnEvent("Click", ButtonTV_Click)
ButtonSaveDir.OnEvent("Click", ButtonSavedDir_Click)
MyGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI
MyGui.Show()

gX := MyGui.MarginX

; #region Start

DetectHiddenWindows true

_Run := RunCMD


; Show VPN status (should be disconnected)

; connectionstate values: Disconnected, Connecting, Connected, Interrupted, Reconnecting, DisconnectingToReconnect, Disconnecting
cmd:= RunCMD.ToCSV("C:\Program Files\Private Internet Access\piactl.exe", "get", "connectionstate")

output := RunCMD(cmd)

WriteStatus("VPN status: " . output)

; #region Functions

StartTorrent() {

 WriteStatus("Starting qBittorrent...")

 if !ProcessExist("qbittorrent.exe") {

  ; dont RunWait
  Run("C:\Program Files\qBittorrent\qBittorrent.exe")

  ;MsgBox output, "TORRENT OUTPUT"

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

    ;this command hangs with RunWait or Run CMD
    Run("C:\Program Files\Private Internet Access\pia-client.exe",, "Hide")
    
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

  ; Connect VPN
  RunCMD(PiaCtlPath ' connect')

  return 1

}

StartURL(){

  WriteStatus("Opening URL...")
 
  Run(UrlPath,, "Hide")
 
  SetTitleMatchMode 1 ; starts with

  if WinWait("snowfl", "", 5)
  {
    WinActivate()
  }
  else
  {
    WriteStatus("Error: URL did not open.")
    return false
  }
  return true
}

ButtonSavedDir_Click(Ctrl, Info) {
  ini := IniFile(TorrentIniPath)
  path := ini.Read("BitTorrent", "Session\DefaultSavePath")
  WriteStatus("Open: " path)
  Run(path)  
}

ButtonStart_Click(Ctrl, Info) {

  WriteStatus("Starting VPN and 0pening URL...")

  if !StartVPN() {
    return
  }

  if !StartURL() {
    return
  }

  StartTorrent() ; sometimes take a long time to open

  WriteStatus("VPN and TOR started and URL open.")

}

ButtonStop_Click(Ctrl, Info) {

WriteStatus("Disconnecting VPN...")
Sleep(1000)

  ; disconnect and close vpn process
  cmd:= RunCMD.ToCSV("C:\Program Files\Private Internet Access\piactl.exe", "get", "connectionstate")
  output := RunCMD(cmd)
  ;NO  output := RunCMD('"C:\Program Files\Private Internet Access\piactl.exe" get connectionstate')

 if output != "Disconnected" {
  ;RunCMD('"C:\Program Files\Private Internet Access\piactl.exe" disconnect')
  RunCMD(PiaCtlPath " disconnect")
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

ButtonMovies_Click(*) {
  WriteStatus("Open: " MoviesFolder)
  Run(MoviesFolder)
}
ButtonTV_Click(*) {
  WriteStatus("Open: " TVFolder)
  Run(TVFolder)
}