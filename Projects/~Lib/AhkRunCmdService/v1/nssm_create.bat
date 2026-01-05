@echo off
nssm install AhkRunCmdService "D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\AhkRunCmdService.exe"
nssm set AhkRunCmdService Objectname .\Jim Pmi$10707
nssm start AhkRunCmdService