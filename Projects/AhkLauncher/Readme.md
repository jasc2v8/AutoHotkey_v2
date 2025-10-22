
# AutoHotkey Launcher Help

## Objectives:

1. **Avoid false positives from antivirus software.** 

	a. When a .ahk file is compiled and installed, it will usually create a false positive A/V warning.
	
	b. This will launch the script as an .ahk file and usually avoid A/V warnings.
	
	c. The AhkLauncher_Setup.ahk will probably result in a false positive A/V warning the first time it is used.
	
2. **Keep all my AHK scripts organized for easy launch.** 

3. **Launch any file that has an associated extension to open/execute.**

4. **Incorporate most used Hotkeys and Scripts for easy access**

## Features:
- Starts at User Login and remains in the system tray.
- Ctrl+Alt+LeftButton or Ctrl+Alt+L will open the Launcher.
- Hotkeys for Launching specified AutoHotkey scripts.
- Hotkey to send Username and Password to active window.
- Username/Password are encrypted and stored by Windows Credential Manager.
- List of Windows Environment / shell / CLSID Variables. Click to open.
- List of files in the AhkApp Directory. Click to open.
- File types can be any launchable app (.ahk, .exe, .txt, .lnk, etc.).

# Installation Folders:

1. Files are installed to A_MyDocuments "\AhkLauncher"

2. The folder structure is:

		A_MyDocuments "\AhkLauncher\"
			\AhkApps
				- *.ahk
				- *.exe
				- *.lnk
			AhkLauncher.ahk
			AhkLauncher.ini
			AhkLauncher_Setup.ahk
			
# Prerequistes:

1. Search for Default Apps, file type .ahk
2. Set default as AutoHotkey 64-bit (or your preference).
3. This will enable .ahk scripts to run when double-clicked.

# Instructions:

1. Extrack AhkLauncher_SetupFiles.zip to: .\AhkLauncher_SetupFiles
2. Double-Click AhkLauncher_Setup to begin the installation process.
3. AhkLauncher_Setup expects all setup files to be in the same folder.

# Press [Install] to:

1. Copy all setup files to: %USERPROFILE%\Documents\AutoHotkey\AhkLauncer
2. Create Startup Shortcut: %APPDATA%'\Microsoft\Windows\Start Menu\Programs\Startup\AhkLauncher.lnk'
3. Create Start Menu Shortcut: %APPDATA%'\Microsoft\Windows\Start Menu\Programs\AhkLauncher.lnk'
4. Ask the user to "Launch Now?"

# Press [Uninstall] to:

1. Remove all shortcuts.
2. Remove all files.
2. Nothing was created in the Windows Registry, no cleanup required.

# Usage:

1. Reboot to verify AhkLauncher starts and resided in the system tray.
2. Right-click to try icon to see menu options: Open, Help, Credentials, Exit
3. Start AhkLauncher with Ctrl+Alt+LButton or Ctrl+Alt+L
4. Press the [Change] button repeatedly to see the available launch lists\
5. Click on a file to launch it.
6. Click the [Explore] button to open the file location.



