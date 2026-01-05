@echo off
nssm stop AhkRunCmdService
ipconfig/all >nul
nssm remove AhkRunCmdService
pause