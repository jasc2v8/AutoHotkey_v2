; 
; Name: QuickerAccess
; Version: 1.4
; AHK Version: 2.0+
; Author: CyberKlabauter
; credits: william_ahk, TeaTrinker, CyberKlabauter
; forum: https://www.autohotkey.com/boards/viewtopic.php?f=83&p=590584
;

; [Strg] + [<] 					to launch the favourites, files and folders (Address List).
; [Strg] + [Shift] + [<] 		to open the contents of the active Windows Explorer.
; [Strg] + [Shift] + [<] 		to see a list of all open Explorer windows.
; [Strg] + [Shift] + [Win + [<] to add selected files and folders to your adresslist.
; [Strg] + [Shift] + [Win + [<] to add a URL of the active browser window/tab to your bookmarks (URLs).
; [Strg] + [<] 					and select the 'URLs' folder, then hit the Tab key to access your bookmarks.
; [Tab] or [Left] 				to enter sub-folder.
; [Ritght] 						to enter parent-folder.

; You can personalize the default hotkey [Strg + <] in the settings

#Requires AutoHotkey v2.0
#SingleInstance Force

; #Include <UIA>  					; https://www.autohotkey.com/boards/viewtopic.php?t=113065
;#Include ..\Lib\UIA.ahk  			; https://www.autohotkey.com/boards/viewtopic.php?t=113065
;#Include <UIA>  			; https://www.autohotkey.com/boards/viewtopic.php?t=113065
#Include .\UIA.ahk  			; https://www.autohotkey.

Global CONFIG_FILEPATH := (()=>(SplitPath(A_ScriptName,,,,&Name), Name ".ini"))()

;Define default values here 
DefaulAdressListItems := A_ScriptDir . "\URLs`n%USERPROFILE%`n%USERPROFILE%\Documents`n%USERPROFILE%\Music`n%WINDIR%\Web\Wallpaper`n%APPDATA%`n%TEMP%`n%WINDIR%\win.ini"
Global DefaultConfig := Map("AddressList",DefaulAdressListItems, "WindowSize","w800 h400", "ShowKey","^<", "RocketMode","0", "UrlDirectory",A_ScriptDir "\URLs")

Global Config := LoadConfig(CONFIG_FILEPATH, DefaultConfig)
Global PreparedAddressList, MainGui, hActvWnd, CurrentExplorerPath, PathLocationInMainGui


/*
global 	Default := Map()
Default["ShowKey"] := "^<"
Default["WindowSize"] := "x11 y40 w800 h400"
Default["RocketMode"] := "0"
; Default["AddressList"] := ""
Default["UrlDirectory"] := A_ScriptDir "\URLs"
*/

Array.Prototype.Join := ArrayJoin

CONFIG_Blacklist := (()=>(SplitPath(A_ScriptName,,,,&Name), Name "BlacklistProgramms.txt"))()
If (FileExist(CONFIG_Blacklist))  {
	Config["BlacklistProgramms"] := Trim(RegExReplace(FileRead(CONFIG_Blacklist), "\R+\R", "`r`n"), "`r`n")
	If (!(Config["BlacklistProgramms"] == ""))  {
		Loop Parse, Config["BlacklistProgramms"], "`n", "`r"
			{
			GroupAdd("AppsToExcludeHotkey", "ahk_class " A_LoopField)
			}
		}
	}

If FileExist(shell32dll := EnvGet("SystemRoot") "\System32\shell32.dll")
	TraySetIcon(shell32dll, (GetWinOSVersion() == "10") ? 321 : 209)

A_TrayMenu.Add()
A_TrayMenu.Add("Edit address list", (*) => EditAddressList())
A_TrayMenu.Add("Settings", Settings)
A_TrayMenu.Add("Show", ToggleMainGui)
A_TrayMenu.Default := "Show"
A_TrayMenu.ClickCount := 1

MainGui := Gui("+Resize", "QuickerAccess")
MainGui.SetFont("s10", "Segoe UI")
MainGui.MarginX := 0, MainGui.MarginY := 0
MainGui.Add("Edit", "vFilterBox").OnEvent("Change", FilterOnChange)
(AddressList := MainGui.Add("ListView", "vAddressList +LV0x10000 -E0x200 -0x200000", ["Name", "Path"])).OnEvent("Click", AddressListOnClick)
DllCall("uxtheme\SetWindowTheme", "Ptr", AddressList.Hwnd, "Str", "Explorer", "Ptr", 0)

MainGui.OnEvent("Size", MainGuiOnSize)
MainGui.OnEvent("Escape", (*) => MainGui.Hide())
MainGui.OnEvent("ContextMenu", ContextMenu)
OnMessage(0x100, MainGuiOnKeyDown) ; WM_KEYDOWN
OnMessage(0x232, MainGuiAfterSize) ; WM_EXITSIZEMOVE
;OnMessage(0x0008, HideOnLooseFocus)   ; WM_KILLFOCUS

MainGui.Show(Config["WindowSize"] " Hide")
ToggleHotkeys("On")

UpdateAddressList(, false)
AdjustAddressList()


ToggleMainGui(*) {
	Global hActvWnd, MainGui, CurrentExplorerPath, PathLocationInMainGui
	CurrentExplorerPath := ""
	PathLocationInMainGui := ""
	GroupAdd("Explorer", "ahk_class CabinetWClass")
	GroupAdd("Explorer", "ahk_class Progman")
	GroupAdd("Explorer", "ahk_class WorkerW")
	GroupAdd("SaveAs", "ahk_class #32770")

	CurrentExplorerPath := GetCurrentExplorerPath()
	if InStr(A_ThisHotkey, "+") && WinActive("ahk_group Explorer")  {
		if (CurrentExplorerPath == "" || CurrentExplorerPath = "ERROR")
			Config["AddressList"] := LoadAddressList(Config["DefaultAddressList"])
		else  {
			PathLocationInMainGui := CurrentExplorerPath
			SubDirList := GetSubDirList(CurrentExplorerPath)
			Config["AddressList"] := LoadAddressList(SubDirList)
			}
		}
	else if InStr(A_ThisHotkey, "+") && WinActive("ahk_group SaveAs")  {
			SubDirList := GetOpenExplorerWindows()
			If (SubDirList == "ERROR")
				Config["AddressList"] := LoadAddressList(Config["DefaultAddressList"])
			else
				Config["AddressList"] := LoadAddressList(SubDirList)
		}
	else if WinActive("ahk_group AppsToExcludeHotkey")  {
		If (InStr(A_ThisHotkey, "+"))  {
			Send("+" . Config["ShowKey"])
			}
		else
			Send(Config["ShowKey"])
		return
		}
	else if (InStr(A_ThisHotkey, "+") && !WinActive("ahk_group Explorer"))  {
		SubDirList := GetOpenExplorerWindows()
		If (SubDirList == "ERROR")
			Config["AddressList"] := LoadAddressList(Config["DefaultAddressList"])
		else
			Config["AddressList"] := LoadAddressList(SubDirList)
		}
	else
		Config["AddressList"] := LoadAddressList(Config["DefaultAddressList"])

	UpdateAddressList()
    if !(IsSet(MainGui) && MainGui)
        return
	if InStr(A_ThisHotkey, "!")
		SendInput "{! up}"
    if !WinActive(MainGui.Hwnd) {
        hActvWnd := WinExist("A") ; handle to current windows
		MainGui.Show()
		MainGui["FilterBox"].Focus()
    } else {
        MainGui.Hide()
		}
	}


HideOnLooseFocus(wParam, lParam, msg, hwnd)  {
	global MainGui
    MainGui.Hide()
	}

ToggleHotkeys(On:=true) {
	ShowKey := "$" . Config["ShowKey"]
	ShowKeyExplorerDir := "$+" . Config["ShowKey"]
	SaveUrlKey := "$+#" . Config["ShowKey"]
	Hotkey ShowKey, ToggleMainGui, On
	Hotkey ShowKeyExplorerDir, ToggleMainGui, On
;	Hotkey SaveUrlKey, CreateWebShortcut.Bind(Config["UrlDirectory"]), On
	Hotkey SaveUrlKey, AddFileFolderOrUrl, On
	}

ContextMenu(GuiObj, GuiCtl, Item, *)  {
	M := Menu()
	M.Add("&Edit address list", (*) => EditAddressList())
	If Item
		M.Add("&Remove item", RemoveItem)
	M.Show()

	RemoveItem(*) {
		MainGui["AddressList"].Delete(Item)
		Config["AddressList"].RemoveAt(Item)
		IniDelete(CONFIG_FILEPATH, "AddressList")
		IniWrite(Config["AddressList"].Join("`n"), CONFIG_FILEPATH, "AddressList")
		}
	}

EditAddressList()  {
	Static Section := "AddressList"
	EditGui := Gui("+Resize +Owner" MainGui.Hwnd, "Edit Address List")
	EditGui.Close := OnClose
	EditGui.OnEvent("Close", EditGui.Close)
	EditGui.OnEvent("Size", OnSize)

	OnMessage(0x102, OnPaste) ; WM_CHAR
	OnMessage(0x104, OnSysKeyDown) ; WM_SYSKEYDOWN
	OnMessage(0x233, OnDropFiles) ; WM_DROPFILES (Drag & Drop support)
	DllCall("Shell32.dll\DragAcceptFiles", "Ptr", EditGui.Hwnd, "Int", 1)

	EditGui.MarginX := 0, EditGui.MarginY := 0
	EditGui.SetFont("s10", "Segoe UI")
	EditGui.MenuBar := MenuBar()
	EditMenu := Menu()
	EditMenu.Add("&Paste file path	Ctrl+V", (*) => EditPaste(A_Clipboard, AddressEdit))
	EditMenu.Add("Move current line up &Up	Alt+Up", (*) => MoveLine(AddressEdit, 0))
	EditMenu.Add("Move current line up &Down	Alt+Down", (*) => MoveLine(AddressEdit, 1))
	EditGui.MenuBar.Add("&Edit", EditMenu)
	FileList := ""
	For index, filepath in Config[Section]
		FileList .= filepath "`n"
	AddressEdit := EditGui.Add("Edit", "w600 r16 -Wrap -E0x200", FileList) ; WS_EX_CLIENTEDGE
	PostMessage 0xB1,,, AddressEdit
	(SaveButton := EditGui.Add("Button", "wp", "Save")).OnEvent("Click", Save)
	EditGui.Show()

	OnSize(GuiObj, MinMax, Width, Height) {
		SaveButton.GetPos(,,, &H)
		Height -= H,
		AddressEdit.Move(,, Width, Height),
		SaveButton.Move(, Height, Width)
		}

	OnSysKeyDown(wp, lp, msg, hwnd)  {
		; VK_UP = 38, VK_DOWN = 40
		If (hwnd = AddressEdit.Hwnd) && ((wp = 38) || (wp = 40))  {
			Direction := wp != 38
			MoveLine(AddressEdit, Direction)
			}
		}

	OnDropFiles(wParam, lParam, msg, hwnd) {
		nFiles := DllCall("Shell32\DragQueryFileW", "Ptr", wParam, "UInt", 0xFFFFFFFF, "Ptr", 0, "UInt")
	
		; Bestehende Pfade sammeln
		existingPaths := Map()
		for _, path in StrSplit(AddressEdit.Value, "`n") {  ; Nur `n` statt `\r\n`
			norm := StrLower(Trim(path))
			if (norm != "")
				existingPaths[norm] := true
		}
	
		filePaths := ""
		Loop nFiles {
			len := DllCall("Shell32\DragQueryFileW", "Ptr", wParam, "UInt", A_Index - 1, "Ptr", 0, "UInt") + 1
			VarSetStrCapacity(&filePath, len)
			DllCall("Shell32\DragQueryFileW", "Ptr", wParam, "UInt", A_Index - 1, "Str", filePath, "UInt", len)
	
			normPath := StrLower(Trim(filePath))
	
		if !existingPaths.Has(normPath) {
				filePaths .= (filePaths != "" ? "`r`n" : "") . filePath
				existingPaths[normPath] := true
			}
		}
	
		DllCall("Shell32\DragFinish", "Ptr", wParam)
		if (filePaths != "")
			if (filePaths != "") {
			current := RTrim(AddressEdit.Value, "`r`n")
			AddressEdit.Value := (current != "" ? current . "`r`n" : "") . filePaths
			}
		}


	OnPaste(wp, lp, msg, hwnd)  { ; Thanks to teadrinker https://www.autohotkey.com/boards/viewtopic.php?p=569093
		Static CF_HDROP := 0xF
		If !(wp = 0x16 && hwnd = AddressEdit.hwnd)
			Return
		DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
		If hData := DllCall("GetClipboardData", "UInt", CF_HDROP, "Ptr")  {
			pDROPFILES := DllCall("GlobalLock", "Ptr", hData, "Ptr")
			addr := pDROPFILES + NumGet(pDROPFILES, "UInt")
			while (filePath := StrGet(addr)) != "" {
				filePaths .= (A_Index = 1 ? "" : "`r`n") filePath
				addr += StrPut(filePath)
			}
			DllCall("GlobalUnlock", "Ptr", hData)
			EditPaste filePaths, AddressEdit
			}
		DllCall("CloseClipboard")
		}

	OnClose(*)  {
		EditGui.Destroy()
		EditGui := unset
		OnMessage(0x102, OnPaste, 0) ; WM_CHAR
		OnMessage(0x104, OnSysKeyDown, 0) ; WM_SYSKEYDOWN
		}

	Save(*)  {
		AddressListStr := RTrim(AddressEdit.value, "`n")
		Config["DefaultAddressList"] := AddressListStr
		Config["AddressList"] := LoadAddressList(AddressListStr)
		EditGui.Close()
		IniDelete(CONFIG_FILEPATH, Section),
		IniWrite(AddressListStr, CONFIG_FILEPATH, Section)
		UpdateAddressList()
		}
	}

MainGuiOnSize(GuiObj, MinMax, Width, Height) {
	AdjustAddressList()
	}

AdjustAddressList()  {
	Static Column1Padding := 15
	MainGui.GetClientPos(,, &Width, &Height)
	FilterBox := MainGui["FilterBox"],
    FilterBox.Move(,, Width),
	FilterBox.GetPos(, , , &H),
	Height -= H,
	LV := MainGui["AddressList"],
	LV.Opt("-Redraw")
	LV.Move(,, W := Width, Height),
	Width -= LV_GetVScrollWidth(LV),
	LV.ModifyCol(1, "AutoHdr"),
	Column1Width := SendMessage(0x101D, 0, , LV), ;LVM_GETCOLUMNWIDTH
	LV.ModifyCol(1, Column1Width+Column1Padding),
	LV.ModifyCol(2, Width-Column1Width-Column1Padding)
	LV.Opt("+Redraw")
	}

MainGuiAfterSize(wParam, lParam, msg, hwnd)  {
	if (hwnd == MainGui.Hwnd) {
		MainGui.GetPos(&X, &Y)
		MainGui.GetClientPos(, , &Width, &Height)
		Pos := "x" X " y" Y " w" Width " h" Height
		if (Pos != Config["WindowSize"]) {
			Config["WindowSize"] := Pos
			IniWrite(Pos, CONFIG_FILEPATH, "Settings", "WindowSize")
			}
		}
	}

MainGuiOnKeyDown(wParam, lParam, Msg, hWnd)  {
	static VK := {Enter: 0xD, Tab: 0x09, Space: 0x20, Up: 0x26, Right: 0x27, Down: 0x28, Left: 0x25}
	If !(GuiCtrl := GuiCtrlFromHwnd(hWnd))
		Return
	switch GuiCtrl.Gui
		{
		case MainGui:
			switch wParam
				{
				case VK.Space:
					if !GetKeyState("Ctrl", "P") && GuiCtrl.Name = "AddressList" {
							OpenSelected()
							MainGui.Minimize()
							MainGui.Hide()
					}
				case VK.Tab, VK.Right:
					LoadSubDir()
					FB := MainGui["FilterBox"]
					return 0  ; Suppress the Tab key
				case VK.Left:
					LoadSubDir(true)
					FB := MainGui["FilterBox"]
					return 0  ; Suppress the Tab key
				case VK.Enter:
					MainGui.Minimize()
					MainGui.Hide()
					OpenSelected()
					MainGui["FilterBox"].value := ""
					UpdateAddressList()
				case VK.Up, VK.Down:
					LV := MainGui["AddressList"]
					if (hWnd != LV.Hwnd) {
						LV.Modify(0, "-Focus -Select")
						LV.Focus()
						LV.Modify(1, "+Focus +Select")
					}
					;LV.Modify(0, "-Select")
					;next := LV.GetNext()
					;if next < 2
					;	next++
					;select := wParam == VK.Up ? (last := LV.GetCount()) : next
					;LV.Modify(1, "+Select")
				}
		default:
		}
	}


AddressListOnClick(LV, RowNumber)  {
	If !RowNumber
		Return

	MainGui.Minimize()
	MainGui.Hide()
    OpenSelected()
	MainGui["FilterBox"].value := ""
	UpdateAddressList()
	}


FilterOnChange(FilterCtrl, *)  {
	Static DebounceFunc := () => (UpdateAddressList(FilterCtrl.value), FnObj := unset)
	SetTimer DebounceFunc, 0
	SetTimer DebounceFunc, -(FilterCtrl.value = "" ? 1 : 100)
	}


OpenSelected()  {
	Global PreparedAddressList, hActvWnd
	Static WC_EXPLORER_WINDOW := "CabinetWClass", WC_EXPLORER_DIALOG := "#32770"
	SelectedRows := []
	RowNumber := 0
	Target_blank := GetKeyState("Ctrl", "P")
	While (RowNumber := MainGui["AddressList"].GetNext(RowNumber))
		SelectedRows.push(RowNumber)
    If !SelectedRows.length
        If (MainGui["AddressList"].GetCount() > 0)
			SelectedRows.push(1)
	For Row in SelectedRows {
		Address := PreparedAddressList[Row]
		IsDir := DllCall("Shlwapi\PathIsDirectory", "Ptr", StrPtr(Address))
		If Target_blank || !(IsSet(hActvWnd) && WinExist(hActvWnd)) {
			OpenPathDestination(Address)
			Continue
			}
		ExplorerClass := WinGetClass(hActvWnd)
		hWndCurrentExplorer := hActvWnd ; use local variable and free hActvWnd 
		hActvWnd := unset

		Switch ExplorerClass {
			Case WC_EXPLORER_WINDOW:
				If (!IsDir)
					OpenPathDestination(Address)  ; open file
				Else if (InStr(GetOpenExplorerWindows(), Address "`n"))  {   ; switch to existing open folder, instead of navigate to path
					hWndAddress := GetExplorerHwndByPath(Address)  ; hWnd to target 
					WinActivate("ahk_id " hWndAddress)
					JumpToExplorerTab(Address, hWndAddress)
					}
				Else  {
					; hWndAddress := GetExplorerHwndByPath(Address)  ; hWnd to target 
					For window in ComObject("Shell.Application").Windows  {
						If (window.hwnd == hWndCurrentExplorer)  {  
							window.navigate2(Address)
							}
						}
					}
			Case WC_EXPLORER_DIALOG:
				If (IsDir) {
					Try {
						ControlFocus "Edit1", hWndCurrentExplorer
						ControlSetText Address, "Edit1", hWndCurrentExplorer
						ControlSend "{Enter}", "Edit1", hWndCurrentExplorer	
						}
					catch {
						If ControlGetHwnd("Address Band Root1", hWndCurrentExplorer) {
							try {
								WinActivate(hWndCurrentExplorer)
								ControlSend "{Ctrl down}{l down}{l up}{Ctrl up}",, hWndCurrentExplorer
								Sleep(10)
								ControlSetText Address, "Edit2", hWndCurrentExplorer
								ControlSend "{Enter}", "Edit2", hWndCurrentExplorer
								ControlFocus "Edit1", hWndCurrentExplorer
								}
							catch  {
								WinActivate(hWndCurrentExplorer)
								ControlSend "{Ctrl down}{l down}{l up}{Ctrl up}",, hWndCurrentExplorer
								Sleep(10)
								ControlSetText Address, "Edit3", hWndCurrentExplorer
								ControlSend "{Enter}", "Edit3", hWndCurrentExplorer
								ControlFocus "Edit1", hWndCurrentExplorer
								}
							}
						}
					}
			Default:
				If (!IsDir)
					OpenPathDestination(Address)
				Else if (InStr(GetOpenExplorerWindows(), Address "`n"))  {
					hWndAddress := GetExplorerHwndByPath(Address)  ; hWnd to target 
					WinActivate("ahk_id " hWndAddress)
					JumpToExplorerTab(Address, hWndAddress)
					}
				else
					OpenPathDestination(Address)
			}
		}
	}


OpenPathDestination(Address := "")  {
	IsDir := DllCall("Shlwapi\PathIsDirectory", "Ptr", StrPtr(Address))
	If (!IsDir)  {
		SplitPath(Address, , , &Extension)
		If(FileExist(Address))
			Run(Address)
		else if (Extension)
			MsgBox("The following file is not accessible:`n" Address, "File not found",  "4144")
		else 
			MsgBox("The following folder is not accessible:`n" Address, "File not found",  "4144")
		}
	else { 
		If(DirExist(Address))
			Run(Address)
		else
			MsgBox("The following folder is not accessible:`n" Address, "File not found",  "4144")
		}
	}
	

LoadSubDir(GoParentFolder:=false) {
	Global PreparedAddressList, PathLocationInMainGui
	Static WC_EXPLORER_WINDOW := "CabinetWClass", WC_EXPLORER_DIALOG := "#32770"
	SelectedRows := []
	RowNumber := 0
	if (GoParentFolder && !(PathLocationInMainGui == "")) {
		BackslashPosition := InStr(PathLocationInMainGui, "`\", , -1)-1
		Address := SubStr(PathLocationInMainGui, 1, BackslashPosition > 1 ? BackslashPosition : 2)
		IsDir := DllCall("Shlwapi\PathIsDirectory", "Ptr", StrPtr(Address))
		If (!IsDir)  {
			SplitPath(Address, , &Address)
			}
			LoadSubDirList(Address)
			return
		} 
	else if (GoParentFolder && PathLocationInMainGui == "")
		return

	While (RowNumber := MainGui["AddressList"].GetNext(RowNumber))
		SelectedRows.push(RowNumber)

	If (!SelectedRows.length) {
        If (MainGui["AddressList"].GetCount() > 0)
			SelectedRows.push(1)
			}
	If (!SelectedRows.length)		
		return

	For Row in SelectedRows {
		Address := PreparedAddressList[Row]
		IsDir := DllCall("Shlwapi\PathIsDirectory", "Ptr", StrPtr(Address))

		If IsDir  {
			;PathLocationInMainGui := Address
			LoadSubDirList(Address)
			return
			}
		Else 
			continue
		}
	Address := PreparedAddressList[1]
	OpenPathDestination(Address)
	}


LoadSubDirList(Directory)  {
	Global hActvWnd, MainGui, PathLocationInMainGui
	PathLocationInMainGui := Directory
	FileList := GetSubDirList(Directory)
	Config["AddressList"] := LoadAddressList(FileList)
	MainGui["FilterBox"].value := ""
	UpdateAddressList()
	MainGui["FilterBox"].Focus()
	}


GetSubDirList(Directory) {
	If (InStr(Directory, "/"))
		Directory := RegExReplace(Directory, "/", "\")
	FileList := ""
	Loop Files, Directory "\*.*" , "FD"
		{
		FileList := FileList . "`n" . A_LoopFilePath
		}
	return FileList
	}


GetOpenExplorerWindows()  {
	ExplorerWindows := ""
    for window in ComObject("Shell.Application").Windows
    	{
        if (InStr(window.FullName, "explorer.exe"))  {
			shellFolderView := window.Document
            ExplorerPath := shellFolderView.Folder.Self.Path

			; exclude "Start", "Catalog", "Trash", "Home" and "Network"
			If (ExplorerPath = "::{F874310E-B6B7-47DC-BC84-B9E6B38F5903}" || ExplorerPath = "::{E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}" || ExplorerPath = "::{645FF040-5081-101B-9F08-00AA002F954E}" || ExplorerPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" || ExplorerPath = "::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}")
					continue

			ExplorerPath := RegExReplace(ExplorerPath, "^file:///", "")
            ExplorerPath := StrReplace(ExplorerPath, "/", "\")
            ExplorerPath := RegExReplace(ExplorerPath, "%20", " ")

			ExplorerWindows .= ExplorerPath "`n"
        	}
		}
		ExplorerWindows := RemoveDuplicateLines(ExplorerWindows)
	if (ExplorerWindows == "")
		return "ERROR"
	else
		return ExplorerWindows
	}


GetOpenExplorerWindows2()  {   ; Neglects  explorer tabs, use GetOpenExplorerWindows() instead
	WindowList := WinGetList(,,"Program Manager",)
	Loop WindowList.Length {
		hWndCurrentWindow := WindowList[A_Index]
		ExplorerPath := GetCurrentExplorerPath(hWndCurrentWindow)
		if (ExplorerPath != "Error" and ExplorerPath != "desktop" and ExplorerPath)  {
            ExplorerWindows .= ExplorerPath "`n"
		    }
	    }
    return RemoveDuplicateLines(ExplorerWindows)
    }


GetExplorerHwndByPath(FolderPath)  {
    FolderPath := RegExReplace(FolderPath, "[\\/]+$", "") ; Entfernt abschließende Backslashes oder Slashes

    for window in ComObject("Shell.Application").Windows  {
        if (InStr(window.FullName, "explorer.exe"))  {
			shellFolderView := window.Document
            windowPath := shellFolderView.Folder.Self.Path

            windowPath := RegExReplace(windowPath, "^file:///", "")
            windowPath := StrReplace(windowPath, "/", "\")
            windowPath := RegExReplace(windowPath, "%20", " ")

            if (windowPath = FolderPath)  {
                return window.HWND
            	}
        	}
    	}
    return 0 ; No window found
	}


RemoveDuplicateLines(Text) {
    UniqueLinesArray := Map()
	UniqueLines := ""
    Loop Parse, Text, "`n", "`r"
    	{
        if (!UniqueLinesArray.Has(A_LoopField))  {
            UniqueLinesArray.Set(A_LoopField,1)
            UniqueLines .= A_LoopField "`n"
        	}
    	}
    return UniqueLines
	}


GetCurrentExplorerPath(hwnd := WinExist("A")) { 
	; by lexikos - modified (from: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=109907)

 	if !(explorerHwnd := explorerGethWnd(hwnd))
		return ErrorLevel := "ERROR"
	; exclude "Start", "Catalog", "Trash", "Home" and "Network"
	if (explorerHwnd="desktop")
		return A_Desktop

	activeTab := 0
	activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd) ; File Explorer (Windows 11)
	for window in ComObject("Shell.Application").Windows {
		if window.hwnd != hwnd
			continue
		if activeTab { ; The window has tabs, so make sure this is the right one.
			static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
			shellBrowser := ComObjQuery(window, IID_IShellBrowser, IID_IShellBrowser)
			ComCall(3, shellBrowser, "uint*", &thisTab:=0)
			if thisTab != activeTab
				continue
		}
        if (type(window.Document) = "ShellFolderView")  {
			ExplorerPath := window.Document.Folder.Self.Path
			; exclude "Start", "Catalog", "Trash", "Home" and "Network"
			If (ExplorerPath = "::{F874310E-B6B7-47DC-BC84-B9E6B38F5903}" || ExplorerPath = "::{E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}" || ExplorerPath = "::{645FF040-5081-101B-9F08-00AA002F954E}" || ExplorerPath = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" || ExplorerPath = "::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}")
				return ErrorLevel := "ERROR"
			else
				return ExplorerPath
			} 
        else
            return "ERROR"
		}
	Return "ERROR"
	}


JumpToExplorerTab(PathExistingExplorerTab, hWndParentExplorerWindow:=WinActive("A")) {
	; Dependency: UIA.ahk -> Download at https://github.com/Descolada/UIA-v2/tree/main/Lib
    If(!(hWndParentExplorerWindow := GetExplorerHwndByPath(PathExistingExplorerTab)))
        return

    Windows := ComObject("Shell.Application").Windows
    Found := 0

    for Window in Windows {
        Path := Window.Document.Folder.Self.Path
        if (PathExistingExplorerTab = Path) {
            WindowClassNN := ""
            for Control in WinGetControls("ahk_id " hWndParentExplorerWindow)  {
                ; get Tab-Pane for explorer windows
                If (InStr(Control, "Microsoft.UI.Content.DesktopChildSiteBridge") && (hWndParentExplorerWindow == Window.hWnd))  {
                    WindowClassNN := Control
                    }
                }      
            
            try 
                ctrl := ControlGetHwnd(WindowClassNN, "ahk_id " Window.hwnd)
            catch
                continue

            SplitPath(PathExistingExplorerTab, &FolderName)
            TabName := Window.Document.Folder.Title
            TabPane := UIA.ElementFromHandle(ctrl)
            Tab := TabPane.FindElement({Type:"TabItem", Name:TabName})  ;
            WinActivate(Window)
            Tab.Click()
            return
            }
        else
            continue
        }
    return
    }


JumpToExplorerTab2(parentHwnd:=WinActive("A"), ExplorerPath := "")  {
	TabExplorerPath := GetCurrentExplorerPath(parentHwnd)
	If (ExplorerPath = "" || TabExplorerPath == ExplorerPath)  ; no path or serached path is active tab
		return 

	ExplorerTabList := GetExplorerTabList(parentHwnd)
	WinActivate("ahk_id" parentHwnd)
	ControlFocus("Microsoft.UI.Content.DesktopChildSiteBridge1",  "ahk_id" parentHwnd)  ; ShellTabWindowClass1 indicate that windows has tabs
	Sleep(50)
    Loop ExplorerTabList.Length {
        Send("{Ctrl down}" A_Index "{Ctrl up}")
        Sleep(25)
        TabExplorerPath := GetCurrentExplorerPath(parentHwnd)
        If (TabExplorerPath == ExplorerPath)
            break
        }
    }


OpenNewExplorerTab(ExplorerHwnd:=WinActive("A"))  {
    SendMessage(0x0111, 0xA21B, 0, "ShellTabWindowClass1", ExplorerHwnd)
    return ExplorerHwnd
    }


OpenPathInNewExplorerTab(Path, ExplorerHwnd:=WinActive("A"))  {
    ; by ntepa - from https://www.autohotkey.com/boards/viewtopic.php?p=586602&sid=c080c461dd2bb15cb1e933d9a5628414#p586602

    If !(WinGetClass(ExplorerHwnd) == "CabinetWClass")
        ExplorerHwnd := WinExist("ahk_class CabinetWClass",,, "Address: Control Panel")

    if !ExplorerHwnd {
        OpenPathInNewExplorerWindows(path)
        ExitApp
        }

    Windows := ComObject("Shell.Application").Windows
    Count := Windows.Count() ; Count of open windows

    if WinGetMinMax(ExplorerHwnd) = -1
        WinRestore(ExplorerHwnd)
    ; open a new tab (https://stackoverflow.com/a/78502949)
    SendMessage(0x0111, 0xA21B, 0, "ShellTabWindowClass1", ExplorerHwnd)

    timeout := A_TickCount + 5000
    ; Wait for new tab.
    while Windows.Count() = Count {
        sleep 10
        ; If unable to create new tab in 5 seconds, create new window.
        if A_TickCount > timeout {
            OpenPathInNewExplorerWindows(path)
            ExitApp
            }
        }
    Item := Windows.Item(Count)
    try Item.Navigate2(path) ; Navigate to path in new tab
    catch {
        OpenPathInNewExplorerWindows(path)
        ExitApp
        }
    }
    

OpenPathInNewExplorerWindows(Path)  {
    ; by ntepa - from https://www.autohotkey.com/boards/viewtopic.php?p=586602&sid=c080c461dd2bb15cb1e933d9a5628414#p586602
    Run("Explorer " path)
    WinWaitActive("ahk_class CabinetWClass")
    SendEvent "{Space}" ; Select first item
    }
    
GetExplorerTabList(parentHwnd:=WinActive("A")) {
    WindowList := WinGetControlsHwnd("ahk_id " parentHwnd)
    ExplorerTabList := []
    Loop WindowList.Length  {
        ClassName := WinGetClass("ahk_id " WindowList[A_Index])
        If (InStr(ClassName, "ShellTabWindowClass"))  {
            ExplorerTabList.Push(WindowList[A_Index])
            }
        }
    return ExplorerTabList
    }

	
explorerGethWnd(hwnd:=WinExist("A"))  {
	; by WKen - modified (from: https://www.autohotkey.com/boards/viewtopic.php?t=114431)
	If (!hWnd)
		return false
	processName := WinGetProcessName("ahk_id " hwnd)
	class := WinGetClass("ahk_id " hwnd)
	if (processName!="explorer.exe")
		return false
	if (class ~= "(Cabinet|Explore)WClass")  {
		for window in ComObject("Shell.Application").Windows
			try if (window.hwnd==hwnd)
				return hwnd
		}
	else if (class ~= "Progman|WorkerW") 
		return "desktop" ; desktop found
	}


LoadConfig(Path, Default)  {
	Config := Map()

	Try Config["ShowKey"] := IniRead(Path, "Settings", "ShowKey")
	Catch
		IniWrite(Default["ShowKey"], Path, "Settings", "ShowKey"),
		Config["ShowKey"] := Default["ShowKey"]

	Try Config["WindowSize"] := IniRead(Path, "Settings", "WindowSize")
	Catch
		IniWrite(Default["WindowSize"], Path, "Settings", "WindowSize"),
		Config["WindowSize"] := Default["WindowSize"]

	Try Config["RocketMode"] := IniRead(Path, "Settings", "RocketMode")
	Catch
		IniWrite(Default["RocketMode"], Path, "Settings", "RocketMode"),
		Config["RocketMode"] := Default["RocketMode"]

	Try Config["DefaultAddressList"] := IniRead(Path, "AddressList")
	Catch
		IniWrite(Default["AddressList"], Path, "AddressList"),
		Config["DefaultAddressList"] := Default["AddressList"]
	Try Config["UrlDirectory"] := IniRead(Path, "Settings", "UrlDirectory")
	Catch
		IniWrite(Default["UrlDirectory"], Path, "Settings", "UrlDirectory"),
		Config["UrlDirectory"] := Default["UrlDirectory"]

	; Post-processing
	Config["AddressList"] := LoadAddressList(Config["DefaultAddressList"])
	Return Config
	}


LoadAddressList(AddressListStr)  {
	AddressList := []
	Loop Parse, AddressListStr, "`n"
		If (Address:=Trim(A_LoopField)) != ""
			{
			for each, format in ["d", "dd", "ddd", "dddd", "M", "MM", "MMM", "MMMM", "y", "yy", "yyyy", "h", "hh", "H", "HH", "m", "mm", "s", "ss"]
				Address := RegExReplace(Address, "%" format "%", FormatTime(, format))
			AddressList.Push(Address)
			}
	Return AddressList
	}


Settings(*)  {
	Global Config
	ToggleHotkeys("Off")
	SettingsGui := Gui(, "Settings")
	SettingsGui.SetFont("s10", "Segoe UI")
	SettingsGui.AddGroupBox("xm w300 h100 section", "Hotkeys")
	SettingsGui.AddButton("xm y+10 w300", "Save").OnEvent("Click", Save)
	SettingsGui.SetFont("s9", "Segoe UI")
	SettingsGui.AddText("xs+10 ys+45 section", "Show/Hide Window: ")
	SettingsGui.AddHotkey("x+10 vShowKey", Config["ShowKey"])
	SettingsGui.OnEvent("Close", (GuiObj, *) => ( ToggleHotkeys("On"), GuiObj.Destroy() ))
	SettingsGui.Show()

	Save(*) {
		Submission := SettingsGui.Submit()
		Config["ShowKey"] := Submission.ShowKey != "" ? Submission.ShowKey : DefaultConfig["ShowKey"]
		IniWrite(Config["ShowKey"], CONFIG_FILEPATH, "Settings", "ShowKey")
		ToggleHotkeys("On")
		}
	}


UpdateAddressList(Query:="", RedrawAfter:=true, AddressList:="")  {
	Global PreparedAddressList
	Static ImageListID
	PreparedAddressList := []
	If AddressList = ""
		AddressList := Config["AddressList"]
	If Query = "" {
		For Address in AddressList {
			FilePath := ExpandEnvironmentStrings(Address)
			SplitPath FilePath, &FileName
			PreparedAddressList.Push(FilePath)
		}
	} Else {
		; translate wildcards in Regex: * → .*, ? → ., # → \d
		; allow . _ , - (won't be escaped)
		EscapedQuery := ""
		Loop Parse Query {
			char := A_LoopField
			Switch char {
				Case "*": EscapedQuery .= ".*"
				Case "?": EscapedQuery .= "."
				Case "#": EscapedQuery .= "\d"
				Case ".", "_", ",", "-": EscapedQuery .= char ; direkt übernehmen
				Default: EscapedQuery .= RegExReplace(char, "([^\w])", "\\$1")
			}
		}
	
		; make regex case-insensitive
		Pattern := "i)" . EscapedQuery
	
		PrimaryI := 1
		For Address in AddressList {
			FilePath := ExpandEnvironmentStrings(Address)
			SplitPath FilePath, &FileName
	
			; Primary: match filename
			If RegExMatch(FileName, Pattern)
				PreparedAddressList.InsertAt(PrimaryI++, FilePath)
			; Secondary: match path
			Else If RegExMatch(FilePath, Pattern)
				PreparedAddressList.Push(FilePath)
		}
	}
	
	LV := MainGui["AddressList"]
	LV.Opt("-Redraw")
	LV.Delete()
	; Calculate buffer size required for SHFILEINFO structure.
    sfi_size := A_PtrSize + 688
    sfi := Buffer(sfi_size)

	If !IsSet(ImageListID) && PreparedAddressList.Length {
		ImageListID := IL_Create(PreparedAddressList.Length)
		LV.SetImageList(ImageListID)
		}
	For FilePath in PreparedAddressList {
		SplitPath FilePath, &FileName,, &FileExt
		; Get the high-quality small-icon associated with this file extension:
		If not DllCall("Shell32\SHGetFileInfoW", "Str", FilePath
			, "Uint", DllCall("kernel32.dll\GetFileAttributes", "Str", FilePath)
			, "Ptr", sfi, "UInt", sfi_size, "UInt", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
		IconNumber := 9999999  ; Set it out of bounds to display a blank icon.
		Else  {   ; Icon successfully loaded.
			; Extract the hIcon member from the structure:
			hIcon := NumGet(sfi, 0, "Ptr")
			; Add the HICON directly to the small-icon and large-icon lists.
			; Below uses +1 to convert the returned index from zero-based to one-based:
			IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID, "Int", -1, "Ptr", hIcon) + 1
			;DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID2, "Int", -1, "Ptr", hIcon)
			; Now that it's been copied into the ImageLists, the original should be destroyed:
			DllCall("DestroyIcon", "Ptr", hIcon)
			}
        LV.Add("Icon" . IconNumber, FileName, FilePath)
		}
	If RedrawAfter
		LV.Opt("+Redraw")
	MainGui["AddressList"].Modify(1, "Select")  
	If ((MainGui["AddressList"].GetCount() == 1) && Config["RocketMode"])
		OpenSelected()
	}


LV_GetVScrollWidth(LV) {
	Static SM_CXVSCROLL := SysGet(2)
	If DllCall("GetWindowLong", "Ptr", LV.Hwnd, "Int", -16) & 0x200000 ;WS_VSCROLL
		Return SM_CXVSCROLL
	Return 0
	}


MoveLine(editCtrl, direction)  {  ; Thanks to teadrinker https://www.autohotkey.com/boards/viewtopic.php?p=580004#p579968
    static EM_GETCARETINDEX := 0x1512, EM_LINEFROMCHAR := 0x00C9, EM_LINEINDEX := 0x00BB, EM_GETLINE := 0x00C4
         , EM_LINELENGTH := 0x00C1, EM_GETLINECOUNT := 0x00BA, EM_SETSEL := 0x00B1, EM_REPLACESEL := 0x00C2

    WinExist(editCtrl)
    caretPos := SendMessage(EM_GETCARETINDEX)
    currentLineIdx := SendMessage(EM_LINEFROMCHAR, caretPos)
    swapLineIdx := currentLineIdx + (direction ? 1 : -1)
    if swapLineIdx < 0 || swapLineIdx = SendMessage(EM_GETLINECOUNT) {
        return
    	}
    currentLinePos := SendMessage(EM_LINEINDEX, currentLineIdx)
    swapLinePos := SendMessage(EM_LINEINDEX, swapLineIdx)
    currentLineText := GetLineText(currentLineIdx, currentLinePos, &currentLineLen)
    swapLineText := GetLineText(swapLineIdx, swapLinePos, &swapLineLen)

    line1 := direction ? 'swapLine' : 'currentLine'
    line2 := direction ? 'currentLine' : 'swapLine'
    text := %line1%Text . '`r`n' . %line2%Text
    StrPut(text, buf := Buffer(StrPut(text), 0))
    SendMessage(EM_SETSEL, %line2%Pos, %line1%Pos + %line1%Len)
    SendMessage(EM_REPLACESEL, true, buf)
    newCaretPos := SendMessage(EM_LINEINDEX, swapLineIdx) + caretPos - currentLinePos
    SendMessage(EM_SETSEL, newCaretPos, newCaretPos)

    static GetLineText(lineIdx, startPos, &len) {
        len := SendMessage(EM_LINELENGTH, startPos)
        NumPut('UShort', len, buf := Buffer(len * 2 + 2, 0))
        (len > 0 && SendMessage(EM_GETLINE, lineIdx, buf))
        return StrGet(buf)
    	}
	}


ExpandEnvironmentStrings(Str) {
	Local Chars := 0
	Local Expanded := ""
	If (Chars := DllCall("ExpandEnvironmentStringsW", "Str", Str, "Ptr", 0, "UInt", 0, "Int")) {
		VarSetStrCapacity(&Expanded, ++Chars)
		DllCall("ExpandEnvironmentStringsW", "Str", Str, "Str", &Expanded, "UInt", Chars, "Int")
		}
	Return (Chars ? Expanded : Str)
	}


ArrayJoin(ArrayObj, Delim:=",") {
	Str := ""
    For Index, Value in ArrayObj
        Str .= Delim . Value
    Return SubStr(Str, StrLen(Delim)+1)
	}


GetWinOSVersion() {
	; from: novelprocedure; Forum: https://www.autohotkey.com/boards/viewtopic.php?t=123735#p591361
    ; Does not account for WinOS versions earlier than XP or later than Windows 11

    i := StrReplace(A_OSVersion, ".", "")

    if (i >= 10022000) ; You're running Windows 11
        return 11
    else if (i >= 10010240 AND i < 10022000) ; You're running Windows 10
        return 10
    else if (i >= 639200 AND i < 10010240) ; You're running Windows 8.1
        return 8.1
    else if (i >= 629200 AND i < 639200) ; You're running Windows 8
        return 8
    else if (i >= 617600 AND i < 629200) ; You're running Windows 7
        return 7
    else if (i >= 606000 AND i < 617600) ; You're running Windows Vista
        return "Vista"
    else if (i >= 512600 AND i < 606000) ; You're running Windows XP
        return "XP"
    else
        return "Unknown Windows version"
}

AddFileFolderOrUrl(*)  {
    ActiveWindowExe := WinGetProcessName("A")
	browsers := Map("chrome.exe", "", "firefox.exe", "", "msedge.exe", "", "opera.exe", "", "brave.exe", "")
    if browsers.Has(ActiveWindowExe) {
		CreateWebShortcut(Config["UrlDirectory"])
    } else if (ActiveWindowExe = "explorer.exe") {
        AddFileFolderToAdressList(ExplorerGetSelection())
    } else {
        Send("$+#" . Config["ShowKey"])
    }
}

AddFileFolderToAdressList(NewFilesAndFolderList)  {
	Static Section := "AddressList"
;	Config["DefaultAddressList"] := Trim(Config["DefaultAddressList"],  "`r`n") . "`n" . Trim(NewFilesAndFolderList,  "`r`n")
	Config["DefaultAddressList"] := MergeItemLists(Trim(Config["DefaultAddressList"]), Trim(NewFilesAndFolderList)) 
	Config["AddressList"] := LoadAddressList(Config["DefaultAddressList"])
	IniDelete(CONFIG_FILEPATH, Section),
	IniWrite(Config["DefaultAddressList"], CONFIG_FILEPATH, Section)
	UpdateAddressList()
	}

CreateWebShortcut(TargetFolder, *) {
	; global BackupClip
    if !DirExist(TargetFolder)
        DirCreate(TargetFolder)

    winTitle := WinGetTitle("A")

	; copy URL 
	Send("^l")
    Sleep(100)
	URL := CopyAndRestoreClipboard()

	; Check for valid URL
    if !RegExMatch(URL, "^https?://") {
        MsgBox "No valid URL."
        return
    	}

    ; suggest title
    DefaultName := RegExReplace(RegExReplace(WinTitle, " - .*", ""), "[\\/:*?`"`&lt;>|]", "")
    Name := DefaultName

    ; check if filename is unique
    while true {
        input := InputBox("Please enter a name for the bookmark:", "Enter a name for the bookmark", "h66" , name)
        if input.Result != "OK" {
            return
        	}
        Name := Trim(RegExReplace(Trim(input.Value), "[\\/:*?`"`&lt;>|]", ""))
        ShortcutPath := TargetFolder "\" Name ".url"

        if !FileExist(ShortcutPath)
            break 

        MsgBox "This Name ist used already.`nPlease rename your bookmark."
    	}

    ; save URL
    try {
        FileAppend("[InternetShortcut]`nURL=" URL "`n", ShortcutPath)
        MsgBox "Bookmark saved in :`n`n" ShortcutPath "`n`nsuccessfully."
    } catch {
        MsgBox "Error occured while saving bookmark."
    	}
	}

ExplorerGetSelection() {
; credits teatrinker
; from https://www.autohotkey.com/boards/viewtopic.php?t=60403#p255169
    result := ""
    hWnd := WinExist("A")
    winClass := WinGetClass("ahk_id " hWnd)

    if !(winClass ~= "^(Progman|WorkerW|(Cabinet|Explore)WClass)$")
        return

    shellWindows := ComObject("Shell.Application").Windows

    if (winClass ~= "Progman|WorkerW") {
        shellFolderView := shellWindows.Item(ComValue(0x13, 0x8)).Document
    } else {
        for window in shellWindows {
            if (window.HWND = hWnd) {
                shellFolderView := window.Document
                break
            }
        }
    }

    if !IsSet(shellFolderView)
        return

    for item in shellFolderView.SelectedItems
        result .= (result = "" ? "" : "`n") item.Path

    return result
	}



CopyAndRestoreClipboard(WaitTime := 1)  {
    copy := ""
	BackupClip := ClipboardAll()
	Clipboard := ""
	ClipWait(0.5, 1)
	Send("^c")
	
    if (ClipWait(WaitTime))
		Copy := A_Clipboard
	if (Copy == "")
		return

	A_Clipboard := BackupClip
	ClipWait(1, 1)
	return Copy
	}



MergeItemLists(existingItemList, newItemList)  {
    existingList := StrSplit(existingItemList, "`n")
    newList := StrSplit(newItemList, "`n")

    for newItem in newList {
        newItem := Trim(newItem)
        found := false
        for existingItem in existingList {
            if (Trim(existingItem) = newItem) {
                found := true
                break
            	}
        	}
        if !found && newItem != "" {
            existingList.Push(newItem)
        	}
    	}

    result := ""
    for i, Item in existingList {
        result .= (i > 1 ? "`n" : "") . Item
    	}
    return result
	}