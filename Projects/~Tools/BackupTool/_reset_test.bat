@echo off

set "SOURCE=D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\BackupWorker.ahk"
set "TARGET=C:\ProgramData\AutoHotkey\AdminLauncher\BackupWorker.ahk"
copy /y "%SOURCE%" "%TARGET%"

REM set "SOURCE=D:\Software\DEV\Work\AHK2\Projects\~Tools\BackupTool\BackupWorker.ahk "
REM set "TARGET=C:\ProgramData\AutoHotkey\BackupTool\BackupWorker.ahk"
REM copy /y "%SOURCE%" "%TARGET%"

rmdir /S /Q D:\Docs_Backup
del /f /q *.log
del /f /q D:\*.log

pause